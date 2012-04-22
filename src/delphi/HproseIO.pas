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
 * HproseIO.pas                                           *
 *                                                        *
 * hprose io unit for delphi.                             *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
}
unit HproseIO;

{$I Hprose.inc}

interface

uses Classes, HproseCommon;

const
  { Hprose Serialize Tags }
  HproseTagInteger    :AnsiChar = 'i';
  HproseTagLong       :AnsiChar = 'l';
  HproseTagDouble     :AnsiChar = 'd';
  HproseTagNull       :AnsiChar = 'n';
  HproseTagEmpty      :AnsiChar = 'e';
  HproseTagTrue       :AnsiChar = 't';
  HproseTagFalse      :AnsiChar = 'f';
  HproseTagNaN        :AnsiChar = 'N';
  HproseTagInfinity   :AnsiChar = 'I';
  HproseTagDate       :AnsiChar = 'D';
  HproseTagTime       :AnsiChar = 'T';
  HproseTagUTC        :AnsiChar = 'Z';
  HproseTagBytes      :AnsiChar = 'b';
  HproseTagUTF8Char   :AnsiChar = 'u';
  HproseTagString     :AnsiChar = 's';
  HproseTagGuid       :AnsiChar = 'g';
  HproseTagList       :AnsiChar = 'a';
  HproseTagMap        :AnsiChar = 'm';
  HproseTagClass      :AnsiChar = 'c';
  HproseTagObject     :AnsiChar = 'o';
  HproseTagRef        :AnsiChar = 'r';
  { Hprose Serialize Marks }
  HproseTagPos        :AnsiChar = '+';
  HproseTagNeg        :AnsiChar = '-';
  HproseTagSemicolon  :AnsiChar = ';';
  HproseTagOpenbrace  :AnsiChar = '{';
  HproseTagClosebrace :AnsiChar = '}';
  HproseTagQuote      :AnsiChar = '"';
  HproseTagPoint      :AnsiChar = '.';
  { Hprose Protocol Tags }
  HproseTagFunctions  :AnsiChar = 'F';
  HproseTagCall       :AnsiChar = 'C';
  HproseTagResult     :AnsiChar = 'R';
  HproseTagArgument   :AnsiChar = 'A';
  HproseTagError      :AnsiChar = 'E';
  HproseTagEnd        :AnsiChar = 'z';

type

  THproseReader = class
  private
    FStream: TStream;
    FRefList: IList;
    FClassRefList: IList;
    FAttrRefMap: IMap;
    function Unserialize(Tag: AnsiChar; VType: TVarType;
      AClass: TClass): Variant; overload;
    function ReadByte: Byte;
    function ReadInt64(Tag: AnsiChar): Int64;
{$IF Defined(DELPHI2009_UP) or Defined(FPC)}
    function ReadUInt64(Tag: AnsiChar): UInt64;
{$IFEND}
    function ReadShortIntArray(Count: Integer): Variant;
    function ReadSmallIntArray(Count: Integer): Variant;
    function ReadWordArray(Count: Integer): Variant;
    function ReadIntegerArray(Count: Integer): Variant;
    function ReadCurrencyArray(Count: Integer): Variant;
    function ReadLongWordArray(Count: Integer): Variant;
    function ReadInt64Array(Count: Integer): Variant;
{$IFDEF DELPHI2009_UP}
    function ReadUInt64Array(Count: Integer): Variant;
{$ENDIF}
{$IFDEF FPC}
    function ReadQWordArray(Count: Integer): Variant;
{$ENDIF}
    function ReadSingleArray(Count: Integer): Variant;
    function ReadDoubleArray(Count: Integer): Variant;
    function ReadBooleanArray(Count: Integer): Variant;
    function ReadWideStringArray(Count: Integer): Variant;
    function ReadDateTimeArray(Count: Integer): Variant;
    function ReadList(AClass: TClass; Count: Integer): Variant; overload;
    function ReadRef: Variant;
    procedure ReadClass;
    procedure ReadRaw(const OStream: TStream; Tag: AnsiChar); overload;
    procedure ReadInfinityRaw(const OStream: TStream; Tag: AnsiChar);
    procedure ReadNumberRaw(const OStream: TStream; Tag: AnsiChar);
    procedure ReadDateTimeRaw(const OStream: TStream; Tag: AnsiChar);
    procedure ReadUTF8CharRaw(const OStream: TStream; Tag: AnsiChar);
    procedure ReadBytesRaw(const OStream: TStream; Tag: AnsiChar);
    procedure ReadStringRaw(const OStream: TStream; Tag: AnsiChar);
    procedure ReadGuidRaw(const OStream: TStream; Tag: AnsiChar);
    procedure ReadComplexRaw(const OStream: TStream; Tag: AnsiChar);
  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;
    function Unserialize(VType: TVarType = varVariant;
      AClass: TClass = nil): Variant; overload;
    procedure CheckTag(expectTag: AnsiChar);
    function CheckTags(const expectTags: RawByteString): AnsiChar;
    function ReadUntil(Tag: AnsiChar): string;
    function ReadInt(Tag: AnsiChar): Integer;    
    function ReadInteger(IncludeTag:Boolean = True): Integer;
    function ReadLong(IncludeTag:Boolean = True): Variant;
    function ReadDouble(IncludeTag:Boolean = True): Extended;
    function ReadCurrency(IncludeTag:Boolean = True): Currency;
    function ReadNull(): Variant;
    function ReadEmpty(): Variant;
    function ReadBoolean(): Boolean;
    function ReadNaN(): Extended;
    function ReadInfinity(IncludeTag:Boolean = True): Extended;
    function ReadDate(IncludeTag:Boolean = True): TDateTime;
    function ReadTime(IncludeTag:Boolean = True): TDateTime;
    function ReadBytes(IncludeTag:Boolean = True): Variant;
    function ReadUTF8Char(IncludeTag:Boolean = True): WideChar;
    function ReadString(IncludeTag:Boolean = True;
      IncludeRef:Boolean = True): WideString;
    function ReadGuid(IncludeTag:Boolean = True): AnsiString;
    function ReadList(ElementType: TVarType; AClass: TClass = nil;
      IncludeTag:Boolean = True): Variant; overload;
    function ReadMap(AClass: TClass = nil; IncludeTag:Boolean = True): Variant;
    function ReadObject(AClass: TClass = nil; IncludeTag:Boolean = True): Variant;
    procedure Reset;
    function ReadRaw: TMemoryStream; overload;
    procedure ReadRaw(const OStream: TStream); overload;
    property Stream: TStream read FStream;
  end;

  THproseWriter = class
  private
    FStream: TStream;
    FRefList: IList;
    FClassRefList: IList;
    function WriteRef(const Value: Variant; CheckRef: Boolean):
      Boolean; overload;
    procedure WriteRef(Value: Integer); overload;
    function WriteClass(Instance: TObject): Integer;
    procedure WriteRawByteString(const S: RawByteString);
    procedure WriteShortIntArray(var P; Count: Integer);
    procedure WriteSmallIntArray(var P; Count: Integer);
    procedure WriteWordArray(var P; Count: Integer);
    procedure WriteIntegerArray(var P; Count: Integer);
    procedure WriteCurrencyArray(var P; Count: Integer);
    procedure WriteLongWordArray(var P; Count: Integer);
    procedure WriteInt64Array(var P; Count: Integer);
{$IFDEF DELPHI2009_UP}
    procedure WriteUInt64Array(var P; Count: Integer);
{$ENDIF}
{$IFDEF FPC}
    procedure WriteQWordArray(var P; Count: Integer);
{$ENDIF}
    procedure WriteSingleArray(var P; Count: Integer);
    procedure WriteDoubleArray(var P; Count: Integer);
    procedure WriteBooleanArray(var P; Count: Integer);
    procedure WriteWideStringArray(var P; Count: Integer);
    procedure WriteDateTimeArray(var P; Count: Integer);
    procedure WriteVariantArray(var P; Count: Integer);
  public
    constructor Create(AStream: TStream);
    procedure Serialize(const Value: Variant); overload;
    procedure Serialize(const Value: array of const); overload;
    procedure WriteInteger(I: Integer);
    procedure WriteLong(L: Int64); overload;
{$IFDEF DELPHI2009_UP}
    procedure WriteLong(L: UInt64); overload;
{$ENDIF}
{$IFDEF FPC}
    procedure WriteLong(L: QWord); overload;
{$ENDIF}
    procedure WriteLong(const L: RawByteString); overload;
    procedure WriteDouble(D: Extended);
    procedure WriteCurrency(C: Currency);
    procedure WriteNull();
    procedure WriteEmpty();
    procedure WriteBoolean(B: Boolean);
    procedure WriteNaN();
    procedure WriteInfinity(Positive: Boolean);
    procedure WriteUTF8Char(C: WideChar);
    procedure WriteDateTime(const ADateTime: TDateTime; CheckRef: Boolean = True);
    procedure WriteBytes(const Bytes: Variant; CheckRef: Boolean = True);
    procedure WriteString(const S: WideString; CheckRef: Boolean = True);
    procedure WriteArray(const Value: Variant; CheckRef: Boolean = True); overload;
    procedure WriteArray(const Value: array of const); overload;
    procedure WriteList(AList: IList; CheckRef: Boolean = True);
    procedure WriteMap(AMap: IMap; CheckRef: Boolean = True);
    procedure WriteObject(AObject: TObject; CheckRef: Boolean = True);
    procedure Reset;
    property Stream: TStream read FStream;
  end;

  THproseFormatter = class
  public
    class function Serialize(Value: TObject): RawByteString; overload;
    class function Serialize(const Value: Variant): RawByteString; overload;
    class function Serialize(const Value: array of const): RawByteString; overload;
    class function Unserialize(const Data:RawByteString; VType: TVarType = varVariant;
      AClass: TClass = nil): Variant;
  end;

function HproseSerialize(Value: TObject): RawByteString; overload;
function HproseSerialize(const Value: Variant): RawByteString; overload;
function HproseSerialize(const Value: array of const): RawByteString; overload;
function HproseUnserialize(const Data:RawByteString; VType: TVarType = varVariant;
  AClass: TClass = nil): Variant;

implementation

uses DateUtils, Math, RTLConsts, SysConst, SysUtils, TypInfo, Variants;

type

  PSmallIntArray = ^TSmallIntArray;
  TSmallIntArray = array[0..MaxInt div Sizeof(SmallInt) - 1] of SmallInt;

  PShortIntArray = ^TShortIntArray;
  TShortIntArray = array[0..MaxInt div Sizeof(ShortInt) - 1] of ShortInt;

  PInt64Array = ^TInt64Array;
  TInt64Array = array[0..MaxInt div Sizeof(Int64) - 1] of Int64;

{$IFDEF DELPHI2009_UP}
  PUInt64Array = ^TUInt64Array;
  TUInt64Array = array[0..MaxInt div Sizeof(UInt64) - 1] of UInt64;
{$ENDIF}

{$IFDEF FPC}
  PQWordArray = ^TQWordArray;
  TQWordArray = array[0..MaxInt div Sizeof(QWord) - 1] of QWord;
{$ENDIF}

  PLongWordArray = ^TLongWordArray;
  TLongWordArray = array[0..MaxInt div Sizeof(LongWord) - 1] of LongWord;

  PSingleArray = ^TSingleArray;
  TSingleArray = array[0..MaxInt div Sizeof(Single) - 1] of Single;

  PDoubleArray = ^TDoubleArray;
  TDoubleArray = array[0..MaxInt div Sizeof(Double) - 1] of Double;

  PCurrencyArray = ^TCurrencyArray;
  TCurrencyArray = array[0..MaxInt div Sizeof(Currency) - 1] of Currency;

  PWordBoolArray = ^TWordBoolArray;
  TWordBoolArray = array[0..MaxInt div Sizeof(WordBool) - 1] of WordBool;

  PWideStringArray = ^TWideStringArray;
  TWideStringArray = array[0..MaxInt div Sizeof(WideString) - 1] of WideString;

  PDateTimeArray = ^TDateTimeArray;
  TDateTimeArray = array[0..MaxInt div Sizeof(TDateTime) - 1] of TDateTime;

  PVariantArray = ^TVariantArray;
  TVariantArray = array[0..MaxInt div Sizeof(Variant) - 1] of Variant;

  SerializeCache = record
    RefCount: Integer;
    Data: RawByteString;
  end;
  PSerializeCache = ^SerializeCache;

var
  PropertiesCache: IMap;

const
  htInteger  = 'i';
  htLong     = 'l';
  htDouble   = 'd';
  htNull     = 'n';
  htEmpty    = 'e';
  htTrue     = 't';
  htFalse    = 'f';
  htNaN      = 'N';
  htInfinity = 'I';
  htDate     = 'D';
  htTime     = 'T';
  htBytes    = 'b';
  htUTF8Char = 'u';
  htString   = 's';
  htGuid     = 'g';
  htList     = 'a';
  htMap      = 'm';
  htClass    = 'c';
  htObject   = 'o';
  htRef      = 'r';
  htError    = 'E';

  HproseTagBoolean   :array[Boolean] of AnsiChar = ('f', 't');
  HproseTagSign      :array[Boolean] of AnsiChar = ('-', '+');

function GetStoredPropList(Instance: TObject; out PropList: PPropList): Integer;
var
  I, Count: Integer;
  TempList: PPropList;
begin
  Count := GetPropList(PTypeInfo(Instance.ClassInfo), TempList);
  PropList := nil;
  Result := 0;
  if Count > 0 then
    try
      for I := 0 to Count - 1 do
        if IsStoredProp(Instance, TempList^[I]) then
          Inc(Result);
      GetMem(PropList, Result * SizeOf(Pointer));
      for I := 0 to Result - 1 do
        if IsStoredProp(Instance, TempList^[I]) then
          PropList^[I] := TempList^[I];
    finally
      FreeMem(TempList);
    end;
end;

{ GetPropValue/SetPropValue }

procedure PropertyNotFound(const Name: string);
begin
  raise EPropertyError.CreateResFmt(@SUnknownProperty, [Name]);
end;

procedure PropertyConvertError(const Name: AnsiString);
begin
  raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyType, [Name]);
end;

{$IFNDEF FPC}
{$IFNDEF DELPHI2007_UP}
type
  TAccessStyle = (asFieldData, asAccessor, asIndexedAccessor);

function GetAccessToProperty(Instance: TObject; PropInfo: PPropInfo;
  AccessorProc: Longint; out FieldData: Pointer;
  out Accessor: TMethod): TAccessStyle;
begin
  if (AccessorProc and $FF000000) = $FF000000 then
  begin  // field - Getter is the field's offset in the instance data
    FieldData := Pointer(Integer(Instance) + (AccessorProc and $00FFFFFF));
    Result := asFieldData;
  end
  else
  begin
    if (AccessorProc and $FF000000) = $FE000000 then
      // virtual method  - Getter is a signed 2 byte integer VMT offset
      Accessor.Code := Pointer(PInteger(PInteger(Instance)^ + SmallInt(AccessorProc))^)
    else
      // static method - Getter is the actual address
      Accessor.Code := Pointer(AccessorProc);

    Accessor.Data := Instance;
    if PropInfo^.Index = Integer($80000000) then  // no index
      Result := asAccessor
    else
      Result := asIndexedAccessor;
  end;
end;

function GetDynArrayProp(Instance: TObject; PropInfo: PPropInfo): Pointer;
type
  { Need a(ny) dynamic array type to force correct call setup.
    (Address of result passed in EDX) }
  TDynamicArray = array of Byte;
type
  TDynArrayGetProc = function: TDynamicArray of object;
  TDynArrayIndexedGetProc = function (Index: Integer): TDynamicArray of object;
var
  M: TMethod;
begin
  case GetAccessToProperty(Instance, PropInfo, Longint(PropInfo^.GetProc),
    Result, M) of
    asFieldData:
      Result := PPointer(Result)^;
    asAccessor:
      Result := Pointer(TDynArrayGetProc(M)());
    asIndexedAccessor:
      Result := Pointer(TDynArrayIndexedGetProc(M)(PropInfo^.Index));
  end;
end;

procedure SetDynArrayProp(Instance: TObject; PropInfo: PPropInfo;
  const Value: Pointer);
type
  TDynArraySetProc = procedure (const Value: Pointer) of object;
  TDynArrayIndexedSetProc = procedure (Index: Integer;
                                       const Value: Pointer) of object;
var
  P: Pointer;
  M: TMethod;
begin
  case GetAccessToProperty(Instance, PropInfo, Longint(PropInfo^.SetProc),
    P, M) of
    asFieldData:
      asm
        MOV    ECX, PropInfo
        MOV    ECX, [ECX].TPropInfo.PropType
        MOV    ECX, [ECX]

        MOV    EAX, [P]
        MOV    EDX, Value
        CALL   System.@DynArrayAsg
      end;
    asAccessor:
      TDynArraySetProc(M)(Value);
    asIndexedAccessor:
      TDynArrayIndexedSetProc(M)(PropInfo^.Index, Value);
  end;
end;
{$ENDIF}
{$ELSE}
function GetDynArrayProp(Instance: TObject; PropInfo: PPropInfo): Pointer;
type
  { Need a(ny) dynamic array type to force correct call setup.
    (Address of result passed in EDX) }
  TDynamicArray = array of Byte;
type
  TDynArrayGetProc = function: TDynamicArray of object;
  TDynArrayIndexedGetProc = function (Index: Integer): TDynamicArray of object;
var
  AMethod: TMethod;
begin
  case (PropInfo^.PropProcs) and 3 of
    ptfield:
      Result := PPointer(Pointer(Instance) + PtrUInt(PropInfo^.GetProc))^;
    ptstatic,
    ptvirtual:
    begin
      if (PropInfo^.PropProcs and 3) = ptStatic then
        AMethod.Code := PropInfo^.GetProc
      else
        AMethod.Code := PPointer(Pointer(Instance.ClassType) + PtrUInt(PropInfo^.GetProc))^;
      AMethod.Data := Instance;
      if ((PropInfo^.PropProcs shr 6) and 1) <> 0 then
        Result := TDynArrayIndexedGetProc(AMethod)(PropInfo^.Index)
      else
        Result := TDynArrayGetProc(AMethod)();
    end;
  end;
end;

procedure SetDynArrayProp(Instance: TObject; PropInfo: PPropInfo;
  const Value: Pointer);
type
  TDynArraySetProc = procedure (const Value: Pointer) of object;
  TDynArrayIndexedSetProc = procedure (Index: Integer;
                                       const Value: Pointer) of object;
var
  AMethod: TMethod;
begin
  case (PropInfo^.PropProcs shr 2) and 3 of
    ptfield:
      PPointer(Pointer(Instance) + PtrUInt(PropInfo^.SetProc))^ := Value;
    ptstatic,
    ptvirtual:
    begin
      if ((PropInfo^.PropProcs shr 2) and 3) = ptStatic then
        AMethod.Code := PropInfo^.SetProc
      else
        AMethod.Code := PPointer(Pointer(Instance.ClassType) + PtrUInt(PropInfo^.SetProc))^;
      AMethod.Data := Instance;
      if ((PropInfo^.PropProcs shr 6) and 1) <> 0 then
        TDynArrayIndexedSetProc(AMethod)(PropInfo^.Index, Value)
      else
        TDynArraySetProc(AMethod)(Value);
    end;
  end;
end;
function GetInterfaceProp(Instance: TObject; PropInfo: PPropInfo): IInterface;
type
  TInterfaceGetProc = function: IInterface of object;
  TInterfaceIndexedGetProc = function (Index: Integer): IInterface of object;
var
  P: ^IInterface;
  AMethod: TMethod;
begin
  case (PropInfo^.PropProcs) and 3 of
    ptfield:
    begin
      P := Pointer(Pointer(Instance) + PtrUInt(PropInfo^.GetProc));
      Result := P^; // auto ref count
    end;
    ptstatic,
    ptvirtual:
    begin
      if (PropInfo^.PropProcs and 3) = ptStatic then
        AMethod.Code := PropInfo^.GetProc
      else
        AMethod.Code := PPointer(Pointer(Instance.ClassType) + PtrUInt(PropInfo^.GetProc))^;
      AMethod.Data := Instance;
      if ((PropInfo^.PropProcs shr 6) and 1) <> 0 then
        Result := TInterfaceIndexedGetProc(AMethod)(PropInfo^.Index)
      else
        Result := TInterfaceGetProc(AMethod)();
    end;
  end;
end;

procedure SetInterfaceProp(Instance: TObject; PropInfo: PPropInfo;
  const Value: IInterface);
type
  TInterfaceSetProc = procedure (const Value: IInterface) of object;
  TInterfaceIndexedSetProc = procedure (Index: Integer;
                                       const Value: IInterface) of object;
var
  P: ^IInterface;
  AMethod: TMethod;
begin
  case (PropInfo^.PropProcs shr 2) and 3 of
    ptfield:
    begin
      P := Pointer(Pointer(Instance) + PtrUInt(PropInfo^.SetProc));
      P^ := Value; // auto ref count
    end;
    ptstatic,
    ptvirtual:
    begin
      if ((PropInfo^.PropProcs shr 2) and 3) = ptStatic then
        AMethod.Code := PropInfo^.SetProc
      else
        AMethod.Code := PPointer(Pointer(Instance.ClassType) + PtrUInt(PropInfo^.SetProc))^;
      AMethod.Data := Instance;
      if ((PropInfo^.PropProcs shr 6) and 1) <> 0 then
        TInterfaceIndexedSetProc(AMethod)(PropInfo^.Index, Value)
      else
        TInterfaceSetProc(AMethod)(Value);
    end;
  end;
end;
{$ENDIF}

function GetPropValue(Instance: TObject; PropInfo: PPropInfo): Variant;
var
  PropType: PTypeInfo;
  DynArray: Pointer;
begin
  // assume failure
  Result := Null;
  PropType := PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF};
  case PropType^.Kind of
    tkInteger:
      Result := GetOrdProp(Instance, PropInfo);
    tkWChar:
      Result := WideString(WideChar(GetOrdProp(Instance, PropInfo)));
    tkChar:
      Result := AnsiChar(GetOrdProp(Instance, PropInfo));
    tkEnumeration:
      if GetTypeData(PropType)^.BaseType{$IFNDEF FPC}^{$ENDIF} = TypeInfo(Boolean) then
        Result := Boolean(GetOrdProp(Instance, PropInfo))
      else
        Result := GetOrdProp(Instance, PropInfo);
    tkSet:
      Result := GetOrdProp(Instance, PropInfo);
    tkFloat:
      if (LowerCase(string(PropType^.Name)) = 'tdatetime') then
        Result := VarAsType(GetFloatProp(Instance, PropInfo), varDate)
      else
        Result := GetFloatProp(Instance, PropInfo);
    tkString, {$IFDEF FPC}tkAString, {$ENDIF}tkLString:
      Result := GetStrProp(Instance, PropInfo);
    tkWString:
      Result := GetWideStrProp(Instance, PropInfo);
{$IFDEF DELPHI2009_UP}
    tkUString:
      Result := GetUnicodeStrProp(Instance, PropInfo);
{$ENDIF}
    tkVariant:
      Result := GetVariantProp(Instance, PropInfo);
    tkInt64:
{$IFDEF DELPHI2009_UP}
    if (LowerCase(string(PropType^.Name)) = 'uint64') then
      Result := UInt64(GetInt64Prop(Instance, PropInfo))
    else
{$ENDIF}
      Result := GetInt64Prop(Instance, PropInfo);
{$IFDEF FPC}
    tkBool:
      Result := Boolean(GetOrdProp(Instance, PropInfo));
    tkQWord:
      Result := QWord(GetInt64Prop(Instance, PropInfo));
{$ENDIF}
    tkInterface:
      Result := GetInterfaceProp(Instance, PropInfo);
    tkDynArray:
      begin
        DynArray := GetDynArrayProp(Instance, PropInfo);
        DynArrayToVariant(Result, DynArray, PropType);
      end;
    tkClass:
      Result := ObjToVar(GetObjectProp(Instance, PropInfo));
  else
    PropertyConvertError(PropType^.Name);
  end;
end;

procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo;
  const Value: Variant);
var
  PropType: PTypeInfo;
  TypeData: PTypeData;
  Obj: TObject;
  DynArray: Pointer;
begin
  PropType := PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF};
  TypeData := GetTypeData(PropType);
  // set the right type
  case PropType^.Kind of
    tkInteger, tkChar, tkWChar, tkEnumeration, tkSet:
      SetOrdProp(Instance, PropInfo, Value);
{$IFDEF FPC}
    tkBool:
      SetOrdProp(Instance, PropInfo, Value);
    tkQWord:
      SetInt64Prop(Instance, PropInfo, QWord(Value));
{$ENDIF}
    tkFloat:
      SetFloatProp(Instance, PropInfo, Value);
    tkString, {$IFDEF FPC}tkAString, {$ENDIF}tkLString:
      SetStrProp(Instance, PropInfo, VarToStr(Value));
    tkWString:
      SetWideStrProp(Instance, PropInfo, VarToWideStr(Value));
{$IFDEF DELPHI2009_UP}
    tkUString:
      SetUnicodeStrProp(Instance, PropInfo, VarToStr(Value)); //SB: ??
    tkInt64:
      SetInt64Prop(Instance, PropInfo, Value);
{$ELSE}
    tkInt64:
      SetInt64Prop(Instance, PropInfo, TVarData(VarAsType(Value, varInt64)).VInt64);
{$ENDIF}
    tkVariant:
      SetVariantProp(Instance, PropInfo, Value);
    tkInterface:
      SetInterfaceProp(Instance, PropInfo, Value);
    tkDynArray:
      begin
        DynArray := nil; // "nil array"
        if VarIsNull(Value) or (VarArrayHighBound(Value, 1) >= 0) then begin
          DynArrayFromVariant(DynArray, Value, PropType);
        end;
        SetDynArrayProp(Instance, PropInfo, DynArray);
{$IFNDEF FPC}
        DynArrayClear(DynArray, PropType);
{$ENDIF}
      end;
    tkClass:
      if VarIsNull(Value) then
        SetOrdProp(Instance, PropInfo, 0)
      else if VarIsObj(Value) then begin
        Obj := VarToObj(Value);
        if (Obj.ClassType.InheritsFrom(TypeData^.ClassType)) then
          SetObjectProp(Instance, PropInfo, Obj)
        else
          PropertyConvertError(PropType^.Name);
      end
      else
        PropertyConvertError(PropType^.Name);
  else
    PropertyConvertError(PropType^.Name);
  end;
end;

function GetVarTypeAndClass(TypeInfo: PTypeInfo; out AClass: TClass): TVarType;
var
  TypeData: PTypeData;
  TypeName: string;
begin
  Result := varVariant;
  AClass := nil;
  TypeName := LowerCase(string(TypeInfo^.Name));
  if TypeName = 'boolean' then
    Result := varBoolean
  else if TypeName = 'tdatetime' then
    Result := varDate
{$IFDEF DELPHI2009_UP}
  else if TypeName = 'uint64' then
    Result := varUInt64
{$ENDIF}
  else begin
    TypeData := GetTypeData(TypeInfo);
    case TypeInfo^.Kind of
      tkInteger, tkEnumeration, tkSet:
        case TypeData^.OrdType of
          otSByte:
            Result := varShortInt;
          otUByte:
            Result := varByte;
          otSWord:
            Result := varSmallInt;
          otUWord:
            Result := varWord;
          otSLong:
            Result := varInteger;
          otULong:
            Result := varLongWord;
        end;
      tkChar: begin
        AClass := TObject;
        Result := varByte;
      end;
      tkWChar: begin
        AClass := TObject;
        Result := varWord;
      end;
{$IFDEF FPC}
      tkBool:
        Result := varBoolean;
      tkQWord:
        Result := varQWord;
{$ENDIF}
      tkFloat:
        case TypeData^.FloatType of
          ftSingle:
            Result := varSingle;
          ftDouble:
            Result := varDouble;
          ftCurr:
            Result := varCurrency;
        end;
      tkString, {$IFDEF FPC}tkAString, {$ENDIF}tkLString:
        Result := varString;
      tkWString:
        Result := varOleStr;
{$IFDEF DELPHI2009_UP}
      tkUString:
        Result := varUString;
{$ENDIF}
      tkInt64:
        Result := varInt64;
      tkInterface:
        Result := varUnknown;
      tkDynArray:
        Result := TypeData.varType;
      tkClass:
        AClass := TypeData.ClassType;
    end;
  end;
end;

function StrToByte(const S:string): Byte; overload;
begin
  if Length(S) = 1 then
    Result := Ord(S[1])
  else
    Result := Byte(StrToInt(S));
end;

function OleStrToWord(const S:WideString): Word; overload;
begin
  if Length(S) = 1 then
    Result := Ord(S[1])
  else
    Result := Word(StrToInt(S));
end;

type
  TAnsiCharSet = set of AnsiChar;

function CharInSet(C: WideChar; const CharSet: TAnsiCharSet): Boolean;
begin
  Result := (C < #$0100) and (AnsiChar(C) in CharSet);
end;

{ THproseReader }

procedure THproseReader.CheckTag(ExpectTag: AnsiChar);
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  if Tag <> expectTag then
    raise EHproseException.Create('Tag "' + ExpectTag + '" expected, but "' +
                                  string(Tag) + '" found in stream');
end;

function THproseReader.CheckTags(const ExpectTags: RawByteString): AnsiChar;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  if Pos(Tag, ExpectTags) = 0 then
    raise EHproseException.Create('Tags "' + string(ExpectTags) + '" expected, but "' +
                                  string(Tag) + '" found in stream');
  Result := Tag;
end;

constructor THproseReader.Create(AStream: TStream);
begin
  FStream := AStream;
  FRefList := TArrayList.Create(False);
  FClassRefList := TArrayList.Create(False);
  FAttrRefMap := THashMap.Create(False);
end;

destructor THproseReader.Destroy;
var
  I: Integer;
  R: Variant;
begin
  FAttrRefMap.Clear;
  for I := 0 to FClassRefList.Count - 1 do begin
    R := FClassRefList[I];
    if VarIsObj(R) then VarToObj(R).Free;
  end;
  inherited Destroy;
end;

function THproseReader.ReadBoolean: Boolean;
begin
  Result := CheckTags(HproseTagTrue + HproseTagFalse) = HproseTagTrue;
end;


function THproseReader.ReadByte: Byte;
begin
  FStream.ReadBuffer(Result, 1);
end;

function THproseReader.ReadBytes(IncludeTag: Boolean): Variant;
var
  Len: Integer;
  P: PByteArray;
begin
  if IncludeTag and
     (CheckTags(HproseTagBytes + HproseTagRef) = HproseTagRef) then begin
    Result := ReadRef();
    Exit;
  end;
  Len := ReadInt(HproseTagQuote);
  Result := VarArrayCreate([0, Len - 1], varByte);
  P := VarArrayLock(Result);
  FStream.ReadBuffer(P^[0], Len);
  VarArrayUnLock(Result);
  CheckTag(HproseTagQuote);
{$IFDEF FPC}
  FRefList.Add(Result);
{$ELSE}
  FRefList.Add(VarArrayRef(Result));
{$ENDIF}
end;

procedure THproseReader.ReadBytesRaw(const OStream: TStream; Tag: AnsiChar);
var
  Len: Integer;
begin
  OStream.WriteBuffer(Tag, 1);
  Len := 0;
  Tag := '0';
  repeat
    Len := Len * 10 + (Ord(Tag) - Ord('0'));
    FStream.ReadBuffer(Tag, 1);
    OStream.WriteBuffer(Tag, 1);
  until (Tag = HproseTagQuote);
  OStream.CopyFrom(FStream, Len + 1);
end;

function THproseReader.ReadCurrency(IncludeTag: Boolean): Currency;
begin
  if IncludeTag then
    CheckTags(HproseTagInteger + HproseTagLong + HproseTagDouble);
  Result := StrToCurr(ReadUntil(HproseTagSemicolon));
end;

function THproseReader.ReadDate(IncludeTag: Boolean): TDateTime;
var
  Tag, Year, Month, Day, Hour, Minute, Second, Millisecond: Integer;
begin
  if IncludeTag and
     (CheckTags(HproseTagDate + HproseTagRef) = HproseTagRef) then begin
    Result := ReadRef;
    Exit;
  end;
  Year := ReadByte - Ord('0');
  Year := Year * 10 + ReadByte - Ord('0');
  Year := Year * 10 + ReadByte - Ord('0');
  Year := Year * 10 + ReadByte - Ord('0');
  Month := ReadByte - Ord('0');
  Month := Month * 10 + ReadByte - Ord('0');
  Day := ReadByte - Ord('0');
  Day := Day * 10 + ReadByte - Ord('0');
  Tag := ReadByte;
  if Tag = Ord(HproseTagTime) then begin
    Hour := ReadByte - Ord('0');
    Hour := Hour * 10 + ReadByte - Ord('0');
    Minute := ReadByte - Ord('0');
    Minute := Minute * 10 + ReadByte - Ord('0');
    Second := ReadByte - Ord('0');
    Second := Second * 10 + ReadByte - Ord('0');
    Millisecond := 0;
    if ReadByte = Ord(HproseTagPoint) then begin
      Millisecond := ReadByte - Ord('0');
      Millisecond := Millisecond * 10 + ReadByte - Ord('0');
      Millisecond := Millisecond * 10 + ReadByte - Ord('0');
      Tag := ReadByte;
      if (Tag >= Ord('0')) and (Tag <= Ord('9')) then begin
        ReadByte;
        ReadByte;
        Tag := ReadByte;
        if (Tag >= Ord('0')) and (Tag <= Ord('9')) then begin
          ReadByte;
          ReadByte;
          ReadByte;
        end;
      end;
    end;
    Result := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, Millisecond);
  end
  else
    Result := EncodeDate(Year, Month, Day);
  FRefList.Add(Result);
end;

function THproseReader.ReadDouble(IncludeTag: Boolean): Extended;
var
  Tag: AnsiChar;
begin
  if IncludeTag then begin
    Tag := CheckTags(HproseTagInteger +
                     HproseTagLong +
                     HproseTagDouble +
                     HproseTagNaN +
                     HproseTagInfinity);
    if Tag = HproseTagNaN then begin
      Result := NaN;
      Exit;
    end;
    if Tag = HproseTagInfinity then begin
      Result := ReadInfinity(False);
      Exit;
    end;
  end;
  Result := StrToFloat(ReadUntil(HproseTagSemicolon));
end;

function THproseReader.ReadInfinity(IncludeTag: Boolean): Extended;
begin
  if IncludeTag then CheckTag(HproseTagInfinity);
  if ReadByte = Ord(HproseTagNeg) then
    Result := NegInfinity
  else
    Result := Infinity;
end;

procedure THproseReader.ReadInfinityRaw(const OStream: TStream; Tag: AnsiChar);
begin
  OStream.WriteBuffer(Tag, 1);
  FStream.ReadBuffer(Tag, 1);
  OStream.WriteBuffer(Tag, 1);
end;

function THproseReader.ReadInteger(IncludeTag: Boolean): Integer;
begin
  if IncludeTag then CheckTag(HproseTagInteger);
  Result := ReadInt(HproseTagSemicolon);
end;

function THproseReader.ReadLong(IncludeTag: Boolean): Variant;
begin
  if IncludeTag then CheckTags(HproseTagInteger + HproseTagLong);
  Result := ReadUntil(HproseTagSemicolon);
end;

function THproseReader.ReadNaN: Extended;
begin
  CheckTag(HproseTagNaN);
  Result := NaN;
end;

function THproseReader.ReadNull: Variant;
begin
  CheckTag(HproseTagNull);
  Result := Null;
end;

procedure THproseReader.ReadNumberRaw(const OStream: TStream; Tag: AnsiChar);
begin
  OStream.WriteBuffer(Tag, 1);
  repeat
    FStream.ReadBuffer(Tag, 1);
    OStream.WriteBuffer(Tag, 1);
  until (Tag = HproseTagSemicolon);
end;

function THproseReader.ReadEmpty: Variant;
begin
  CheckTag(HproseTagEmpty);
  Result := '';
end;

function THproseReader.ReadString(IncludeTag, IncludeRef: Boolean): WideString;
var
  Count, I: Integer;
  C, C2, C3, C4: LongWord;
begin
  if IncludeTag and
    (CheckTags(HproseTagString + HproseTagRef) = HproseTagRef) then begin
    Result := ReadRef;
    Exit;
  end;
  Count := ReadInt(HproseTagQuote);
  SetLength(Result, Count);
  I := 0;
  while I < Count do begin
    Inc(I);
    C := ReadByte;
    case C shr 4 of
      0..7: { 0xxx xxxx } Result[I] := WideChar(C);
      12,13: begin
        { 110x xxxx   10xx xxxx }
        C2 := ReadByte;
        Result[I] := WideChar(((C and $1F) shl 6) or
                              (C2 and $3F));
      end;
      14: begin
        { 1110 xxxx  10xx xxxx  10xx xxxx }
        C2 := ReadByte;
        C3 := ReadByte;
        Result[I] := WideChar(((C and $0F) shl 12) or
                             ((C2 and $3F) shl 6)  or
                              (C3 and $3F));
      end;
      15: begin
        { 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx }
        if (C and $F) <= 4 then begin
          C2 := ReadByte;
          C3 := ReadByte;
          C4 := ReadByte;
          C := ((C and $07) shl 18) or
              ((C2 and $3F) shl 12) or
              ((C3 and $3F) shl 6)  or
               (C4 and $3F) - $10000;
          if C <= $FFFFF then begin
            Result[I] := WideChar(((C shr 10) and $03FF) or $D800);
            Inc(I);
            Result[I] := WideChar((C and $03FF) or $DC00);
            Continue;
          end;
        end;
        raise EHproseException.Create('bad unicode encoding at $' + IntToHex(C, 4));
      end;
    else
      raise EHproseException.Create('bad unicode encoding at $' + IntToHex(C, 4));
    end;
  end;
  CheckTag(HproseTagQuote);
  if IncludeRef then FRefList.Add(Result);
end;

procedure THproseReader.ReadStringRaw(const OStream: TStream; Tag: AnsiChar);
var
  Len, I: Integer;
begin
  OStream.WriteBuffer(Tag, 1);
  Len := 0;
  Tag := '0';
  repeat
    Len := Len * 10 + (Ord(Tag) - Ord('0'));
    FStream.ReadBuffer(Tag, 1);
    OStream.WriteBuffer(Tag, 1);
  until (Tag = HproseTagQuote);
  { When I = Len, Read & Write HproseTagQuote }
  for I := 0 to Len do begin
    FStream.ReadBuffer(Tag, 1);
    case Ord(Tag) shr 4 of
      0..7: OStream.WriteBuffer(Tag, 1);
      12,13: begin
        OStream.WriteBuffer(Tag, 1);
        FStream.ReadBuffer(Tag, 1);
        OStream.WriteBuffer(Tag, 1);
      end;
      14: begin
        OStream.WriteBuffer(Tag, 1);
        FStream.ReadBuffer(Tag, 1);
        OStream.WriteBuffer(Tag, 1);
        FStream.ReadBuffer(Tag, 1);
        OStream.WriteBuffer(Tag, 1);
      end;
      15: begin
        if (Ord(Tag) and $F) <= 4 then begin
          OStream.WriteBuffer(Tag, 1);
          FStream.ReadBuffer(Tag, 1);
          OStream.WriteBuffer(Tag, 1);
          FStream.ReadBuffer(Tag, 1);
          OStream.WriteBuffer(Tag, 1);
          FStream.ReadBuffer(Tag, 1);
          OStream.WriteBuffer(Tag, 1);
          Continue;
        end;
        raise EHproseException.Create('bad unicode encoding at $' +
                                      IntToHex(Ord(Tag), 4));
      end;
    else
      raise EHproseException.Create('bad unicode encoding at $' +
                                    IntToHex(Ord(Tag), 4));
    end;
  end;
end;

function THproseReader.ReadTime(IncludeTag: Boolean): TDateTime;
var
  Tag, Hour, Minute, Second, Millisecond: Integer;
begin
  if IncludeTag and
     (CheckTags(HproseTagTime + HproseTagRef) = HproseTagRef) then begin
    Result := ReadRef;
    Exit;
  end;
  Hour := ReadByte - Ord('0');
  Hour := Hour * 10 + ReadByte - Ord('0');
  Minute := ReadByte - Ord('0');
  Minute := Minute * 10 + ReadByte - Ord('0');
  Second := ReadByte - Ord('0');
  Second := Second * 10 + ReadByte - Ord('0');
  Millisecond := 0;
  if ReadByte = Ord(HproseTagPoint) then begin
    Millisecond := ReadByte - Ord('0');
    Millisecond := Millisecond * 10 + ReadByte - Ord('0');
    Millisecond := Millisecond * 10 + ReadByte - Ord('0');
    Tag := ReadByte;
    if (Tag >= Ord('0')) and (Tag <= Ord('9')) then begin
      ReadByte;
      ReadByte;
      Tag := ReadByte;
      if (Tag >= Ord('0')) and (Tag <= Ord('9')) then begin
        ReadByte;
        ReadByte;
        ReadByte;
      end;
    end;
  end;
  Result := EncodeTime(Hour, Minute, Second, Millisecond);
  FRefList.Add(Result);
end;

function THproseReader.ReadUntil(Tag: AnsiChar): string;
var
  S: TStringBuffer;
  C: AnsiChar;
begin
  S := TStringBuffer.Create();
  try
    while (FStream.Read(C, 1) = 1) and (C <> Tag) do S.Write(C, 1);
    Result := S.ToString;
  finally
    S.Free;
  end;
end;

function THproseReader.ReadUTF8Char(IncludeTag: Boolean): WideChar;
var
  C, C2, C3: LongWord;
begin
  if IncludeTag then CheckTag(HproseTagUTF8Char);
  C := ReadByte;
  case C shr 4 of
    0..7: { 0xxx xxxx } Result := WideChar(C);
    12,13: begin
      { 110x xxxx   10xx xxxx }
      C2 := ReadByte;
      Result := WideChar(((C and $1F) shl 6) or
                          (C2 and $3F));
    end;
    14: begin
      { 1110 xxxx  10xx xxxx  10xx xxxx }
      C2 := ReadByte;
      C3 := ReadByte;
      Result := WideChar(((C and $0F) shl 12) or
                         ((C2 and $3F) shl 6) or
                          (C3 and $3F));
    end;
  else
    raise EHproseException.Create('bad unicode encoding at $' + IntToHex(C, 4));
  end;
end;

procedure THproseReader.ReadUTF8CharRaw(const OStream: TStream; Tag: AnsiChar);
begin
  OStream.WriteBuffer(Tag, 1);
  FStream.ReadBuffer(Tag, 1);
  case Ord(Tag) shr 4 of
    0..7: OStream.WriteBuffer(Tag, 1);
    12,13: begin
      OStream.WriteBuffer(Tag, 1);
      FStream.ReadBuffer(Tag, 1);
      OStream.WriteBuffer(Tag, 1);
    end;
    14: begin
      OStream.WriteBuffer(Tag, 1);
      FStream.ReadBuffer(Tag, 1);
      OStream.WriteBuffer(Tag, 1);
      FStream.ReadBuffer(Tag, 1);
      OStream.WriteBuffer(Tag, 1);
    end;
  else
    raise EHproseException.Create('bad unicode encoding at $' +
                                  IntToHex(Ord(Tag), 4));
  end;
end;

function THproseReader.ReadInt(Tag: AnsiChar): Integer;
var
  S: Integer;
  I: Integer;
  C: AnsiChar;
begin
  Result := 0;
  S := 1;
  I := FStream.Read(C, 1);
  if I = 1 then
    if C = '+' then
      I := FStream.Read(C, 1)
    else if C = '-' then begin
      S := -1;
      I := FStream.Read(C, 1);
    end;
  while (I = 1) and (C <> Tag) do begin
    Result := Result * 10 + (Ord(C) - Ord('0')) * S;
    I := FStream.Read(C, 1);
  end
end;

function THproseReader.ReadInt64(Tag: AnsiChar): Int64;
var
  S: Int64;
  I: Integer;
  C: AnsiChar;
begin
  Result := 0;
  S := 1;
  I := FStream.Read(C, 1);
  if I = 1 then
    if C = '+' then
      I := FStream.Read(C, 1)
    else if C = '-' then begin
      S := -1;
      I := FStream.Read(C, 1);
    end;
  while (I = 1) and (C <> Tag) do begin
    Result := Result * 10 + Int64(Ord(C) - Ord('0')) * S;
    I := FStream.Read(C, 1);
  end
end;

{$IF Defined(DELPHI2009_UP) or Defined(FPC)}
function THproseReader.ReadUInt64(Tag: AnsiChar): UInt64;
var
  I: Integer;
  C: AnsiChar;
begin
  Result := 0;
  I := FStream.Read(C, 1);
  if (I = 1) and (C = '+') then I := FStream.Read(C, 1);
  while (I = 1) and (C <> Tag) do begin
    Result := Result * 10 + UInt64(Ord(C) - Ord('0'));
    I := FStream.Read(C, 1);
  end
end;
{$IFEND}

function THproseReader.Unserialize(VType: TVarType;
  AClass: TClass): Variant;
var
  Tag: AnsiChar;
begin
  if FStream.Read(Tag, 1) < 1 then
    raise EHproseException.Create('No byte found in stream');
  Result := Unserialize(Tag, VType, AClass);
end;

function THproseReader.Unserialize(Tag: AnsiChar; VType: TVarType;
  AClass: TClass): Variant;
begin
  case Tag of
    '0'..'9': begin
      case VType of
        varInteger, varVariant: Result := Ord(Tag) - Ord('0');
        varByte: Result := Byte(Ord(Tag) - Ord('0'));
        varShortInt: Result := ShortInt(Ord(Tag) - Ord('0'));
        varWord: Result := Word(Ord(Tag) - Ord('0'));
        varSmallint: Result := Smallint(Ord(Tag) - Ord('0'));
        varLongWord: Result := LongWord(Ord(Tag) - Ord('0'));
        varSingle: Result := VarAsType(Ord(Tag) - Ord('0'), varSingle);
        varDouble: Result := VarAsType(Ord(Tag) - Ord('0'), varDouble);
        varCurrency: Result := StrToCurr(string(Tag));
        varInt64: Result := Int64(Ord(Tag) - Ord('0'));
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := UInt64(Ord(Tag) - Ord('0'));
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := QWord(Ord(Tag) - Ord('0'));
{$ENDIF}
        varString: Result := AnsiString(Tag);
{$IFDEF DELPHI2009_UP}
        varUString: Result := UnicodeString(Tag);
{$ENDIF}
        varOleStr: Result := WideString(Tag);
        varBoolean: Result := Tag <> '0';
        varDate: Result := TimeStampToDateTime(MSecsToTimeStamp(
                           Ord(Tag) - Ord('0')));
      else
        Error(reInvalidCast);
      end;
    end;
    htInteger: begin
      case VType of
        varInteger, varVariant: Result := ReadInteger(False);
        varByte: Result := Byte(ReadInteger(False));
        varShortInt: Result := ShortInt(ReadInteger(False));
        varWord: Result := Word(ReadInteger(False));
        varSmallint: Result := Smallint(ReadInteger(False));
        varLongWord: Result := LongWord(ReadInteger(False));
        varSingle: Result := VarAsType(ReadInteger(False), varSingle);
        varDouble: Result := VarAsType(ReadInteger(False), varDouble);
        varCurrency: Result := StrToCurr(ReadUntil(HproseTagSemicolon));
        varInt64: Result := ReadInt64(HproseTagSemicolon);
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := ReadUInt64(HproseTagSemicolon);
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := ReadUInt64(HproseTagSemicolon);
{$ENDIF}
        varString: Result := ReadUntil(HproseTagSemicolon);
{$IFDEF DELPHI2009_UP}
        varUString: Result := ReadUntil(HproseTagSemicolon);
{$ENDIF}
        varOleStr: Result := WideString(ReadUntil(HproseTagSemicolon));
        varBoolean: Result := ReadInteger(False) <> 0;
        varDate: Result := TimeStampToDateTime(MSecsToTimeStamp(
                           ReadInteger(False)));
      else
        Error(reInvalidCast);
      end;
    end;
    htLong: begin
      case VType of
        varString, varVariant: Result := ReadLong(False);
{$IFDEF DELPHI2009_UP}
        varUString: Result := ReadLong(False);
{$ENDIF}
        varInteger: Result := ReadInteger(False);
        varByte: Result := Byte(ReadInteger(False));
        varShortInt: Result := ShortInt(ReadInteger(False));
        varWord: Result := Word(ReadInteger(False));
        varSmallint: Result := Smallint(ReadInteger(False));
        varLongWord: Result := LongWord(ReadInt64(HproseTagSemicolon));
        varSingle: Result := VarAsType(StrToFloat(ReadLong(False)), varSingle);
        varDouble: Result := VarAsType(StrToFloat(ReadLong(False)), varDouble);
        varCurrency: Result := StrToCurr(ReadUntil(HproseTagSemicolon));
        varInt64: Result := ReadInt64(HproseTagSemicolon);
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := ReadUInt64(HproseTagSemicolon);
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := ReadUInt64(HproseTagSemicolon);
{$ENDIF}
        varOleStr: Result := WideString(ReadUntil(HproseTagSemicolon));
        varBoolean: Result := ReadLong(False) <> '0';
        varDate: Result := TimeStampToDateTime(MSecsToTimeStamp(
                           StrToInt64(ReadLong(False))));
      else
        Error(reInvalidCast);
      end;
    end;
    htDouble: begin
      case VType of
        varDouble, varVariant: Result := VarAsType(ReadDouble(False), varDouble);
        varSingle: Result := VarAsType(ReadDouble(False), varSingle);
        varCurrency: Result := ReadCurrency(False);
        varInteger: Result := ReadInteger(False);
        varByte: Result := Byte(ReadInteger(False));
        varShortInt: Result := ShortInt(ReadInteger(False));
        varWord: Result := Word(ReadInteger(False));
        varSmallint: Result := Smallint(ReadInteger(False));
        varLongWord: Result := LongWord(ReadInt64(HproseTagSemicolon));
        varInt64: Result := ReadInt64(HproseTagSemicolon);
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := ReadUInt64(HproseTagSemicolon);
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := ReadUInt64(HproseTagSemicolon);
{$ENDIF}
        varString: Result := ReadUntil(HproseTagSemicolon);
{$IFDEF DELPHI2009_UP}
        varUString: Result := ReadUntil(HproseTagSemicolon);
{$ENDIF}
        varOleStr: Result := WideString(ReadUntil(HproseTagSemicolon));
        varBoolean: Result := ReadDouble(False) <> 0.0;
        varDate: Result := TimeStampToDateTime(MSecsToTimeStamp(
                           StrToInt64(ReadLong(False))));
      else
        Error(reInvalidCast);
      end;
    end;
    htNull: begin
      case VType of
        varEmpty: Result := Unassigned;
        varBoolean: Result := False;
        varSingle: Result := VarAsType(0, varSingle);
        varDouble: Result := VarAsType(0, varDouble);
        varCurrency: Result := VarAsType(0, varCurrency);
        varInteger: Result := 0;
        varByte: Result := Byte(0);
        varShortInt: Result := ShortInt(0);
        varWord: Result := Word(0);
        varSmallint: Result := Smallint(0);
        varLongWord: Result := LongWord(0);
        varInt64: Result := Int64(0);
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := UInt64(0);
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := QWord(0);
{$ENDIF}
        varString: Result := '';
{$IFDEF DELPHI2009_UP}
        varUString: Result := '';
{$ENDIF}
        varOleStr: Result := WideString('');
      else
        Result := Null;
      end;
    end;
    htEmpty: begin
      case VType of
        varEmpty: Result := Unassigned;
        varBoolean: Result := False;
        varSingle: Result := VarAsType(0, varSingle);
        varDouble: Result := VarAsType(0, varDouble);
        varCurrency: Result := VarAsType(0, varCurrency);
        varInteger: Result := 0;
        varByte: Result := Byte(0);
        varShortInt: Result := ShortInt(0);
        varWord: Result := Word(0);
        varSmallint: Result := Smallint(0);
        varLongWord: Result := LongWord(0);
        varInt64: Result := Int64(0);
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := UInt64(0);
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := QWord(0);
{$ENDIF}
        varString: Result := '';
{$IFDEF DELPHI2009_UP}
        varUString: Result := '';
{$ENDIF}
        varOleStr: Result := WideString('');
      else
        Result := '';
      end;
    end;
    htTrue: begin
      case VType of
        varBoolean, varVariant: Result := True;
        varSingle: Result := VarAsType(1, varSingle);
        varDouble: Result := VarAsType(1, varDouble);
        varCurrency: Result := VarAsType(1, varCurrency);
        varInteger: Result := 1;
        varByte: Result := Byte(1);
        varShortInt: Result := ShortInt(1);
        varWord: Result := Word(1);
        varSmallint: Result := Smallint(1);
        varLongWord: Result := LongWord(1);
        varInt64: Result := Int64(1);
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := UInt64(1);
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := QWord(1);
{$ENDIF}
        varString: Result := 'True';
{$IFDEF DELPHI2009_UP}
        varUString: Result := 'True';
{$ENDIF}
        varOleStr: Result := WideString('True');
      else
        Error(reInvalidCast);
      end;
    end;
    htFalse: begin
      case VType of
        varBoolean, varVariant: Result := False;
        varSingle: Result := VarAsType(0, varSingle);
        varDouble: Result := VarAsType(0, varDouble);
        varCurrency: Result := VarAsType(0, varCurrency);
        varInteger: Result := 0;
        varByte: Result := Byte(0);
        varShortInt: Result := ShortInt(0);
        varWord: Result := Word(0);
        varSmallint: Result := Smallint(0);
        varLongWord: Result := LongWord(0);
        varInt64: Result := Int64(0);
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := UInt64(0);
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := QWord(0);
{$ENDIF}
        varString: Result := 'False';
{$IFDEF DELPHI2009_UP}
        varUString: Result := 'False';
{$ENDIF}
        varOleStr: Result := WideString('False');
      else
        Error(reInvalidCast);
      end;
    end;
    htNaN: begin
      case VType of
        varDouble, varVariant: Result := VarAsType(NaN, varDouble);
        varSingle: Result := VarAsType(NaN, varSingle);
        varString: Result := 'NaN';
{$IFDEF DELPHI2009_UP}
        varUString: Result := 'NaN';
{$ENDIF}
        varOleStr: Result := WideString('NaN');
      else
        Error(reInvalidCast);
      end;
    end;
    htInfinity: begin
      case VType of
        varDouble, varVariant:
          if ReadByte = Ord(HproseTagNeg) then
            Result := VarAsType(NegInfinity, varDouble)
          else
            Result := VarAsType(Infinity, varDouble);
        varSingle:
          if ReadByte = Ord(HproseTagNeg) then
            Result := VarAsType(NegInfinity, varSingle)
          else
            Result := VarAsType(Infinity, varSingle);
        varString:
          if ReadByte = Ord(HproseTagNeg) then
            Result := '-Infinity'
          else
            Result := 'Infinity';
{$IFDEF DELPHI2009_UP}
        varUString:
          if ReadByte = Ord(HproseTagNeg) then
            Result := '-Infinity'
          else
            Result := 'Infinity';
{$ENDIF}
        varOleStr:
          if ReadByte = Ord(HproseTagNeg) then
            Result := WideString('-Infinity')
          else
            Result := WideString('Infinity');
      else
        Error(reInvalidCast);
      end;
    end;
    htUTF8Char: begin
      case VType of
        varOleStr, varVariant: Result := ReadUTF8Char(False);
        varString: Result := AnsiString(ReadUTF8Char(False));
{$IFDEF DELPHI2009_UP}
        varUString: Result := UnicodeString(ReadUTF8Char(False));
{$ENDIF}
        varInteger: Result := Ord(ReadUTF8Char(False));
        varByte: Result := Byte(Ord(AnsiString(ReadUTF8Char(False))[1]));
        varWord: Result := Word(Ord(ReadUTF8Char(False)));
        varShortInt: Result := VarAsType(Ord(ReadUTF8Char(False)), varShortInt);
        varSmallint: Result := VarAsType(Ord(ReadUTF8Char(False)), varSmallint);
        varLongWord: Result := VarAsType(Ord(ReadUTF8Char(False)), varLongWord);
        varSingle: Result := VarAsType(Ord(ReadUTF8Char(False)), varSingle);
        varDouble: Result := VarAsType(Ord(ReadUTF8Char(False)), varDouble);
        varCurrency: Result := VarAsType(Ord(ReadUTF8Char(False)), varCurrency);
        varInt64: Result := Int64(Ord(ReadUTF8Char(False)));
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := UInt64(Ord(ReadUTF8Char(False)));
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := UInt64(Ord(ReadUTF8Char(False)));
{$ENDIF}
        varBoolean: Result := not CharInSet(ReadUTF8Char(False), [#0, '0', 'F', 'f']);
      else
        Error(reInvalidCast);
      end;
    end;
    htString   : begin
      case VType of
        varOleStr, varVariant: Result := ReadString(False);
        varString: Result := AnsiString(ReadString(False));
{$IFDEF DELPHI2009_UP}
        varUString: Result := UnicodeString(ReadString(False));
{$ENDIF}
        varInteger: Result := StrToInt(ReadString(False));
        varByte:
          if AClass = nil then
            Result := VarAsType(ReadString(False), varByte)
          else
            Result := StrToByte(ReadString(False));
        varWord:
          if AClass = nil then
            Result := VarAsType(ReadString(False), varWord)
          else
            Result := OleStrToWord(ReadString(False));
        varShortInt: Result := VarAsType(ReadString(False), varShortInt);
        varSmallint: Result := VarAsType(ReadString(False), varSmallint);
        varLongWord: Result := VarAsType(ReadString(False), varLongWord);
        varSingle: Result := VarAsType(ReadString(False), varSingle);
        varDouble: Result := VarAsType(ReadString(False), varDouble);
        varCurrency: Result := StrToCurr(ReadString(False));
        varInt64: Result := StrToInt64(ReadString(False));
{$IFDEF DELPHI2009_UP}
        varUInt64: Result := VarAsType(ReadString(False), varUInt64);
{$ENDIF}
{$IFDEF FPC}
        varQWord: Result := VarAsType(ReadString(False), varQWord);
{$ENDIF}
        varBoolean: Result := VarAsType(ReadInteger(False), varBoolean);
      else
        Error(reInvalidCast);
      end;
    end;
    htGuid   : begin
      case VType of
        varString, varVariant: Result := ReadGuid(False);
        varOleStr: Result := WideString(ReadGuid(False));
{$IFDEF DELPHI2009_UP}
        varUString: Result := UnicodeString(ReadGuid(False));
{$ENDIF}
      else
        Error(reInvalidCast);
      end;
    end;
    htDate     : Result := ReadDate(False);
    htTime     : Result := ReadTime(False);
    htBytes    : Result := ReadBytes(False);
    htList     : Result := ReadList(VType and varTypeMask, AClass, False);
    htMap      : Result := ReadMap(AClass, False);
    htClass    : begin
      ReadClass;
      Result := Unserialize(VType, AClass);
    end;
    htObject   : Result := ReadObject(AClass, False);
    htRef      : Result := ReadRef;
    htError    : raise EHproseException.Create(ReadString());
  else
    raise EHproseException.Create('Unexpected serialize tag "' +
                                  Tag + '" in stream');
  end;
end;

function THproseReader.ReadBooleanArray(Count: Integer): Variant;
var
  P: PWordBoolArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varBoolean);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varBoolean);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadDoubleArray(Count: Integer): Variant;
var
  P: PDoubleArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varDouble);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varDouble);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadInt64Array(Count: Integer): Variant;
var
  P: PInt64Array;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varInt64);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varInt64);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadIntegerArray(Count: Integer): Variant;
var
  P: PIntegerArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varInteger);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varInteger);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadList(ElementType: TVarType;
  AClass: TClass; IncludeTag: Boolean): Variant;
var
  Count: Integer;
begin
  if IncludeTag and
    (CheckTags(HproseTagList + HproseTagRef) = HproseTagRef) then begin
    Result := ReadRef;
    Exit;
  end;
  Count := ReadInt(HproseTagOpenbrace);
  if AClass = nil then
    case ElementType of
      varInteger:  Result := ReadIntegerArray(Count);
      varShortInt: Result := ReadShortIntArray(Count);
      varWord:     Result := ReadWordArray(Count);
      varSmallint: Result := ReadSmallintArray(Count);
      varLongWord: Result := ReadLongWordArray(Count);
      varSingle:   Result := ReadSingleArray(Count);
      varDouble:   Result := ReadDoubleArray(Count);
      varCurrency: Result := ReadCurrencyArray(Count);
      varInt64:    Result := ReadInt64Array(Count);
{$IFDEF DELPHI2009_UP}
      varUInt64:   Result := ReadUInt64Array(Count);
{$ENDIF}
{$IFDEF FPC}
      varQWord:    Result := ReadQWordArray(Count);
{$ENDIF}
      varOleStr:   Result := ReadWideStringArray(Count);
      varBoolean:  Result := ReadBooleanArray(Count);
      varDate:     Result := ReadDateTimeArray(Count);
      varVariant:  Result := ReadList(TArrayList, Count);
    end
  else if AClass.InheritsFrom(TAbstractList) then begin
    Result := ReadList(AClass, Count);
  end
  else
    raise EHproseException.Create(AClass.ClassName + ' is not an IList class');
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadList(AClass: TClass; Count: Integer): Variant;
var
  I: Integer;
  AList: IList;
begin
    AList := TListClass(AClass).Create(Count) as IList;
    Result := AList;
    FRefList.Add(Result);
    for I := 0 to Count - 1 do AList[I] := Unserialize;
end;

function THproseReader.ReadLongWordArray(Count: Integer): Variant;
var
  P: PLongWordArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varLongWord);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varLongWord);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadMap(AClass: TClass; IncludeTag: Boolean): Variant;
var
  I, Count: Integer;
  Key: Variant;
  AMap: IMap;
  Instance: TObject;
  PropInfo: PPropInfo;
  VType: TVarType;
  PropClass: TClass;
begin
  if IncludeTag and
    (CheckTags(HproseTagMap + HproseTagRef) = HproseTagRef) then begin
    Result := ReadRef;
    Exit;
  end;
  Count := ReadInt(HproseTagOpenbrace);
  if AClass = nil then AClass := THashMap;
  if AClass.InheritsFrom(TAbstractMap) then begin
    AMap := TMapClass(AClass).Create(Count) as IMap;
    Result := AMap;
    FRefList.Add(Result);
    for I := 0 to Count - 1 do begin
      Key := Unserialize;
      AMap[Key] := Unserialize;
    end;
  end
  else begin
    Instance := AClass.Create;
    Result := ObjToVar(Instance);
    FRefList.Add(Result);
    for I := 0 to Count - 1 do begin
      Key := ReadString;
      PropInfo := GetPropInfo(AClass, Key);
      VType := GetVarTypeAndClass(PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF}, PropClass);
      SetPropValue(Instance, PropInfo, Unserialize(VType, PropClass));
    end;
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadObject(AClass: TClass; IncludeTag: Boolean): Variant;
var
  Tag: AnsiChar;
  C: Variant;
  AttrNames: IList;
  I, Count: Integer;
  Cls: TClass;
  AMap: IMap;
  Instance: TObject;
  PropInfo: PPropInfo;
  VType: TVarType;
  PropClass: TClass;
begin
  if IncludeTag then repeat
    Tag := CheckTags(HproseTagObject + HproseTagClass + HproseTagRef);
    if Tag = HproseTagRef then begin
      Result := ReadRef;
      Exit;
    end;
    if Tag = HproseTagClass then ReadClass;
  until Tag = HproseTagObject;
  C := FClassRefList[ReadInt(HproseTagOpenbrace)];
  AttrNames := VarToList(FAttrRefMap[C]);
  Count := AttrNames.Count;
  Instance := nil;
  if {$IFDEF CPU64}VarType(C) = varInt64{$ELSE}VarType(C) = varInteger{$ENDIF} then begin
{$IFDEF CPU64}
    Cls := TClass(Int64(C));
{$ELSE}
    Cls := TClass(Integer(C));
{$ENDIF}
    if (AClass = nil) or Cls.InheritsFrom(AClass) then Instance := Cls.Create;
  end;
  if (Instance = nil) and (AClass <> nil) then Instance := AClass.Create;
  if Instance = nil then begin
    AMap := TCaseInsensitiveHashMap.Create(Count);
    Result := AMap;
    FRefList.Add(Result);
    for I := 0 to Count - 1 do AMap[AttrNames[I]] := Unserialize;
  end
  else begin
    Result := ObjToVar(Instance);
    FRefList.Add(Result);
    for I := 0 to Count - 1 do begin
      PropInfo := GetPropInfo(Instance, AttrNames[I]);
      VType := GetVarTypeAndClass(PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF}, PropClass);
      SetPropValue(Instance, PropInfo, Unserialize(VType, PropClass));
    end;
  end;
  CheckTag(HproseTagClosebrace);  
end;

function THproseReader.ReadShortIntArray(Count: Integer): Variant;
var
  P: PShortIntArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varShortInt);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varShortInt);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadSingleArray(Count: Integer): Variant;
var
  P: PSingleArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varSingle);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varSingle);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadSmallIntArray(Count: Integer): Variant;
var
  P: PSmallIntArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varSmallInt);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varSmallInt);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadWideStringArray(Count: Integer): Variant;
var
  P: PWideStringArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varOleStr);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varOleStr);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadWordArray(Count: Integer): Variant;
var
  P: PWordArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varWord);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varWord);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadCurrencyArray(Count: Integer): Variant;
var
  P: PCurrencyArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varCurrency);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varCurrency);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

function THproseReader.ReadDateTimeArray(Count: Integer): Variant;
var
  P: PDateTimeArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varDate);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varDate);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;

procedure THproseReader.ReadDateTimeRaw(const OStream: TStream; Tag: AnsiChar);
begin
  OStream.WriteBuffer(Tag, 1);
  repeat
    FStream.ReadBuffer(Tag, 1);
    OStream.WriteBuffer(Tag, 1);
  until (Tag = HproseTagSemicolon) or
        (Tag = HproseTagUTC);
end;

{$IFDEF DELPHI2009_UP}
function THproseReader.ReadUInt64Array(Count: Integer): Variant;
var
  P: PUInt64Array;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varUInt64);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varUInt64);
  VarArrayUnlock(Result);
{$IFDEF FPC}
  FRefList[N] := Result;
{$ELSE}
  FRefList[N] := VarArrayRef(Result);
{$ENDIF}
end;
{$ENDIF}

{$IFDEF FPC}
function THproseReader.ReadQWordArray(Count: Integer): Variant;
var
  P: PQWordArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varQWord);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize(varQWord);
  VarArrayUnlock(Result);
  FRefList[N] := Result;
end;
{$ENDIF}

function THproseReader.ReadRaw: TMemoryStream;
begin
  Result := TMemoryStream.Create;
  ReadRaw(Result);
end;

procedure THproseReader.ReadRaw(const OStream: TStream);
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  ReadRaw(OStream, Tag);
end;

procedure THproseReader.ReadRaw(const OStream: TStream; Tag: AnsiChar);
begin
  case Tag of
    '0'..'9', htNull, htEmpty, htTrue, htFalse, htNaN: OStream.WriteBuffer(Tag, 1);
    htInfinity: ReadInfinityRaw(OStream, Tag);
    htInteger, htLong, htDouble, htRef: ReadNumberRaw(OStream, Tag);
    htDate, htTime: ReadDateTimeRaw(OStream, Tag);
    htUTF8Char: ReadUTF8CharRaw(OStream, Tag);
    htBytes: ReadBytesRaw(OStream, Tag);
    htString: ReadStringRaw(OStream, Tag);
    htGuid: ReadGuidRaw(OStream, Tag);
    htList, htMap, htObject: ReadComplexRaw(OStream, Tag);
    htClass: begin
      ReadComplexRaw(OStream, Tag);
      ReadRaw(OStream);
    end;
    htError: begin
      OStream.WriteBuffer(Tag, 1);
      ReadRaw(OStream);
    end;
  else
    raise EHproseException.Create('Unexpected serialize tag "' +
                                  Tag + '" in stream');
  end;
end;

function THproseReader.ReadRef: Variant;
begin
  Result := FRefList[ReadInt(HproseTagSemicolon)];
end;

procedure THproseReader.ReadClass;
var
  ClassName: string;
  I, Count: Integer;
  AttrNames: IList;
  AClass: TClass;
  Key: Variant;
begin
  ClassName := ReadString(False, False);
  Count := ReadInt(HproseTagOpenbrace);
  AttrNames := TArrayList.Create(Count, False);
  for I := 0 to Count - 1 do AttrNames[I] := ReadString();
  CheckTag(HproseTagClosebrace);
  AClass := GetClassByAlias(ClassName);
  if AClass = nil then begin
    Key := ObjToVar(TObject.Create());
    FClassRefList.Add(Key);
    FAttrRefMap[Key] := AttrNames;
  end
  else begin
{$IFDEF CPU64}
    Key := Int64(AClass);
{$ELSE}
    Key := Integer(AClass);
{$ENDIF}
    FClassRefList.Add(Key);
    FAttrRefMap[Key] := AttrNames;
  end;
end;

procedure THproseReader.ReadComplexRaw(const OStream: TStream; Tag: AnsiChar);
begin
  OStream.WriteBuffer(Tag, 1);
  repeat
    FStream.ReadBuffer(Tag, 1);
    OStream.WriteBuffer(Tag, 1);
  until (Tag = HproseTagOpenbrace);
  FStream.ReadBuffer(Tag, 1);
  while (Tag <> HproseTagClosebrace) do begin
    ReadRaw(OStream, Tag);
    FStream.ReadBuffer(Tag, 1);
  end;
  OStream.WriteBuffer(Tag, 1);
end;

function THproseReader.ReadGuid(IncludeTag: Boolean): AnsiString;
begin
  if IncludeTag and
     (CheckTags(HproseTagGuid + HproseTagRef) = HproseTagRef) then begin
    Result := AnsiString(ReadRef());
    Exit;
  end;
  SetLength(Result, 38);
  FStream.ReadBuffer(Result[1], 38);
  FRefList.Add(Result);
end;

procedure THproseReader.ReadGuidRaw(const OStream: TStream; Tag: AnsiChar);
begin
  OStream.WriteBuffer(Tag, 1);
  OStream.CopyFrom(FStream, 38);
end;

procedure THproseReader.Reset;
begin
  FRefList.Clear;
  FClassRefList.Clear;
  FAttrRefMap.Clear;
end;

{ THproseWriter }

constructor THproseWriter.Create(AStream: TStream);
begin
  FStream := AStream;
  FRefList := THashedList.Create(False);
  FClassRefList := THashedList.Create(False);
end;

procedure THproseWriter.Serialize(const Value: Variant);
var
  AList: IList;
  AMap: IMap;
  Obj: TObject;
begin
  with FindVarData(Value)^ do begin
    case VType and not varByRef of
      varEmpty, varNull :
        WriteNull;
      varBoolean :
        WriteBoolean(Value);
      varByte, varWord, varShortInt, varSmallint, varInteger:
        WriteInteger(Value);
{$IFDEF DELPHI2009_UP}
      varUInt64:
        WriteLong(RawByteString(UIntToStr(Value)));
{$ENDIF}
      {$IFDEF FPC}varQWord, {$ENDIF}
      varLongWord, varInt64:
        WriteLong(RawByteString(VarToStr(Value)));
      varSingle, varDouble:
        WriteDouble(Value);
      varCurrency:
        WriteCurrency(Value);
      varString, {$IFDEF DELPHI2009_UP}varUString, {$ENDIF}varOleStr:
        if Length(Value) = 0 then
          WriteEmpty
        else if Length(Value) = 1 then
          WriteUTF8Char(VarToWideStr(Value)[1])
        else
          WriteString(Value);
      varDate:
        WriteDateTime(Value);
      varUnknown:
        if Supports(IInterface(Value), IList, AList) then
          WriteList(AList)
        else if Supports(IInterface(Value), IMap, AMap) then
          WriteMap(AMap)
        else
          WriteNull;
    else
      if VType and varArray = varArray then
        if (VType and varTypeMask = varByte) and
           (VarArrayDimCount(Value) = 1) then
          WriteBytes(Value)
        else
          WriteArray(Value)
      else if VType and not varByRef = varObject then begin
        Obj := VarToObj(Value);
        if Obj = nil then WriteNull
        else if Obj is TAbstractList then WriteList(TAbstractList(Obj))
        else if Obj is TAbstractMap then WriteMap(TAbstractMap(Obj))
        else WriteObject(Obj);
      end
    end;
  end;
end;

procedure THproseWriter.Serialize(const Value: array of const);
begin
  WriteArray(Value);
end;

procedure THproseWriter.WriteRawByteString(const S: RawByteString);
begin
  FStream.WriteBuffer(S[1], Length(S));
end;


procedure THproseWriter.WriteArray(const Value: array of const);
var
  I, N: Integer;
  AList: IList;
  AMap: IMap;
begin
  FRefList.Add(Null);
  N := Length(Value);
  FStream.WriteBuffer(HproseTagList, 1);
  if N > 0 then WriteRawByteString(RawByteString(IntToStr(N)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for I := 0 to N - 1 do
    with Value[I] do
      case VType of
      vtInteger:       WriteInteger(VInteger);
      vtBoolean:       WriteBoolean(VBoolean);
      vtChar:          WriteUTF8Char(WideString(VChar)[1]);
      vtExtended:      WriteDouble(VExtended^);
      vtString:        WriteString(WideString(VString^));
      vtPChar:         WriteString(WideString(AnsiString(VPChar)));
      vtObject:
        if Supports(VObject, IList, AList) then
          WriteList(AList)
        else if Supports(VObject, IMap, AMap) then
          WriteMap(AMap)
        else
          WriteObject(VObject);
      vtWideChar:      WriteUTF8Char(VWideChar);
      vtPWideChar:     WriteString(WideString(VPWideChar));
      vtAnsiString:    WriteString(WideString(AnsiString(VAnsiString)));
      vtCurrency:      WriteCurrency(VCurrency^);
      vtVariant:       Serialize(VVariant^);
      vtInterface:
        if Supports(IList(VInterface), IList, AList) then
          WriteList(AList)
        else if Supports(IMap(VInterface), IMap, AMap) then
          WriteMap(AMap)
        else
          WriteNull;
      vtWideString:    WriteString(WideString(VWideString));
      vtInt64:         WriteLong(VInt64^);
{$IFDEF FPC}
      vtQWord:         WriteLong(VQWord^);
{$ENDIF}
{$IFDEF DELPHI2009_UP}
      vtUnicodeString: WriteString(UnicodeString(VUnicodeString));
{$ENDIF}
    else
      WriteNull;
    end;
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteArray(const Value: Variant;
  CheckRef: Boolean);
var
  PVar: PVarData;
  P: Pointer;
  Rank, Count, MaxRank, I, N: Integer;
  Des: array of array[0..1] of Integer;
  Loc, Len: array of Integer;
begin
  if WriteRef(Value, CheckRef) then begin
    PVar := FindVarData(Value);
    Rank := VarArrayDimCount(Value);
    if Rank = 1 then begin
      Count := VarArrayHighBound(Value, 1) - VarArrayLowBound(Value, 1) + 1;
      FStream.WriteBuffer(HproseTagList, 1);
      if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
      FStream.WriteBuffer(HproseTagOpenbrace, 1);
      P := VarArrayLock(Value);
      case PVar.VType and varTypeMask of
        varInteger: WriteIntegerArray(P, Count);
        varShortInt: WriteShortIntArray(P, Count);
        varWord: WriteWordArray(P, Count);
        varSmallint: WriteSmallintArray(P, Count);
        varLongWord: WriteLongWordArray(P, Count);
        varSingle: WriteSingleArray(P, Count);
        varDouble: WriteDoubleArray(P, Count);
        varCurrency: WriteCurrencyArray(P, Count);
        varInt64: WriteInt64Array(P, Count);
{$IFDEF DELPHI2009_UP}
        varUInt64: WriteUInt64Array(P, Count);
{$ENDIF}
{$IFDEF FPC}
        varQWord: WriteQWordArray(P, Count);
{$ENDIF}
        varOleStr: WriteWideStringArray(P, Count);
        varBoolean: WriteBooleanArray(P, Count);
        varDate: WriteDateTimeArray(P, Count);
        varVariant: WriteVariantArray(P, Count);
      end;
      VarArrayUnLock(Value);
      FStream.WriteBuffer(HproseTagClosebrace, 1);
    end
    else begin
      SetLength(Des, Rank);
      SetLength(Loc, Rank);
      SetLength(Len, Rank);
      MaxRank := Rank - 1;
      for I := 0 to MaxRank do begin
        Des[I, 0] := VarArrayLowBound(Value, I + 1);
        Des[I, 1] := VarArrayHighBound(Value, I + 1);
        Loc[I] := Des[I, 0];
        Len[I] := Des[I, 1] - Des[I, 0] + 1;
      end;
      FStream.WriteBuffer(HproseTagList, 1);
      if Len[0] > 0 then WriteRawByteString(RawByteString(IntToStr(Len[0])));
      FStream.WriteBuffer(HproseTagOpenbrace, 1);
      while Loc[0] <= Des[0, 1] do begin
        N := 0;
        for I := Maxrank downto 1 do
          if Loc[I] = Des[I, 0] then Inc(N) else Break;
        for I := Rank - N to MaxRank do begin
          FRefList.Add(Null);
          FStream.WriteBuffer(HproseTagList, 1);
          if Len[I] > 0 then WriteRawByteString(RawByteString(IntToStr(Len[I])));
          FStream.WriteBuffer(HproseTagOpenbrace, 1);
        end;
        for I := Des[MaxRank, 0] to Des[MaxRank, 1] do begin
          Loc[MaxRank] := I;
          Serialize(VarArrayGet(Value, Loc));
        end;
        Inc(Loc[MaxRank]);
        for I := MaxRank downto 1 do
          if Loc[I] > Des[I, 1] then begin
            Loc[I] := Des[I, 0];
            Inc(Loc[I - 1]);
            FStream.WriteBuffer(HproseTagClosebrace, 1);
          end;
      end;
      FStream.WriteBuffer(HproseTagClosebrace, 1);
    end;
  end;
end;

procedure THproseWriter.WriteBoolean(B: Boolean);
begin
  FStream.WriteBuffer(HproseTagBoolean[B], 1);
end;

procedure THproseWriter.WriteBooleanArray(var P; Count: Integer);
var
  AP: PWordBoolArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteBoolean(AP^[I]);
end;

procedure THproseWriter.WriteBytes(const Bytes: Variant;
  CheckRef: Boolean);
var
  N: Integer;
begin
  if WriteRef(Bytes, CheckRef) then begin
    N := VarArrayHighBound(Bytes, 1) - VarArrayLowBound(Bytes, 1) + 1;
    FStream.WriteBuffer(HproseTagBytes, 1);
    WriteRawByteString(RawByteString(IntToStr(N)));
    FStream.WriteBuffer(HproseTagQuote, 1);
    FStream.WriteBuffer(VarArrayLock(Bytes)^, N);
    VarArrayUnLock(Bytes);
    FStream.WriteBuffer(HproseTagQuote, 1);
  end;
end;

function THproseWriter.WriteClass(Instance: TObject): Integer;
var
  ClassAlias: string;
  PropName: ShortString;
  PropList: PPropList;
  PropCount, I: Integer;
  CachePointer: PSerializeCache;
  CacheStream: TMemoryStream;
  TempData: RawByteString;
  TempWStr: WideString;
begin
  ClassAlias := GetClassAlias(Instance.ClassType);
  if ClassAlias = '' then
    raise EHproseException.Create(Instance.ClassName + ' has not registered');
  PropertiesCache.Lock;
  try
{$IFDEF CPU64}
    CachePointer := PSerializeCache(Int64(PropertiesCache[ClassAlias]));
{$ELSE}
    CachePointer := PSerializeCache(Integer(PropertiesCache[ClassAlias]));
{$ENDIF}
    if CachePointer = nil then begin
      New(CachePointer);
      try
        CachePointer^.RefCount := 0;
        CachePointer^.Data := '';
        CacheStream := TMemoryStream.Create;
        try
          PropCount := GetStoredPropList(Instance, PropList);
          try
            CacheStream.WriteBuffer(HproseTagClass, 1);
            TempData := RawByteString(IntToStr(Length(ClassAlias)));
            CacheStream.WriteBuffer(TempData[1], Length(TempData));
            CacheStream.WriteBuffer(HproseTagQuote, 1);
            Tempdata := RawByteString(ClassAlias);
            CacheStream.WriteBuffer(TempData[1], Length(TempData));
            CacheStream.WriteBuffer(HproseTagQuote, 1);
            if PropCount > 0 then begin
              Tempdata := RawByteString(IntToStr(PropCount));
              CacheStream.WriteBuffer(TempData[1], Length(TempData));
            end;
            CacheStream.WriteBuffer(HproseTagOpenbrace, 1);
            for I := 0 to PropCount - 1 do begin
              PropName := PropList^[I]^.Name;
              if PropName[1] in ['A'..'Z'] then
                PropName[1] := AnsiChar(Integer(PropName[1]) + 32);
              TempWStr := WideString(PropName);
              CacheStream.WriteBuffer(HproseTagString, 1);
              Tempdata := RawByteString(IntToStr(Length(TempWStr)));
              CacheStream.WriteBuffer(TempData[1], Length(TempData));
              CacheStream.WriteBuffer(HproseTagQuote, 1);
              Tempdata := UTF8Encode(TempWStr);
              CacheStream.WriteBuffer(TempData[1], Length(TempData));
              CacheStream.WriteBuffer(HproseTagQuote, 1);
              Inc(CachePointer^.RefCount);
            end;
            CacheStream.WriteBuffer(HproseTagClosebrace, 1);
          finally
            FreeMem(PropList);
          end;
          CacheStream.Position := 0;
          SetLength(CachePointer^.Data, CacheStream.Size);
          Move(CacheStream.Memory^, PAnsiChar(CachePointer^.Data)^, CacheStream.Size);
        finally
          CacheStream.Free;
        end;
      except
        Dispose(CachePointer);
      end;
{$IFDEF CPU64}
      PropertiesCache[ClassAlias] := Int64(CachePointer);
{$ELSE}
      PropertiesCache[ClassAlias] := Integer(CachePointer);
{$ENDIF}
    end;
  finally
    PropertiesCache.UnLock;
  end;
  FStream.WriteBuffer(CachePointer^.Data[1], Length(CachePointer^.Data));
  if CachePointer^.RefCount > 0 then
    FRefList.Count := FRefList.Count + CachePointer^.RefCount;
  Result := FClassRefList.Add(Instance.ClassName);
end;

procedure THproseWriter.WriteCurrency(C: Currency);
begin
  stream.WriteBuffer(HproseTagDouble, 1);
  WriteRawByteString(RawByteString(CurrToStr(C)));
  stream.WriteBuffer(HproseTagSemicolon, 1);
end;

procedure THproseWriter.WriteCurrencyArray(var P; Count: Integer);
var
  AP: PCurrencyArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteCurrency(AP^[I]);
end;

procedure THproseWriter.WriteDateTimeArray(var P; Count: Integer);
var
  AP: PDateTimeArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteDateTime(AP^[I]);
end;

procedure THproseWriter.WriteDateTime(const ADateTime: TDateTime;
  CheckRef: Boolean);
var
  ADate, ATime, AMillisecond: RawByteString;
begin
  if WriteRef(ADateTime, CheckRef) then begin
    ADate := RawByteString(FormatDateTime('yyyymmdd', ADateTime));
    ATime := RawByteString(FormatDateTime('hhnnss', ADateTime));
    AMillisecond := RawByteString(FormatDateTime('zzz', ADateTime));
    if (ATime = '000000') and (AMillisecond = '000') then begin
      FStream.WriteBuffer(HproseTagDate, 1);
      WriteRawByteString(ADate);
    end
    else if ADate = '18991230' then begin
      FStream.WriteBuffer(HproseTagTime, 1);
      WriteRawByteString(ATime);
      if AMillisecond <> '000' then begin
        FStream.WriteBuffer(HproseTagPoint, 1);
        WriteRawByteString(AMillisecond);
      end;
    end
    else begin
      FStream.WriteBuffer(HproseTagDate, 1);
      WriteRawByteString(ADate);
      FStream.WriteBuffer(HproseTagTime, 1);
      WriteRawByteString(ATime);
      if AMillisecond <> '000' then begin
        FStream.WriteBuffer(HproseTagPoint, 1);
        WriteRawByteString(AMillisecond);
      end;
    end;
    FStream.WriteBuffer(HproseTagSemicolon, 1);
  end;
end;

procedure THproseWriter.WriteDouble(D: Extended);
begin
  if IsNaN(D) then
    WriteNaN
  else if IsInfinite(D) then
    WriteInfinity(Sign(D) = 1)
  else begin
    stream.WriteBuffer(HproseTagDouble, 1);
    WriteRawByteString(RawByteString(FloatToStr(D)));
    stream.WriteBuffer(HproseTagSemicolon, 1);
  end;
end;

procedure THproseWriter.WriteDoubleArray(var P; Count: Integer);
var
  AP: PDoubleArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteDouble(AP^[I]);
end;

procedure THproseWriter.WriteInfinity(Positive: Boolean);
begin
  FStream.WriteBuffer(HproseTagInfinity, 1);
  FStream.WriteBuffer(HproseTagSign[Positive], 1);
end;

procedure THproseWriter.WriteInt64Array(var P; Count: Integer);
var
  AP: PInt64Array absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteLong(AP^[I]);
end;

{$IFDEF DELPHI2009_UP}
procedure THproseWriter.WriteUInt64Array(var P; Count: Integer);
var
  AP: PUInt64Array absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteLong(AP^[I]);
end;
{$ENDIF}

{$IFDEF FPC}
procedure THproseWriter.WriteQWordArray(var P; Count: Integer);
var
  AP: PQWordArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteLong(AP^[I]);
end;
{$ENDIF}

procedure THproseWriter.WriteInteger(I: Integer);
var
  C: AnsiChar;
begin
  if (I >= 0) and (I <= 9) then begin
    C := AnsiChar(I + Ord('0'));
    FStream.WriteBuffer(C, 1);
  end
  else begin
    FStream.WriteBuffer(HproseTagInteger, 1);
    WriteRawByteString(RawByteString(IntToStr(I)));
    FStream.WriteBuffer(HproseTagSemicolon, 1);
  end;
end;

procedure THproseWriter.WriteIntegerArray(var P; Count: Integer);
var
  AP: PIntegerArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteInteger(AP^[I]);
end;

procedure THproseWriter.WriteList(AList: IList; CheckRef: Boolean);
var
  Count, I: Integer;
begin
  if WriteRef(AList, CheckRef) then begin
    Count := AList.Count;
    FStream.WriteBuffer(HproseTagList, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    for I := 0 to Count - 1 do Serialize(AList[I]);
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteLong(const L: RawByteString);
begin
  if (Length(L) = 1) and (L[1] in ['0'..'9']) then
    FStream.WriteBuffer(L[1], 1)
  else begin
    FStream.WriteBuffer(HproseTagLong, 1);
    WriteRawByteString(L);
    FStream.WriteBuffer(HproseTagSemicolon, 1);
  end;
end;

procedure THproseWriter.WriteLong(L: Int64);
var
  C: AnsiChar;
begin
  if (L >= 0) and (L <= 9) then begin
    C := AnsiChar(L + Ord('0'));
    FStream.WriteBuffer(C, 1);
  end
  else begin
    FStream.WriteBuffer(HproseTagLong, 1);
    WriteRawByteString(RawByteString(IntToStr(L)));
    FStream.WriteBuffer(HproseTagSemicolon, 1);
  end;
end;

{$IFDEF DELPHI2009_UP}
procedure THproseWriter.WriteLong(L: UInt64);
var
  C: AnsiChar;
begin
  if L <= 9 then begin
    C := AnsiChar(L + Ord('0'));
    FStream.WriteBuffer(C, 1);
  end
  else begin
    FStream.WriteBuffer(HproseTagLong, 1);
    WriteRawByteString(RawByteString(UIntToStr(L)));
    FStream.WriteBuffer(HproseTagSemicolon, 1);
  end;
end;
{$ENDIF}

{$IFDEF FPC}
procedure THproseWriter.WriteLong(L: QWord);
var
  C: AnsiChar;
begin
  if L <= 9 then begin
    C := AnsiChar(L + Ord('0'));
    FStream.WriteBuffer(C, 1);
  end
  else begin
    FStream.WriteBuffer(HproseTagLong, 1);
    WriteRawByteString(RawByteString(IntToStr(L)));
    FStream.WriteBuffer(HproseTagSemicolon, 1);
  end;
end;
{$ENDIF}

procedure THproseWriter.WriteLongWordArray(var P; Count: Integer);
var
  AP: PLongWordArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteLong(AP^[I]);
end;

procedure THproseWriter.WriteMap(AMap: IMap; CheckRef: Boolean);
var
  Count, I: Integer;
begin
  if WriteRef(AMap, CheckRef) then begin
    Count := AMap.Count;
    FStream.WriteBuffer(HproseTagMap, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    for I := 0 to Count - 1 do begin
      Serialize(AMap.Keys[I]);
      Serialize(AMap.Values[I]);
    end;
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteNaN;
begin
  FStream.WriteBuffer(HproseTagNaN, 1);
end;

procedure THproseWriter.WriteNull;
begin
  FStream.WriteBuffer(HproseTagNull, 1);
end;

procedure THproseWriter.WriteEmpty;
begin
  FStream.WriteBuffer(HproseTagEmpty, 1);
end;

procedure THproseWriter.WriteObject(AObject: TObject; CheckRef: Boolean);
var
  Ref, ClassRef: Integer;
  Value: Variant;
  PropList: PPropList;
  PropCount, I: Integer;
begin
  Value := ObjToVar(AObject);
  if CheckRef then begin
    Ref := FRefList.IndexOf(Value);
    if Ref > -1 then begin
      WriteRef(Ref);
      Exit;
    end;
  end;
  ClassRef := FClassRefList.IndexOf(AObject.ClassName);
  if ClassRef < 0 then ClassRef := WriteClass(AObject);
  FRefList.Add(Value);
  FStream.WriteBuffer(HproseTagObject, 1);
  WriteRawByteString(RawByteString(IntToStr(ClassRef)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  PropCount := GetStoredPropList(AObject, PropList);
  try
    for I := 0 to PropCount - 1 do
      Serialize(GetPropValue(AObject, PropList^[I]));
  finally
    FreeMem(PropList);
  end;
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

function THproseWriter.WriteRef(const Value: Variant;
  CheckRef: Boolean): Boolean;
var
  Ref: Integer;
begin
  if CheckRef then begin
    Ref := FRefList.IndexOf(Value);
    if Ref > -1 then begin
      WriteRef(Ref);
      Result := False;
      Exit;
    end;
  end;
  FRefList.Add(Value);
  Result := True;
end;

procedure THproseWriter.WriteRef(Value: Integer);
begin
  FStream.WriteBuffer(HproseTagRef, 1);
  WriteRawByteString(RawByteString(IntToStr(Value)));
  FStream.WriteBuffer(HproseTagSemicolon, 1);
end;

procedure THproseWriter.WriteShortIntArray(var P; Count: Integer);
var
  AP: PShortIntArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteInteger(AP^[I]);
end;

procedure THproseWriter.WriteSingleArray(var P; Count: Integer);
var
  AP: PSingleArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteDouble(AP^[I]);
end;

procedure THproseWriter.WriteSmallIntArray(var P; Count: Integer);
var
  AP: PSmallIntArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteInteger(AP^[I]);
end;

procedure THproseWriter.WriteUTF8Char(C: WideChar);
begin
  FStream.WriteBuffer(HproseTagUTF8Char, 1);
  WriteRawByteString(UTF8Encode(WideString(C)));
end;

procedure THproseWriter.WriteString(const S: WideString;
  CheckRef: Boolean);
begin
  if WriteRef(S, CheckRef) then begin
    FStream.WriteBuffer(HproseTagString, 1);
    WriteRawByteString(RawByteString(IntToStr(Length(S))));
    FStream.WriteBuffer(HproseTagQuote, 1);
    WriteRawByteString(UTF8Encode(S));
    FStream.WriteBuffer(HproseTagQuote, 1);
  end;
end;

procedure THproseWriter.WriteVariantArray(var P; Count: Integer);
var
  AP: PVariantArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do Serialize(AP^[I]);
end;

procedure THproseWriter.WriteWideStringArray(var P; Count: Integer);
var
  AP: PWideStringArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteString(AP^[I]);
end;

procedure THproseWriter.WriteWordArray(var P; Count: Integer);
var
  AP: PWordArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteInteger(AP^[I]);
end;

procedure THproseWriter.Reset;
begin
  FRefList.Clear;
  FClassRefList.Clear;
end;

{ HproseSerialize }

function HproseSerialize(Value: TObject): RawByteString;
begin
  Result := HproseSerialize(ObjToVar(Value));
end;

function HproseSerialize(const Value: Variant): RawByteString;
var
  Writer: THproseWriter;
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Writer := THproseWriter.Create(Stream);
    try
      Writer.Serialize(Value);
      Stream.Position := 0;
      SetLength(Result, Stream.Size);
      Move(Stream.Memory^, PAnsiChar(Result)^, Stream.Size);
    finally
      Writer.Free;
    end;
  finally
    Stream.Free;
  end;
end;

function HproseSerialize(const Value: array of const): RawByteString;
var
  Writer: THproseWriter;
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Writer := THproseWriter.Create(Stream);
    try
      Writer.Serialize(Value);
      Stream.Position := 0;
      SetLength(Result, Stream.Size);
      Move(Stream.Memory^, PAnsiChar(Result)^, Stream.Size);
    finally
      Writer.Free;
    end;
  finally
    Stream.Free;
  end;
end;

{ HproseUnserialize }

function HproseUnserialize(const Data: RawByteString; VType: TVarType;
  AClass: TClass): Variant;
var
  Reader: THproseReader;
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.SetSize(Length(Data));
    Move(PAnsiChar(Data)^, Stream.Memory^, Stream.Size);
    Reader := THproseReader.Create(Stream);
    try
      Result := Reader.Unserialize(VType, AClass);
    finally
      Reader.Free;
    end;
  finally
    Stream.Free;
  end;
end;

{ THproseFormatter }

class function THproseFormatter.Serialize(
  Value: TObject): RawByteString;
begin
  Result := HproseSerialize(Value);
end;

class function THproseFormatter.Serialize(
  const Value: Variant): RawByteString;
begin
  Result := HproseSerialize(Value);
end;

class function THproseFormatter.Serialize(
  const Value: array of const): RawByteString;
begin
  Result := HproseSerialize(Value);
end;

class function THproseFormatter.Unserialize(const Data: RawByteString;
  VType: TVarType; AClass: TClass): Variant;
begin
  Result := HproseUnserialize(Data, VType, AClass);
end;

procedure FreePropertiesCache;
var
  I: Integer;
  CacheValues: IList;
  CachePointer: PSerializeCache;
begin
  PropertiesCache.Lock;
  try
    CacheValues := PropertiesCache.Values;
    for I := 0 to CacheValues.Count - 1 do begin
{$IFDEF CPU64}
      CachePointer := PSerializeCache(Int64(CacheValues[I]));
{$ELSE}
      CachePointer := PSerializeCache(Integer(CacheValues[I]));
{$ENDIF}
      Dispose(CachePointer);
    end;
  finally
    PropertiesCache.Unlock;
  end;
end;

initialization
  PropertiesCache := THashMap.Create;

finalization
  FreePropertiesCache;

end.
