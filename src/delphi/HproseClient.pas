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
 * HproseClient.pas                                       *
 *                                                        *
 * hprose client unit for delphi.                         *
 *                                                        *
 * LastModified: Nov 27, 2012                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
}
unit HproseClient;

{$I Hprose.inc}

interface

uses HproseCommon, Classes, SysUtils;

type

  THproseCallback1 = procedure(Result: Variant) of object;
  THproseCallback2 = procedure(Result: Variant;
    const Args: TVariants) of object;

  THproseErrorEvent = procedure(const Name:string;
                                const Error: Exception) of object;

  THproseClient = class(TComponent)
  private
    FErrorEvent: THproseErrorEvent;
    FFilter: IHproseFilter;
  protected
    FUri: string;
    function GetInvokeContext: TObject; virtual; abstract;
    function GetOutputStream(var Context: TObject): TStream; virtual; abstract;
    procedure SendData(var Context: TObject); virtual; abstract;
    function GetInputStream(var Context: TObject): TStream; virtual; abstract;
    procedure EndInvoke(var Context: TObject); virtual; abstract;
    function DoInput(var Args: TVariants; ReturnType: TVarType;
      ReturnClass: TClass; ResultMode: THproseResultMode;
      InStream: TStream): Variant; overload;
    function DoInput(ReturnType: TVarType;
      ReturnClass: TClass;  ResultMode: THproseResultMode;
      InStream: TStream): Variant; overload;
    procedure DoOutput(const Name: string; const Args: array of const;
      OutStream: TStream); overload;
    procedure DoOutput(const Name: string; const Args: TVariants;
      ByRef: Boolean; OutStream: TStream); overload;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UseService(const AUri: string); virtual;
    // Synchronous invoke
    function Invoke(const Name: string;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    function Invoke(const Name: string; const Args: array of const;
      ResultMode: THproseResultMode): Variant;
      overload; virtual;
    function Invoke(const Name: string; const Args: array of const;
      ReturnType: TVarType;
      ResultMode: THproseResultMode): Variant;
      overload; virtual;
    function Invoke(const Name: string; const Args: array of const;
      ReturnClass: TClass;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    function Invoke(const Name: string; const Args: array of const;
      ReturnType: TVarType = varVariant;
      ReturnClass: TClass = nil;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    // Synchronous invoke
    function Invoke(const Name: string; var Args: TVariants;
      ByRef: Boolean;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    function Invoke(const Name: string; var Args: TVariants;
      ReturnType: TVarType;
      ByRef: Boolean;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    function Invoke(const Name: string; var Args: TVariants;
      ReturnClass: TClass;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    function Invoke(const Name: string; var Args: TVariants;
      ReturnType: TVarType = varVariant;
      ReturnClass: TClass = nil;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    // Asynchronous invoke
    procedure Invoke(const Name: string;
      Callback: THproseCallback1;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string;
      Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ResultMode: THproseResultMode);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent;
      ResultMode: THproseResultMode);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ReturnType: TVarType;
      ResultMode: THproseResultMode);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent;
      ReturnType: TVarType;
      ResultMode: THproseResultMode);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ReturnClass: TClass;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent;
      ReturnClass: TClass;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ReturnType: TVarType = varVariant;
      ReturnClass: TClass = nil;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent;
      ReturnType: TVarType = varVariant;
      ReturnClass: TClass = nil;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    // Asynchronous invoke
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ByRef: Boolean;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ErrorEvent: THproseErrorEvent;
      ByRef: Boolean;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ReturnType: TVarType;
      ByRef: Boolean;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ErrorEvent: THproseErrorEvent;
      ReturnType: TVarType;
      ByRef: Boolean;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ReturnClass: TClass;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ErrorEvent: THproseErrorEvent;
      ReturnClass: TClass;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ReturnType: TVarType = varVariant;
      ReturnClass: TClass = nil;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ErrorEvent: THproseErrorEvent;
      ReturnType: TVarType = varVariant;
      ReturnClass: TClass = nil;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
  published
    property Uri: string read FUri write UseService;
    property Filter: IHproseFilter read FFilter write FFilter;
    // This event OnError only for asynchronous invoke
    property OnError: THproseErrorEvent read FErrorEvent write FErrorEvent;
  end;

implementation

uses
  HproseIO, Variants;

type

  TAsyncInvokeThread1 = class(TThread)
  private
    FClient: THproseClient;
    FName: string;
    FArgs: TConstArray;
    FCallback: THproseCallback1;
    FErrorEvent: THproseErrorEvent;
    FReturnType: TVarType;
    FReturnClass: TClass;
    FResultMode: THproseResultMode;
    FResult: Variant;
    FError: Exception;
  protected
    procedure Execute; override;
    procedure DoCallback;
    procedure DoError;
  public
    constructor Create(Client: THproseClient; const Name: string;
      const Args: array of const; Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent; ReturnType: TVarType; ReturnClass: TClass;
      ResultMode: THproseResultMode);
  end;

  TAsyncInvokeThread2 = class(TThread)
  private
    FClient: THproseClient;
    FName: string;
    FArgs: TVariants;
    FCallback: THproseCallback2;
    FErrorEvent: THproseErrorEvent;
    FReturnType: TVarType;
    FReturnClass: TClass;
    FByRef: Boolean;
    FResultMode: THproseResultMode;
    FResult: Variant;
    FError: Exception;
  protected
    procedure Execute; override;
    procedure DoCallback;
    procedure DoError;
  public
    constructor Create(Client: THproseClient; const Name: string;
      const Args: TVariants; Callback: THproseCallback2;
      ErrorEvent: THproseErrorEvent; ReturnType: TVarType; ReturnClass: TClass;
      ByRef: Boolean; ResultMode: THproseResultMode);
  end;

{ THproseClient }

constructor THproseClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FErrorEvent := nil;
  FFilter := nil;
end;

function THproseClient.DoInput(var Args: TVariants;
  ReturnType: TVarType; ReturnClass: TClass; ResultMode: THproseResultMode;
  InStream: TStream): Variant;
var
  Tag: AnsiChar;
  HproseReader: THproseReader;
  Stream: TMemoryStream;
begin
  if Assigned(FFilter) then InStream := FFilter.InputFilter(InStream);
  Result := Null;
  if (ResultMode = RawWithEndTag) or
    (ResultMode = Raw) then begin
    Stream := TMemoryStream.Create;
    Stream.CopyFrom(InStream, 0);
    Stream.Position := 0;
    Result := ObjToVar(Stream);
    if ResultMode = Raw then Stream.Size := Stream.Size - 1;
  end
  else begin
    HproseReader := THproseReader.Create(InStream);
    try
      repeat
        Tag := HproseReader.CheckTags(HproseTagResult +
                                      HproseTagArgument +
                                      HproseTagError +
                                      HproseTagEnd);
        if Tag = HproseTagResult then begin
          if ResultMode = Serialized then begin
            Stream := HproseReader.ReadRaw;
            Stream.Position := 0;
            Result := ObjToVar(Stream);
          end
          else begin
            HproseReader.Reset;
            Result := HproseReader.Unserialize(ReturnType, ReturnClass)
          end;
        end
        else if Tag = HproseTagArgument then begin
          HproseReader.Reset;
          Args := VarToList(HproseReader.ReadList(varVariant)).ToArray
        end
        else if Tag = HproseTagError then begin
          HproseReader.Reset;
          Result := ObjToVar(EHproseException.Create(HproseReader.ReadString()));
        end;
      until Tag = HproseTagEnd;
    finally
      HproseReader.Free;
    end;
  end;
end;

function THproseClient.DoInput(ReturnType: TVarType;
  ReturnClass: TClass; ResultMode: THproseResultMode;
  InStream: TStream): Variant;
var
  Tag: AnsiChar;
  HproseReader: THproseReader;
  Stream: TMemoryStream;
begin
  if Assigned(FFilter) then InStream := FFilter.InputFilter(InStream);
  Result := Null;
  if (ResultMode = RawWithEndTag) or
    (ResultMode = Raw) then begin
    Stream := TMemoryStream.Create;
    Stream.CopyFrom(InStream, 0);
    Stream.Position := 0;
    Result := ObjToVar(Stream);
    if ResultMode = Raw then Stream.Size := Stream.Size - 1;
  end
  else begin
    HproseReader := THproseReader.Create(InStream);
    try
      repeat
        Tag := HproseReader.CheckTags(HproseTagResult +
                                      HproseTagError +
                                      HproseTagEnd);
        if Tag = HproseTagResult then begin
          if ResultMode = Serialized then begin
            Stream := HproseReader.ReadRaw;
            Stream.Position := 0;
            Result := ObjToVar(Stream);
          end
          else begin
            HproseReader.Reset;
            Result := HproseReader.Unserialize(ReturnType, ReturnClass)
          end
        end
        else if Tag = HproseTagError then begin
          HproseReader.Reset;
          Result := ObjToVar(EHproseException.Create(HproseReader.ReadString()));
        end;
      until Tag = HproseTagEnd;
    finally
      HproseReader.Free;
    end;
  end;
end;

procedure THproseClient.DoOutput(const Name: string;
  const Args: array of const; OutStream: TStream);
var
  HproseWriter: THproseWriter;
begin
  if Assigned(FFilter) then OutStream := FFilter.OutputFilter(OutStream);
  HproseWriter := THproseWriter.Create(OutStream);
  try
    OutStream.Write(HproseTagCall, 1);
    HproseWriter.WriteString(Name, False);
    if Length(Args) > 0 then begin
      HproseWriter.Reset;
      HproseWriter.WriteArray(Args);
    end;
    OutStream.Write(HproseTagEnd, 1);
  finally
    HproseWriter.Free;
  end;
end;

procedure THproseClient.DoOutput(const Name: string;
  const Args: TVariants; ByRef: Boolean; OutStream: TStream);
var
  HproseWriter: THproseWriter;
begin
  if Assigned(FFilter) then OutStream := FFilter.OutputFilter(OutStream);
  HproseWriter := THproseWriter.Create(OutStream);
  try
    OutStream.Write(HproseTagCall, 1);
    HproseWriter.WriteString(Name, False);
    if (Length(Args) > 0) or ByRef then begin
      HproseWriter.Reset;
      HproseWriter.WriteArray(Args, False);
      if ByRef then HproseWriter.WriteBoolean(True);
    end;
    OutStream.Write(HproseTagEnd, 1);
  finally
    HproseWriter.Free;
  end;
end;

// Synchronous invoke
function THproseClient.Invoke(const Name: string;
  ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, [], varVariant, TClass(nil), ResultMode);
end;

function THproseClient.Invoke(const Name: string;
  const Args: array of const; ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, Args, varVariant, TClass(nil), ResultMode);
end;

function THproseClient.Invoke(const Name: string;
  const Args: array of const; ReturnType: TVarType;
  ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, Args, ReturnType, TClass(nil), ResultMode);
end;

function THproseClient.Invoke(const Name: string;
  const Args: array of const; ReturnClass: TClass;
  ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, Args, varVariant, ReturnClass, ResultMode);
end;

function THproseClient.Invoke(const Name: string;
  const Args: array of const; ReturnType: TVarType;
  ReturnClass: TClass; ResultMode: THproseResultMode): Variant;
var
  Context: TObject;
  InStream, OutStream: TStream;
begin
  Context := GetInvokeContext;
  try
    OutStream := GetOutputStream(Context);
    DoOutput(Name, Args, OutStream);
    SendData(Context);
    Result := Null;
    InStream := GetInputStream(Context);
    Result := DoInput(ReturnType, ReturnClass, ResultMode, InStream);
  finally
    EndInvoke(Context);
  end;
  if VarIsObj(Result, EHproseException) then
    raise EHproseException(VarToObj(Result))
end;

// Synchronous invoke
function THproseClient.Invoke(const Name: string; var Args: TVariants;
  ByRef: Boolean; ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, Args, varVariant, TClass(nil), ByRef, ResultMode);
end;

function THproseClient.Invoke(const Name: string; var Args: TVariants;
  ReturnType: TVarType; ByRef: Boolean;
  ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, Args, ReturnType, TClass(nil), ByRef, ResultMode);
end;

function THproseClient.Invoke(const Name: string; var Args: TVariants;
  ReturnClass: TClass; ByRef: Boolean;
  ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, Args, varVariant, ReturnClass, ByRef, ResultMode);
end;

function THproseClient.Invoke(const Name: string;
  var Args: TVariants; ReturnType: TVarType;
  ReturnClass: TClass; ByRef: Boolean; ResultMode: THproseResultMode): Variant;
var
  Context: TObject;
  InStream, OutStream: TStream;
begin
  Context := GetInvokeContext;
  try
    OutStream := GetOutputStream(Context);
    DoOutput(Name, Args, Byref, OutStream);
    SendData(Context);
    Result := Null;
    InStream := GetInputStream(Context);
    Result := DoInput(Args, ReturnType, ReturnClass, ResultMode, InStream);
  finally
    EndInvoke(Context);
  end;
  if VarIsObj(Result, EHproseException) then
    raise EHproseException(VarToObj(Result));
end;

// Asynchronous invoke
procedure THproseClient.Invoke(const Name: string;
  Callback: THproseCallback1; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, [], Callback, nil, varVariant,
    TClass(nil), ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  Callback: THproseCallback1; ErrorEvent: THproseErrorEvent;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, [], Callback, ErrorEvent, varVariant,
    TClass(nil), ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  const Args: array of const; Callback: THproseCallback1;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, nil, varVariant,
    TClass(nil), ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  const Args: array of const; Callback: THproseCallback1;
  ErrorEvent: THproseErrorEvent; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, ErrorEvent, varVariant,
    TClass(nil), ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  const Args: array of const; Callback: THproseCallback1;
  ReturnType: TVarType; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, nil, ReturnType,
    TClass(nil), ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  const Args: array of const; Callback: THproseCallback1;
  ErrorEvent: THproseErrorEvent; ReturnType: TVarType;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, ErrorEvent, ReturnType,
    TClass(nil), ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  const Args: array of const; Callback: THproseCallback1;
  ReturnClass: TClass; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, nil, varVariant,
    ReturnClass, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  const Args: array of const; Callback: THproseCallback1;
  ErrorEvent: THproseErrorEvent; ReturnClass: TClass;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, ErrorEvent, varVariant,
    ReturnClass, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  const Args: array of const; Callback: THproseCallback1;
  ReturnType: TVarType; ReturnClass: TClass;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, nil, ReturnType,
    ReturnClass, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  const Args: array of const; Callback: THproseCallback1;
  ErrorEvent: THproseErrorEvent; ReturnType: TVarType; ReturnClass: TClass;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, ErrorEvent, ReturnType,
    ReturnClass, ResultMode);
end;

// Asynchronous invoke
procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2; ByRef: Boolean;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, nil, varVariant,
    TClass(nil), ByRef, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2; ErrorEvent: THproseErrorEvent;
  ByRef: Boolean; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, ErrorEvent, varVariant,
    TClass(nil), ByRef, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2; ReturnClass: TClass; ByRef: Boolean;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, nil, varVariant,
    ReturnClass, ByRef, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2; ErrorEvent: THproseErrorEvent;
  ReturnClass: TClass; ByRef: Boolean; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, ErrorEvent, varVariant,
    ReturnClass, ByRef, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2; ReturnType: TVarType; ByRef: Boolean;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, nil, ReturnType,
    TClass(nil), ByRef, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2; ErrorEvent: THproseErrorEvent;
  ReturnType: TVarType; ByRef: Boolean; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, ErrorEvent, ReturnType,
    TClass(nil), ByRef, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2; ReturnType: TVarType; ReturnClass: TClass;
  ByRef: Boolean; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, nil, ReturnType,
    ReturnClass, ByRef, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  var Args: TVariants; Callback: THproseCallback2;
  ErrorEvent: THproseErrorEvent; ReturnType: TVarType; ReturnClass: TClass;
  ByRef: Boolean; ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, ErrorEvent, ReturnType,
    ReturnClass, ByRef, ResultMode);
end;

procedure THproseClient.UseService(const AUri: string);
begin
  if AUri <> '' then FUri := AUri;
end;

{ TAsyncInvokeThread1 }

constructor TAsyncInvokeThread1.Create(Client: THproseClient;
  const Name: string; const Args: array of const;
  Callback: THproseCallback1; ErrorEvent: THproseErrorEvent;
  ReturnType: TVarType; ReturnClass: TClass; ResultMode: THproseResultMode);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FClient := Client;
  FName := Name;
  FArgs := CreateConstArray(Args);
  FCallback := Callback;
  FErrorEvent := ErrorEvent;
  FReturnType := ReturnType;
  FReturnClass := ReturnClass;
  FResultMode := ResultMode;
  FError := nil;
end;

procedure TAsyncInvokeThread1.DoCallback;
begin
  if FError = nil then FCallback(FResult);
end;

procedure TAsyncInvokeThread1.DoError;
begin
  if Assigned(FErrorEvent) then
    FErrorEvent(FName, FError)
  else if Assigned(FClient.FErrorEvent) then
    FClient.FErrorEvent(FName, FError);
end;

procedure TAsyncInvokeThread1.Execute;
begin
  try
    try
      FResult := FClient.Invoke(FName,
                                FArgs,
                                FReturnType,
                                FReturnClass,
                                FResultMode);
    except
      on E: Exception do begin
        FError := E;
        Synchronize(DoError);
      end;
    end;
  finally
    FinalizeConstArray(FArgs);
  end;
  Synchronize(DoCallback);
end;

{ TAsyncInvokeThread2 }

constructor TAsyncInvokeThread2.Create(Client: THproseClient;
  const Name: string; const Args: TVariants;
  Callback: THproseCallback2; ErrorEvent: THproseErrorEvent;
  ReturnType: TVarType; ReturnClass: TClass; ByRef: Boolean;
  ResultMode: THproseResultMode);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FClient := Client;
  FName := Name;
  FArgs := Args;
  FCallback := Callback;
  FErrorEvent := ErrorEvent;
  FReturnType := ReturnType;
  FReturnClass := ReturnClass;
  FByRef := ByRef;
  FResultMode := ResultMode;
  FError := nil;
end;

procedure TAsyncInvokeThread2.DoCallback;
begin
  if FError = nil then FCallback(FResult, FArgs);
end;

procedure TAsyncInvokeThread2.DoError;
begin
  if Assigned(FErrorEvent) then
    FErrorEvent(FName, FError)
  else if Assigned(FClient.FErrorEvent) then
    FClient.FErrorEvent(FName, FError);
end;

procedure TAsyncInvokeThread2.Execute;
begin
  try
    FResult := FClient.Invoke(FName,
                              FArgs,
                              FReturnType,
                              FReturnClass,
                              FByRef,
                              FResultMode);
  except
    on E: Exception do begin
      FError := E;
      Synchronize(DoError);
    end;
  end;
  Synchronize(DoCallback);
end;

end.
