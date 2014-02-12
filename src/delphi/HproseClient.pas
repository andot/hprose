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
 * LastModified: Nov 4, 2013                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
}
unit HproseClient;

{$I Hprose.inc}

interface

uses HproseCommon, Classes, SysUtils, TypInfo;

type
{$IFDEF Supports_Anonymous_Method}
  THproseCallback1 = reference to procedure(Result: Variant);
  THproseCallback2 = reference to procedure(Result: Variant;
    const Args: TVariants);
  THproseErrorEvent = reference to procedure(const Name:string;
                                const Error: Exception);
{$ELSE}
  THproseCallback1 = procedure(Result: Variant) of object;
  THproseCallback2 = procedure(Result: Variant;
    const Args: TVariants) of object;

  THproseErrorEvent = procedure(const Name:string;
                                const Error: Exception) of object;
{$ENDIF}

{$IFDEF Supports_Generics}
  THproseCallback1<T> = reference to procedure(Result: T);
  THproseCallback2<T> = reference to procedure(Result: T;
    const Args: TVariants);
{$ENDIF}

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
    function DoInput(var Args: TVariants; ResultType: PTypeInfo;
      ResultMode: THproseResultMode; InStream: TStream): Variant; overload;
    function DoInput(ResultType: PTypeInfo; ResultMode: THproseResultMode;
      InStream: TStream): Variant; overload;
    procedure DoOutput(const Name: string; const Args: array of const;
      OutStream: TStream); overload;
    procedure DoOutput(const Name: string; const Args: TVariants;
      ByRef: Boolean; OutStream: TStream); overload;
{$IFDEF Supports_Generics}
    procedure DoInput(var Args: TVariants; ResultType: PTypeInfo;
      InStream: TStream; out Result); overload;
    procedure DoInput(ResultType: PTypeInfo;
      InStream: TStream; out Result); overload;
{$ENDIF}
    // Synchronous invoke
    function Invoke(const Name: string; const Args: array of const;
      ResultType: PTypeInfo; ResultMode: THproseResultMode): Variant;
      overload; virtual;
    function Invoke(const Name: string; var Args: TVariants;
      ResultType: PTypeInfo; ByRef: Boolean;
      ResultMode: THproseResultMode): Variant;
      overload; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UseService(const AUri: string); virtual;
    // Synchronous invoke
    function Invoke(const Name: string;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    function Invoke(const Name: string; ResultType: PTypeInfo): Variant;
      overload; virtual;
    // Synchronous invoke
    function Invoke(const Name: string; const Args: array of const;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    function Invoke(const Name: string; const Args: array of const;
      ResultType: PTypeInfo): Variant;
      overload; virtual;
    // Synchronous invoke
    function Invoke(const Name: string; var Args: TVariants;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal): Variant;
      overload; virtual;
    function Invoke(const Name: string; var Args: TVariants;
      ResultType: PTypeInfo;
      ByRef: Boolean = True): Variant;
      overload; virtual;
{$IFDEF Supports_Generics}
    // Synchronous invoke
    function Invoke<T>(const Name: string): T; overload;
    function Invoke<T>(const Name: string; const Args: array of const): T;
      overload;
    function Invoke<T>(const Name: string; var Args: TVariants;
      ByRef: Boolean = True): T; overload;
{$ENDIF}
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
    // Asynchronous invoke
    procedure Invoke(const Name: string;
      Callback: THproseCallback1;
      ResultType: PTypeInfo);
      overload; virtual;
    procedure Invoke(const Name: string;
      Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent;
      ResultType: PTypeInfo);
      overload; virtual;
    // Asynchronous invoke
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    // Asynchronous invoke
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ResultType: PTypeInfo);
      overload; virtual;
    procedure Invoke(const Name: string; const Args: array of const;
      Callback: THproseCallback1;
      ErrorEvent: THproseErrorEvent;
      ResultType: PTypeInfo);
      overload; virtual;
    // Asynchronous invoke
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ErrorEvent: THproseErrorEvent;
      ByRef: Boolean = True;
      ResultMode: THproseResultMode = Normal);
      overload; virtual;
    // Asynchronous invoke
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ResultType: PTypeInfo;
      ByRef: Boolean = True);
      overload; virtual;
    procedure Invoke(const Name: string; var Args: TVariants;
      Callback: THproseCallback2;
      ErrorEvent: THproseErrorEvent;
      ResultType: PTypeInfo;
      ByRef: Boolean = True);
      overload; virtual;
{$IFDEF Supports_Generics}
    // Asynchronous invoke
    procedure Invoke<T>(const Name: string;
      Callback: THproseCallback1<T>;
      ErrorEvent: THproseErrorEvent = nil); overload;
    procedure Invoke<T>(const Name: string; const Args: array of const;
      Callback: THproseCallback1<T>;
      ErrorEvent: THproseErrorEvent = nil); overload;
    procedure Invoke<T>(const Name: string; var Args: TVariants;
      Callback: THproseCallback2<T>;
      ByRef: Boolean = True); overload;
    procedure Invoke<T>(const Name: string; var Args: TVariants;
      Callback: THproseCallback2<T>;
      ErrorEvent: THproseErrorEvent;
      ByRef: Boolean = True); overload;
{$ENDIF}
  published
    property Uri: string read FUri write UseService;
    property Filter: IHproseFilter read FFilter write FFilter;
    // This event OnError only for asynchronous invoke
    property OnError: THproseErrorEvent read FErrorEvent write FErrorEvent;
  end;

{$IFDEF Supports_Generics}
// The following two classes is private class, but they can't be moved to the
// implementation section because of E2506.
  TAsyncInvokeThread1<T> = class(TThread)
  private
    FClient: THproseClient;
    FName: string;
    FArgs: TConstArray;
    FCallback: THproseCallback1<T>;
    FErrorEvent: THproseErrorEvent;
    FResult: T;
    FError: Exception;
    constructor Create(Client: THproseClient; const Name: string;
      const Args: array of const; Callback: THproseCallback1<T>;
      ErrorEvent: THproseErrorEvent);
  protected
    procedure Execute; override;
    procedure DoCallback;
    procedure DoError;
  end;

  TAsyncInvokeThread2<T> = class(TThread)
  private
    FClient: THproseClient;
    FName: string;
    FArgs: TVariants;
    FCallback: THproseCallback2<T>;
    FErrorEvent: THproseErrorEvent;
    FByRef: Boolean;
    FResult: T;
    FError: Exception;
    constructor Create(Client: THproseClient; const Name: string;
      const Args: TVariants; Callback: THproseCallback2<T>;
      ErrorEvent: THproseErrorEvent; ByRef: Boolean);
  protected
    procedure Execute; override;
    procedure DoCallback;
    procedure DoError;
  end;
{$ENDIF}

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
    FResultType: PTypeInfo;
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
      ErrorEvent: THproseErrorEvent; ResultType: PTypeInfo;
      ResultMode: THproseResultMode);
  end;

  TAsyncInvokeThread2 = class(TThread)
  private
    FClient: THproseClient;
    FName: string;
    FArgs: TVariants;
    FCallback: THproseCallback2;
    FErrorEvent: THproseErrorEvent;
    FResultType: PTypeInfo;
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
      ErrorEvent: THproseErrorEvent; ResultType: PTypeInfo;
      ByRef: Boolean; ResultMode: THproseResultMode);
  end;

{ THproseClient }

constructor THproseClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FErrorEvent := nil;
  FFilter := nil;
end;

function THproseClient.DoInput(var Args: TVariants; ResultType: PTypeInfo;
  ResultMode: THproseResultMode; InStream: TStream): Variant;
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
            Result := HproseReader.Unserialize(ResultType)
          end
        end
        else if Tag = HproseTagArgument then begin
          HproseReader.Reset;
          Args := HproseReader.ReadVariantArray;
        end
        else if Tag = HproseTagError then begin
          HproseReader.Reset;
          raise EHproseException.Create(HproseReader.ReadString());
        end;
      until Tag = HproseTagEnd;
    finally
      HproseReader.Free;
    end;
  end;
end;

function THproseClient.DoInput(ResultType: PTypeInfo;
  ResultMode: THproseResultMode; InStream: TStream): Variant;
var
  Args: TVariants;
begin
  Result := DoInput(Args, ResultType, ResultMode, InStream);
end;

{$IFDEF Supports_Generics}
procedure THproseClient.DoInput(var Args: TVariants; ResultType: PTypeInfo;
      InStream: TStream; out Result);
var
  Tag: AnsiChar;
  HproseReader: THproseReader;
begin
  if Assigned(FFilter) then InStream := FFilter.InputFilter(InStream);
  HproseReader := THproseReader.Create(InStream);
  try
    repeat
      Tag := HproseReader.CheckTags(HproseTagResult +
                                    HproseTagArgument +
                                    HproseTagError +
                                    HproseTagEnd);
      if Tag = HproseTagResult then begin
        HproseReader.Reset;
        HproseReader.Unserialize(ResultType, Result);
      end
      else if Tag = HproseTagArgument then begin
        HproseReader.Reset;
        Args := HproseReader.ReadVariantArray;
      end
      else if Tag = HproseTagError then begin
        HproseReader.Reset;
        raise EHproseException.Create(HproseReader.ReadString());
      end;
    until Tag = HproseTagEnd;
  finally
    HproseReader.Free;
  end;
end;

procedure THproseClient.DoInput(ResultType: PTypeInfo;
  InStream: TStream; out Result);
var
  Args: TVariants;
begin
  DoInput(Args, ResultType, InStream, Result);
end;
{$ENDIF}

procedure THproseClient.DoOutput(const Name: string;
  const Args: array of const; OutStream: TStream);
var
  HproseWriter: THproseWriter;
begin
  if Assigned(FFilter) then OutStream := FFilter.OutputFilter(OutStream);
  HproseWriter := THproseWriter.Create(OutStream);
  try
    OutStream.Write(HproseTagCall, 1);
    HproseWriter.WriteString(Name);
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
    HproseWriter.WriteString(Name);
    if (Length(Args) > 0) or ByRef then begin
      HproseWriter.Reset;
      HproseWriter.WriteArray(Args);
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
  Result := Invoke(Name, [], PTypeInfo(nil), ResultMode);
end;

function THproseClient.Invoke(const Name: string;
  ResultType: PTypeInfo): Variant;
begin
  Result := Invoke(Name, [], ResultType, Normal);
end;

function THproseClient.Invoke(const Name: string;
  const Args: array of const; ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, Args, PTypeInfo(nil), ResultMode);
end;

function THproseClient.Invoke(const Name: string;
  const Args: array of const; ResultType: PTypeInfo): Variant;
begin
  Result := Invoke(Name, Args, ResultType, Normal);
end;

function THproseClient.Invoke(const Name: string;
  const Args: array of const; ResultType: PTypeInfo;
  ResultMode: THproseResultMode): Variant;
var
  Context: TObject;
  InStream, OutStream: TStream;
begin
  Context := GetInvokeContext;
  try
    OutStream := GetOutputStream(Context);
    DoOutput(Name, Args, OutStream);
    SendData(Context);
    InStream := GetInputStream(Context);
    Result := DoInput(ResultType, ResultMode, InStream);
  finally
    EndInvoke(Context);
  end;
end;

// Synchronous invoke
function THproseClient.Invoke(const Name: string; var Args: TVariants;
  ByRef: Boolean; ResultMode: THproseResultMode): Variant;
begin
  Result := Invoke(Name, Args, PTypeInfo(nil), ByRef, ResultMode);
end;

function THproseClient.Invoke(const Name: string; var Args: TVariants;
  ResultType: PTypeInfo; ByRef: Boolean): Variant;
begin
  Result := Invoke(Name, Args, ResultType, ByRef, Normal);
end;

function THproseClient.Invoke(const Name: string; var Args: TVariants;
  ResultType: PTypeInfo; ByRef: Boolean;
  ResultMode: THproseResultMode): Variant;
var
  Context: TObject;
  InStream, OutStream: TStream;
begin
  Context := GetInvokeContext;
  try
    OutStream := GetOutputStream(Context);
    DoOutput(Name, Args, Byref, OutStream);
    SendData(Context);
    InStream := GetInputStream(Context);
    Result := DoInput(Args, ResultType, ResultMode, InStream);
  finally
    EndInvoke(Context);
  end;
end;

{$IFDEF Supports_Generics}
// Synchronous invoke
function THproseClient.Invoke<T>(const Name: string): T;
begin
  Result := Self.Invoke<T>(Name, []);
end;

function THproseClient.Invoke<T>(const Name: string;
  const Args: array of const): T;
var
  Context: TObject;
  InStream, OutStream: TStream;
begin
  Context := GetInvokeContext;
  try
    OutStream := GetOutputStream(Context);
    DoOutput(Name, Args, OutStream);
    SendData(Context);
    InStream := GetInputStream(Context);
    Result := Default(T);
    DoInput(TypeInfo(T), InStream, Result);
  finally
    EndInvoke(Context);
  end;
end;

function THproseClient.Invoke<T>(const Name: string; var Args: TVariants;
  ByRef: Boolean): T;
var
  Context: TObject;
  InStream, OutStream: TStream;
begin
  Context := GetInvokeContext;
  try
    OutStream := GetOutputStream(Context);
    DoOutput(Name, Args, Byref, OutStream);
    SendData(Context);
    InStream := GetInputStream(Context);
    Result := Default(T);
    DoInput(Args, TypeInfo(T), InStream, Result);
  finally
    EndInvoke(Context);
  end;
end;
{$ENDIF}

// Asynchronous invoke
procedure THproseClient.Invoke(const Name: string;
  Callback: THproseCallback1;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, [], Callback, nil, nil, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string;
  Callback: THproseCallback1;
  ErrorEvent: THproseErrorEvent;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, [], Callback, ErrorEvent, nil, ResultMode);
end;

// Asynchronous invoke
procedure THproseClient.Invoke(const Name: string;
  Callback: THproseCallback1;
  ResultType: PTypeInfo);
begin
  TAsyncInvokeThread1.Create(Self, Name, [], Callback, nil, ResultType, Normal);
end;

procedure THproseClient.Invoke(const Name: string;
  Callback: THproseCallback1;
  ErrorEvent: THproseErrorEvent;
  ResultType: PTypeInfo);
begin
  TAsyncInvokeThread1.Create(Self, Name, [], Callback, ErrorEvent, ResultType, Normal);
end;

// Asynchronous invoke
procedure THproseClient.Invoke(const Name: string; const Args: array of const;
  Callback: THproseCallback1;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, nil, nil, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string; const Args: array of const;
  Callback: THproseCallback1;
  ErrorEvent: THproseErrorEvent;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, ErrorEvent, nil, ResultMode);
end;

// Asynchronous invoke
procedure THproseClient.Invoke(const Name: string; const Args: array of const;
  Callback: THproseCallback1;
  ResultType: PTypeInfo);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, nil, ResultType, Normal);
end;

procedure THproseClient.Invoke(const Name: string; const Args: array of const;
  Callback: THproseCallback1;
  ErrorEvent: THproseErrorEvent;
  ResultType: PTypeInfo);
begin
  TAsyncInvokeThread1.Create(Self, Name, Args, Callback, ErrorEvent, ResultType, Normal);
end;

// Asynchronous invoke
procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2;
  ByRef: Boolean;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, nil, nil, ByRef, ResultMode);
end;

procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2;
  ErrorEvent: THproseErrorEvent;
  ByRef: Boolean;
  ResultMode: THproseResultMode);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, ErrorEvent, nil, ByRef, ResultMode);
end;

// Asynchronous invoke
procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2;
  ResultType: PTypeInfo;
  ByRef: Boolean);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, nil, ResultType, ByRef, Normal);
end;

procedure THproseClient.Invoke(const Name: string; var Args: TVariants;
  Callback: THproseCallback2;
  ErrorEvent: THproseErrorEvent;
  ResultType: PTypeInfo;
  ByRef: Boolean);
begin
  TAsyncInvokeThread2.Create(Self, Name, Args, Callback, ErrorEvent, ResultType, ByRef, Normal);
end;

{$IFDEF Supports_Generics}
procedure THproseClient.Invoke<T>(const Name: string;
  Callback: THproseCallback1<T>;
  ErrorEvent: THproseErrorEvent);
begin
  TAsyncInvokeThread1<T>.Create(Self, Name, [], Callback, ErrorEvent);
end;

procedure THproseClient.Invoke<T>(const Name: string; const Args: array of const;
  Callback: THproseCallback1<T>;
  ErrorEvent: THproseErrorEvent);
begin
  TAsyncInvokeThread1<T>.Create(Self, Name, Args, Callback, ErrorEvent);
end;

procedure THproseClient.Invoke<T>(const Name: string; var Args: TVariants;
  Callback: THproseCallback2<T>;
  ByRef: Boolean);
begin
  TAsyncInvokeThread2<T>.Create(Self, Name, Args, Callback, nil, ByRef);
end;

procedure THproseClient.Invoke<T>(const Name: string; var Args: TVariants;
  Callback: THproseCallback2<T>;
  ErrorEvent: THproseErrorEvent;
  ByRef: Boolean);
begin
  TAsyncInvokeThread2<T>.Create(Self, Name, Args, Callback, ErrorEvent, ByRef);
end;
{$ENDIF}

procedure THproseClient.UseService(const AUri: string);
begin
  if AUri <> '' then FUri := AUri;
end;

{ TAsyncInvokeThread1 }

constructor TAsyncInvokeThread1.Create(Client: THproseClient;
  const Name: string; const Args: array of const;
  Callback: THproseCallback1; ErrorEvent: THproseErrorEvent;
  ResultType: PTypeInfo; ResultMode: THproseResultMode);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FClient := Client;
  FName := Name;
  FArgs := CreateConstArray(Args);
  FCallback := Callback;
  FErrorEvent := ErrorEvent;
  FResultType := ResultType;
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
                                FResultType,
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
  ResultType: PTypeInfo; ByRef: Boolean;
  ResultMode: THproseResultMode);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FClient := Client;
  FName := Name;
  FArgs := Args;
  FCallback := Callback;
  FErrorEvent := ErrorEvent;
  FResultType := ResultType;
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
                              FResultType,
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

{$IFDEF Supports_Generics}
{ TAsyncInvokeThread1<T> }

constructor TAsyncInvokeThread1<T>.Create(Client: THproseClient;
  const Name: string; const Args: array of const;
  Callback: THproseCallback1<T>; ErrorEvent: THproseErrorEvent);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FClient := Client;
  FName := Name;
  FArgs := CreateConstArray(Args);
  FCallback := Callback;
  FErrorEvent := ErrorEvent;
  FError := nil;
end;

procedure TAsyncInvokeThread1<T>.DoCallback;
begin
  if FError = nil then FCallback(FResult);
end;

procedure TAsyncInvokeThread1<T>.DoError;
begin
  if Assigned(FErrorEvent) then
    FErrorEvent(FName, FError)
  else if Assigned(FClient.FErrorEvent) then
    FClient.FErrorEvent(FName, FError);
end;

procedure TAsyncInvokeThread1<T>.Execute;
begin
  try
    try
      FResult := FClient.Invoke<T>(FName, FArgs);
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

{ TAsyncInvokeThread2<T> }

constructor TAsyncInvokeThread2<T>.Create(Client: THproseClient;
  const Name: string; const Args: TVariants;
  Callback: THproseCallback2<T>; ErrorEvent: THproseErrorEvent;
  ByRef: Boolean);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FClient := Client;
  FName := Name;
  FArgs := Args;
  FCallback := Callback;
  FErrorEvent := ErrorEvent;
  FByRef := ByRef;
  FError := nil;
end;

procedure TAsyncInvokeThread2<T>.DoCallback;
begin
  if FError = nil then FCallback(FResult, FArgs);
end;

procedure TAsyncInvokeThread2<T>.DoError;
begin
  if Assigned(FErrorEvent) then
    FErrorEvent(FName, FError)
  else if Assigned(FClient.FErrorEvent) then
    FClient.FErrorEvent(FName, FError);
end;

procedure TAsyncInvokeThread2<T>.Execute;
begin
  try
    FResult := FClient.Invoke<T>(FName, FArgs, FByRef);
  except
    on E: Exception do begin
      FError := E;
      Synchronize(DoError);
    end;
  end;
  Synchronize(DoCallback);
end;
{$ENDIF}

end.
