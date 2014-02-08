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
 * LastModified: Feb 8, 2014                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
}
unit HproseIO;

{$I Hprose.inc}

interface

uses Classes, HproseCommon
{$IFDEF Supports_Generics}, Generics.Collections {$ENDIF}, TypInfo;

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
    function UnexpectedTag(Tag: AnsiChar;
      const ExpectTags: string = ''): EHproseException;
    function TagToString(Tag: AnsiChar): string;
    function ReadByte: Byte;
    function ReadInt64(Tag: AnsiChar): Int64; overload;
{$IFDEF Supports_UInt64}
    function ReadUInt64(Tag: AnsiChar): UInt64; overload;
{$ENDIF}
    function ReadStringAsWideString: WideString;
    function ReadBooleanArray(Count: Integer): Variant;
    function ReadShortIntArray(Count: Integer): Variant;
    function ReadByteArray(Count: Integer): Variant;
    function ReadSmallIntArray(Count: Integer): Variant;
    function ReadWordArray(Count: Integer): Variant;
    function ReadIntegerArray(Count: Integer): Variant;
    function ReadLongWordArray(Count: Integer): Variant;
    function ReadSingleArray(Count: Integer): Variant;
    function ReadDoubleArray(Count: Integer): Variant;
    function ReadCurrencyArray(Count: Integer): Variant;
    function ReadDateTimeArray(Count: Integer): Variant;
    function ReadWideStringArray(Count: Integer): Variant;
    function ReadVariantArray(Count: Integer): Variant; overload;
    function ReadInterfaceArray(Count: Integer): Variant;
    function ReadDynArrayWithoutTag(varType: Integer): Variant;
    function ReadIList(AClass: TClass): IList;
    function ReadList(AClass: TClass): TAbstractList;
    function ReadListAsIMap(AClass: TClass): IMap;
    function ReadListAsMap(AClass: TClass): TAbstractMap;
    function ReadIMap(AClass: TClass): IMap;
    function ReadMap(AClass: TClass): TAbstractMap;
    function ReadMapAsInterface(AClass: TClass; const IID: TGUID): IInterface;
    function ReadMapAsObject(AClass: TClass): TObject;
    function ReadObjectAsIMap(AClass: TMapClass): IMap;
    function ReadObjectAsMap(AClass: TMapClass): TAbstractMap;
    function ReadObjectAsInterface(AClass: TClass; const IID: TGUID): IInterface;
    function ReadObjectWithoutTag(AClass: TClass): TObject; overload;
    procedure ReadClass;
    function ReadRef: Variant;
{$IFDEF Supports_Generics}
    procedure ReadArray<T>(var DynArray: TArray<T>; TypeInfo: PTypeInfo); overload;
    procedure ReadArray(TypeInfo: PTypeInfo; out DynArray); overload;
    procedure ReadDynArray(TypeInfo: PTypeInfo; out DynArray); overload;
{$IFDEF Supports_Rtti}
    function ReadTList<T>(TypeInfo, ElementTypeInfo: PTypeInfo): TList<T>; overload;
    function ReadTList(TypeInfo: PTypeInfo): TObject; overload;
    function ReadTQueue<T>(TypeInfo, ElementTypeInfo: PTypeInfo): TQueue<T>; overload;
    function ReadTQueue(TypeInfo: PTypeInfo): TObject; overload;
    function ReadTStack<T>(TypeInfo, ElementTypeInfo: PTypeInfo): TStack<T>; overload;
    function ReadTStack(TypeInfo: PTypeInfo): TObject; overload;
    function ReadTDictionary2<TKey, TValue>(
      TypeInfo, KeyTypeInfo, ValueTypeInfo: PTypeInfo): TDictionary<TKey, TValue>;
    function ReadTDictionary1<TKey>(TypeInfo, KeyTypeInfo,
      ValueTypeInfo: PTypeInfo; ValueSize: Integer): TObject;
    function ReadTDictionary(TypeInfo: PTypeInfo): TObject;
    function UnserializeTypeAsT<T>(TypeInfo: PTypeInfo): T;
{$ENDIF}
    function ReadSmartObject(TypeInfo: PTypeInfo): ISmartObject;
{$ENDIF}
    procedure ReadRaw(const OStream: TStream; Tag: AnsiChar); overload;
    procedure ReadInfinityRaw(const OStream: TStream);
    procedure ReadNumberRaw(const OStream: TStream);
    procedure ReadDateTimeRaw(const OStream: TStream);
    procedure ReadUTF8CharRaw(const OStream: TStream);
    procedure ReadStringRaw(const OStream: TStream);
    procedure ReadBytesRaw(const OStream: TStream);
    procedure ReadGuidRaw(const OStream: TStream);
    procedure ReadComplexRaw(const OStream: TStream);
  public
    constructor Create(AStream: TStream);
    procedure CheckTag(expectTag: AnsiChar);
    function CheckTags(const expectTags: RawByteString): AnsiChar;
    function ReadUntil(Tag: AnsiChar): string;
    function ReadInt(Tag: AnsiChar): Integer;
    function ReadIntegerWithoutTag: Integer;
    function ReadLongWithoutTag: string;
    function ReadInfinityWithoutTag: Extended;
    function ReadDoubleWithoutTag: Extended;
    function ReadDateWithoutTag: TDateTime;
    function ReadTimeWithoutTag: TDateTime;
    function ReadUTF8CharWithoutTag: WideChar;
    function ReadStringWithoutTag: WideString;
    function ReadBytesWithoutTag: Variant;
    function ReadGuidWithoutTag: string;
    function ReadListWithoutTag: Variant;
    function ReadMapWithoutTag: Variant;
    function ReadObjectWithoutTag: Variant; overload;
    function ReadInteger: Integer;
    function ReadInt64: Int64; overload;
{$IFDEF Supports_UInt64}
    function ReadUInt64: UInt64; overload;
{$ENDIF}
    function ReadExtended: Extended;
    function ReadCurrency: Currency;
    function ReadBoolean: Boolean;
    function ReadDateTime: TDateTime;
    function ReadUTF8Char: WideChar;
    function ReadString: WideString;
    function ReadBytes: Variant;
    function ReadGuid: string;
    function ReadDynArray(varType: Integer): Variant; overload;
    function ReadVariantArray: TVariants; overload;
    function ReadInterface(AClass: TClass; const IID: TGUID): IInterface;
    function ReadObject(AClass: TClass): TObject;
{$IFDEF Supports_Generics}
    procedure Unserialize(TypeInfo: PTypeInfo; out Value); overload;
    function Unserialize<T>: T; overload;
{$ENDIF}
    function Unserialize: Variant; overload;
    function Unserialize(TypeInfo: PTypeInfo): Variant; overload;
    function ReadRaw: TMemoryStream; overload;
    procedure ReadRaw(const OStream: TStream); overload;
    procedure Reset;
    property Stream: TStream read FStream;
  end;

  THproseWriter = class
  private
    FStream: TStream;
    FRefList: IList;
    FClassRefList: IList;
    procedure WriteRef(Value: Integer);
    function WriteClass(const Instance: TObject): Integer;
    procedure WriteRawByteString(const S: RawByteString);
    procedure WriteShortIntArray(var P; Count: Integer);
    procedure WriteSmallIntArray(var P; Count: Integer);
    procedure WriteWordArray(var P; Count: Integer);
    procedure WriteIntegerArray(var P; Count: Integer);
    procedure WriteCurrencyArray(var P; Count: Integer);
    procedure WriteLongWordArray(var P; Count: Integer);
    procedure WriteSingleArray(var P; Count: Integer);
    procedure WriteDoubleArray(var P; Count: Integer);
    procedure WriteBooleanArray(var P; Count: Integer);
    procedure WriteWideStringArray(var P; Count: Integer);
    procedure WriteDateTimeArray(var P; Count: Integer);
    procedure WriteVariantArray(var P; Count: Integer);
    procedure WriteWideString(const Str: WideString);
    procedure WriteStrings(const SS: TStrings);
    procedure WriteList(const AList: TAbstractList); overload;
    procedure WriteMap(const AMap: TAbstractMap); overload;
{$IFDEF Supports_Generics}
    procedure Serialize(const Value; TypeInfo: Pointer); overload;
    procedure WriteArray(const DynArray; const Name: string); overload;
    procedure WriteArrayWithRef(const DynArray; TypeInfo: Pointer); overload;
    procedure WriteList(const AList: TObject); overload;
    procedure WriteObjectList(const AList: TObject);
    procedure WriteQueue(const AQueue: TObject);
    procedure WriteObjectQueue(const AQueue: TObject);
    procedure WriteStack(const AStack: TObject);
    procedure WriteObjectStack(const AStack: TObject);
    procedure WriteDictionary(const ADict: TObject);
    procedure WriteObjectDictionary(const ADict: TObject);
    procedure WriteTDictionary1<TKey>(const ADict: TObject; ValueSize: Integer;
              KeyTypeInfo, ValueTypeInfo: Pointer);
    procedure WriteTDictionary2<TKey, TValue>(const ADict: TDictionary<TKey, TValue>;
              KeyTypeInfo, ValueTypeInfo: Pointer);
{$ENDIF}
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
    procedure WriteDateTime(const ADateTime: TDateTime);
    procedure WriteDateTimeWithRef(const ADateTime: TDateTime);
    procedure WriteBytes(const Bytes: Variant);
    procedure WriteBytesWithRef(const Bytes: Variant);
    procedure WriteString(const S: WideString);
    procedure WriteStringWithRef(const S: WideString);
    procedure WriteArray(const Value: Variant); overload;
    procedure WriteArrayWithRef(const Value: Variant); overload;
    procedure WriteArray(const Value: array of const); overload;
    procedure WriteList(const AList: IList); overload;
    procedure WriteListWithRef(const AList: IList); overload;
    procedure WriteMap(const AMap: IMap); overload;
    procedure WriteMapWithRef(const AMap: IMap);
{$IFDEF Supports_Generics}
    procedure Serialize<T>(const Value: T); overload;
    procedure WriteArray<T>(const DynArray: array of T); overload;
    procedure WriteDynArray<T>(const DynArray: TArray<T>);
    procedure WriteDynArrayWithRef<T>(const DynArray: TArray<T>); overload;
    procedure WriteTList<T>(const AList: TList<T>); overload;
    procedure WriteTListWithRef<T>(const AList: TList<T>); overload;
    procedure WriteTQueue<T>(const AQueue: TQueue<T>); overload;
    procedure WriteTQueueWithRef<T>(const AQueue: TQueue<T>);
    procedure WriteTStack<T>(const AStack: TStack<T>); overload;
    procedure WriteTStackWithRef<T>(const AStack: TStack<T>);
    procedure WriteTDictionary<TKey, TValue>(const ADict: TDictionary<TKey, TValue>); overload;
    procedure WriteTDictionaryWithRef<TKey, TValue>(const ADict: TDictionary<TKey, TValue>);
{$ELSE}
    procedure Serialize(const Value: TObject); overload;
{$ENDIF}
    procedure WriteObject(const AObject: TObject);
    procedure WriteObjectWithRef(const AObject: TObject);
    procedure WriteInterface(const Intf: IInterface);
    procedure WriteInterfaceWithRef(const Intf: IInterface);
    procedure WriteSmartObject(const SmartObject: ISmartObject);
    procedure WriteSmartObjectWithRef(const SmartObject: ISmartObject);
    procedure Reset;
    property Stream: TStream read FStream;
  end;

  THproseFormatter = class
  public
    class function Serialize(const Value: Variant): RawByteString; overload;
    class function Serialize(const Value: array of const): RawByteString; overload;
{$IFDEF Supports_Generics}
    class function Serialize<T>(const Value: T): RawByteString; overload;
    class function Unserialize<T>(const Data:RawByteString): T; overload;
{$ELSE}
    class function Serialize(const Value: TObject): RawByteString; overload;
{$ENDIF}
    class function Unserialize(const Data:RawByteString): Variant; overload;
    class function Unserialize(const Data:RawByteString; TypeInfo: Pointer): Variant; overload;
  end;

function HproseSerialize(const Value: TObject): RawByteString; overload;
function HproseSerialize(const Value: Variant): RawByteString; overload;
function HproseSerialize(const Value: array of const): RawByteString; overload;
function HproseUnserialize(const Data:RawByteString; TypeInfo: Pointer = nil): Variant;

implementation

uses DateUtils, Math, RTLConsts,
{$IFNDEF FPC}StrUtils, SysConst, {$ENDIF}
{$IFDEF Supports_Rtti}Rtti, {$ENDIF}
     SysUtils, Variants;
type

  PSmallIntArray = ^TSmallIntArray;
  TSmallIntArray = array[0..MaxInt div Sizeof(SmallInt) - 1] of SmallInt;

  PShortIntArray = ^TShortIntArray;
  TShortIntArray = array[0..MaxInt div Sizeof(ShortInt) - 1] of ShortInt;

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

  PInterfaceArray = ^TInterfaceArray;
  TInterfaceArray = array[0..MaxInt div Sizeof(Variant) - 1] of IInterface;

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

{$IFDEF Supports_Generics}
type
  TB1 = Byte;
  TB2 = Word;
  TB4 = LongWord;
  TB8 = UInt64;

function IsSmartObject(const Name: string): Boolean; inline;
begin
  Result := AnsiStartsText('ISmartObject<', Name) or
            AnsiStartsText('HproseCommon.ISmartObject<', Name);
end;

function GetElementName(const Name: string): string;
var
  I, L: Integer;
begin
  L := Length(Name);
  for I := 1 to L do if Name[I] = '<' then begin
    Result := AnsiMidStr(Name, I + 1, L - I - 1);
    Break;
  end;
end;

procedure SplitKeyValueTypeName(const Name: string;
  var KeyName, ValueName: string);
var
  I, N, P, L: Integer;
begin
  L := Length(Name);
  N := 0;
  P := 0;
  for I := 1 to L do begin
    case Name[I] of
      '<': Inc(N);
      '>': Dec(N);
      ',': if N = 0 then begin
        P := I;
        Break;
      end;
    end;
  end;
  if P > 0 then begin
    KeyName := AnsiMidStr(Name, 1, P - 1);
    ValueName := AnsiMidStr(Name, P + 1, L - P);
  end;
end;
{$ENDIF}

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
      if ((GetTypeName(PropType) = 'TDateTime') or
          (GetTypeName(PropType) = 'TDate') or
          (GetTypeName(PropType) = 'TTime')) then
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
    if (GetTypeName(PropType) = 'UInt64') then
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
      begin
        SetInterfaceProp(Instance, PropInfo, Value);
      end;
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
  TypeName := GetTypeName(TypeInfo);
  if TypeName = 'Boolean' then
    Result := varBoolean
  else if (TypeName = 'TDateTime') or
          (TypeName = 'TDate') or
          (TypeName = 'TTime') then
    Result := varDate
{$IFDEF DELPHI2009_UP}
  else if TypeName = 'UInt64' then
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
          ftDouble, ftExtended:
            Result := varDouble;
          ftComp:
            Result := varInt64;
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
      tkInterface: begin
        Result := varUnknown;
        AClass := GetClassByInterface(TypeData.Guid);
      end;
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

constructor THproseReader.Create(AStream: TStream);
begin
  FStream := AStream;
  FRefList := TArrayList.Create(False);
  FClassRefList := TArrayList.Create(False);
  FAttrRefMap := THashMap.Create(False);
end;

function THproseReader.UnexpectedTag(Tag: AnsiChar;
  const ExpectTags: string): EHproseException;
begin
  if ExpectTags = '' then
    Result := EHproseException.Create('Unexpected serialize tag "' +
                                       string(Tag) + '" in stream')
  else
    Result := EHproseException.Create('Tag "' + ExpectTags +
                                       '" expected, but "' + string(Tag) +
                                       '" found in stream');
end;

function THproseReader.TagToString(Tag: AnsiChar): string;
begin
  case Tag of
    '0'..'9', htInteger: Result := 'Integer';
    htLong: Result := 'BigInteger';
    htDouble: Result := 'Double';
    htNull: Result := 'Null';
    htEmpty: Result := 'Empty String';
    htTrue: Result := 'Boolean True';
    htFalse: Result := 'Boolean False';
    htNaN: Result := 'NaN';
    htInfinity: Result := 'Infinity';
    htDate: Result := 'DateTime';
    htTime: Result := 'DateTime';
    htBytes: Result := 'Binary Data';
    htUTF8Char: Result := 'Char';
    htString: Result := 'String';
    htGuid: Result := 'Guid';
    htList: Result := 'List';
    htMap: Result := 'Map';
    htClass: Result := 'Class';
    htObject: Result := 'Object';
    htRef: Result := 'Object Reference';
    htError: raise EHproseException.Create(ReadString());
  else
    raise UnexpectedTag(Tag);
  end;
end;

procedure THproseReader.CheckTag(ExpectTag: AnsiChar);
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  if Tag <> expectTag then raise UnexpectedTag(Tag, string(ExpectTag));
end;

function THproseReader.CheckTags(const ExpectTags: RawByteString): AnsiChar;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  if Pos(Tag, ExpectTags) = 0 then raise UnexpectedTag(Tag, string(ExpectTags));
  Result := Tag;
end;

function THproseReader.ReadByte: Byte;
begin
  FStream.ReadBuffer(Result, 1);
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
  end;
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
  end;
end;

{$IFDEF Supports_UInt64}
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
  end;
end;
{$ENDIF}

function THproseReader.ReadIntegerWithoutTag: Integer;
begin
  Result := ReadInt(HproseTagSemicolon);
end;

function THproseReader.ReadLongWithoutTag: string;
begin
  Result := ReadUntil(HproseTagSemicolon);
end;

function THproseReader.ReadInfinityWithoutTag: Extended;
begin
  if ReadByte = Ord(HproseTagNeg) then
    Result := NegInfinity
  else
    Result := Infinity;
end;

function THproseReader.ReadDoubleWithoutTag: Extended;
begin
  Result := StrToFloat(ReadUntil(HproseTagSemicolon));
end;

function THproseReader.ReadDateWithoutTag: TDateTime;
var
  Tag, Year, Month, Day, Hour, Minute, Second, Millisecond: Integer;
begin
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

function THproseReader.ReadTimeWithoutTag: TDateTime;
var
  Tag, Hour, Minute, Second, Millisecond: Integer;
begin
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

function THproseReader.ReadUTF8CharWithoutTag: WideChar;
var
  C, C2, C3: LongWord;
begin
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

function THproseReader.ReadStringAsWideString: WideString;
var
  Count, I: Integer;
  C, C2, C3, C4: LongWord;
begin
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
end;

function THproseReader.ReadStringWithoutTag: WideString;
begin
  Result := ReadStringAsWideString;
  FRefList.Add(Result);
end;

function THproseReader.ReadBytesWithoutTag: Variant;
var
  Len: Integer;
  P: PByteArray;
begin
  Len := ReadInt(HproseTagQuote);
  Result := VarArrayCreate([0, Len - 1], varByte);
  P := VarArrayLock(Result);
  FStream.ReadBuffer(P^[0], Len);
  VarArrayUnLock(Result);
  CheckTag(HproseTagQuote);
  FRefList.Add(VarArrayRef(Result));
end;

function THproseReader.ReadGuidWithoutTag: string;
begin
  SetLength(Result, 38);
  FStream.ReadBuffer(Result[1], 38);
  FRefList.Add(Result);
end;

function THproseReader.ReadBooleanArray(Count: Integer): Variant;
var
  P: PWordBoolArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varBoolean);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := ReadBoolean;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadShortIntArray(Count: Integer): Variant;
var
  P: PShortIntArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varShortInt);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := ShortInt(ReadInteger);
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadByteArray(Count: Integer): Variant;
var
  P: PShortIntArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varByte);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Byte(ReadInteger);
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadSmallIntArray(Count: Integer): Variant;
var
  P: PSmallIntArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varSmallInt);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := SmallInt(ReadInteger);
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadWordArray(Count: Integer): Variant;
var
  P: PWordArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varWord);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Word(ReadInteger);
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadIntegerArray(Count: Integer): Variant;
var
  P: PIntegerArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varInteger);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := ReadInteger;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadLongWordArray(Count: Integer): Variant;
var
  P: PLongWordArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varLongWord);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := LongWord(ReadInt64);
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadSingleArray(Count: Integer): Variant;
var
  P: PSingleArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varSingle);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := ReadExtended;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadDoubleArray(Count: Integer): Variant;
var
  P: PDoubleArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varDouble);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := ReadExtended;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadCurrencyArray(Count: Integer): Variant;
var
  P: PCurrencyArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varCurrency);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := ReadCurrency;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadDateTimeArray(Count: Integer): Variant;
var
  P: PDateTimeArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varDate);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := ReadDateTime;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadWideStringArray(Count: Integer): Variant;
var
  P: PWideStringArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varOleStr);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := ReadString;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadVariantArray(Count: Integer): Variant;
var
  P: PVariantArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varVariant);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadInterfaceArray(Count: Integer): Variant;
var
  P: PInterfaceArray;
  I, N: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varVariant);
  N := FRefList.Add(Null);
  P := VarArrayLock(Result);
  for I := 0 to Count - 1 do P^[I] := Unserialize;
  VarArrayUnlock(Result);
  FRefList[N] := VarArrayRef(Result);
end;

function THproseReader.ReadDynArrayWithoutTag(varType: Integer): Variant;
var
  Count: Integer;
begin
  Count := ReadInt(HproseTagOpenbrace);
  case varType of
    varBoolean:  Result := ReadBooleanArray(Count);
    varShortInt: Result := ReadShortIntArray(Count);
    varByte:     Result := ReadByteArray(Count);
    varSmallint: Result := ReadSmallintArray(Count);
    varWord:     Result := ReadWordArray(Count);
    varInteger:  Result := ReadIntegerArray(Count);
    varLongWord: Result := ReadLongWordArray(Count);
    varSingle:   Result := ReadSingleArray(Count);
    varDouble:   Result := ReadDoubleArray(Count);
    varCurrency: Result := ReadCurrencyArray(Count);
    varOleStr:   Result := ReadWideStringArray(Count);
    varDate:     Result := ReadDateTimeArray(Count);
    varVariant:  Result := ReadVariantArray(Count);
    varUnknown:  Result := ReadInterfaceArray(Count);
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadIList(AClass: TClass): IList;
var
  Count, I: Integer;
begin
  Count := ReadInt(HproseTagOpenbrace);
  Result := TListClass(AClass).Create(Count) as IList;
  FRefList.Add(Result);
  for I := 0 to Count - 1 do Result[I] := Unserialize;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadList(AClass: TClass): TAbstractList;
var
  Count, I: Integer;
begin
  Count := ReadInt(HproseTagOpenbrace);
  Result := TListClass(AClass).Create(Count);
  FRefList.Add(ObjToVar(Result));
  for I := 0 to Count - 1 do Result[I] := Unserialize;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadListWithoutTag: Variant;
begin
  Result := ReadIList(TArrayList);
end;

function THproseReader.ReadListAsIMap(AClass: TClass): IMap;
var
  Count, I: Integer;
begin
  Count := ReadInt(HproseTagOpenbrace);
  Result := TMapClass(AClass).Create(Count) as IMap;
  FRefList.Add(Result);
  for I := 0 to Count - 1 do Result[I] := Unserialize;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadListAsMap(AClass: TClass): TAbstractMap;
var
  Count, I: Integer;
begin
  Count := ReadInt(HproseTagOpenbrace);
  Result := TMapClass(AClass).Create(Count);
  FRefList.Add(ObjToVar(Result));
  for I := 0 to Count - 1 do Result[I] := Unserialize;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadIMap(AClass: TClass): IMap;
var
  Count, I: Integer;
  Key: Variant;
begin
  Count := ReadInt(HproseTagOpenbrace);
  Result := TMapClass(AClass).Create(Count) as IMap;
  FRefList.Add(Result);
  for I := 0 to Count - 1 do begin
    Key := Unserialize;
    Result[Key] := Unserialize;
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadMap(AClass: TClass): TAbstractMap;
var
  Count, I: Integer;
  Key: Variant;
begin
  Count := ReadInt(HproseTagOpenbrace);
  Result := TMapClass(AClass).Create(Count);
  FRefList.Add(ObjToVar(Result));
  for I := 0 to Count - 1 do begin
    Key := Unserialize;
    Result[Key] := Unserialize;
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadMapAsInterface(AClass: TClass; const IID: TGUID): IInterface;
var
  Count, I: Integer;
  Instance: TObject;
  PropInfo: PPropInfo;
begin
  Count := ReadInt(HproseTagOpenbrace);
  Instance := AClass.Create;
  Supports(Instance, IID, Result);
  FRefList.Add(Result);
  for I := 0 to Count - 1 do begin
    PropInfo := GetPropInfo(AClass, ReadString);
    if (PropInfo <> nil) then
      SetPropValue(Instance, PropInfo,
                   Unserialize(PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF}))
    else Unserialize;
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadMapAsObject(AClass: TClass): TObject;
var
  Count, I: Integer;
  PropInfo: PPropInfo;
begin
  Count := ReadInt(HproseTagOpenbrace);
  Result := AClass.Create;
  FRefList.Add(ObjToVar(Result));
  for I := 0 to Count - 1 do begin
    PropInfo := GetPropInfo(AClass, ReadString);
    if (PropInfo <> nil) then
      SetPropValue(Result, PropInfo,
                   Unserialize(PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF}))
    else Unserialize;
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadMapWithoutTag: Variant;
begin
  Result := ReadIMap(THashMap);
end;

procedure THproseReader.ReadClass;
var
  ClassName: string;
  I, Count: Integer;
  AttrNames: IList;
  AClass: TClass;
  Key: Variant;
begin
  ClassName := ReadStringAsWideString;
  Count := ReadInt(HproseTagOpenbrace);
  AttrNames := TArrayList.Create(Count, False) as IList;
  for I := 0 to Count - 1 do AttrNames[I] := ReadString;
  CheckTag(HproseTagClosebrace);
  AClass := GetClassByAlias(ClassName);
  if AClass = nil then begin
    Key := IInterface(TInterfacedObject.Create);
    FClassRefList.Add(Key);
    FAttrRefMap[Key] := AttrNames;
  end
  else begin
    Key := NativeInt(AClass);
    FClassRefList.Add(Key);
    FAttrRefMap[Key] := AttrNames;
  end;
end;

function THproseReader.ReadObjectAsIMap(AClass: TMapClass): IMap;
var
  C: Variant;
  AttrNames: IList;
  I, Count: Integer;
begin
  C := FClassRefList[ReadInt(HproseTagOpenbrace)];
  AttrNames := VarToList(FAttrRefMap[C]);
  Count := AttrNames.Count;
  Result := AClass.Create(Count) as IMap;
  FRefList.Add(Result);
  for I := 0 to Count - 1 do Result[AttrNames[I]] := Unserialize;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadObjectAsMap(AClass: TMapClass): TAbstractMap;
var
  C: Variant;
  AttrNames: IList;
  I, Count: Integer;
begin
  C := FClassRefList[ReadInt(HproseTagOpenbrace)];
  AttrNames := VarToList(FAttrRefMap[C]);
  Count := AttrNames.Count;
  Result := AClass.Create(Count);
  FRefList.Add(ObjToVar(Result));
  for I := 0 to Count - 1 do Result[AttrNames[I]] := Unserialize;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadObjectAsInterface(AClass: TClass; const IID: TGUID): IInterface;
var
  C: Variant;
  RegisteredClass: TClass;
  AttrNames: IList;
  I, Count: Integer;
  Instance: TObject;
  PropInfo: PPropInfo;
begin
  C := FClassRefList[ReadInt(HproseTagOpenbrace)];
  if VarType(C) = varNativeInt then begin
    RegisteredClass := TClass(NativeInt(C));
    if (AClass = nil) or
       RegisteredClass.InheritsFrom(AClass) then AClass := RegisteredClass;
  end;
  AttrNames := VarToList(FAttrRefMap[C]);
  Count := AttrNames.Count;
  Instance := AClass.Create;
  Supports(Instance, IID, Result);
  FRefList.Add(Result);
  for I := 0 to Count - 1 do begin
    PropInfo := GetPropInfo(Instance, AttrNames[I]);
    if (PropInfo <> nil) then
      SetPropValue(Instance, PropInfo,
                   Unserialize(PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF}))
    else Unserialize;
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadObjectWithoutTag(AClass: TClass): TObject;
var
  C: Variant;
  RegisteredClass: TClass;
  AttrNames: IList;
  I, Count: Integer;
  PropInfo: PPropInfo;
begin
  C := FClassRefList[ReadInt(HproseTagOpenbrace)];
  if VarType(C) = varNativeInt then begin
    RegisteredClass := TClass(NativeInt(C));
    if (AClass = nil) or
       RegisteredClass.InheritsFrom(AClass) then AClass := RegisteredClass;
  end;
  AttrNames := VarToList(FAttrRefMap[C]);
  Count := AttrNames.Count;
  Result := AClass.Create;
  FRefList.Add(ObjToVar(Result));
  for I := 0 to Count - 1 do begin
    PropInfo := GetPropInfo(Result, AttrNames[I]);
    if (PropInfo <> nil) then
      SetPropValue(Result, PropInfo,
                   Unserialize(PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF}))
    else Unserialize;
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadObjectWithoutTag: Variant;
var
  C: Variant;
  AttrNames: IList;
  I, Count: Integer;
  AClass: TClass;
  AMap: IMap;
  Intf: IInterface;
  Instance: TObject;
  Map: TAbstractMap;
  PropInfo: PPropInfo;
begin
  C := FClassRefList[ReadInt(HproseTagOpenbrace)];
  AttrNames := VarToList(FAttrRefMap[C]);
  Count := AttrNames.Count;
  if VarType(C) = varNativeInt then begin
    AClass := TClass(NativeInt(C));
    if AClass.InheritsFrom(TInterfacedObject) and
       HasRegisterWithInterface(TInterfacedClass(AClass)) then begin
      Instance := AClass.Create;
      Supports(Instance, GetInterfaceByClass(TInterfacedClass(AClass)), Intf);
      Result := Intf;
    end
    else begin
      Instance := AClass.Create;
      Result := ObjToVar(Instance);
    end;
    FRefList.Add(Result);
    if Instance is TAbstractMap then begin
      Map := TAbstractMap(Instance);
      for I := 0 to Count - 1 do Map[AttrNames[I]] := Unserialize;
    end
    else for I := 0 to Count - 1 do begin
      PropInfo := GetPropInfo(Instance, AttrNames[I]);
      if (PropInfo <> nil) then
        SetPropValue(Instance, PropInfo,
                     Unserialize(PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF}))
      else Unserialize;
    end;
  end
  else begin
    AMap := TCaseInsensitiveHashMap.Create(Count) as IMap;
    Result := AMap;
    FRefList.Add(Result);
    for I := 0 to Count - 1 do AMap[AttrNames[I]] := Unserialize;
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadRef: Variant;
begin
  Result := FRefList[ReadInt(HproseTagSemicolon)];
end;

function CastError(const SrcType, DestType: string): EHproseException;
begin
  Result := EHproseException.Create(SrcType + ' can''t change to ' + DestType);
end;

function THproseReader.ReadInteger: Integer;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0': Result := 0;
    '1': Result := 1;
    '2': Result := 2;
    '3': Result := 3;
    '4': Result := 4;
    '5': Result := 5;
    '6': Result := 6;
    '7': Result := 7;
    '8': Result := 8;
    '9': Result := 9;
    htInteger,
    htLong: Result := ReadIntegerWithoutTag;
    htDouble: Result := Integer(Trunc(ReadDoubleWithoutTag));
    htNull,
    htEmpty,
    htFalse: Result := 0;
    htTrue: Result := 1;
    htUTF8Char: Result := StrToInt(string(ReadUTF8CharWithoutTag));
    htString: Result := StrToInt(ReadStringWithoutTag);
  else
    raise CastError(TagToString(Tag), 'Integer');
  end;
end;

function THproseReader.ReadInt64: Int64;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0': Result := 0;
    '1': Result := 1;
    '2': Result := 2;
    '3': Result := 3;
    '4': Result := 4;
    '5': Result := 5;
    '6': Result := 6;
    '7': Result := 7;
    '8': Result := 8;
    '9': Result := 9;
    htInteger,
    htLong: Result := ReadInt64(HproseTagSemicolon);
    htDouble: Result := Trunc(ReadDoubleWithoutTag);
    htNull,
    htEmpty,
    htFalse: Result := 0;
    htTrue: Result := 1;
    htUTF8Char: Result := StrToInt64(string(ReadUTF8CharWithoutTag));
    htString: Result := StrToInt64(ReadStringWithoutTag);
  else
    raise CastError(TagToString(Tag), 'Int64');
  end;
end;

{$IFDEF Supports_UInt64}
function THproseReader.ReadUInt64: UInt64;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0': Result := 0;
    '1': Result := 1;
    '2': Result := 2;
    '3': Result := 3;
    '4': Result := 4;
    '5': Result := 5;
    '6': Result := 6;
    '7': Result := 7;
    '8': Result := 8;
    '9': Result := 9;
    htInteger,
    htLong: Result := ReadUInt64(HproseTagSemicolon);
    htDouble: Result := Trunc(ReadDoubleWithoutTag);
    htNull,
    htEmpty,
    htFalse: Result := 0;
    htTrue: Result := 1;
{$IFDEF FPC}
    htUTF8Char: Result := StrToQWord(string(ReadUTF8CharWithoutTag));
    htString: Result := StrToQWord(ReadStringWithoutTag);
{$ELSE}
    htUTF8Char: Result := StrToInt64(string(ReadUTF8CharWithoutTag));
    htString: Result := StrToInt64(ReadStringWithoutTag);
{$ENDIF}
  else
    raise CastError(TagToString(Tag), 'UInt64');
  end;
end;
{$ENDIF}

function THproseReader.ReadExtended: Extended;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0': Result := 0;
    '1': Result := 1;
    '2': Result := 2;
    '3': Result := 3;
    '4': Result := 4;
    '5': Result := 5;
    '6': Result := 6;
    '7': Result := 7;
    '8': Result := 8;
    '9': Result := 9;
    htInteger,
    htLong,
    htDouble: Result := ReadDoubleWithoutTag;
    htNull,
    htEmpty,
    htFalse: Result := 0;
    htTrue: Result := 1;
    htNaN: Result := NaN;
    htInfinity: Result := ReadInfinityWithoutTag;
    htUTF8Char: Result := StrToFloat(string(ReadUTF8CharWithoutTag));
    htString: Result := StrToFloat(ReadStringWithoutTag);
  else
    raise CastError(TagToString(Tag), 'Extended');
  end;
end;

function THproseReader.ReadCurrency: Currency;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0': Result := 0;
    '1': Result := 1;
    '2': Result := 2;
    '3': Result := 3;
    '4': Result := 4;
    '5': Result := 5;
    '6': Result := 6;
    '7': Result := 7;
    '8': Result := 8;
    '9': Result := 9;
    htInteger,
    htLong,
    htDouble: Result := StrToCurr(ReadUntil(HproseTagSemicolon));
    htNull,
    htEmpty,
    htFalse: Result := 0;
    htTrue: Result := 1;
    htUTF8Char: Result := StrToCurr(string(ReadUTF8CharWithoutTag));
    htString: Result := StrToCurr(ReadStringWithoutTag);
  else
    raise CastError(TagToString(Tag), 'Currency');
  end;
end;

function THproseReader.ReadBoolean: Boolean;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0': Result := False;
    '1'..'9': Result := True;
    htInteger,
    htLong,
    htDouble: Result := ReadDoubleWithoutTag <> 0;
    htNull,
    htEmpty,
    htFalse: Result := False;
    htTrue: Result := True;
    htUTF8Char: Result := StrToBool(string(ReadUTF8CharWithoutTag));
    htString: Result := StrToBool(ReadStringWithoutTag);
  else
    raise CastError(TagToString(Tag), 'Boolean');
  end;
end;

function THproseReader.ReadDateTime: TDateTime;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0'..'9': Result := TimeStampToDateTime(MSecsToTimeStamp(Ord(Tag) - Ord('0')));
    htInteger: Result := TimeStampToDateTime(MSecsToTimeStamp(ReadIntegerWithoutTag));
    htLong: Result := TimeStampToDateTime(MSecsToTimeStamp(ReadInt64(HproseTagSemicolon)));
    htDouble: Result := TimeStampToDateTime(MSecsToTimeStamp(Trunc(ReadDoubleWithoutTag)));
    htDate: Result := ReadDateWithoutTag;
    htTime: Result := ReadTimeWithoutTag;
    htString: Result := StrToDateTime(ReadStringWithoutTag);
    htRef: Result := ReadRef;
  else
    raise CastError(TagToString(Tag), 'TDateTime');
  end;
end;

function THproseReader.ReadUTF8Char: WideChar;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0'..'9': Result := WideChar(Tag);
    htInteger,
    htLong: Result := WideChar(ReadIntegerWithoutTag);
    htDouble: Result := WideChar(Trunc(ReadDoubleWithoutTag));
    htNull: Result := #0;
    htUTF8Char: Result := ReadUTF8CharWithoutTag;
    htString: Result := ReadStringWithoutTag[1];
  else
    raise CastError(TagToString(Tag), 'WideChar');
  end;
end;

function THproseReader.ReadString: WideString;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0'..'9': Result := WideString(Tag);
    htInteger,
    htLong,
    htDouble: Result := ReadUntil(HproseTagSemicolon);
    htNull,
    htEmpty: Result := '';
    htFalse: Result := 'False';
    htTrue: Result := 'True';
    htNaN: Result := FloatToStr(NaN);
    htInfinity: Result := FloatToStr(ReadInfinityWithoutTag);
    htDate: Result := DateTimeToStr(ReadDateWithoutTag);
    htTime: Result := DateTimeToStr(ReadTimeWithoutTag);
    htUTF8Char: Result := WideString(ReadUTF8CharWithoutTag);
    htString: Result := ReadStringWithoutTag;
    htGuid: Result := WideString(ReadGuidWithoutTag);
    htRef: Result := ReadRef;
  else
    raise CastError(TagToString(Tag), 'String');
  end;
end;

function THproseReader.ReadBytes: Variant;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    htNull,
    htEmpty: Result := Null;
    htBytes: Result := ReadBytesWithoutTag;
    htList: Result := ReadDynArrayWithoutTag(varByte);
    htRef: Result := ReadRef;
  else
    raise CastError(TagToString(Tag), 'Byte');
  end;
end;

function THproseReader.ReadGuid: string;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    htNull,
    htEmpty: Result := '';
    htString: Result := GuidToString(StringToGuid(ReadStringWithoutTag));
    htGuid: Result := ReadGuidWithoutTag;
    htRef: Result := ReadRef;
  else
    raise CastError(TagToString(Tag), 'TGUID');
  end;
end;

function THproseReader.ReadDynArray(varType: Integer): Variant;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    htNull,
    htEmpty: Result := Null;
    htList: Result := ReadDynArrayWithoutTag(varType);
    htRef: Result := ReadRef;
  else
    raise CastError(TagToString(Tag), 'DynArray');
  end;
end;

function THproseReader.ReadVariantArray: TVariants;
var
  Tag: AnsiChar;
  I, Count: Integer;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    htNull,
    htEmpty: Result := Null;
    htList: begin
      Count := ReadInt(HproseTagOpenbrace);
      SetLength(Result, Count);
      FRefList.Add(Null);
      for I := 0 to Count - 1 do Result[I] := Unserialize;
      CheckTag(HproseTagClosebrace);
    end;
  else
    raise CastError(TagToString(Tag), 'TVariants');
  end;
end;

function THproseReader.ReadInterface(AClass: TClass; const IID: TGUID): IInterface;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    htNull,
    htEmpty: Result := nil;
    htList:
      if AClass.InheritsFrom(TAbstractList) then
        Result := ReadIList(AClass)
      else if AClass.InheritsFrom(TAbstractMap) then
        Result := ReadListAsIMap(AClass)
      else
        Result := nil;
    htMap:
      if AClass.InheritsFrom(TAbstractMap) then
        Result := ReadIMap(AClass)
      else
        Result := ReadMapAsInterface(AClass, IID);
    htClass: begin
      ReadClass;
      Result := ReadInterface(AClass, IID);
    end;
    htObject: begin
      if AClass.InheritsFrom(TAbstractMap) then
        Result := ReadObjectAsIMap(TMapClass(AClass))
      else
        Result := ReadObjectAsInterface(AClass, IID);
    end;
    htRef: Result := ReadRef;
  else
    raise CastError(TagToString(Tag), 'Interface');
  end;
end;

function THproseReader.ReadObject(AClass: TClass): TObject;
var
{$IFDEF Supports_Rtti}
  ClassName: string;
  TypeInfo: PTypeInfo;
{$ENDIF}
  Tag: AnsiChar;
begin
{$IFDEF Supports_Rtti}
  ClassName := AClass.ClassName;
  TypeInfo := PTypeInfo(AClass.ClassInfo);
{$ENDIF}
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    htNull,
    htEmpty: Result := nil;
    htList:
      if AClass.InheritsFrom(TAbstractList) then
        Result := ReadList(AClass)
      else if AClass.InheritsFrom(TAbstractMap) then
        Result := ReadListAsMap(AClass)
{$IFDEF Supports_Rtti}
      else if AnsiStartsText('TList<', ClassName) or
        AnsiStartsText('TObjectList<', ClassName) then
        Result := ReadTList(TypeInfo)
      else if AnsiStartsText('TQueue<', ClassName) or
        AnsiStartsText('TObjectQueue<', ClassName) then
        Result := ReadTQueue(TypeInfo)
      else if AnsiStartsText('TStack<', ClassName) or
        AnsiStartsText('TObjectStack<', ClassName) then
        Result := ReadTStack(TypeInfo)
{$ENDIF}
      else
        Result := nil;
    htMap:
      if AClass.InheritsFrom(TAbstractMap) then
        Result := ReadMap(AClass)
{$IFDEF Supports_Rtti}
      else if AnsiStartsText('TDictionary<', ClassName) or
        AnsiStartsText('TObjectDictionary<', ClassName) then
        Result := ReadTDictionary(TypeInfo)
{$ENDIF}
      else
        Result := ReadMapAsObject(AClass);
    htClass: begin
      ReadClass;
      Result := ReadObject(AClass);
    end;
    htObject: begin
      if AClass.InheritsFrom(TAbstractMap) then
        Result := ReadObjectAsMap(TMapClass(AClass))
      else
        Result := ReadObjectWithoutTag(AClass);
    end;
    htRef: Result := VarToObj(ReadRef);
  else
    raise CastError(TagToString(Tag), 'Object');
  end;
end;

{$IFDEF Supports_Generics}
procedure THproseReader.ReadArray<T>(var DynArray: TArray<T>; TypeInfo: PTypeInfo);
var
  Count, I: Integer;
begin
  Count := ReadInt(HproseTagOpenbrace);
  SetLength(DynArray, Count);
  FRefList.Add(NativeInt(Pointer(DynArray)));
  for I := 0 to Count - 1 do Unserialize(TypeInfo, DynArray[I]);
  CheckTag(HproseTagClosebrace);
end;

procedure THproseReader.ReadArray(TypeInfo: PTypeInfo; out DynArray);
var
  TypeName, ElementName: string;
  ElementTypeInfo: PTypeInfo;
  Size: Integer;
begin
  TypeName := GetTypeName(TypeInfo);
  ElementName := GetElementName(TypeName);
  ElementTypeInfo := GetTypeInfo(ElementName, Size);
  if ElementTypeInfo = nil then
    raise EHproseException.Create(ElementName + 'is not registered');
  case ElementTypeInfo^.Kind of
    tkString: ReadArray<ShortString>(TArray<ShortString>(DynArray), ElementTypeInfo);
    tkLString: ReadArray<AnsiString>(TArray<AnsiString>(DynArray), ElementTypeInfo);
    tkWString: ReadArray<WideString>(TArray<WideString>(DynArray), ElementTypeInfo);
    tkUString: ReadArray<UnicodeString>(TArray<UnicodeString>(DynArray), ElementTypeInfo);
    tkVariant: ReadArray<Variant>(TArray<Variant>(DynArray), ElementTypeInfo);
    tkDynArray: ReadArray<TArray<Pointer>>(TArray<TArray<Pointer>>(DynArray), ElementTypeInfo);
    tkInterface: ReadArray<IInterface>(TArray<IInterface>(DynArray), ElementTypeInfo);
    tkClass: ReadArray<TObject>(TArray<TObject>(DynArray), ElementTypeInfo);
  else
    case Size of
      1: ReadArray<TB1>(TArray<TB1>(DynArray), ElementTypeInfo);
      2: ReadArray<TB2>(TArray<TB2>(DynArray), ElementTypeInfo);
      4: ReadArray<TB4>(TArray<TB4>(DynArray), ElementTypeInfo);
      8: ReadArray<TB8>(TArray<TB8>(DynArray), ElementTypeInfo);
    else if GetTypeName(TypeInfo) = 'Extended' then
      ReadArray<Extended>(TArray<Extended>(DynArray), ElementTypeInfo)
    else
      raise EHproseException.Create('Can not unserialize ' + TypeName);
    end;
  end;
end;

type
  PDynArrayRec = ^TDynArrayRec;
  TDynArrayRec = packed record
  {$IFDEF CPUX64}
    _Padding: LongInt; // Make 16 byte align for payload..
  {$ENDIF}
    RefCnt: LongInt;
    Length: NativeInt;
  end;

procedure DynArrayAddRef(P: Pointer);
begin
  if P <> nil then
    Inc(PDynArrayRec(PByte(P) - SizeOf(TDynArrayRec))^.RefCnt);
end;

procedure THproseReader.ReadDynArray(TypeInfo: PTypeInfo; out DynArray);
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    htNull,
    htEmpty: Pointer(DynArray) := nil;
    htList: ReadArray(TypeInfo, DynArray);
    htRef: begin
      Pointer(DynArray) := Pointer(NativeInt(ReadRef));
      DynArrayAddRef(Pointer(DynArray));
    end;
  else
    raise CastError(TagToString(Tag), 'DynArray');
  end;
end;

{$IFDEF Supports_Rtti}
function THproseReader.ReadTList<T>(TypeInfo, ElementTypeInfo: PTypeInfo): TList<T>;
var
  Count, I: Integer;
  AClass: TClass;
  Context: TRttiContext;
  RttiType: TRttiType;
  RttiMethod: TRttiMethod;
begin
  Count := ReadInt(HproseTagOpenbrace);
  AClass := GetTypeData(TypeInfo)^.ClassType;
  Context := TRttiContext.Create;
  RttiType := Context.GetType(AClass);
  RttiMethod := RttiType.GetMethod('Create');
  Result := TList<T>(RttiMethod.Invoke(AClass, []).AsObject);
  RttiMethod.Free;
  RttiType.Free;
  Context.Free;
  Result.Count := Count;
  FRefList.Add(ObjToVar(Result));
  for I := 0 to Count - 1 do Result[I] := UnserializeTypeAsT<T>(ElementTypeInfo);
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadTList(TypeInfo: PTypeInfo): TObject;
var
  TypeName, ElementName: string;
  ElementTypeInfo: PTypeInfo;
  Size: Integer;
begin
  TypeName := GetTypeName(TypeInfo);
  ElementName := GetElementName(TypeName);
  ElementTypeInfo := GetTypeInfo(ElementName, Size);
  if ElementTypeInfo = nil then
    raise EHproseException.Create(ElementName + 'is not registered');
  case ElementTypeInfo^.Kind of
    tkString: Result := ReadTList<ShortString>(TypeInfo, ElementTypeInfo);
    tkLString: Result := ReadTList<AnsiString>(TypeInfo, ElementTypeInfo);
    tkWString: Result := ReadTList<WideString>(TypeInfo, ElementTypeInfo);
    tkUString: Result := ReadTList<UnicodeString>(TypeInfo, ElementTypeInfo);
    tkVariant: Result := ReadTList<Variant>(TypeInfo, ElementTypeInfo);
    tkDynArray: Result := ReadTList<TArray<Pointer>>(TypeInfo, ElementTypeInfo);
    tkInterface: Result := ReadTList<IInterface>(TypeInfo, ElementTypeInfo);
    tkClass: Result := ReadTList<TObject>(TypeInfo, ElementTypeInfo);
  else
    case Size of
      1: Result := ReadTList<TB1>(TypeInfo, ElementTypeInfo);
      2: Result := ReadTList<TB2>(TypeInfo, ElementTypeInfo);
      4: Result := ReadTList<TB4>(TypeInfo, ElementTypeInfo);
      8: Result := ReadTList<TB8>(TypeInfo, ElementTypeInfo);
    else if GetTypeName(TypeInfo) = 'Extended' then
      Result := ReadTList<Extended>(TypeInfo, ElementTypeInfo)
    else
      raise EHproseException.Create('Can not unserialize ' + TypeName);
    end;
  end;
end;

function THproseReader.ReadTQueue<T>(TypeInfo, ElementTypeInfo: PTypeInfo): TQueue<T>;
var
  Count, I: Integer;
  AClass: TClass;
  Context: TRttiContext;
  RttiType: TRttiType;
  RttiMethod: TRttiMethod;
begin
  Count := ReadInt(HproseTagOpenbrace);
  AClass := GetTypeData(TypeInfo)^.ClassType;
  Context := TRttiContext.Create;
  RttiType := Context.GetType(AClass);
  RttiMethod := RttiType.GetMethod('Create');
  Result := TQueue<T>(RttiMethod.Invoke(AClass, []).AsObject);
  RttiMethod.Free;
  RttiType.Free;
  Context.Free;
  FRefList.Add(ObjToVar(Result));
  for I := 1 to Count do Result.Enqueue(UnserializeTypeAsT<T>(ElementTypeInfo));
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadTQueue(TypeInfo: PTypeInfo): TObject;
var
  TypeName, ElementName: string;
  ElementTypeInfo: PTypeInfo;
  Size: Integer;
begin
  TypeName := GetTypeName(TypeInfo);
  ElementName := GetElementName(TypeName);
  ElementTypeInfo := GetTypeInfo(ElementName, Size);
  if ElementTypeInfo = nil then
    raise EHproseException.Create(ElementName + 'is not registered');
  case ElementTypeInfo^.Kind of
    tkString: Result := ReadTQueue<ShortString>(TypeInfo, ElementTypeInfo);
    tkLString: Result := ReadTQueue<AnsiString>(TypeInfo, ElementTypeInfo);
    tkWString: Result := ReadTQueue<WideString>(TypeInfo, ElementTypeInfo);
    tkUString: Result := ReadTQueue<UnicodeString>(TypeInfo, ElementTypeInfo);
    tkVariant: Result := ReadTQueue<Variant>(TypeInfo, ElementTypeInfo);
    tkDynArray: Result := ReadTQueue<TArray<Pointer>>(TypeInfo, ElementTypeInfo);
    tkInterface: Result := ReadTQueue<IInterface>(TypeInfo, ElementTypeInfo);
    tkClass: Result := ReadTQueue<TObject>(TypeInfo, ElementTypeInfo);
  else
    case Size of
      1: Result := ReadTQueue<TB1>(TypeInfo, ElementTypeInfo);
      2: Result := ReadTQueue<TB2>(TypeInfo, ElementTypeInfo);
      4: Result := ReadTQueue<TB4>(TypeInfo, ElementTypeInfo);
      8: Result := ReadTQueue<TB8>(TypeInfo, ElementTypeInfo);
    else if GetTypeName(TypeInfo) = 'Extended' then
      Result := ReadTQueue<Extended>(TypeInfo, ElementTypeInfo)
    else
      raise EHproseException.Create('Can not unserialize ' + TypeName);
    end;
  end;
end;

function THproseReader.ReadTStack<T>(TypeInfo, ElementTypeInfo: PTypeInfo): TStack<T>;
var
  Count, I: Integer;
  AClass: TClass;
begin
  Count := ReadInt(HproseTagOpenbrace);
  AClass := GetTypeData(TypeInfo)^.ClassType;
  Result := TStack<T>(AClass.Create);
  FRefList.Add(ObjToVar(Result));
  for I := 1 to Count do Result.Push(UnserializeTypeAsT<T>(ElementTypeInfo));
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadTStack(TypeInfo: PTypeInfo): TObject;
var
  TypeName, ElementName: string;
  ElementTypeInfo: PTypeInfo;
  Size: Integer;
begin
  TypeName := GetTypeName(TypeInfo);
  ElementName := GetElementName(TypeName);
  ElementTypeInfo := GetTypeInfo(ElementName, Size);
  if ElementTypeInfo = nil then
    raise EHproseException.Create(ElementName + 'is not registered');
  case ElementTypeInfo^.Kind of
    tkString: Result := ReadTStack<ShortString>(TypeInfo, ElementTypeInfo);
    tkLString: Result := ReadTStack<AnsiString>(TypeInfo, ElementTypeInfo);
    tkWString: Result := ReadTStack<WideString>(TypeInfo, ElementTypeInfo);
    tkUString: Result := ReadTStack<UnicodeString>(TypeInfo, ElementTypeInfo);
    tkVariant: Result := ReadTStack<Variant>(TypeInfo, ElementTypeInfo);
    tkDynArray: Result := ReadTStack<TArray<Pointer>>(TypeInfo, ElementTypeInfo);
    tkInterface: Result := ReadTStack<IInterface>(TypeInfo, ElementTypeInfo);
    tkClass: Result := ReadTStack<TObject>(TypeInfo, ElementTypeInfo);
  else
    case Size of
      1: Result := ReadTStack<TB1>(TypeInfo, ElementTypeInfo);
      2: Result := ReadTStack<TB2>(TypeInfo, ElementTypeInfo);
      4: Result := ReadTStack<TB4>(TypeInfo, ElementTypeInfo);
      8: Result := ReadTStack<TB8>(TypeInfo, ElementTypeInfo);
    else if GetTypeName(TypeInfo) = 'Extended' then
      Result := ReadTStack<Extended>(TypeInfo, ElementTypeInfo)
    else
      raise EHproseException.Create('Can not unserialize ' + TypeName);
    end;
  end;
end;

function THproseReader.ReadTDictionary2<TKey, TValue>(
  TypeInfo, KeyTypeInfo, ValueTypeInfo: PTypeInfo): TDictionary<TKey, TValue>;
var
  Count, I: Integer;
  Key: TKey;
  Value: TValue;
  AClass: TClass;
  Context: TRttiContext;
  RttiType: TRttiType;
  RttiMethod: TRttiMethod;
begin
  Count := ReadInt(HproseTagOpenbrace);
  AClass := GetTypeData(TypeInfo)^.ClassType;
  Context := TRttiContext.Create;
  RttiType := Context.GetType(AClass);
  RttiMethod := RttiType.GetMethod('Create');
  Result := TDictionary<TKey, TValue>(RttiMethod.Invoke(AClass, [Count]).AsObject);
  RttiMethod.Free;
  RttiType.Free;
  Context.Free;
  FRefList.Add(ObjToVar(Result));
  for I := 1 to Count do begin
    Unserialize(KeyTypeInfo, Key);
    Unserialize(ValueTypeInfo, Value);
    Result.Add(Key, Value);
  end;
  CheckTag(HproseTagClosebrace);
end;

function THproseReader.ReadTDictionary1<TKey>(TypeInfo, KeyTypeInfo,
   ValueTypeInfo: PTypeInfo; ValueSize: Integer): TObject;
begin
  case ValueTypeInfo^.Kind of
    tkString: Result := ReadTDictionary2<TKey, ShortString>(
                TypeInfo, KeyTypeInfo, ValueTypeInfo);
    tkLString: Result := ReadTDictionary2<TKey, AnsiString>(
                 TypeInfo, KeyTypeInfo, ValueTypeInfo);
    tkWString: Result := ReadTDictionary2<TKey, WideString>(
                 TypeInfo, KeyTypeInfo, ValueTypeInfo);
    tkUString: Result := ReadTDictionary2<TKey, UnicodeString>(
                 TypeInfo, KeyTypeInfo, ValueTypeInfo);
    tkVariant: Result := ReadTDictionary2<TKey, Variant>(
                 TypeInfo, KeyTypeInfo, ValueTypeInfo);
    tkDynArray: Result := ReadTDictionary2<TKey, TArray<Pointer>>(
                  TypeInfo, KeyTypeInfo, ValueTypeInfo);
    tkInterface: Result := ReadTDictionary2<TKey, IInterface>(
                   TypeInfo, KeyTypeInfo, ValueTypeInfo);
    tkClass: Result := ReadTDictionary2<TKey, TObject>(
               TypeInfo, KeyTypeInfo, ValueTypeInfo);
  else
    case ValueSize of
      1: Result := ReadTDictionary2<TKey, TB1>(
           TypeInfo, KeyTypeInfo, ValueTypeInfo);
      2: Result := ReadTDictionary2<TKey, TB2>(
           TypeInfo, KeyTypeInfo, ValueTypeInfo);
      4: Result := ReadTDictionary2<TKey, TB4>(
           TypeInfo, KeyTypeInfo, ValueTypeInfo);
      8: Result := ReadTDictionary2<TKey, TB8>(
           TypeInfo, KeyTypeInfo, ValueTypeInfo);
    else if GetTypeName(ValueTypeInfo) = 'Extended' then
      Result := ReadTDictionary2<TKey, Extended>(
        TypeInfo, KeyTypeInfo, ValueTypeInfo)
    else
      raise EHproseException.Create('Can not unserialize ' + GetTypeName(TypeInfo));
    end;
  end;
end;

function THproseReader.ReadTDictionary(TypeInfo: PTypeInfo): TObject;
var
  TypeName, KeyName, ValueName: string;
  KeyTypeInfo, ValueTypeInfo: PTypeInfo;
  KeySize, ValueSize: Integer;
begin
  TypeName := GetTypeName(TypeInfo);
  SplitKeyValueTypeName(GetElementName(TypeName), KeyName, ValueName);
  KeyTypeInfo := GetTypeInfo(KeyName, KeySize);
  ValueTypeInfo := GetTypeInfo(ValueName, ValueSize);
  if KeyTypeInfo = nil then
    raise EHproseException.Create(KeyName + 'is not registered');
  if ValueTypeInfo = nil then
    raise EHproseException.Create(ValueName + 'is not registered');
  case KeyTypeInfo^.Kind of
    tkString: Result := ReadTDictionary1<ShortString>(TypeInfo, KeyTypeInfo,
                          ValueTypeInfo, ValueSize);
    tkLString: Result := ReadTDictionary1<AnsiString>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
    tkWString: Result := ReadTDictionary1<WideString>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
    tkUString: Result := ReadTDictionary1<UnicodeString>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
    tkVariant: Result := ReadTDictionary1<Variant>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
    tkDynArray: Result := ReadTDictionary1<TArray<Pointer>>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
    tkInterface: Result := ReadTDictionary1<IInterface>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
    tkClass: Result := ReadTDictionary1<TObject>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
  else
    case KeySize of
      1: Result := ReadTDictionary1<TB1>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
      2: Result := ReadTDictionary1<TB2>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
      4: Result := ReadTDictionary1<TB4>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
      8: Result := ReadTDictionary1<TB8>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize);
    else if GetTypeName(KeyTypeInfo) = 'Extended' then
      Result := ReadTDictionary1<Extended>(TypeInfo, KeyTypeInfo,
                           ValueTypeInfo, ValueSize)
    else
      raise EHproseException.Create('Can not unserialize ' + TypeName);
    end;
  end;
end;

function THproseReader.UnserializeTypeAsT<T>(TypeInfo: PTypeInfo): T;
begin
  Unserialize(TypeInfo, Result);
end;
{$ENDIF}

function THproseReader.ReadSmartObject(TypeInfo: PTypeInfo): ISmartObject;
var
  TypeName, ElementName: string;
  ElementTypeInfo: PTypeInfo;
  AObject: TObject;
begin
  TypeName := GetTypeName(TypeInfo);
  if not IsSmartObject(TypeName) then
    raise EHproseException.Create(TypeName + ' is not a ISmartObject interface');
  ElementName := GetElementName(TypeName);
  TypeName := 'TSmartObject<' + ElementName + '>';
  TypeInfo := TTypeManager.TypeInfo(TypeName);
  ElementTypeInfo := TTypeManager.TypeInfo(ElementName);
  if (TypeInfo = nil) or (ElementTypeInfo = nil) then
    raise EHproseException.Create(ElementName + 'is not registered');
  if ElementTypeInfo^.Kind <> tkClass then
    raise EHproseException.Create(ElementName + 'is not a Class');
  AObject := ReadObject(GetTypeData(ElementTypeInfo)^.ClassType);
  Result := TSmartClass(GetTypeData(TypeInfo)^.ClassType).Create(AObject) as ISmartObject;
end;

procedure THproseReader.Unserialize(TypeInfo: PTypeInfo; out Value);
var
  TypeData: PTypeData;
  TypeName: string;
  AClass: TClass;
begin
  TypeName := GetTypeName(TypeInfo);
  if TypeName = 'Boolean' then
    Boolean(Value) := ReadBoolean
  else if (TypeName = 'TDateTime') or
          (TypeName = 'TDate') or
          (TypeName = 'TTime') then
    TDateTime(Value) := ReadDateTime
{$IFDEF DELPHI2009_UP}
  else if TypeName = 'UInt64' then
    UInt64(Value) := ReadUInt64
{$ENDIF}
  else begin
    TypeData := GetTypeData(TypeInfo);
    case TypeInfo^.Kind of
      tkInteger, tkEnumeration, tkSet:
        case TypeData^.OrdType of
          otSByte:
            ShortInt(Value) := ShortInt(ReadInteger);
          otUByte:
            Byte(Value) := Byte(ReadInteger);
          otSWord:
            SmallInt(Value) := SmallInt(ReadInteger);
          otUWord:
            Word(Value) := Word(ReadInteger);
          otSLong:
            Integer(Value) := ReadInteger;
          otULong:
            LongWord(Value) := LongWord(ReadInt64);
        end;
      tkChar:
        AnsiChar(Value) := AnsiChar(ReadUTF8Char);
      tkWChar:
        WideChar(Value) := ReadUTF8Char;
{$IFDEF FPC}
      tkBool:
        Boolean(Value) := ReadBoolean;
      tkQWord:
        QWord(Value) := ReadUInt64;
{$ENDIF}
      tkFloat:
        case TypeData^.FloatType of
          ftSingle:
            Single(Value) := ReadExtended;
          ftDouble:
            Double(Value) := ReadExtended;
          ftExtended:
            Extended(Value) := ReadExtended;
          ftComp:
            Comp(Value) := ReadInt64;
          ftCurr:
            Currency(Value) := ReadCurrency;
        end;
      tkString:
        ShortString(Value) := ShortString(ReadString());
      tkLString{$IFDEF FPC}, tkAString{$ENDIF}:
        AnsiString(Value) := AnsiString(ReadString);
      tkWString:
        WideString(Value) := ReadString;
{$IFDEF DELPHI2009_UP}
      tkUString:
        UnicodeString(Value) := UnicodeString(ReadString);
{$ENDIF}
      tkInt64:
        Int64(Value) := ReadInt64;
      tkInterface: begin
        AClass := GetClassByInterface(TypeData^.Guid);
        if AClass = nil then
          raise EHproseException.Create(GetTypeName(TypeInfo) + ' is not registered')
        else if Supports(AClass, ISmartObject) then
          ISmartObject(Value) := ReadSmartObject(TypeInfo)
        else
          IInterface(Value) := ReadInterface(AClass, TypeData^.Guid);
      end;
      tkDynArray:
        ReadDynArray(TypeInfo, Value);
      tkClass: begin
        AClass := TypeData^.ClassType;
        TObject(Value) := ReadObject(AClass);
      end;
    end;
  end;
end;

function THproseReader.Unserialize<T>: T;
begin
  Unserialize(TypeInfo(T), Result);
end;

{$ENDIF}

function THproseReader.Unserialize: Variant;
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  case Tag of
    '0'..'9': Result := Ord(Tag) - Ord('0');
    htInteger: Result := ReadIntegerWithoutTag;
    htLong: Result := ReadLongWithoutTag;
    htDouble: Result := ReadDoubleWithoutTag;
    htNaN: Result := NaN;
    htInfinity: Result := ReadInfinityWithoutTag;
    htTrue: Result := True;
    htFalse: Result := False;
    htNull: Result := Null;
    htEmpty: Result := '';
    htDate: Result := ReadDateWithoutTag;
    htTime: Result := ReadTimeWithoutTag;
    htBytes: Result := ReadBytesWithoutTag;
    htUTF8Char: Result := ReadUTF8CharWithoutTag;
    htString: Result := ReadStringWithoutTag;
    htGuid: Result := ReadGuidWithoutTag;
    htList: Result := ReadListWithoutTag;
    htMap: Result := ReadMapWithoutTag;
    htClass: begin
      ReadClass;
      Result := Unserialize;
    end;
    htObject: Result := ReadObjectWithoutTag;
    htRef: Result := ReadRef;
  else
    raise EHproseException.Create(TagToString(Tag) + 'can''t unserialize');
  end;
end;

function THproseReader.Unserialize(TypeInfo: PTypeInfo): Variant;
var
  TypeData: PTypeData;
  TypeName: string;
  AClass: TClass;
begin
  if TypeInfo = nil then Result := Unserialize
  else begin
    Result := Unassigned;
    TypeName := GetTypeName(TypeInfo);
    if TypeName = 'Boolean' then
      Result := ReadBoolean
    else if (TypeName = 'TDateTime') or
            (TypeName = 'TDate') or
            (TypeName = 'TTime') then
      Result := ReadDateTime
{$IFDEF DELPHI2009_UP}
    else if TypeName = 'UInt64' then
      Result := ReadUInt64
{$ENDIF}
    else begin
      TypeData := GetTypeData(TypeInfo);
      case TypeInfo^.Kind of
        tkInteger, tkEnumeration, tkSet:
          case TypeData^.OrdType of
            otSByte:
              Result := ShortInt(ReadInteger);
            otUByte:
              Result := Byte(ReadInteger);
            otSWord:
              Result := SmallInt(ReadInteger);
            otUWord:
              Result := Word(ReadInteger);
            otSLong:
              Result := ReadInteger;
            otULong:
              Result := LongWord(ReadInt64);
          end;
        tkChar: begin
          Result := AnsiChar(ReadUTF8Char);
        end;
        tkWChar: begin
          Result := ReadUTF8Char;
        end;
{$IFDEF FPC}
        tkBool:
          Result := ReadBoolean;
        tkQWord:
          Result := ReadUInt64;
{$ENDIF}
        tkFloat:
          case TypeData^.FloatType of
            ftSingle:
              Result := VarAsType(ReadExtended, varSingle);
            ftDouble, ftExtended:
              Result := ReadExtended;
            ftComp:
              Result := ReadInt64;
            ftCurr:
              Result := ReadCurrency;
          end;
        tkString:
          Result := ShortString(ReadString());
        tkLString{$IFDEF FPC}, tkAString{$ENDIF}:
          Result := AnsiString(ReadString);
        tkWString:
          Result := ReadString;
{$IFDEF DELPHI2009_UP}
        tkUString:
          Result := UnicodeString(ReadString);
{$ENDIF}
        tkInt64:
          Result := ReadInt64;
        tkInterface: begin
          AClass := GetClassByInterface(TypeData^.Guid);
          if AClass = nil then
            raise EHproseException.Create(GetTypeName(TypeInfo) + ' is not registered');
          Result := ReadInterface(AClass, TypeData^.Guid);
        end;
        tkDynArray:
          Result := ReadDynArray(TypeData^.varType and not varArray);
        tkClass: begin
          AClass := TypeData^.ClassType;
          Result := ObjToVar(ReadObject(AClass));
        end;
      end;
    end;
  end;
end;

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
  OStream.WriteBuffer(Tag, 1);
  case Tag of
    '0'..'9',
    htNull,
    htEmpty,
    htTrue,
    htFalse,
    htNaN: begin end;
    htInfinity: ReadInfinityRaw(OStream);
    htInteger,
    htLong,
    htDouble,
    htRef: ReadNumberRaw(OStream);
    htDate,
    htTime: ReadDateTimeRaw(OStream);
    htUTF8Char: ReadUTF8CharRaw(OStream);
    htBytes: ReadBytesRaw(OStream);
    htString: ReadStringRaw(OStream);
    htGuid: ReadGuidRaw(OStream);
    htList,
    htMap,
    htObject: ReadComplexRaw(OStream);
    htClass: begin
      ReadComplexRaw(OStream);
      ReadRaw(OStream);
    end;
    htError: begin
      ReadRaw(OStream);
    end;
  else
    raise EHproseException.Create('Unexpected serialize tag "' +
                                  Tag + '" in stream');
  end;
end;

procedure THproseReader.ReadInfinityRaw(const OStream: TStream);
var
  Tag: AnsiChar;
begin
  FStream.ReadBuffer(Tag, 1);
  OStream.WriteBuffer(Tag, 1);
end;

procedure THproseReader.ReadNumberRaw(const OStream: TStream);
var
  Tag: AnsiChar;
begin
  repeat
    FStream.ReadBuffer(Tag, 1);
    OStream.WriteBuffer(Tag, 1);
  until (Tag = HproseTagSemicolon);
end;

procedure THproseReader.ReadDateTimeRaw(const OStream: TStream);
var
  Tag: AnsiChar;
begin
  repeat
    FStream.ReadBuffer(Tag, 1);
    OStream.WriteBuffer(Tag, 1);
  until (Tag = HproseTagSemicolon) or
        (Tag = HproseTagUTC);
end;

procedure THproseReader.ReadUTF8CharRaw(const OStream: TStream);
var
  Tag: AnsiChar;
begin
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

procedure THproseReader.ReadBytesRaw(const OStream: TStream);
var
  Tag: AnsiChar;
  Len: Integer;
begin
  Len := 0;
  Tag := '0';
  repeat
    Len := Len * 10 + (Ord(Tag) - Ord('0'));
    FStream.ReadBuffer(Tag, 1);
    OStream.WriteBuffer(Tag, 1);
  until (Tag = HproseTagQuote);
  OStream.CopyFrom(FStream, Len + 1);
end;

procedure THproseReader.ReadStringRaw(const OStream: TStream);
var
  Tag: AnsiChar;
  Len, I: Integer;
begin
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

procedure THproseReader.ReadGuidRaw(const OStream: TStream);
begin
  OStream.CopyFrom(FStream, 38);
end;

procedure THproseReader.ReadComplexRaw(const OStream: TStream);
var
  Tag: AnsiChar;
begin
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
  ASmartObject: ISmartObject;
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
        WriteWideString(Value);
      varDate:
        WriteDateTimeWithRef(Value);
      varUnknown:
        if (IInterface(Value) = nil) then
          WriteNull
        else if Supports(IInterface(Value), IList, AList) then
          WriteListWithRef(AList)
        else if Supports(IInterface(Value), IMap, AMap) then
          WriteMapWithRef(AMap)
        else if Supports(IInterface(Value), ISmartObject, ASmartObject) then
          WriteSmartObjectWithRef(ASmartObject)
        else
          WriteInterfaceWithRef(IInterface(Value));
    else
      if VType and varArray = varArray then
        if (VType and varTypeMask = varByte) and
           (VarArrayDimCount(Value) = 1) then
          WriteBytesWithRef(Value)
        else
          WriteArrayWithRef(Value)
      else if VType and not varByRef = varObject then begin
        Obj := VarToObj(Value);
        if Obj = nil then WriteNull else WriteObjectWithRef(Obj);
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
  ASmartObject: ISmartObject;
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
      vtString:        WriteStringWithRef(WideString(VString^));
      vtPChar:         WriteStringWithRef(WideString(AnsiString(VPChar)));
      vtObject:
        if VObject = nil then WriteNull else WriteObjectWithRef(VObject);
      vtWideChar:      WriteUTF8Char(VWideChar);
      vtPWideChar:     WriteStringWithRef(WideString(VPWideChar));
      vtAnsiString:    WriteStringWithRef(WideString(AnsiString(VAnsiString)));
      vtCurrency:      WriteCurrency(VCurrency^);
      vtVariant:       Serialize(VVariant^);
      vtInterface:
        if IInterface(VInterface) = nil then
          WriteNull
        else if Supports(IInterface(VInterface), IList, AList) then
          WriteListWithRef(AList)
        else if Supports(IInterface(VInterface), IMap, AMap) then
          WriteMapWithRef(AMap)
        else if Supports(IInterface(VInterface), ISmartObject, ASmartObject) then
          WriteSmartObjectWithRef(ASmartObject)
        else
          WriteInterfaceWithRef(IInterface(VInterface));
      vtWideString:    WriteStringWithRef(WideString(VWideString));
      vtInt64:         WriteLong(VInt64^);
{$IFDEF FPC}
      vtQWord:         WriteLong(VQWord^);
{$ENDIF}
{$IFDEF DELPHI2009_UP}
      vtUnicodeString: WriteStringWithRef(UnicodeString(VUnicodeString));
{$ENDIF}
    else
      WriteNull;
    end;
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteArray(const Value: Variant);
var
  PVar: PVarData;
  P: Pointer;
  Rank, Count, MaxRank, I, N: Integer;
  Des: array of array[0..1] of Integer;
  Loc, Len: array of Integer;
begin
  FRefList.Add(Value);
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

procedure THproseWriter.WriteArrayWithRef(const Value: Variant);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(Value);
  if Ref > -1 then WriteRef(Ref) else WriteArray(Value);
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

procedure THproseWriter.WriteBytes(const Bytes: Variant);
var
  N: Integer;
begin
  FRefList.Add(Bytes);
  N := VarArrayHighBound(Bytes, 1) - VarArrayLowBound(Bytes, 1) + 1;
  FStream.WriteBuffer(HproseTagBytes, 1);
  WriteRawByteString(RawByteString(IntToStr(N)));
  FStream.WriteBuffer(HproseTagQuote, 1);
  FStream.WriteBuffer(VarArrayLock(Bytes)^, N);
  VarArrayUnLock(Bytes);
  FStream.WriteBuffer(HproseTagQuote, 1);
end;

procedure THproseWriter.WriteBytesWithRef(const Bytes: Variant);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(Bytes);
  if Ref > -1 then WriteRef(Ref) else WriteBytes(Bytes);
end;

function THproseWriter.WriteClass(const Instance: TObject): Integer;
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
    CachePointer := PSerializeCache(NativeInt(PropertiesCache[ClassAlias]));
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
      PropertiesCache[ClassAlias] := NativeInt(CachePointer);
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
  for I := 0 to Count - 1 do WriteDateTimeWithRef(AP^[I]);
end;

procedure THproseWriter.WriteDateTime(const ADateTime: TDateTime);
var
  ADate, ATime, AMillisecond: RawByteString;
begin
  FRefList.Add(ADateTime);
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

procedure THproseWriter.WriteDateTimeWithRef(const ADateTime: TDateTime);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(ADateTime);
  if Ref > -1 then WriteRef(Ref) else WriteDateTime(ADateTime);
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

procedure THproseWriter.WriteList(const AList: IList);
var
  Count, I: Integer;
begin
  FRefList.Add(AList);
  Count := AList.Count;
  FStream.WriteBuffer(HproseTagList, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for I := 0 to Count - 1 do Serialize(AList[I]);
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteListWithRef(const AList: IList);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(AList);
  if Ref > -1 then WriteRef(Ref) else WriteList(AList);
end;

procedure THproseWriter.WriteList(const AList: TAbstractList);
var
  Count, I: Integer;
begin
  FRefList.Add(ObjToVar(AList));
  Count := AList.Count;
  FStream.WriteBuffer(HproseTagList, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for I := 0 to Count - 1 do Serialize(AList[I]);
  FStream.WriteBuffer(HproseTagClosebrace, 1);
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

procedure THproseWriter.WriteMap(const AMap: IMap);
var
  Count, I: Integer;
begin
  FRefList.Add(AMap);
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

procedure THproseWriter.WriteMapWithRef(const AMap: IMap);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(AMap);
  if Ref > -1 then WriteRef(Ref) else WriteMap(AMap);
end;

procedure THproseWriter.WriteMap(const AMap: TAbstractMap);
var
  Count, I: Integer;
begin
  FRefList.Add(ObjToVar(AMap));
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

procedure THproseWriter.WriteObject(const AObject: TObject);
var
  ClassRef: Integer;
  Value: Variant;
  PropList: PPropList;
  PropCount, I: Integer;
  ClassName: string;
begin
  ClassName := AObject.ClassName;
  if AObject is TAbstractList then WriteList(TAbstractList(AObject))
  else if AObject is TAbstractMap then WriteMap(TAbstractMap(AObject))
  else if AObject is TStrings then WriteStrings(TStrings(AObject))
  else
{$IFDEF Supports_Generics}
  if AnsiStartsText('TList<', ClassName) then
    WriteList(AObject)
  else if AnsiStartsText('TQueue<', ClassName) then
    WriteQueue(AObject)
  else if AnsiStartsText('TStack<', ClassName) then
    WriteStack(AObject)
  else if AnsiStartsText('TDictionary<', ClassName) then
    WriteDictionary(AObject)
  else if AnsiStartsText('TObjectList<', ClassName) then
    WriteObjectList(AObject)
  else if AnsiStartsText('TObjectQueue<', ClassName) then
    WriteObjectQueue(AObject)
  else if AnsiStartsText('TObjectStack<', ClassName) then
    WriteObjectStack(AObject)
  else if AnsiStartsText('TObjectDictionary<', ClassName) then
    WriteObjectDictionary(AObject)
  else
{$ENDIF}
  begin
    Value := ObjToVar(AObject);
    ClassRef := FClassRefList.IndexOf(ClassName);
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
end;

procedure THproseWriter.WriteObjectWithRef(const AObject: TObject);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(ObjToVar(AObject));
  if Ref > -1 then WriteRef(Ref) else WriteObject(AObject);
end;

procedure THproseWriter.WriteInterface(const Intf: IInterface);
var
  ClassRef: Integer;
  AObject: TObject;
  PropList: PPropList;
  PropCount, I: Integer;
begin
  AObject := IntfToObj(Intf);
  ClassRef := FClassRefList.IndexOf(AObject.ClassName);
  if ClassRef < 0 then ClassRef := WriteClass(AObject);
  FRefList.Add(Intf);
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

procedure THproseWriter.WriteInterfaceWithRef(const Intf: IInterface);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(Intf);
  if Ref > -1 then WriteRef(Ref) else WriteInterface(Intf);
end;

procedure THproseWriter.WriteSmartObject(const SmartObject: ISmartObject);
begin
  WriteObject(SmartObject.Value);
end;

procedure THproseWriter.WriteSmartObjectWithRef(const SmartObject: ISmartObject);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(ObjToVar(SmartObject.Value));
  if Ref > -1 then
    WriteRef(Ref)
  else if SmartObject.Value is TStrings then
    WriteStrings(TStrings(SmartObject.Value))
  else
    WriteObject(SmartObject.Value);
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

procedure THproseWriter.WriteString(const S: WideString);
begin
  FRefList.Add(S);
  FStream.WriteBuffer(HproseTagString, 1);
  WriteRawByteString(RawByteString(IntToStr(Length(S))));
  FStream.WriteBuffer(HproseTagQuote, 1);
  WriteRawByteString(UTF8Encode(S));
  FStream.WriteBuffer(HproseTagQuote, 1);
end;

procedure THproseWriter.WriteStringWithRef(const S: WideString);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(S);
  if Ref > -1 then WriteRef(Ref) else WriteString(S);
end;

procedure THproseWriter.WriteStrings(const SS: TStrings);
var
  Count, I: Integer;
begin
  FRefList.Add(ObjToVar(SS));
  Count := SS.Count;
  FStream.WriteBuffer(HproseTagList, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for I := 0 to Count - 1 do WriteStringWithRef(SS[I]);
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteVariantArray(var P; Count: Integer);
var
  AP: PVariantArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do Serialize(AP^[I]);
end;

procedure THproseWriter.WriteWideString(const Str: WideString);
begin
  case Length(Str) of
    0: WriteEmpty;
    1: WriteUTF8Char(Str[1]);
  else
    WriteStringWithRef(Str);
  end;
end;

procedure THproseWriter.WriteWideStringArray(var P; Count: Integer);
var
  AP: PWideStringArray absolute P;
  I: Integer;
begin
  for I := 0 to Count - 1 do WriteWideString(AP^[I]);
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

{$IFDEF Supports_Generics}

procedure THproseWriter.Serialize(const Value; TypeInfo: Pointer);
var
  TypeData: PTypeData;
  TypeName: string;
  AList: IList;
  AMap: IMap;
  ASmartObject: ISmartObject;
  Obj: TObject;
begin
  TypeName := GetTypeName(TypeInfo);
  if TypeName = 'Boolean' then
    WriteBoolean(Boolean(Value))
  else if (TypeName = 'TDateTime') or
          (TypeName = 'TDate') or
          (TypeName = 'TTime') then
    WriteDateTimeWithRef(TDateTime(Value))
  else if TypeName = 'UInt64' then
    WriteLong(RawByteString(UIntToStr(UInt64(Value))))
  else begin
    TypeData := GetTypeData(TypeInfo);
    case PTypeInfo(TypeInfo)^.Kind of
      tkVariant: Serialize(Variant(Value));
      tkInteger, tkEnumeration, tkSet:
        case TypeData^.OrdType of
          otSByte: WriteInteger(ShortInt(Value));
          otUByte: WriteInteger(Byte(Value));
          otSWord: WriteInteger(SmallInt(Value));
          otUWord: WriteInteger(Word(Value));
          otSLong: WriteInteger(Integer(Value));
          otULong: WriteLong(RawByteString(UIntToStr(LongWord(Value))));
        end;
      tkChar: WriteUTF8Char(WideString(AnsiChar(Value))[1]);
      tkWChar: WriteUTF8Char(WideChar(Value));
      tkFloat:
        case TypeData^.FloatType of
          ftSingle: WriteDouble(Single(Value));
          ftDouble: WriteDouble(Double(Value));
          ftExtended: WriteDouble(Extended(Value));
          ftComp: WriteLong(RawByteString(IntToStr(Int64(Value))));
          ftCurr: WriteCurrency(Currency(Value));
        end;
      tkString: WriteWideString(WideString(ShortString(Value)));
      tkLString: WriteWideString(WideString(AnsiString(Value)));
      tkWString: WriteWideString(WideString(Value));
      tkUString: WriteWideString(WideString(UnicodeString(Value)));
      tkInt64: WriteLong(RawByteString(IntToStr(Int64(Value))));
      tkDynArray: WriteArrayWithRef(Value, TypeInfo);
      tkInterface: begin
        if IInterface(Value) = nil then
          WriteNull
        else if Supports(IInterface(Value), IList, AList) then
          WriteListWithRef(AList)
        else if Supports(IInterface(Value), IMap, AMap) then
          WriteMapWithRef(AMap)
        else if Supports(IInterface(Value), ISmartObject, ASmartObject) then
          WriteSmartObjectWithRef(ASmartObject)
        else
          WriteInterfaceWithRef(IInterface(Value));
      end;
      tkClass: begin
        Obj := TObject(Value);
        if Obj = nil then WriteNull else WriteObjectWithRef(Obj);
      end;
    end;
  end;
end;

procedure THproseWriter.WriteArray(const DynArray; const Name: string);
var
  TypeName: string;
  Size: Integer;
  TypeInfo: PTypeInfo;
  B1Array: TArray<TB1> absolute DynArray;
  B2Array: TArray<TB2> absolute DynArray;
  B4Array: TArray<TB4> absolute DynArray;
  B8Array: TArray<TB8> absolute DynArray;
  EArray: TArray<Extended> absolute DynArray;
  SArray: TArray<ShortString> absolute DynArray;
  LArray: TArray<AnsiString> absolute DynArray;
  WArray: TArray<WideString> absolute DynArray;
  UArray: TArray<UnicodeString> absolute DynArray;
  VArray: TArray<Variant> absolute DynArray;
  DArray: TArray<TArray<Pointer>> absolute DynArray;
  IArray: TArray<IInterface> absolute DynArray;
  OArray: TArray<TObject> absolute DynArray;
  Count, I: Integer;
begin
  TypeName := GetElementName(Name);
  if IsSmartObject(TypeName) then TypeName := 'ISmartObject';
  TypeInfo := GetTypeInfo(TypeName, Size);
  if TypeInfo = nil then
    raise EHproseException.Create('Can not serialize ' + Name)
  else begin
    FRefList.Add(NativeInt(Pointer(DynArray)));
    Count := Length(B1Array);
    FStream.WriteBuffer(HproseTagList, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    case PTypeInfo(TypeInfo)^.Kind of
      tkString: for I := 0 to Count - 1 do WriteWideString(WideString(SArray[I]));
      tkLString: for I := 0 to Count - 1 do WriteWideString(WideString(LArray[I]));
      tkWString: for I := 0 to Count - 1 do WriteWideString(WArray[I]);
      tkUString: for I := 0 to Count - 1 do WriteWideString(WideString(UArray[I]));
      tkVariant: for I := 0 to Count - 1 do Serialize(VArray[I]);
      tkDynArray: for I := 0 to Count - 1 do WriteArrayWithRef(DArray[I], TypeInfo);
      tkInterface: for I := 0 to Count - 1 do Serialize(IArray[I], TypeInfo);
      tkClass: for I := 0 to Count - 1 do Serialize(OArray[I], TypeInfo);
    else
      case Size of
        1: for I := 0 to Count - 1 do Serialize(B1Array[I], TypeInfo);
        2: for I := 0 to Count - 1 do Serialize(B2Array[I], TypeInfo);
        4: for I := 0 to Count - 1 do Serialize(B4Array[I], TypeInfo);
        8: for I := 0 to Count - 1 do Serialize(B8Array[I], TypeInfo);
      else if GetTypeName(TypeInfo) = 'Extended' then
        for I := 0 to Count - 1 do WriteDouble(EArray[I])
      else
        raise EHproseException.Create('Can not serialize ' + Name);
      end;
    end;
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteArrayWithRef(const DynArray; TypeInfo: Pointer);
var
  Name: string;
  Ref: Integer;
  Value: Variant;
  TypeData: PTypeData;
begin
  Name := GetTypeName(TypeInfo);
  if AnsiStartsText('TArray<', Name) then begin
    Ref := FRefList.IndexOf(NativeInt(Pointer(DynArray)));
    if Ref > -1 then WriteRef(Ref) else WriteArray(DynArray, Name);
  end
  else begin
    DynArrayToVariant(Value, Pointer(DynArray), TypeInfo);
    TypeData := GetTypeData(TypeInfo);
    if (TypeData^.varType and varTypeMask = varByte) and
       (VarArrayDimCount(Value) = 1) then
      WriteBytesWithRef(Value)
    else
      WriteArrayWithRef(Value);
  end;
end;

procedure THproseWriter.WriteList(const AList: TObject);
var
  ClassName: string;
  TypeName: string;
  Size: Integer;
  TypeInfo: PTypeInfo;
  B1List: TList<TB1> absolute AList;
  B2List: TList<TB2> absolute AList;
  B4List: TList<TB4> absolute AList;
  B8List: TList<TB8> absolute AList;
  EList: TList<Extended> absolute AList;
  SList: TList<ShortString> absolute AList;
  LList: TList<AnsiString> absolute AList;
  WList: TList<WideString> absolute AList;
  UList: TList<UnicodeString> absolute AList;
  VList: TList<Variant> absolute AList;
  DList: TList<TArray<Pointer>> absolute AList;
  IList: TList<IInterface> absolute AList;
  OList: TList<TObject> absolute AList;
  B1: TB1;
  B2: TB2;
  B4: TB4;
  B8: TB8;
  SS: ShortString;
  LS: AnsiString;
  WS: WideString;
  US: UnicodeString;
  V: Variant;
  E: Extended;
  D: TArray<Pointer>;
  I: IInterface;
  O: TObject;
  Count: Integer;
begin
  ClassName := AList.ClassName;
  TypeName := GetElementName(ClassName);
  if IsSmartObject(TypeName) then TypeName := 'ISmartObject';
  TypeInfo := GetTypeInfo(TypeName, Size);
  if TypeInfo = nil then
    raise EHproseException.Create('Can not serialize ' + ClassName)
  else begin
    FRefList.Add(ObjToVar(AList));
    Count := B1List.Count;
    FStream.WriteBuffer(HproseTagList, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    case PTypeInfo(TypeInfo)^.Kind of
      tkString: for SS in SList do WriteWideString(WideString(SS));
      tkLString: for LS in LList do WriteWideString(WideString(LS));
      tkWString: for WS in WList do WriteWideString(WS);
      tkUString: for US in UList do WriteWideString(WideString(US));
      tkVariant: for V in VList do Serialize(V);
      tkDynArray: for D in DList do WriteArrayWithRef(D, TypeInfo);
      tkInterface: for I in IList do Serialize(I, TypeInfo);
      tkClass: for O in OList do Serialize(O, TypeInfo);
    else
      case Size of
        1: for B1 in B1List do Serialize(B1, TypeInfo);
        2: for B2 in B2List do Serialize(B2, TypeInfo);
        4: for B4 in B4List do Serialize(B4, TypeInfo);
        8: for B8 in B8List do Serialize(B8, TypeInfo);
      else if GetTypeName(TypeInfo) = 'Extended' then
        for E in EList do WriteDouble(E)
      else
        raise EHproseException.Create('Can not serialize ' + ClassName);
      end;
    end;
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteObjectList(const AList: TObject);
var
  ClassName: string;
  TypeInfo: PTypeInfo;
  OList: TObjectList<TObject> absolute AList;
  O: TObject;
  Count: Integer;
begin
  ClassName := AList.ClassName;
  TypeInfo := TTypeManager.TypeInfo(GetElementName(ClassName));
  if TypeInfo = nil then
    raise EHproseException.Create('Can not serialize ' + ClassName)
  else begin
    FRefList.Add(ObjToVar(AList));
    Count := OList.Count;
    FStream.WriteBuffer(HproseTagList, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    for O in OList do Serialize(O, TypeInfo);
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteQueue(const AQueue: TObject);
var
  ClassName: string;
  TypeName: string;
  Size: Integer;
  TypeInfo: PTypeInfo;
  B1Queue: TQueue<TB1> absolute AQueue;
  B2Queue: TQueue<TB2> absolute AQueue;
  B4Queue: TQueue<TB4> absolute AQueue;
  B8Queue: TQueue<TB8> absolute AQueue;
  EQueue: TQueue<Extended> absolute AQueue;
  SQueue: TQueue<ShortString> absolute AQueue;
  LQueue: TQueue<AnsiString> absolute AQueue;
  WQueue: TQueue<WideString> absolute AQueue;
  UQueue: TQueue<UnicodeString> absolute AQueue;
  VQueue: TQueue<Variant> absolute AQueue;
  DQueue: TQueue<TArray<Pointer>> absolute AQueue;
  IQueue: TQueue<IInterface> absolute AQueue;
  OQueue: TQueue<TObject> absolute AQueue;
  B1: TB1;
  B2: TB2;
  B4: TB4;
  B8: TB8;
  SS: ShortString;
  LS: AnsiString;
  WS: WideString;
  US: UnicodeString;
  V: Variant;
  E: Extended;
  D: TArray<Pointer>;
  I: IInterface;
  O: TObject;
  Count: Integer;
begin
  ClassName := AQueue.ClassName;
  TypeName := GetElementName(ClassName);
  if IsSmartObject(TypeName) then TypeName := 'ISmartObject';
  TypeInfo := GetTypeInfo(TypeName, Size);
  if TypeInfo = nil then
    raise EHproseException.Create('Can not serialize ' + ClassName)
  else begin
    FRefList.Add(ObjToVar(AQueue));
    Count := B1Queue.Count;
    FStream.WriteBuffer(HproseTagList, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    case PTypeInfo(TypeInfo)^.Kind of
      tkString: for SS in SQueue do WriteWideString(WideString(SS));
      tkLString: for LS in LQueue do WriteWideString(WideString(LS));
      tkWString: for WS in WQueue do WriteWideString(WS);
      tkUString: for US in UQueue do WriteWideString(WideString(US));
      tkVariant: for V in VQueue do Serialize(V);
      tkDynArray: for D in DQueue do WriteArrayWithRef(D, TypeInfo);
      tkInterface: for I in IQueue do Serialize(I, TypeInfo);
      tkClass: for O in OQueue do Serialize(O, TypeInfo);
    else
      case Size of
        1: for B1 in B1Queue do Serialize(B1, TypeInfo);
        2: for B2 in B2Queue do Serialize(B2, TypeInfo);
        4: for B4 in B4Queue do Serialize(B4, TypeInfo);
        8: for B8 in B8Queue do Serialize(B8, TypeInfo);
      else if GetTypeName(TypeInfo) = 'Extended' then
        for E in EQueue do WriteDouble(E)
      else
        raise EHproseException.Create('Can not serialize ' + ClassName);
      end;
    end;
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteObjectQueue(const AQueue: TObject);
var
  ClassName: string;
  TypeInfo: PTypeInfo;
  OQueue: TObjectQueue<TObject> absolute AQueue;
  O: TObject;
  Count: Integer;
begin
  ClassName := AQueue.ClassName;
  TypeInfo := TTypeManager.TypeInfo(GetElementName(ClassName));
  if TypeInfo = nil then
    raise EHproseException.Create('Can not serialize ' + ClassName)
  else begin
    FRefList.Add(ObjToVar(AQueue));
    Count := OQueue.Count;
    FStream.WriteBuffer(HproseTagList, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    for O in OQueue do Serialize(O, TypeInfo);
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteStack(const AStack: TObject);
var
  ClassName: string;
  TypeName: string;
  Size: Integer;
  TypeInfo: PTypeInfo;
  B1Stack: TStack<TB1> absolute AStack;
  B2Stack: TStack<TB2> absolute AStack;
  B4Stack: TStack<TB4> absolute AStack;
  B8Stack: TStack<TB8> absolute AStack;
  EStack: TStack<Extended> absolute AStack;
  SStack: TStack<ShortString> absolute AStack;
  LStack: TStack<AnsiString> absolute AStack;
  WStack: TStack<WideString> absolute AStack;
  UStack: TStack<UnicodeString> absolute AStack;
  VStack: TStack<Variant> absolute AStack;
  DStack: TStack<TArray<Pointer>> absolute AStack;
  IStack: TStack<IInterface> absolute AStack;
  OStack: TStack<TObject> absolute AStack;
  B1: TB1;
  B2: TB2;
  B4: TB4;
  B8: TB8;
  SS: ShortString;
  LS: AnsiString;
  WS: WideString;
  US: UnicodeString;
  V: Variant;
  E: Extended;
  D: TArray<Pointer>;
  I: IInterface;
  O: TObject;
  Count: Integer;
begin
  ClassName := AStack.ClassName;
  TypeName := GetElementName(ClassName);
  if IsSmartObject(TypeName) then TypeName := 'ISmartObject';
  TypeInfo := GetTypeInfo(TypeName, Size);
  if TypeInfo = nil then
    raise EHproseException.Create('Can not serialize ' + ClassName)
  else begin
    FRefList.Add(ObjToVar(AStack));
    Count := B1Stack.Count;
    FStream.WriteBuffer(HproseTagList, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    case PTypeInfo(TypeInfo)^.Kind of
      tkString: for SS in SStack do WriteWideString(WideString(SS));
      tkLString: for LS in LStack do WriteWideString(WideString(LS));
      tkWString: for WS in WStack do WriteWideString(WS);
      tkUString: for US in UStack do WriteWideString(WideString(US));
      tkVariant: for V in VStack do Serialize(V);
      tkDynArray: for D in DStack do WriteArrayWithRef(D, TypeInfo);
      tkInterface: for I in IStack do Serialize(I, TypeInfo);
      tkClass: for O in OStack do Serialize(O, TypeInfo);
    else
      case Size of
        1: for B1 in B1Stack do Serialize(B1, TypeInfo);
        2: for B2 in B2Stack do Serialize(B2, TypeInfo);
        4: for B4 in B4Stack do Serialize(B4, TypeInfo);
        8: for B8 in B8Stack do Serialize(B8, TypeInfo);
      else if GetTypeName(TypeInfo) = 'Extended' then
        for E in EStack do WriteDouble(E)
      else
        raise EHproseException.Create('Can not serialize ' + ClassName);
      end;
    end;
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteObjectStack(const AStack: TObject);
var
  ClassName: string;
  TypeInfo: PTypeInfo;
  OStack: TObjectStack<TObject> absolute AStack;
  O: TObject;
  Count: Integer;
begin
  ClassName := AStack.ClassName;
  TypeInfo := TTypeManager.TypeInfo(GetElementName(ClassName));
  if TypeInfo = nil then
    raise EHproseException.Create('Can not serialize ' + ClassName)
  else begin
    FRefList.Add(ObjToVar(AStack));
    Count := OStack.Count;
    FStream.WriteBuffer(HproseTagList, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    for O in OStack do Serialize(O, TypeInfo);
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.WriteTDictionary1<TKey>(const ADict: TObject;
    ValueSize: Integer; KeyTypeInfo, ValueTypeInfo: Pointer);
begin
    case PTypeInfo(ValueTypeInfo)^.Kind of
      tkString: WriteTDictionary2<TKey, ShortString>(
        TDictionary<TKey, ShortString>(ADict), KeyTypeInfo, ValueTypeInfo);
      tkLString: WriteTDictionary2<TKey, AnsiString>(
        TDictionary<TKey, AnsiString>(ADict), KeyTypeInfo, ValueTypeInfo);
      tkWString: WriteTDictionary2<TKey, WideString>(
        TDictionary<TKey, WideString>(ADict), KeyTypeInfo, ValueTypeInfo);
      tkUString: WriteTDictionary2<TKey, UnicodeString>(
        TDictionary<TKey, UnicodeString>(ADict), KeyTypeInfo, ValueTypeInfo);
      tkVariant: WriteTDictionary2<TKey, Variant>(
        TDictionary<TKey, Variant>(ADict), KeyTypeInfo, ValueTypeInfo);
      tkDynArray: WriteTDictionary2<TKey, TArray<Pointer>>(
        TDictionary<TKey, TArray<Pointer>>(ADict), KeyTypeInfo, ValueTypeInfo);
      tkInterface: WriteTDictionary2<TKey, IInterface>(
        TDictionary<TKey, IInterface>(ADict), KeyTypeInfo, ValueTypeInfo);
      tkClass: WriteTDictionary2<TKey, TObject>(
        TDictionary<TKey, TObject>(ADict), KeyTypeInfo, ValueTypeInfo);
    else
      case ValueSize of
        1: WriteTDictionary2<TKey, TB1>(
          TDictionary<TKey, TB1>(ADict), KeyTypeInfo, ValueTypeInfo);
        2: WriteTDictionary2<TKey, TB2>(
          TDictionary<TKey, TB2>(ADict), KeyTypeInfo, ValueTypeInfo);
        4: WriteTDictionary2<TKey, TB4>(
          TDictionary<TKey, TB4>(ADict), KeyTypeInfo, ValueTypeInfo);
        8: WriteTDictionary2<TKey, TB8>(
          TDictionary<TKey, TB8>(ADict), KeyTypeInfo, ValueTypeInfo);
      else if GetTypeName(ValueTypeInfo) = 'Extended' then
        WriteTDictionary2<TKey, Extended>(
          TDictionary<TKey, Extended>(ADict), KeyTypeInfo, ValueTypeInfo)
      else
        raise EHproseException.Create('Can not serialize ' + ClassName);
      end;
    end;
end;


procedure THproseWriter.WriteDictionary(const ADict: TObject);
var
  ClassName: string;
  KeyTypeName: string;
  KeySize: Integer;
  KeyTypeInfo: PTypeInfo;
  ValueTypeName: string;
  ValueSize: Integer;
  ValueTypeInfo: PTypeInfo;
begin
  ClassName := ADict.ClassName;
  SplitKeyValueTypeName(GetElementName(ClassName), KeyTypeName, ValueTypeName);
  if IsSmartObject(KeyTypeName) then KeyTypeName := 'ISmartObject';
  if IsSmartObject(ValueTypeName) then ValueTypeName := 'ISmartObject';
  KeyTypeInfo := GetTypeInfo(KeyTypeName, KeySize);
  ValueTypeInfo := GetTypeInfo(ValueTypeName, ValueSize);
  if (KeyTypeInfo = nil) or (ValueTypeInfo = nil) then
    raise EHproseException.Create('Can not serialize ' + ClassName)
  else begin
    case PTypeInfo(KeyTypeInfo)^.Kind of
      tkString: WriteTDictionary1<ShortString>(ADict, ValueSize,
                                           KeyTypeInfo, ValueTypeInfo);
      tkLString: WriteTDictionary1<AnsiString>(ADict, ValueSize,
                                           KeyTypeInfo, ValueTypeInfo);
      tkWString: WriteTDictionary1<WideString>(ADict, ValueSize,
                                           KeyTypeInfo, ValueTypeInfo);
      tkUString: WriteTDictionary1<UnicodeString>(ADict, ValueSize,
                                              KeyTypeInfo, ValueTypeInfo);
      tkVariant: WriteTDictionary1<Variant>(ADict, ValueSize,
                                        KeyTypeInfo, ValueTypeInfo);
      tkDynArray: WriteTDictionary1<TArray<Pointer>>(ADict, ValueSize,
                                          KeyTypeInfo, ValueTypeInfo);
      tkInterface: WriteTDictionary1<IInterface>(ADict, ValueSize,
                                            KeyTypeInfo, ValueTypeInfo);
      tkClass: WriteTDictionary1<TObject>(ADict, ValueSize,
                                     KeyTypeInfo, ValueTypeInfo);
    else
      case KeySize of
        1: WriteTDictionary1<TB1>(ADict, ValueSize, KeyTypeInfo, ValueTypeInfo);
        2: WriteTDictionary1<TB2>(ADict, ValueSize, KeyTypeInfo, ValueTypeInfo);
        4: WriteTDictionary1<TB4>(ADict, ValueSize, KeyTypeInfo, ValueTypeInfo);
        8: WriteTDictionary1<TB8>(ADict, ValueSize, KeyTypeInfo, ValueTypeInfo);
      else if GetTypeName(KeyTypeInfo) = 'Extended' then
         WriteTDictionary1<Extended>(ADict, ValueSize,
                               KeyTypeInfo, ValueTypeInfo)
      else
        raise EHproseException.Create('Can not serialize ' + ClassName);
      end;
    end;
  end;
end;

procedure THproseWriter.WriteObjectDictionary(const ADict: TObject);
var
  ClassName, KeyTypeName, ValueTypeName: string;
  KeyTypeInfo, ValueTypeInfo: PTypeInfo;
  ODict: TObjectDictionary<TObject, TObject> absolute ADict;
  O: TPair<TObject, TObject>;
  Count: Integer;
begin
  ClassName := ADict.ClassName;
  SplitKeyValueTypeName(GetElementName(ClassName), KeyTypeName, ValueTypeName);
  KeyTypeInfo := TTypeManager.TypeInfo(KeyTypeName);
  ValueTypeInfo := TTypeManager.TypeInfo(ValueTypeName);
  if (KeyTypeInfo = nil) or (ValueTypeInfo = nil) then
    raise EHproseException.Create('Can not serialize ' + ClassName)
  else begin
    FRefList.Add(ObjToVar(ADict));
    Count := ODict.Count;
    FStream.WriteBuffer(HproseTagMap, 1);
    if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
    FStream.WriteBuffer(HproseTagOpenbrace, 1);
    for O in ODict do begin
      Serialize(O.Key, KeyTypeInfo);
      Serialize(O.Value, ValueTypeInfo);
    end;
    FStream.WriteBuffer(HproseTagClosebrace, 1);
  end;
end;

procedure THproseWriter.Serialize<T>(const Value: T);
begin
  Serialize(Value, TypeInfo(T));
end;

procedure THproseWriter.WriteArray<T>(const DynArray: array of T);
var
  Count, I: Integer;
begin
  FRefList.Add(Null);
  Count := Length(DynArray);
  FStream.WriteBuffer(HproseTagList, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for I := 0 to Count - 1 do Serialize(DynArray[I], TypeInfo(T));
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteDynArray<T>(const DynArray: TArray<T>);
var
  Count, I: Integer;
begin
  FRefList.Add(NativeInt(Pointer(DynArray)));
  Count := Length(DynArray);
  FStream.WriteBuffer(HproseTagList, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for I := 0 to Count - 1 do Serialize(DynArray[I], TypeInfo(T));
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteDynArrayWithRef<T>(const DynArray: TArray<T>);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(NativeInt(Pointer(DynArray)));
  if Ref > -1 then WriteRef(Ref) else WriteDynArray<T>(DynArray);
end;

procedure THproseWriter.WriteTList<T>(const AList: TList<T>);
var
  Count, I: Integer;
  Element: T;
begin
  FRefList.Add(ObjToVar(AList));
  Count := AList.Count;
  FStream.WriteBuffer(HproseTagList, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for I := 0 to Count - 1 do begin
    Element := AList[I];
    Serialize(Element, TypeInfo(T));
  end;
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteTListWithRef<T>(const AList: TList<T>);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(ObjToVar(AList));
  if Ref > -1 then WriteRef(Ref) else WriteTList<T>(AList);
end;

procedure THproseWriter.WriteTQueue<T>(const AQueue: TQueue<T>);
var
  Count, I: Integer;
  Element: T;
begin
  FRefList.Add(ObjToVar(AQueue));
  Count := AQueue.Count;
  FStream.WriteBuffer(HproseTagList, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for Element in AQueue do Serialize(Element, TypeInfo(T));
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteTQueueWithRef<T>(const AQueue: TQueue<T>);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(ObjToVar(AQueue));
  if Ref > -1 then WriteRef(Ref) else WriteTQueue<T>(AQueue);
end;

procedure THproseWriter.WriteTStack<T>(const AStack: TStack<T>);
var
  Count, I: Integer;
  Element: T;
begin
  FRefList.Add(ObjToVar(AStack));
  Count := AStack.Count;
  FStream.WriteBuffer(HproseTagList, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for Element in AStack do Serialize(Element, TypeInfo(T));
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteTStackWithRef<T>(const AStack: TStack<T>);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(ObjToVar(AStack));
  if Ref > -1 then WriteRef(Ref) else WriteTStack<T>(AStack);
end;

procedure THproseWriter.WriteTDictionary2<TKey, TValue>(
  const ADict: TDictionary<TKey, TValue>; KeyTypeInfo, ValueTypeInfo: Pointer);
var
  Count, I: Integer;
  Pair: TPair<TKey, TValue>;
begin
  FRefList.Add(ObjToVar(ADict));
  Count := ADict.Count;
  FStream.WriteBuffer(HproseTagMap, 1);
  if Count > 0 then WriteRawByteString(RawByteString(IntToStr(Count)));
  FStream.WriteBuffer(HproseTagOpenbrace, 1);
  for Pair in ADict do begin
    Serialize(Pair.Key, KeyTypeInfo);
    Serialize(Pair.Value, ValueTypeInfo);
  end;
  FStream.WriteBuffer(HproseTagClosebrace, 1);
end;

procedure THproseWriter.WriteTDictionary<TKey, TValue>(
  const ADict: TDictionary<TKey, TValue>);
begin
  WriteTDictionary2<TKey, TValue>(ADict, TypeInfo(TKey), TypeInfo(TValue));
end;

procedure THproseWriter.WriteTDictionaryWithRef<TKey, TValue>(
  const ADict: TDictionary<TKey, TValue>);
var
  Ref: Integer;
begin
  Ref := FRefList.IndexOf(ObjToVar(ADict));
  if Ref > -1 then WriteRef(Ref) else WriteTDictionary<TKey, TValue>(ADict);
end;

{$ELSE}

procedure THproseWriter.Serialize(const Value: TObject);
begin
  Serialize(ObjToVar(Value));
end;

{$ENDIF}

{ HproseSerialize }

function HproseSerialize(const Value: TObject): RawByteString;
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

function HproseUnserialize(const Data: RawByteString; TypeInfo: Pointer): Variant;
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
      Result := Reader.Unserialize(TypeInfo);
    finally
      Reader.Free;
    end;
  finally
    Stream.Free;
  end;
end;

{ THproseFormatter }

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

{$IFDEF Supports_Generics}

class function THproseFormatter.Serialize<T>(const Value: T): RawByteString;
var
  Writer: THproseWriter;
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Writer := THproseWriter.Create(Stream);
    try
      Writer.Serialize<T>(Value);
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

class function THproseFormatter.Unserialize<T>(const Data:RawByteString): T;
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
      Result := Reader.Unserialize<T>;
    finally
      Reader.Free;
    end;
  finally
    Stream.Free;
  end;
end;

{$ELSE}

class function THproseFormatter.Serialize(const Value: TObject): RawByteString;
begin
  Result := HproseSerialize(Value);
end;

{$ENDIF}

class function THproseFormatter.Unserialize(const Data: RawByteString;
  TypeInfo: Pointer): Variant;
begin
  Result := HproseUnserialize(Data, TypeInfo);
end;

class function THproseFormatter.Unserialize(const Data:RawByteString): Variant;
begin
  Result := HproseUnserialize(Data, nil);
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
      CachePointer := PSerializeCache(NativeInt(CacheValues[I]));
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
