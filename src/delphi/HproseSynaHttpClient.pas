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
 * HproseSynaHttpClient.pas                               *
 *                                                        *
 * hprose synapse http client unit for delphi.            *
 *                                                        *
 * LastModified: Dec 29, 2012                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
}
unit HproseSynaHttpClient;

{$I Hprose.inc}

interface

uses Classes, HproseCommon, HproseClient;

type

  { THproseSynaHttpClient }

  THproseSynaHttpClient = class(THproseClient)
  private
    FHttpPool: IList;
    FProtocol: string;
    FUser: string;
    FPassword: string;
    FHost: string;
    FPort: string;
    FPath: string;
    FPara: string;
    FHeaders: TStringList;
    FKeepAlive: Boolean;
    FKeepAliveTimeout: integer;
    FStatus100: Boolean;
    FProxyHost: string;
    FProxyPort: Integer;
    FProxyUser: string;
    FProxyPass: string;
    FUserAgent: string;
    FTimeout: Integer;
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

    {:If @true (default value is @false), keepalives in HTTP protocol 1.1 is enabled.}
    property KeepAlive: Boolean read FKeepAlive write FKeepAlive;

    {:Define timeout for keepalives in seconds! Default value is 300.}
    property KeepAliveTimeout: integer read FKeepAliveTimeout write FKeepAliveTimeout;

    {:if @true, then server is requested for 100status capability when uploading
     data. Default is @true (on).}
    property Status100: Boolean read FStatus100 write FStatus100;

    {:Address of proxy server (IP address or domain name).}
    property ProxyHost: string read FProxyHost write FProxyHost;

    {:Port number for proxy connection. Default value is 8080.}
    property ProxyPort: Integer read FProxyPort write FProxyPort;

    {:Username for connect to proxy server.}
    property ProxyUser: string read FProxyUser write FProxyUser;

    {:Password for connect to proxy server.}
    property ProxyPass: string read FProxyPass write FProxyPass;

    {:Here you can specify custom User-Agent indentification. By default is
     used: 'Hprose Http Client for Delphi (Synapse)'}
    property UserAgent: string read FUserAgent write FUserAgent;

    {:UserName for user authorization.}
    property UserName: string read FUser write FUser;

    {:Password for user authorization.}
    property Password: string read FPassword write FPassword;

    {:Specify default timeout for socket operations.}
    property Timeout: Integer read FTimeout write FTimeout;
  end;

procedure Register;

implementation

uses httpsend, synautil, SysUtils, Variants;

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
        Cookie['expires'] := DecodeRfcDateTime(Cookie['expires']);
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

{ THproseSynaHttpClient }

function THproseSynaHttpClient.GetInvokeContext: TObject;
begin
  FHttpPool.Lock;
  try
    if FHttpPool.Count > 0 then
      Result := VarToObj(FHttpPool.Delete(FHttpPool.Count - 1))
    else
      Result := THttpSend.Create;
  finally
    FHttpPool.Unlock;
  end;
end;

function THproseSynaHttpClient.GetOutputStream(var Context: TObject): TStream;
begin
  if Context <> nil then
    Result := THTTPSend(Context).Document
  else
    raise EHproseException.Create('Can''t get output stream.');
end;

procedure THproseSynaHttpClient.SendData(var Context: TObject);
var
  Cookie: string;
begin
  if Context <> nil then
    with THTTPSend(Context) do begin
      Headers.Assign(FHeaders);
      KeepAlive := FKeepAlive;
      KeepAliveTimeout := FKeepAliveTimeout;
      Status100 := FStatus100;
      UserName := FUser;
      Password := FPassword;
      ProxyHost := FProxyHost;
      if FProxyPort = 0 then
        ProxyPort := ''
      else
        ProxyPort := IntToStr(FProxyPort);
      ProxyUser := FProxyUser;
      ProxyPass := FProxyPass;
      UserAgent := FUserAgent;
      Timeout := FTimeout;
      Protocol := '1.1';
      MimeType := 'application/hprose';
      Cookie := GetCookie(FHost,
                          FPath,
                          LowerCase(FProtocol) = 'https');
      if Cookie <> '' then Headers.Add('Cookie: ' + Cookie);
      HTTPMethod('POST', FUri);
      SetCookie(Headers, FHost);
    end
  else
    raise EHproseException.Create('Can''t send data.');
end;

function THproseSynaHttpClient.GetInputStream(var Context: TObject): TStream;
begin
  if Context <> nil then
    Result := THTTPSend(Context).Document
  else
    raise EHproseException.Create('Can''t get input stream.');
end;

procedure THproseSynaHttpClient.EndInvoke(var Context: TObject);
begin
  if Context <> nil then begin
    FHttpPool.Lock;
    try
      with THTTPSend(Context) do begin
        Clear;
        Cookies.Clear;
      end;
      FHttpPool.Add(ObjToVar(Context));
    finally
      FHttpPool.Unlock;
    end;
  end;
end;

constructor THproseSynaHttpClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHttpPool := TArrayList.Create(10);
  FHeaders := TStringList.Create;
  FUser := '';
  FPassword := '';
  FKeepAlive := False;
  FKeepAliveTimeout := 300;
  FStatus100 := False;
  FProxyHost := '';
  FProxyPort := 8080;
  FProxyUser := '';
  FProxyPass := '';
  FUserAgent := 'Hprose Http Client for Delphi (Synapse)';
  FTimeout := 30000;
end;

destructor THproseSynaHttpClient.Destroy;
var
  I: Integer;
begin
  FHttpPool.Lock;
  try
    for I := FHttpPool.Count - 1 downto 0 do
      THTTPSend(VarToObj(FHttpPool.Delete(I))).Free;
  finally
    FHttpPool.Unlock;
  end;
  FreeAndNil(FHeaders);
  inherited;
end;

procedure THproseSynaHttpClient.UseService(const AUri: string);
begin
  inherited UseService(AUri);
  ParseURL(FUri, FProtocol, FUser, FPassword, FHost, FPort, FPath, FPara);
end;

procedure Register;
begin
  RegisterComponents('Hprose',[THproseSynaHttpClient]);
end;

initialization
  CookieManager := TCaseInsensitiveHashMap.Create(False, True);

end.
