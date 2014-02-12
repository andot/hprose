{
/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/

/**********************************************************\
 *                                                        *
 * HproseIdHttpClient.pas                                 *
 *                                                        *
 * hprose indy http client unit for delphi.               *
 *                                                        *
 * LastModified: Jun 5, 2010                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
}
unit HproseIdHttpClient;

{$I Hprose.inc}

interface

uses Classes, HproseCommon, HproseClient, IdURI;

type

  THproseIdHttpClient = class(THproseClient)
  private
    FHttpPool: IList;
    FIdUri: TIdURI;
    FHeaders: TStringList;
    FProxyHost: string;
    FProxyPort: Integer;
    FProxyUser: string;
    FProxyPass: string;
    FUserAgent: string;
  protected
    function GetInvokeContext: TObject; override;
    function GetOutputStream(var Context: TObject): TStream; override;
    procedure SendData(var Context: TObject); override;
    function GetInputStream(var Context: TObject): TStream; override;
    procedure EndInvoke(var Context: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UseService(const AUri: string); override;
  published
    {:Before HTTP operation you may define any non-standard headers for HTTP
     request, except of: 'Expect: 100-continue', 'Content-Length', 'Content-Type',
     'Connection', 'Authorization', 'Proxy-Authorization' and 'Host' headers.}
    property Headers: TStringList read FHeaders;

    {:Address of proxy server (IP address or domain name).}
    property ProxyHost: string read FProxyHost Write FProxyHost;

    {:Port number for proxy connection. Default value is 8080.}
    property ProxyPort: Integer read FProxyPort Write FProxyPort;

    {:Username for connect to proxy server.}
    property ProxyUser: string read FProxyUser Write FProxyUser;

    {:Password for connect to proxy server.}
    property ProxyPass: string read FProxyPass Write FProxyPass;

    {:Here you can specify custom User-Agent indentification. By default is
     used: 'Hprose Http Client for Delphi (Indy8)'}
    property UserAgent: string read FUserAgent Write FUserAgent;
  end;

procedure Register;

implementation

uses IdGlobal, IdHeaderList, IdHttp, SysUtils, Variants;

type

  THproseIdHttpInvokeContext = class
    IdHttp: TIdHttp;
    OutStream: TStream;
    InStream: TStream;
  end;

var
  cookieManager: IMap;

procedure SetCookie(Header: TStringList; const Host: string);
var
  I, Pos: Integer;
  Name, Value, CookieString, Path: string;
  Cookie: IMap;
begin
  for I := 0 to Header.Count - 1 do begin
    Value := Header.Strings[I];
    Pos := AnsiPos(':', Value);
    Name := LowerCase(Copy(Value, 1, Pos - 1));
    if (Name = 'set-cookie') or (Name = 'set-cookie2') then begin
      Value := Trim(Copy(Value, Pos + 1, MaxInt));
      Pos := AnsiPos(';', Value);
      CookieString := Copy(Value, 1, Pos - 1);
      Value := Copy(Value, Pos + 1, MaxInt);
      Cookie := TCaseInsensitiveHashMap.Split(Value, ';', '=', 0, True, False, True);
      Pos := AnsiPos('=', CookieString);
      Cookie['name'] := Copy(CookieString, 1, Pos - 1);
      Cookie['value'] := Copy(CookieString, Pos + 1, MaxInt);
      if Cookie.ContainsKey('path') then begin
        Path := Cookie['path'];
        if (Length(Path) > 0) then begin
          if (Path[1] = '"') then Delete(Path, 1, 1);
          if (Path[Length(Path)] = '"') then SetLength(Path, Length(Path) - 1);
        end;
        if (Length(Path) > 0) then
          Cookie['path'] := Path
        else
          Cookie['path'] := '/';
      end
      else
        Cookie['path'] := '/';
      if Cookie.ContainsKey('expires') then begin
        // GMTToLocalDateTime of Indy 8 can't parse cookie expires directly.
        // Use StringReplace to fix this bug.
        Value := StringReplace(Cookie['expires'], '-', ' ', [rfReplaceAll]);
        Cookie['expires'] := GMTToLocalDateTime(Value);
      end;
      if Cookie.ContainsKey('domain') then
        Cookie['domain'] := LowerCase(Cookie['domain'])
      else
        Cookie['domain'] := Host;
      Cookie['secure'] := Cookie.ContainsKey('secure');
      CookieManager.BeginWrite;
      try
        if not CookieManager.ContainsKey(Cookie['domain']) then
          CookieManager[Cookie['domain']] := THashMap.Create(False, True) as IMap;
        VarToMap(CookieManager[Cookie['domain']])[Cookie['name']] := Cookie;
      finally
        CookieManager.EndWrite;
      end;
    end;
  end;
end;

function GetCookie(const Host, Path: string; Secure: Boolean): string;
var
  Cookies, CookieMap, Cookie: IMap;
  Names: IList;
  Domain: string;
  I, J: Integer;
begin
  Cookies := THashMap.Create(False);
  CookieManager.BeginRead;
  try
    for I := 0 to CookieManager.Count - 1 do begin
      Domain := VarToStr(CookieManager.Keys[I]);
      if AnsiPos(Domain, Host) <> 0 then begin
        CookieMap := VarToMap(CookieManager.Values[I]);
		CookieMap.BeginRead;
		try
          Names := TArrayList.Create(False);
          for J := 0 to CookieMap.Count - 1 do begin
            Cookie := VarToMap(CookieMap.Values[J]);
            if Cookie.ContainsKey('expires') and (Cookie['expires'] < Now) then
              Names.Add(Cookie['name'])
            else if AnsiPos(Cookie['path'], Path) = 1 then begin
              if ((Secure and Cookie['secure']) or not Cookie['secure']) and
                  (Cookie['value'] <> '') then
                Cookies[Cookie['name']] := Cookie['value'];
            end;
          end;
		finally
		  CookieMap.EndRead;
		end;
		if Names.Count > 0 then begin
	      CookieMap.BeginWrite;
		  try
		    for J := 0 to Names.Count - 1 do CookieMap.Delete(Names[J]);
		  finally
		    CookieMap.EndWrite;
		  end;
		end;
      end;
    end;
    Result := Cookies.Join('; ');
  finally
    CookieManager.EndRead;
  end;
end;

{ THproseIdHttpClient }

constructor THproseIdHttpClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHttpPool := TArrayList.Create(10);
  FIdUri := nil;
  FHeaders := TIdHeaderList.Create;
  FProxyHost := '';
  FProxyPort := 8080;
  FProxyUser := '';
  FProxyPass := '';
  FUserAgent := 'Hprose Http Client for Delphi (Indy8)';
end;

destructor THproseIdHttpClient.Destroy;
var
  I: Integer;
begin
  FHttpPool.Lock;
  try
    for I := FHttpPool.Count - 1 downto 0 do
      TIdHttp(VarToObj(FHttpPool.Delete(I))).Free;
  finally
    FHttpPool.Unlock;
  end;
  FreeAndNil(FHeaders);
  FreeAndNil(FIdUri);
  inherited;
end;

procedure THproseIdHttpClient.UseService(const AUri: string);
begin
  inherited UseService(AUri);
  FreeAndNil(FIdUri);
  FIdUri := TIdURI.Create(FUri);
end;

procedure THproseIdHttpClient.EndInvoke(var Context: TObject);
begin
  if Context <> nil then
    with THproseIdHttpInvokeContext(Context) do begin
      IdHttp.Request.Clear;
      IdHttp.Response.Clear;
      FHttpPool.Lock;
      try
        FHttpPool.Add(ObjToVar(IdHttp));
      finally
        FHttpPool.Unlock;
      end;
      FreeAndNil(OutStream);
      FreeAndNil(InStream);
      FreeAndNil(Context);
    end;
end;

function THproseIdHttpClient.GetInputStream(var Context: TObject): TStream;
begin
  if Context <> nil then
    Result := THproseIdHttpInvokeContext(Context).InStream
  else
    raise EHproseException.Create('Can''t get input stream.');
end;

function THproseIdHttpClient.GetInvokeContext: TObject;
begin
  Result := THproseIdHttpInvokeContext.Create;
  with THproseIdHttpInvokeContext(Result) do begin
    FHttpPool.Lock;
    try
      if FHttpPool.Count > 0 then
        IdHttp := TIdHttp(VarToObj(FHttpPool.Delete(FHttpPool.Count - 1)))
      else
        IdHttp := TIdHttp.Create(nil);
    finally
      FHttpPool.Unlock;
    end;
    OutStream := TMemoryStream.Create;
    InStream := TMemoryStream.Create;
  end;
end;

function THproseIdHttpClient.GetOutputStream(var Context: TObject): TStream;
begin
  if Context <> nil then
    Result := THproseIdHttpInvokeContext(Context).OutStream
  else
    raise EHproseException.Create('Can''t get output stream.');
end;

procedure THproseIdHttpClient.SendData(var Context: TObject);
var
  Cookie: string;
begin
  if Context <> nil then
    with THproseIdHttpInvokeContext(Context) do begin
      OutStream.Position := 0;
      Cookie := GetCookie(FIdUri.Host,
                          FIdUri.Path,
                          LowerCase(FIdUri.Protocol) = 'https');
      if Cookie <> '' then IdHttp.Request.ExtraHeaders.Add('Cookie: ' + Cookie);
      IdHttp.Request.UserAgent := FUserAgent;
      IdHttp.Request.ProxyServer := FProxyHost;
      IdHttp.Request.ProxyPort := FProxyPort;
      IdHttp.Request.ProxyUsername := FProxyUser;
      IdHttp.Request.ProxyPassword := FProxyPass;
      IdHttp.Request.Connection := 'close';
      IdHttp.Request.ContentType := 'application/hprose';
      IdHttp.ProtocolVersion := pv1_0;
      IdHttp.DoRequest(hmPost, FUri, OutStream, InStream);
      InStream.Position := 0;
      SetCookie(IdHttp.Response.ExtraHeaders, FIdUri.Host);
    end
  else
    raise EHproseException.Create('Can''t send data.');
end;

procedure Register;
begin
  RegisterComponents('Hprose', [THproseIdHttpClient]);
end;

initialization
  CookieManager := TCaseInsensitiveHashMap.Create(False, True);

end.
