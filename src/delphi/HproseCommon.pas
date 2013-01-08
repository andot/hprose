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
 * HproseCommon.pas                                       *
 *                                                        *
 * hprose common unit for delphi.                         *
 *                                                        *
 * LastModified: Jan 8, 2013                              *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
}
unit HproseCommon;

{$I Hprose.inc}

interface

uses Classes, SyncObjs, SysUtils;

type

{$IFNDEF DELPHI2009_UP}
  RawByteString = type AnsiString;
{$ENDIF}

  THproseResultMode = (Normal, Serialized, Raw, RawWithEndTag);

  TVariants = array of Variant;
  PVariants = ^TVariants;

  TConstArray = array of TVarRec;

  EHproseException = class(Exception);
  EHashBucketError = class(Exception);
  EArrayListError = class(Exception);

  IHproseFilter = interface
  ['{4AD7CCF2-1121-4CA4-92A7-5704C5956BA4}']
    function InputFilter(const data: TStream): TStream;
    function OutputFilter(const data: TStream): TStream;
  end;

  IListEnumerator = interface
  ['{767477EC-A143-4DC6-9962-A6837A7AEC01}']
    function GetCurrent: Variant;
    function MoveNext: Boolean;
    property Current: Variant read GetCurrent;
  end;

  IList = interface(IReadWriteSync)
  ['{DE925411-42B8-4DB3-A00C-B585C087EC4C}']
    function Get(Index: Integer): Variant;
    procedure Put(Index: Integer; const Value: Variant);
    function GetCapacity: Integer;
    function GetCount: Integer;
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    function Add(const Value: Variant): Integer;
    procedure AddAll(const ArrayList: IList); overload;
    procedure AddAll(const Container: Variant); overload;
    procedure Assign(const Source: IList);
    procedure Clear;
    function Contains(const Value: Variant): Boolean;
    function Delete(Index: Integer): Variant;
    procedure Exchange(Index1, Index2: Integer);
    function GetEnumerator: IListEnumerator;
    function IndexOf(const Value: Variant): Integer;
    procedure Insert(Index: Integer; const Value: Variant);
    function Join(const Glue: string = ',';
                  const LeftPad: string = '';
                  const RightPad: string = ''): string;
    procedure InitLock;
    procedure InitReadWriteLock;
    procedure Lock;
    procedure Unlock;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(const Value: Variant): Integer;
    function ToArray: TVariants; overload;
    function ToArray(VarType: TVarType): Variant; overload;
    property Item[Index: Integer]: Variant read Get write Put; default;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
  end;

  TAbstractList = class(TInterfacedObject, IList)
  private
    FLock: TCriticalSection;
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  protected
    function Get(Index: Integer): Variant; virtual; abstract;
    procedure Put(Index: Integer; const Value: Variant); virtual; abstract;
    function GetCapacity: Integer; virtual; abstract;
    function GetCount: Integer; virtual; abstract;
    procedure SetCapacity(NewCapacity: Integer); virtual; abstract;
    procedure SetCount(NewCount: Integer); virtual; abstract;
  public
    constructor Create(Capacity: Integer = 4; Sync: Boolean = True;
      ReadWriteSync: Boolean = False); overload; virtual; abstract;
    constructor Create(Sync: Boolean;
      ReadWriteSync: Boolean = False); overload; virtual; abstract;
    destructor Destroy; override;
    function Add(const Value: Variant): Integer; virtual; abstract;
    procedure AddAll(const ArrayList: IList); overload; virtual; abstract;
    procedure AddAll(const Container: Variant); overload; virtual; abstract;
    procedure Assign(const Source: IList); virtual;
    procedure Clear; virtual; abstract;
    function Contains(const Value: Variant): Boolean; virtual; abstract;
    function Delete(Index: Integer): Variant; virtual; abstract;
    procedure Exchange(Index1, Index2: Integer); virtual; abstract;
    function GetEnumerator: IListEnumerator; virtual;
    function IndexOf(const Value: Variant): Integer; virtual; abstract;
    procedure Insert(Index: Integer; const Value: Variant); virtual; abstract;
    function Join(const Glue, LeftPad, RightPad: string): string; virtual;
    class function Split(Str: string; const Separator: string = ',';
      Limit: Integer = 0; TrimItem: Boolean = False;
      SkipEmptyItem: Boolean = False; Sync: Boolean = True;
      ReadWriteSync: Boolean = False): IList; virtual;
    procedure InitLock;
    procedure InitReadWriteLock;
    procedure Lock;
    procedure Unlock;
    procedure BeginRead;
    procedure EndRead;
    function BeginWrite: Boolean;
    procedure EndWrite;
    procedure Move(CurIndex, NewIndex: Integer); virtual; abstract;
    function Remove(const Value: Variant): Integer; virtual; abstract;
    function ToArray: TVariants; overload; virtual; abstract;
    function ToArray(VarType: TVarType): Variant; overload; virtual; abstract;
    property Item[Index: Integer]: Variant read Get write Put; default;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
  end;

  TListClass = class of TAbstractList;

  IArrayList = interface(IList)
  ['{0D12803C-6B0B-476B-A9E3-C219BF651BD1}']
  end;

  TArrayList = class(TAbstractList, IArrayList)
  private
    FCount: Integer;
    FCapacity: Integer;
    FList: TVariants;
  protected
    function Get(Index: Integer): Variant; override;
    procedure Grow; virtual;
    procedure Put(Index: Integer; const Value: Variant); override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetCount(NewCount: Integer); override;
  public
    constructor Create(Capacity: Integer = 4; Sync: Boolean = True;
      ReadWriteSync: Boolean = False); overload; override;
    constructor Create(Sync: Boolean;
      ReadWriteSync: Boolean = False); overload; override;
{$IFDEF BCB}
    constructor Create0; virtual; // for C++ Builder
    constructor Create1(Capacity: Integer); virtual; // for C++ Builder
    constructor Create2(Capacity: Integer; Sync: Boolean); virtual; // for C++ Builder
    constructor CreateS(Sync: Boolean); virtual; // for C++ Builder
{$ENDIF}
    function Add(const Value: Variant): Integer; override;
    procedure AddAll(const AList: IList); overload; override;
    procedure AddAll(const Container: Variant); overload; override;
    procedure Clear; override;
    function Contains(const Value: Variant): Boolean; override;
    function Delete(Index: Integer): Variant; override;
    procedure Exchange(Index1, Index2: Integer); override;
    function IndexOf(const Value: Variant): Integer; override;
    procedure Insert(Index: Integer; const Value: Variant); override;
    procedure Move(CurIndex, NewIndex: Integer); override;
    function Remove(const Value: Variant): Integer; override;
    function ToArray: TVariants; overload; override;
    function ToArray(VarType: TVarType): Variant; overload; override;
    property Item[Index: Integer]: Variant read Get write Put; default;
    property Count: Integer read GetCount write SetCount;
    property Capacity: Integer read GetCapacity write SetCapacity;
  end;

  PHashItem = ^THashItem;

  THashItem = record
    Next: PHashItem;
    Index: Integer;
    HashCode: Integer;
  end;

  THashItemDynArray = array of PHashItem;

  TIndexCompareMethod = function (Index: Integer;
    const Value: Variant): Boolean of object;

  THashBucket = class(TObject)
  private
    FCount: Integer;
    FFactor: Single;
    FCapacity: Integer;
    FIndices: THashItemDynArray;
    procedure Grow;
    procedure SetCapacity(NewCapacity: Integer);
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75);
    destructor Destroy; override;
    function Add(HashCode, Index: Integer): PHashItem;
    procedure Clear;
    procedure Delete(HashCode, Index: Integer);
    function IndexOf(HashCode: Integer; const Value: Variant;
      CompareProc: TIndexCompareMethod): Integer;
    function Modify(OldHashCode, NewHashCode, Index: Integer): PHashItem;
    property Count: Integer read FCount;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  IHashedList = interface(IArrayList)
  ['{D2392014-7451-40EF-809E-D25BFB0FA661}']
  end;

  THashedList = class(TArrayList, IHashedList)
  private
    FHashBucket: THashBucket;
  protected
    function HashOf(const Value: Variant): Integer; virtual;
    function IndexCompare(Index: Integer; const Value: Variant):
      Boolean; virtual;
    procedure Put(Index: Integer; const Value: Variant); override;
  public
    constructor Create(Capacity: Integer = 4; Sync: Boolean = True;
      ReadWriteSync: Boolean = False); overload; override;
    constructor Create(Capacity: Integer; Factor: Single; Sync: Boolean = True;
      ReadWriteSync: Boolean = False); reintroduce; overload; virtual;
{$IFDEF BCB}
    constructor Create3(Capacity: Integer; Factor: Single;
      Sync: Boolean); virtual; // for C++ Builder
{$ENDIF}
    destructor Destroy; override;
    function Add(const Value: Variant): Integer; override;
    procedure Clear; override;
    function Delete(Index: Integer): Variant; override;
    procedure Exchange(Index1, Index2: Integer); override;
    function IndexOf(const Value: Variant): Integer; override;
    procedure Insert(Index: Integer; const Value: Variant); override;
  end;

  ICaseInsensitiveHashedList = interface(IHashedList)
  ['{9ECA15EC-9486-4BF6-AADD-BBD88890FAF8}']
  end;

  TCaseInsensitiveHashedList = class(THashedList, ICaseInsensitiveHashedList)
  protected
    function HashOf(const Value: Variant): Integer; override;
    function IndexCompare(Index: Integer; const Value: Variant):
      Boolean; override;
{$IFDEF BCB}
  public
    constructor Create4(Capacity: Integer; Factor: Single; Sync,
      ReadWriteSync: Boolean); virtual; // for C++ Builder
{$ENDIF}
  end;

  TMapEntry = record
    Key: Variant;
    Value: Variant;
  end;

  IMapEnumerator = interface
  ['{5DE7A194-4476-42A6-A1E7-CB1D20AA7B0A}']
    function GetCurrent: TMapEntry;
    function MoveNext: Boolean;
    property Current: TMapEntry read GetCurrent;
  end;

  IMap = interface(IReadWriteSync)
  ['{28B78387-CB07-4C28-B642-09716DAA2170}']
    procedure Assign(const Source: IMap);
    function GetCount: Integer;
    function GetKeys: IList;
    function GetValues: IList;
    function GetKey(const Value: Variant): Variant;
    function Get(const Key: Variant): Variant;
    procedure Put(const Key, Value: Variant);
    procedure Clear;
    function ContainsKey(const Key: Variant): Boolean;
    function ContainsValue(const Value: Variant): Boolean;
    function Delete(const Key: Variant): Variant;
    function GetEnumerator: IMapEnumerator;
    function Join(const ItemGlue: string = ';';
                  const KeyValueGlue: string = '=';
                  const LeftPad: string = '';
                  const RightPad: string = ''): string;
    procedure InitLock;
    procedure InitReadWriteLock;
    procedure Lock;
    procedure Unlock;
    procedure PutAll(const AList: IList); overload;
    procedure PutAll(const AMap: IMap); overload;
    procedure PutAll(const Container: Variant); overload;
    function ToList(ListClass: TListClass; Sync: Boolean = True;
      ReadWriteSync: Boolean = False): IList;
    property Count: Integer read GetCount;
    property Key[const Value: Variant]: Variant read GetKey;
    property Value[const Key: Variant]: Variant read Get write Put; default;
    property Keys: IList read GetKeys;
    property Values: IList read GetValues;
  end;

  TAbstractMap = class(TInterfacedObject, IMap)
  private
    FLock: TCriticalSection;
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  protected
    procedure Assign(const Source: IMap);
    function GetCount: Integer; virtual; abstract;
    function GetKeys: IList; virtual; abstract;
    function GetValues: IList; virtual; abstract;
    function GetKey(const Value: Variant): Variant; virtual; abstract;
    function Get(const Key: Variant): Variant; virtual; abstract;
    procedure Put(const Key, Value: Variant); virtual; abstract;
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); overload; virtual; abstract;
    constructor Create(Sync: Boolean;
      ReadWriteSync: Boolean = False); overload; virtual; abstract;
    destructor Destroy; override;
    procedure Clear; virtual; abstract;
    function ContainsKey(const Key: Variant): Boolean; virtual; abstract;
    function ContainsValue(const Value: Variant): Boolean; virtual; abstract;
    function Delete(const Key: Variant): Variant; virtual; abstract;
    function GetEnumerator: IMapEnumerator; virtual;
    function Join(const ItemGlue, KeyValueGlue, LeftPad, RightPad: string):
      string; virtual;
    class function Split(Str: string; const ItemSeparator: string = ';';
      const KeyValueSeparator: string = '='; Limit: Integer = 0;
      TrimKey: Boolean = False; TrimValue: Boolean = False;
      SkipEmptyKey: Boolean = False; SkipEmptyValue: Boolean = False;
      Sync: Boolean = True; ReadWriteSync: Boolean = False): IMap; virtual;
    procedure InitLock;
    procedure InitReadWriteLock;
    procedure Lock;
    procedure Unlock;
    procedure BeginRead;
    procedure EndRead;
    function BeginWrite: Boolean;
    procedure EndWrite;
    procedure PutAll(const AList: IList); overload; virtual; abstract;
    procedure PutAll(const AMap: IMap); overload; virtual; abstract;
    procedure PutAll(const Container: Variant); overload; virtual; abstract;
    function ToList(ListClass: TListClass; Sync: Boolean = True;
      ReadWriteSync: Boolean = False): IList; virtual; abstract;
    property Count: Integer read GetCount;
    property Key[const Value: Variant]: Variant read GetKey;
    property Value[const Key: Variant]: Variant read Get write Put; default;
    property Keys: IList read GetKeys;
    property Values: IList read GetValues;
  end;

  TMapClass = class of TAbstractMap;
  { function ContainsValue is an O(n) operation in THashMap,
    and property Key is also an O(n) operation. They perform
    a linear search. THashedMap is faster than THashMap when
    do those operations. But THashMap needs less memory than
    THashedMap. }

  IHashMap = interface(IMap)
  ['{B66C3C4F-3FBB-41FF-B0FA-5E73D87CBE56}']
  end;

  THashMap = class(TAbstractMap, IHashMap)
  private
    FKeys: IList;
    FValues: IList;
  protected
    function GetCount: Integer; override;
    function GetKeys: IList; override;
    function GetValues: IList; override;
    function GetKey(const Value: Variant): Variant; override;
    function Get(const Key: Variant): Variant; override;
    procedure Put(const Key, Value: Variant); override;
    procedure InitData(Keys, Values: IList);
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); overload; override;
    constructor Create(Sync: Boolean;
      ReadWriteSync: Boolean = False); overload; override;
{$IFDEF BCB}
    constructor Create0; virtual;
    constructor Create1(Capacity: Integer); virtual;
    constructor Create2(Capacity: Integer; Factor: Single); virtual;
    constructor Create3(Capacity: Integer; Factor: Single; Sync: Boolean); virtual;
    constructor CreateS(Sync: Boolean); virtual;
{$ENDIF}
    procedure Clear; override;
    function ContainsKey(const Key: Variant): Boolean; override;
    function ContainsValue(const Value: Variant): Boolean; override;
    function Delete(const Key: Variant): Variant; override;
    procedure PutAll(const AList: IList); overload; override;
    procedure PutAll(const AMap: IMap); overload; override;
    procedure PutAll(const Container: Variant); overload; override;
    function ToList(ListClass: TListClass; Sync: Boolean = True;
      ReadWriteSync: Boolean = False): IList; override;
    function ToArrayList(Sync: Boolean = True;
      ReadWriteSync: Boolean = False): TArrayList; virtual;
    property Key[const Value: Variant]: Variant read GetKey;
    property Value[const Key: Variant]: Variant read Get write Put; default;
    property Count: Integer read GetCount;
    property Keys: IList read GetKeys;
    property Values: IList read GetValues;
  end;

  { function ContainsValue is an O(1) operation in THashedMap,
    and property Key is also an O(1) operation. }

  IHashedMap = interface(IHashMap)
  ['{D2598919-07DA-401A-A971-7DB8624E2660}']
  end;

  THashedMap = class(THashMap, IHashedMap)
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); override;
  end;

  ICaseInsensitiveHashMap = interface(IHashMap)
  ['{B8F8E5E7-53ED-48BE-B171-2EA2548FCAC7}']
  end;

  TCaseInsensitiveHashMap = class(THashMap, ICaseInsensitiveHashMap)
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); override;
  end;

  ICaseInsensitiveHashedMap = interface(IHashMap)
  ['{839DCE08-95DE-462F-B59D-16BA89D3DC6B}']
  end;

  TCaseInsensitiveHashedMap = class(THashMap, ICaseInsensitiveHashedMap)
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); override;
  end;

  TStringBuffer = class(TObject)
  private
    FDataString: RawByteString;
    FPosition: Integer;
    FCapacity: Integer;
    FLength: Integer;
    procedure Grow;
    procedure SetPosition(NewPosition: Integer);
    procedure SetCapacity(NewCapacity: Integer);
  public
    constructor Create(Capacity: Integer = 255); overload;
    constructor Create(const AString: string); overload;
    function Read(var Buffer; Count: Longint): Longint;
    function ReadString(Count: Longint): string;
    function Write(const Buffer; Count: Longint): Longint;
    procedure WriteString(const AString: string);
    function Insert(const Buffer; Count: Longint): Longint;
    procedure InsertString(const AString: string);
    function Seek(Offset: Longint; Origin: Word): Longint;
    function ToString: string; {$IFDEF DELPHI2009_UP}override;{$ENDIF}{$IFDEF FPC}override;{$ENDIF}
    property Position: Integer read FPosition write SetPosition;
    property Length: Integer read FLength;
    property Capacity: Integer read FCapacity write SetCapacity;
    property DataString: RawByteString read FDataString;
  end;

  ISmartObject = interface
  ['{496CD091-9C33-423A-BC4A-61AF16C74A75}']
    function ClassType: TClass;
    function Value: TObject;
  end;

  TSmartObject = class(TInterfacedObject, ISmartObject)
  private
    FObject: TObject;
    FClass: TClass;
    constructor Create(const AClass: TClass);
    function ClassType: TClass;
    function Value: TObject;
  public
    class function New(const AClass: TClass): ISmartObject;
    destructor Destroy; override;
  end;

{$IFDEF Supports_Generics}
  ISmartObject<T: constructor, class> = interface
  ['{91FEB85D-1284-4516-A9DA-5D370A338DA0}']
    function Value: T;
  end;

  TSmartObject<T: constructor, class> = class(TInterfacedObject, ISmartObject<T>, ISmartObject)
  private
    FObject: T;
    constructor Create;
    function ClassType: TClass;
    function Get: TObject;
    function GetValue: T;
    function ISmartObject.Value = Get;
    function ISmartObject<T>.Value = GetValue;
  public
    class function New: ISmartObject<T>;
    destructor Destroy; override;
  end;
{$ENDIF}

{$IFDEF FPC}
const
  varObject = 23;  {23 is not used by FreePascal and Delphi, so it's safe.}
{$ELSE}
var
  varObject: TVarType;
{$ENDIF}
{$IFDEF DELPHI6}
function FindVarData(const Value: Variant): PVarData;
function VarIsType(const V: Variant; AVarType: TVarType): Boolean; overload;
function VarIsType(const V: Variant; const AVarTypes: array of TVarType):
  Boolean; overload;
function VarIsCustom(const V: Variant): Boolean;
function VarIsOrdinal(const V: Variant): Boolean;
function VarIsFloat(const V: Variant): Boolean;
function VarIsNumeric(const V: Variant): Boolean;
function VarIsStr(const V: Variant): Boolean;
function VarIsEmpty(const V: Variant): Boolean;
function VarIsNull(const V: Variant): Boolean;
{$ENDIF}
function VarIsObj(const Value: Variant): Boolean; overload;
function VarIsObj(const Value: Variant; AClass: TClass): Boolean; overload;
function VarToObj(const Value: Variant): TObject; overload;
function VarToObj(const Value: Variant; AClass: TClass):
  TObject; overload;
function VarToObj(const Value: Variant; AClass: TClass; out AObject):
  Boolean; overload;
function ObjToVar(const Value: TObject): Variant;
function VarEquals(const Left, Right: Variant): Boolean;
function VarRef(const Value: Variant): Variant;
function VarUnref(const Value: Variant): Variant;
function VarIsList(const Value: Variant): Boolean;
function VarIsMap(const Value: Variant): Boolean;
function VarToList(const Value: Variant): IList;
function VarToMap(const Value: Variant): IMap;
function VarIsIntf(const Value: Variant): Boolean; overload;
function VarIsIntf(const Value: Variant; const IID: TGUID): Boolean; overload;
function VarToIntf(const Value: Variant; const IID: TGUID; out AIntf): Boolean;
function IntfToObj(const Intf: IInterface): TInterfacedObject;

function CopyVarRec(const Item: TVarRec): TVarRec;
function CreateConstArray(const Elements: array of const): TConstArray;
procedure FinalizeVarRec(var Item: TVarRec);
procedure FinalizeConstArray(var Arr: TConstArray);

procedure RegisterClass(const AClass: TClass; const Alias: string); overload;
procedure RegisterClass(const AClass: TInterfacedClass; const IID: TGUID; const Alias: string); overload;
function GetClassByAlias(const Alias: string): TClass;
function GetClassAlias(const AClass: TClass): string;
function GetClassByInterface(const IID: TGUID): TClass;
function GetInterfaceByClass(const AClass: TClass): TGUID;

function ListSplit(ListClass: TListClass; Str: string;
  const Separator: string = ','; Limit: Integer = 0; TrimItem: Boolean = False;
  SkipEmptyItem: Boolean = False): IList;
function MapSplit(MapClass: TMapClass; Str: string;
  const ItemSeparator: string = ';'; const KeyValueSeparator: string = '=';
  Limit: Integer = 0; TrimKey: Boolean = False; TrimValue: Boolean = False;
  SkipEmptyKey: Boolean = False; SkipEmptyValue: Boolean = False): IMap;

implementation

uses RTLConsts, Variants;
{$IFNDEF FPC}
type

  TVarObjectType = class(TCustomVariantType)
  public
    procedure CastTo(var Dest: TVarData; const Source: TVarData;
      const AVarType: TVarType); override;
    procedure Clear(var V: TVarData); override;
    function CompareOp(const Left, Right: TVarData;
      const Operation: TVarOp): Boolean; override;
    procedure Copy(var Dest: TVarData; const Source: TVarData;
      const Indirect: Boolean); override;
    function IsClear(const V: TVarData): Boolean; override;
  end;

var
  VarObjectType: TVarObjectType;
{$ENDIF}

{$IFDEF DELPHI2012_UP}
const
{ Maximum TList size }
  MaxListSize = Maxint div 16;
{$ENDIF}

{$IFDEF DELPHI6}
function FindVarData(const Value: Variant): PVarData;
begin
  Result := @TVarData(Value);
  while Result.VType = varByRef or varVariant do
    Result := PVarData(Result.VPointer);
end;

function VarIsType(const V: Variant; AVarType: TVarType): Boolean;
begin
  Result := FindVarData(V)^.VType = AVarType;
end;

function VarIsType(const V: Variant; const AVarTypes: array of TVarType): Boolean;
var
  I: Integer;
begin
  Result := False;
  with FindVarData(V)^ do
    for I := Low(AVarTypes) to High(AVarTypes) do
      if VType = AVarTypes[I] then
      begin
        Result := True;
        Break;
      end;
end;

function VarTypeIsCustom(const AVarType: TVarType): Boolean;
var
  LHandler: TCustomVariantType;
begin
  Result := FindCustomVariantType(AVarType, LHandler);
end;

function VarIsCustom(const V: Variant): Boolean;
begin
  Result := VarTypeIsCustom(FindVarData(V)^.VType);
end;

function VarTypeIsOrdinal(const AVarType: TVarType): Boolean;
begin
  Result := AVarType in [varSmallInt, varInteger, varBoolean, varShortInt,
                         varByte, varWord, varLongWord, varInt64];
end;

function VarIsOrdinal(const V: Variant): Boolean;
begin
  Result := VarTypeIsOrdinal(FindVarData(V)^.VType);
end;

function VarTypeIsFloat(const AVarType: TVarType): Boolean;
begin
  Result := AVarType in [varSingle, varDouble, varCurrency];
end;

function VarIsFloat(const V: Variant): Boolean;
begin
  Result := VarTypeIsFloat(FindVarData(V)^.VType);
end;

function VarTypeIsNumeric(const AVarType: TVarType): Boolean;
begin
  Result := VarTypeIsOrdinal(AVarType) or VarTypeIsFloat(AVarType);
end;

function VarIsNumeric(const V: Variant): Boolean;
begin
  Result := VarTypeIsNumeric(FindVarData(V)^.VType);
end;

function VarTypeIsStr(const AVarType: TVarType): Boolean;
begin
  Result := (AVarType = varOleStr) or (AVarType = varString);
end;

function VarIsStr(const V: Variant): Boolean;
begin
  Result := VarTypeIsStr(FindVarData(V)^.VType);
end;

function VarIsEmpty(const V: Variant): Boolean;
begin
  Result := FindVarData(V)^.VType = varEmpty;
end;

function VarIsNull(const V: Variant): Boolean;
begin
  Result := FindVarData(V)^.VType = varNull;
end;
{$ENDIF}

function VarToObj(const Value: Variant): TObject;
begin
  Result := nil;
  try
    with FindVarData(Value)^ do
      if VType = varObject then begin
        Result := TObject(VPointer);
      end
      else if VType <> varNull then Error(reInvalidCast);
  except
    Error(reInvalidCast);
  end;
end;

function VarToObj(const Value: Variant; AClass: TClass): TObject;
begin
  Result := nil;
  try
    with FindVarData(Value)^ do
      if VType = varObject then begin
        Result := TObject(VPointer);
        if not (Result is AClass) then Error(reInvalidCast);
      end
      else if VType <> varNull then Error(reInvalidCast);
  except
    Error(reInvalidCast);
  end;
end;

function VarToObj(const Value: Variant; AClass: TClass; out AObject):
  Boolean;
var
  Obj: TObject absolute AObject;
begin
  Obj := nil;
  Result := True;
  try
    with FindVarData(Value)^ do
      if VType = varObject then begin
        Obj := TObject(VPointer) as AClass;
        Result := (Obj <> nil) or (VPointer = nil);
      end
      else if VType <> varNull then
        Result := False;
  except
    Result := False;
  end;
end;

function ObjToVar(const Value: TObject): Variant;
begin
  VarClear(Result);
  TVarData(Result).VPointer := Pointer(Value);
  TVarData(Result).VType := varObject;
end;

function VarEquals(const Left, Right: Variant): Boolean;
var
  L, R: PVarData;
  LA, RA: PVarArray;
begin
  Result := False;
  L := FindVarData(Left);
  R := FindVarData(Right);
  if VarIsArray(Left) and VarIsArray(Right) then begin
    if (L.VType and varByRef) <> 0 then
      LA := PVarArray(L.VPointer^)
    else
      LA := L.VArray;
    if (R.VType and varByRef) <> 0 then
      RA := PVarArray(R.VPointer^)
    else
      RA := R.VArray;
    if LA = RA then Result := True;
  end
  else begin
    if (L.VType = varUnknown) and
       (R.VType = varUnknown) then
      Result := L.VUnknown = R.VUnknown
    else if (L.VType = varUnknown or varByRef) and
            (R.VType = varUnknown) then
      Result := Pointer(L.VPointer^) = R.VUnknown
    else if (L.VType = varUnknown) and
            (R.VType = varUnknown or varByRef) then
      Result := L.VUnknown = Pointer(R.VPointer^)
    else if (L.VType = varUnknown or varByRef) and
            (R.VType = varUnknown or varByRef) then
      Result := Pointer(L.VPointer^) = Pointer(R.VPointer^)
    else
      try
        Result := Left = Right;
      except
        Result := False;
      end;
  end;
end;

function VarRef(const Value: Variant): Variant;
var
  VType: TVarType;
begin
  if VarIsByRef(Value) then
    Result := Value
  else if VarIsArray(Value, False) then
    Result := VarArrayRef(Value)
  else begin
    VarClear(Result);
    VType := VarType(Value);
    if VType in [varSmallint, varInteger, varSingle, varDouble,
                 varCurrency, varDate, varOleStr, varDispatch,
                 varError, varBoolean, varUnknown, varShortInt,
                 varByte ,varWord, varLongWord, varInt64
                 {$IFDEF DELPHI2009_UP}, varUInt64{$ENDIF}] then begin
      TVarData(Result).VType := VType or varByRef;
      TVarData(Result).VPointer := @TVarData(Value).VPointer;
    end
{$IFDEF DELPHI6}
    else if VType <> varVariant then begin
      TVarData(Result).VType := VType or varByRef;
      TVarData(Result).VPointer := @TVarData(Value).VPointer;
    end
{$ENDIF}    
    else begin
      TVarData(Result).VType := varByRef or varVariant;
      TVarData(Result).VPointer := @TVarData(Value);
    end;
  end;
end;

function VarUnref(const Value: Variant): Variant;
begin
  if not VarIsByRef(Value) then
    Result := Value
  else begin
    VarClear(Result);
    with FindVarData(Value)^ do
      if (VType and varByRef) = 0 then begin
        TVarData(Result).VType := VType;
        TVarData(Result).VInt64 := VInt64;
      end
      else begin
        TVarData(Result).VType := VType and (not varByRef);
        TVarData(Result).VInt64 := Int64(VPointer^);
      end;
  end;
end;

function VarIsObj(const Value: Variant): Boolean;
begin
  Result := VarIsObj(Value, TObject);
end;

function VarIsObj(const Value: Variant; AClass: TClass): Boolean;
begin
  Result := True;
  try
    with FindVarData(Value)^ do
      if VType = varObject then
        Result := TObject(VPointer) is AClass
      else if VType <> varNull then
        Result := False;
  except
    Result := False;
  end;
end;

function VarIsList(const Value: Variant): Boolean;
begin
  Result := (FindVarData(Value)^.VType = varUnknown) and
            Supports(IInterface(Value), IList) or
            VarIsObj(Value, TAbstractList);
end;

function VarToList(const Value: Variant): IList;
begin
  if FindVarData(Value)^.VType = varUnknown then
    Supports(IInterface(Value), IList, Result)
  else if VarIsObj(Value, TAbstractList) then
    VarToObj(Value, TAbstractList, Result)
  else
    Error(reInvalidCast);
end;

function VarIsMap(const Value: Variant): Boolean;
begin
  Result := (FindVarData(Value)^.VType = varUnknown) and
            Supports(IInterface(Value), IMap) or
            VarIsObj(Value, TAbstractMap);
end;

function VarToMap(const Value: Variant): IMap;
begin
  if FindVarData(Value)^.VType = varUnknown then
    Supports(IInterface(Value), IMap, Result)
  else if VarIsObj(Value, TAbstractMap) then
    VarToObj(Value, TAbstractMap, Result)
  else
    Error(reInvalidCast);
end;

function VarIsIntf(const Value: Variant): Boolean;
begin
  Result := (FindVarData(Value)^.VType = varUnknown);
end;

function VarIsIntf(const Value: Variant; const IID: TGUID): Boolean;
begin
  Result := (FindVarData(Value)^.VType = varUnknown) and
            Supports(IInterface(Value), IID);
end;

function VarToIntf(const Value: Variant; const IID: TGUID; out AIntf): Boolean;
begin
  if FindVarData(Value)^.VType = varUnknown then
    Result := Supports(IInterface(Value), IID, AIntf)
  else
    Result := false;
end;

{$ifndef DELPHI2010_UP}
type
  TObjectFromInterfaceStub = packed record
    Stub: cardinal;
    case integer of
    0: (ShortJmp: ShortInt);
    1: (LongJmp: LongInt)
  end;
  PObjectFromInterfaceStub = ^TObjectFromInterfaceStub;
{$endif}

function IntfToObj(const Intf: IInterface): TInterfacedObject; {$ifdef DELPHI2010_UP}inline;{$endif}
begin
  if Intf = nil then
    result := nil
  else begin
{$ifdef DELPHI2010_UP}
    result := Intf as TInterfacedObject; // slower but always working
{$else}
    with PObjectFromInterfaceStub(PPointer(PPointer(Intf)^)^)^ do
    case Stub of
      $04244483: result := Pointer(Integer(Intf) + ShortJmp);
      $04244481: result := Pointer(Integer(Intf) + LongJmp);
      else       result := nil;
    end;
{$endif}
  end;
end;

const
  htNull    = $00000000;
  htBoolean = $10000000;
  htInteger = $20000000;
  htInt64   = $30000000;
  htDouble  = $40000000;
  htOleStr  = $50000000;
  htDate    = $60000000;
  htObject  = $70000000;
  htArray   = $80000000;

function HashOfString(const Value: WideString): Integer;
var
  I, N: Integer;
begin
  N := Length(Value);
  Result := 0;
  for I := 1 to N do
    Result := ((Result shl 2) or (Result shr 30)) xor Ord(Value[I]);
  Result := htOleStr or (Result and $0FFFFFFF);
end;

function GetHashType(VType: Word): Integer;
begin
  case VType of
    varEmpty:    Result := htNull;
    varNull:     Result := htNull;
    varBoolean:  Result := htBoolean;
    varByte:     Result := htInteger;
    varWord:     Result := htInteger;
    varShortInt: Result := htInteger;
    varSmallint: Result := htInteger;
    varInteger:  Result := htInteger;
    varLongWord: Result := htInt64;
    varInt64:    Result := htInt64;
{$IFDEF DELPHI2009_UP}
    varUInt64:   Result := htInt64;
{$ENDIF}
    varSingle:   Result := htDouble;
    varDouble:   Result := htDouble;
    varCurrency: Result := htDouble;
    varOleStr:   Result := htOleStr;
    varDate:     Result := htDate;
    varUnknown:  Result := htObject;
    varVariant:  Result := htObject;
  else
    if VType = varObject then
      Result := htObject
    else
      Result := htNull;
  end;
end;

function HashOfVariant(const Value: Variant): Integer;
var
  P: PVarData;
begin
  P := FindVarData(Value);
  case P.VType of
    varEmpty:    Result := 0;
    varNull:     Result := 1;
    varBoolean:  Result := htBoolean or Abs(Integer(P.VBoolean));
    varByte:     Result := htInteger or P.VByte;
    varWord:     Result := htInteger or P.VWord;
    varShortInt: Result := htInteger or (P.VShortInt and $FF);
    varSmallint: Result := htInteger or (P.VSmallInt and $FFFF);
    varInteger:  Result := htInteger or (P.VInteger and $0FFFFFFF);
    varLongWord: Result := htInt64 or (P.VLongWord and $0FFFFFFF)
                           xor (not (P.VLongWord shr 3) and $10000000);
    varInt64:    Result := htInt64 or (P.VInt64 and $0FFFFFFF)
                           xor (not (P.VInt64 shr 3) and $10000000);
{$IFDEF DELPHI2009_UP}
    varUInt64:   Result := htInt64 or (P.VUInt64 and $0FFFFFFF)
                           xor (not (P.VUInt64 shr 3) and $10000000);
{$ENDIF}
    varSingle:   Result := htDouble or (P.VInteger and $0FFFFFFF);
    varDouble:   Result := htDouble or ((P.VInteger xor (P.VInt64 shr 32))
                           and $0FFFFFFF);
    varCurrency: Result := htDouble or ((P.VInteger xor (P.VInt64 shr 32))
                           and $0FFFFFFF);
    varDate:     Result := htDate or ((P.VInteger xor (P.VInt64 shr 32))
                           and $0FFFFFFF);
    varUnknown:  Result := htObject or (P.VInteger and $0FFFFFFF);
    varVariant:  Result := htObject or (P.VInteger and $0FFFFFFF);
  else
    if  P.VType and varByRef <> 0 then
      case P.VType and not varByRef of
        varBoolean:  Result := htBoolean
                               or Abs(Integer(PWordBool(P.VPointer)^));
        varByte:     Result := htInteger or PByte(P.VPointer)^;
        varWord:     Result := htInteger or PWord(P.VPointer)^;
        varShortInt: Result := htInteger or (PShortInt(P.VPointer)^ and $FF);
        varSmallInt: Result := htInteger or (PSmallInt(P.VPointer)^ and $FFFF);
        varInteger:  Result := htInteger or (PInteger(P.VPointer)^
                               and $0FFFFFFF);
        varLongWord: Result := htInt64 or (PLongWord(P.VPointer)^ and $0FFFFFFF)
                               xor (not (PLongWord(P.VPointer)^ shr 3)
                               and $10000000);
        varInt64:    Result := htInt64 or (PInt64(P.VPointer)^ and $0FFFFFFF)
                               xor (not (PInt64(P.VPointer)^ shr 3)
                               and $10000000);
{$IFDEF DELPHI2009_UP}
        varUInt64:   Result := htInt64 or (PUInt64(P.VPointer)^ and $0FFFFFFF)
                               xor (not (PUInt64(P.VPointer)^ shr 3)
                               and $10000000);
{$ENDIF}
        varSingle:   Result := htDouble or (PInteger(P.VPointer)^
                               and $0FFFFFFF);
        varDouble:   Result := htDouble or ((PInteger(P.VPointer)^
                               xor (PInt64(P.VPointer)^ shr 32)) and $0FFFFFFF);
        varCurrency: Result := htDouble or ((PInteger(P.VPointer)^
                               xor (PInt64(P.VPointer)^ shr 32)) and $0FFFFFFF);
        varDate:     Result := htDate or ((PInteger(P.VPointer)^
                               xor (PInt64(P.VPointer)^ shr 32)) and $0FFFFFFF);
        varUnknown:  Result := htObject or (PInteger(P.VPointer)^
                               and $0FFFFFFF);
      else
        if VarIsArray(Value) then
          Result := Integer(htArray) or GetHashType(P.VType and varTypeMask)
                    or (PInteger(P.VPointer)^ and $0FFFFFFF)
        else
          Result := 0;
      end
    else if VarIsArray(Value) then
      Result := Integer(htArray) or GetHashType(P.VType and varTypeMask)
                or (P.VInteger and $0FFFFFFF)
    else if P.VType = varObject then
      Result := htObject or (P.VInteger and $0FFFFFFF)
    else
      Result := (P.VInteger xor (P.VInt64 shr 32)) and $0FFFFFFF;
  end;
end;

// Copies a TVarRec and its contents. If the content is referenced
// the value will be copied to a new location and the reference
// updated.
function CopyVarRec(const Item: TVarRec): TVarRec;
var
  W: WideString;
begin
  // Copy entire TVarRec first
  Result := Item;

  // Now handle special cases
  case Item.VType of
    vtExtended:
      begin
        New(Result.VExtended);
        Result.VExtended^ := Item.VExtended^;
      end;
    vtString:
      begin
        New(Result.VString);
        Result.VString^ := Item.VString^;
      end;
    vtPChar:
      Result.VPChar := StrNew(Item.VPChar);
    // there is no StrNew for PWideChar
    vtPWideChar:
      begin
        W := Item.VPWideChar;
        GetMem(Result.VPWideChar, 
               (Length(W) + 1) * SizeOf(WideChar));
        Move(PWideChar(W)^, Result.VPWideChar^, 
             (Length(W) + 1) * SizeOf(WideChar));
      end;
    // a little trickier: casting to AnsiString will ensure
    // reference counting is done properly
    vtAnsiString:
      begin
        // nil out first, so no attempt to decrement
        // reference count
        Result.VAnsiString := nil;
        AnsiString(Result.VAnsiString) := AnsiString(Item.VAnsiString);
      end;
    vtCurrency:
      begin
        New(Result.VCurrency);
        Result.VCurrency^ := Item.VCurrency^;
      end;
    vtVariant:
      begin
        New(Result.VVariant);
        Result.VVariant^ := Item.VVariant^;
      end;
    // casting ensures proper reference counting
    vtInterface:
      begin
        Result.VInterface := nil;
        IInterface(Result.VInterface) := IInterface(Item.VInterface);
      end;
    // casting ensures a proper copy is created
    vtWideString:
      begin
        Result.VWideString := nil;
        WideString(Result.VWideString) := WideString(Item.VWideString);
      end;
    vtInt64:
      begin
        New(Result.VInt64);
        Result.VInt64^ := Item.VInt64^;
      end;
{$IFDEF DELPHI2009_UP}
    vtUnicodeString:
      begin
        // nil out first, so no attempt to decrement
        // reference count
        Result.VUnicodeString := nil;
        UnicodeString(Result.VUnicodeString) := UnicodeString(Item.VUnicodeString);
      end;
{$ENDIF}
{$IFDEF FPC}
    vtQWord:
      begin
        New(Result.VQWord);
        Result.VQWord^ := Item.VQWord^;
      end;
{$ENDIF}
    // VPointer and VObject don't have proper copy semantics so it
    // is impossible to write generic code that copies the contents
  end;
end;

// Creates a TConstArray out of the values given. Uses CopyVarRec
// to make copies of the original elements.
function CreateConstArray(const Elements: array of const): TConstArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Elements));
  for I := Low(Elements) to High(Elements) do
    Result[I] := CopyVarRec(Elements[I]);
end;


// TVarRecs created by CopyVarRec must be finalized with this function.
// You should not use it on other TVarRecs.
// use this function on copied TVarRecs only!
procedure FinalizeVarRec(var Item: TVarRec);
begin
  case Item.VType of
    vtExtended: Dispose(Item.VExtended);
    vtString: Dispose(Item.VString);
    vtPChar: StrDispose(Item.VPChar);
    vtPWideChar: FreeMem(Item.VPWideChar);
    vtAnsiString: AnsiString(Item.VAnsiString) := '';
    vtCurrency: Dispose(Item.VCurrency);
    vtVariant: Dispose(Item.VVariant);
    vtInterface: IInterface(Item.VInterface) := nil;
    vtWideString: WideString(Item.VWideString) := '';
    vtInt64: Dispose(Item.VInt64);
  {$IFDEF DELPHI2009_UP}
    vtUnicodeString: UnicodeString(Item.VUnicodeString) := '';
  {$ENDIF}
  {$IFDEF FPC}
    vtQWord: Dispose(Item.VQWord);
  {$ENDIF}
  end;
  Item.VPointer := nil;
end;

// A TConstArray contains TVarRecs that must be finalized. This function
// does that for all items in the array.
procedure FinalizeConstArray(var Arr: TConstArray);
var
  I: Integer;
begin
  for I := Low(Arr) to High(Arr) do
    FinalizeVarRec(Arr[I]);
  Finalize(Arr);
  Arr := nil;
end;

type

  TListEnumerator = class(TInterfacedObject, IListEnumerator)
  private
    FList: IList;
    FIndex: Integer;
    function GetCurrent: Variant;
  public
    constructor Create(AList: IList);
    function MoveNext: Boolean;
    property Current: Variant read GetCurrent;
  end;

{ TListEnumerator }

constructor TListEnumerator.Create(AList: IList);
begin
  FList := AList;
  FIndex := -1;
end;

function TListEnumerator.GetCurrent: Variant;
begin
  Result := FList[FIndex];
end;

function TListEnumerator.MoveNext: Boolean;
begin
  if FIndex < FList.Count - 1 then begin
    Inc(FIndex);
    Result := True;
  end
  else
    Result := False;
end;

{ TAbstractList }

destructor TAbstractList.Destroy;
begin
  Clear;
  FreeAndNil(FLock);
  FreeAndNil(FReadWriteLock);
  inherited Destroy;
end;

procedure TAbstractList.InitLock;
begin
  if FLock = nil then
    FLock := TCriticalSection.Create;
end;

procedure TAbstractList.InitReadWriteLock;
begin
  if FReadWriteLock = nil then
    FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

procedure TAbstractList.Lock;
begin
  FLock.Acquire;
end;

procedure TAbstractList.Unlock;
begin
  FLock.Release;
end;

procedure TAbstractList.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

function TAbstractList.BeginWrite: Boolean;
begin
  Result := FReadWriteLock.BeginWrite;
end;

procedure TAbstractList.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TAbstractList.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

procedure TAbstractList.Assign(const Source: IList);
var
  I: Integer;
begin
  Clear;
  Capacity := Source.Capacity;
  for I := 0 to Source.Count - 1 do Add(Source[I]);
end;

function TAbstractList.GetEnumerator: IListEnumerator;
begin
  Result := TListEnumerator.Create(Self);
end;

function TAbstractList.Join(const Glue, LeftPad, RightPad: string): string;
var
  Buffer: TStringBuffer;
  E: IListEnumerator;
begin
  if Count = 0 then begin
    Result := LeftPad + RightPad;
    Exit;
  end;
  E := GetEnumerator;
  Buffer := TStringBuffer.Create(LeftPad);
  E.MoveNext;
  while True do begin
    Buffer.WriteString(VarToStr(E.Current));
    if not E.MoveNext then Break;
    Buffer.WriteString(Glue);
  end;
  Buffer.WriteString(RightPad);
  Result := Buffer.ToString;
  Buffer.Free;
end;

class function TAbstractList.Split(Str: string; const Separator: string;
  Limit: Integer; TrimItem: Boolean; SkipEmptyItem: Boolean; Sync: Boolean;
      ReadWriteSync: Boolean): IList;
var
  I, N, L: Integer;
  S: string;
begin
  if Str = '' then begin
    Result := nil;
    Exit;
  end;
  Result := Self.Create(Sync, ReadWriteSync);
  L := Length(Separator);
  N := 0;
  I := L;
  while (I > 0) and ((Limit = 0) or (N < Limit - 1)) do begin
    I := AnsiPos(Separator, Str);
    if I > 0 then begin
      S := Copy(Str, 1, I - 1);
      if TrimItem then S := Trim(S);
      if not SkipEmptyItem or (S <> '') then Result.Add(S);
      Str := Copy(Str, I + L, MaxInt);
      Inc(N);
    end
  end;
  if TrimItem then Str := Trim(Str);
  if not SkipEmptyItem or (Str <> '') then Result.Add(Str);
end;

{ TArrayList }

function TArrayList.Add(const Value: Variant): Integer;
begin
  Result := FCount;
  if FCount = FCapacity then Grow;
  FList[Result] := Value;
  Inc(FCount);
end;

procedure TArrayList.AddAll(const AList: IList);
var
  TotalCount, I: Integer;
begin
  TotalCount := FCount + AList.Count;
  if TotalCount > FCapacity then begin
    FCapacity := TotalCount;
    Grow;
  end;
  for I := 0 to AList.Count - 1 do Add(AList[I]);
end;

procedure TArrayList.AddAll(const Container: Variant);
var
  I: Integer;
begin
  if VarIsList(Container) then begin
    AddAll(VarToList(Container));
  end
  else if VarIsArray(Container) then begin
    for I := VarArrayLowBound(Container, 1) to
             VarArrayHighBound(Container, 1) do
      Add(Container[I]);
  end;
end;

procedure TArrayList.Clear;
begin
  SetLength(FList, 0);
  FCount := 0;
  FCapacity := 0;
end;

function TArrayList.Contains(const Value: Variant): Boolean;
begin
  Result := IndexOf(Value) > -1;
end;


constructor TArrayList.Create(Capacity: Integer; Sync, ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  FCapacity := Capacity;
  FCount := 0;
  SetLength(FList, FCapacity);
end;

constructor TArrayList.Create(Sync, ReadWriteSync: Boolean);
begin
  Create(4, Sync, ReadWriteSync);
end;

{$IFDEF BCB}
constructor TArrayList.Create0;
begin
  Create;
end;
constructor TArrayList.Create1(Capacity: Integer);
begin
  Create(Capacity);
end;
constructor TArrayList.Create2(Capacity: Integer; Sync: Boolean);
begin
  Create(Capacity, Sync);
end;

constructor TArrayList.CreateS(Sync: Boolean);
begin
  Create(Sync);
end;
{$ENDIF}

function TArrayList.Delete(Index: Integer): Variant;
begin
  if (Index >= 0) and (Index < FCount) then begin
    Result := FList[Index];
    Dec(FCount);

    VarClear(FList[Index]);

    if Index < FCount then begin
      System.Move(FList[Index + 1], FList[Index],
        (FCount - Index) * SizeOf(Variant));
      FillChar(FList[FCount], SizeOf(Variant), 0);
    end;
  end;
end;

procedure TArrayList.Exchange(Index1, Index2: Integer);
var
  Item: Variant;
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index1]);
  if (Index2 < 0) or (Index2 >= FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index2]);

  Item := FList[Index1];
  FList[Index1] := FList[Index2];
  FList[Index2] := Item;
end;

function TArrayList.Get(Index: Integer): Variant;
begin
  if (Index >= 0) and (Index < FCount) then
    Result := FList[Index]
  else
    Result := Unassigned;
end;

function TArrayList.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TArrayList.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TArrayList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TArrayList.IndexOf(const Value: Variant): Integer;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    if VarEquals(FList[I], Value) then begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

procedure TArrayList.Insert(Index: Integer; const Value: Variant);
begin
  if (Index < 0) or (Index > FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index]);
  if FCount = FCapacity then Grow;
  if Index < FCount then begin
    System.Move(FList[Index], FList[Index + 1],
      (FCount - Index) * SizeOf(Variant));
    FillChar(FList[Index], SizeOf(Variant), 0);
  end;
  FList[Index] := Value;
  Inc(FCount);
end;

procedure TArrayList.Move(CurIndex, NewIndex: Integer);
var
  Value: Variant;
begin
  if CurIndex <> NewIndex then begin
    if (NewIndex < 0) or (NewIndex >= FCount) then
      raise EArrayListError.CreateResFmt(@SListIndexError, [NewIndex]);
    Value := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Value);
  end;
end;

procedure TArrayList.Put(Index: Integer; const Value: Variant);
begin
  if (Index < 0) or (Index > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index]);

  if Index >= FCapacity then begin
    FCapacity := Index;
    Grow;
  end;
  if Index >= FCount then FCount := Index + 1;

  FList[Index] := Value;
end;

function TArrayList.Remove(const Value: Variant): Integer;
begin
  Result := IndexOf(Value);
  if Result >= 0 then Delete(Result);
end;

function TArrayList.ToArray: TVariants;
begin
  Result := Copy(FList, 0, FCount);
end;

function TArrayList.ToArray(VarType: TVarType): Variant;
var
  I: Integer;
begin
  Result := VarArrayCreate([0, FCount - 1], VarType);
  for I := 0 to FCount - 1 do Result[I] := FList[I];
end;

procedure TArrayList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListCapacityError, [NewCapacity]);
  if NewCapacity <> FCapacity then begin
    SetLength(FList, NewCapacity);
    FCapacity := NewCapacity;
  end;
end;

procedure TArrayList.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListCountError, [NewCount]);

  if NewCount > FCapacity then begin
    FCapacity := NewCount;
    Grow;
  end
  else if NewCount < FCount then
    for I := FCount - 1 downto NewCount do
      Delete(I);

  FCount := NewCount;
end;

{ THashBucket }

function THashBucket.Add(HashCode, Index: Integer): PHashItem;
var
  HashIndex: Integer;
begin
  if FCount * FFactor >= FCapacity then Grow;
  HashIndex := (HashCode and $7FFFFFFF) mod FCapacity;
  System.New(Result);
  Result.HashCode := HashCode;
  Result.Index := Index;
  Result.Next := FIndices[HashIndex];
  FIndices[HashIndex] := Result;
  Inc(FCount);
end;

procedure THashBucket.Clear;
var
  I: Integer;
  HashItem: PHashItem;
begin
  for I := 0 to FCapacity - 1 do begin
    while FIndices[I] <> nil do begin
      HashItem := FIndices[I].Next;
      Dispose(FIndices[I]);
      FIndices[I] := HashItem;
    end;
  end;
  FCount := 0;
end;

constructor THashBucket.Create(Capacity: Integer; Factor: Single);
begin
  FCount := 0;
  FFactor := Factor;
  FCapacity := Capacity;
  SetLength(FIndices, FCapacity);
end;

procedure THashBucket.Delete(HashCode, Index: Integer);
var
  HashIndex: Integer;
  HashItem, Prev: PHashItem;
begin
  HashIndex := (HashCode and $7FFFFFFF) mod FCapacity;
  HashItem := FIndices[HashIndex];
  Prev := nil;
  while HashItem <> nil do begin
    if HashItem.Index = Index then begin
      if Prev <> nil then
        Prev.Next := HashItem.Next
      else
        FIndices[HashIndex] := HashItem.Next;
      Dispose(HashItem);
      Dec(FCount);
      Exit;
    end;
    Prev := HashItem;
    HashItem := HashItem.Next;
  end;
end;

destructor THashBucket.Destroy;
begin
  Clear;
  inherited;
end;

procedure THashBucket.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function THashBucket.IndexOf(HashCode: Integer; const Value: Variant;
  CompareProc: TIndexCompareMethod): Integer;
var
  HashIndex: Integer;
  HashItem: PHashItem;
begin
  Result := -1;
  HashIndex := (HashCode and $7FFFFFFF) mod FCapacity;
  HashItem := FIndices[HashIndex];
  while HashItem <> nil do
    if (HashItem.HashCode = HashCode) and
       CompareProc(HashItem.Index, Value) then begin
      Result := HashItem.Index;
      Exit;
    end
    else
      HashItem := HashItem.Next;
end;

function THashBucket.Modify(OldHashCode, NewHashCode,
  Index: Integer): PHashItem;
var
  HashIndex: Integer;
  Prev: PHashItem;
begin
  if OldHashCode = NewHashCode then
    Result := nil
  else begin
     HashIndex := (OldHashCode and $7FFFFFFF) mod FCapacity;
    Result := FIndices[HashIndex];
    Prev := nil;
    while Result <> nil do begin
      if Result.Index = Index then begin
        if Prev <> nil then
          Prev.Next := Result.Next
       else
          FIndices[HashIndex] := Result.Next;
        Result.HashCode := NewHashCode;
        HashIndex := (NewHashCode and $7FFFFFFF) mod FCapacity;
        Result.Next := FIndices[HashIndex];
        FIndices[HashIndex] := Result;
        Exit;
      end;
      Prev := Result;
      Result := Result.Next;
    end;
  end;
end;

procedure THashBucket.SetCapacity(NewCapacity: Integer);
var
  HashIndex, I: Integer;
  NewIndices: THashItemDynArray;
  HashItem, NewHashItem: PHashItem;
begin
  if (NewCapacity < 0) or (NewCapacity > MaxListSize) then
    raise EHashBucketError.CreateResFmt(@SListCapacityError, [NewCapacity]);
  if FCapacity = NewCapacity then Exit;
  if NewCapacity = 0 then begin
    Clear;
    SetLength(FIndices, 0);
    FCapacity := 0;
  end
  else begin
    SetLength(NewIndices, NewCapacity);
    for I := 0 to FCapacity - 1 do begin
      HashItem := FIndices[I];
      while HashItem <> nil do begin
        NewHashItem := HashItem;
        HashItem := HashItem.Next;
        HashIndex := (NewHashItem.HashCode and $7FFFFFFF) mod NewCapacity;
        NewHashItem.Next := NewIndices[HashIndex];
        NewIndices[HashIndex] := NewHashItem;
      end;
    end;
    FIndices := NewIndices;
    FCapacity := NewCapacity;
  end;
end;

{ THashedList }

function THashedList.Add(const Value: Variant): Integer;
begin
  Result := inherited Add(Value);
  FHashBucket.Add(HashOf(Value), Result);
end;

procedure THashedList.Clear;
begin
  inherited;
  if FHashBucket <> nil then FHashBucket.Clear;
end;

constructor THashedList.Create(Capacity: Integer; Sync, ReadWriteSync: Boolean);
begin
  Create(Capacity, 0.75, Sync, ReadWriteSync);
end;

constructor THashedList.Create(Capacity: Integer; Factor: Single; Sync,
  ReadWriteSync: Boolean);
begin
  inherited Create(Capacity, Sync, ReadWriteSync);
  FHashBucket := THashBucket.Create(Capacity, Factor);
end;

{$IFDEF BCB}
constructor THashedList.Create3(Capacity: Integer; Factor: Single;
  Sync: Boolean);
begin
  Create(Capacity, Factor, Sync);
end;
{$ENDIF}

function THashedList.Delete(Index: Integer): Variant;
var
  OldHashCode, NewHashCode, I, OldCount: Integer;
begin
  OldCount := Count;
  Result := inherited Delete(Index);
  if (Index >= 0) and (Index < OldCount) then begin
    if Index < Count then begin
      OldHashCode := HashOf(Result);
      for I := Index to Count - 1 do begin
        NewHashCode := HashOf(FList[I]);
        FHashBucket.Modify(OldHashCode, NewHashCode, I);
        OldHashCode := NewHashCode;
      end;
    end;
    FHashBucket.Delete(HashOf(Result), Count);
  end;
end;

destructor THashedList.Destroy;
begin
  FreeAndNil(FHashBucket);
  inherited;
end;

procedure THashedList.Exchange(Index1, Index2: Integer);
var
  HashCode1, HashCode2: Integer;
begin
  HashCode1 := HashOf(Get(Index1));
  HashCode2 := HashOf(Get(Index2));
  if HashCode1 <> HashCode2 then begin
    FHashBucket.Modify(HashCode1, HashCode2, Index1);
    FHashBucket.Modify(HashCode2, HashCode1, Index2);
  end;

  inherited Exchange(Index1, Index2);
end;

function THashedList.HashOf(const Value: Variant): Integer;
begin
  if VarIsStr(Value) then
    Result := HashOfString(WideString(Value))
  else
    Result := HashOfVariant(Value);
end;

function THashedList.IndexCompare(Index: Integer;
  const Value: Variant): Boolean;
var
  Item: Variant;
begin
  Item := Get(Index);
  if VarIsStr(Item) and VarIsStr(Value) then
    Result := WideCompareStr(Item, Value) = 0
  else
    Result := VarEquals(Item, Value)
end;

function THashedList.IndexOf(const Value: Variant): Integer;
begin
  Result := FHashBucket.IndexOf(HashOf(Value), Value, IndexCompare);
end;

procedure THashedList.Insert(Index: Integer; const Value: Variant);
var
  NewHashCode, OldHashCode, I, LastIndex: Integer;
begin
  LastIndex := Count;
  inherited Insert(Index, Value);

  NewHashCode := HashOf(Value);

  if Index < LastIndex then begin
    for I := Index to LastIndex - 1 do begin
      OldHashCode := HashOf(Get(I + 1));
      FHashBucket.Modify(OldHashCode, NewHashCode, I);
      NewHashCode := OldHashCode;
    end;
  end;

  FHashBucket.Add(NewHashCode, LastIndex);
end;

procedure THashedList.Put(Index: Integer; const Value: Variant);
var
  OldHashCode, NewHashCode: Integer;
begin
  OldHashCode := HashOf(Get(Index));
  NewHashCode := HashOf(Value);

  inherited Put(Index, Value);

  if (OldHashCode <> NewHashCode) and
    (FHashBucket.Modify(OldHashCode, NewHashCode, Index) = nil) then
    FHashBucket.Add(NewHashCode, Index);
end;

{ TCaseInsensitiveHashedList }
{$IFDEF BCB}
constructor TCaseInsensitiveHashedList.Create4(Capacity: Integer;
  Factor: Single; Sync, ReadWriteSync: Boolean);
begin
  Create(Capacity, Factor, Sync, ReadWriteSync);
end;
{$ENDIF}

function TCaseInsensitiveHashedList.HashOf(const Value: Variant): Integer;
begin
  if VarIsStr(Value) then
    Result := HashOfString(WideLowerCase(Value))
  else
    Result := HashOfVariant(Value);
end;

function TCaseInsensitiveHashedList.IndexCompare(Index: Integer;
  const Value: Variant): Boolean;
var
  Item: Variant;
begin
  Item := Get(Index);
  if VarIsStr(Item) and VarIsStr(Value) then
    Result := WideCompareText(Item, Value) = 0
  else
    Result := VarEquals(Item, Value)
end;

type

  TMapEnumerator = class(TInterfacedObject, IMapEnumerator)
  private
    FMap: IMap;
    FIndex: Integer;
    function GetCurrent: TMapEntry;
  public
    constructor Create(AMap: IMap);
    function MoveNext: Boolean;
    property Current: TMapEntry read GetCurrent;
  end;

{ TMapEnumerator }

constructor TMapEnumerator.Create(AMap: IMap);
begin
  FMap := AMap;
  FIndex := -1;
end;

function TMapEnumerator.GetCurrent: TMapEntry;
begin
  Result.Key := FMap.Keys[FIndex];
  Result.Value := FMap.Values[FIndex];
end;

function TMapEnumerator.MoveNext: Boolean;
begin
    if FIndex < FMap.Count - 1 then begin
    Inc(FIndex);
    Result := True;
  end
  else
    Result := False;
end;

{ TAbstractMap }

destructor TAbstractMap.Destroy;
begin
  FreeAndNil(FLock);
  FreeAndNil(FReadWriteLock);
  inherited Destroy;
end;

function TAbstractMap.GetEnumerator: IMapEnumerator;
begin
  Result := TMapEnumerator.Create(Self);
end;

procedure TAbstractMap.InitLock;
begin
  if FLock = nil then
    FLock := TCriticalSection.Create;
end;

procedure TAbstractMap.InitReadWriteLock;
begin
  if FReadWriteLock = nil then
    FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

procedure TAbstractMap.Lock;
begin
  FLock.Acquire;
end;

procedure TAbstractMap.Unlock;
begin
  FLock.Release;
end;

procedure TAbstractMap.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

function TAbstractMap.BeginWrite: Boolean;
begin
  Result := FReadWriteLock.BeginWrite;
end;

procedure TAbstractMap.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TAbstractMap.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

procedure TAbstractMap.Assign(const Source: IMap);
begin
  Keys.Assign(Source.Keys);
  Values.Assign(Source.Values);
end;

function TAbstractMap.Join(const ItemGlue, KeyValueGlue, LeftPad,
  RightPad: string): string;
var
  Buffer: TStringBuffer;
  E: IMapEnumerator;
  Entry: TMapEntry;
begin
  if Count = 0 then begin
    Result := LeftPad + RightPad;
    Exit;
  end;
  E := GetEnumerator;
  Buffer := TStringBuffer.Create(LeftPad);
  E.MoveNext;
  while True do begin
    Entry := E.Current;
    Buffer.WriteString(VarToStr(Entry.Key));
    Buffer.WriteString(KeyValueGlue);
    Buffer.WriteString(VarToStr(Entry.Value));
    if not E.MoveNext then Break;
    Buffer.WriteString(ItemGlue);
  end;
  Buffer.WriteString(RightPad);
  Result := Buffer.ToString;
  Buffer.Free;
end;

class function TAbstractMap.Split(Str: string; const ItemSeparator,
  KeyValueSeparator: string; Limit: Integer; TrimKey, TrimValue,
  SkipEmptyKey, SkipEmptyValue: Boolean; Sync, ReadWriteSync: Boolean): IMap;

var
  I, L, L2, N: Integer;

procedure SetKeyValue(const AMap: IMap; const S: string);
var
  J: Integer;
  Key, Value: string;
begin
  if (SkipEmptyKey or SkipEmptyValue) and (S = '') then Exit;
  J := AnsiPos(KeyValueSeparator, S);
  if J > 0 then begin
    Key := Copy(S, 1, J - 1);
    if TrimKey then Key := Trim(Key);
    Value := Copy(S, J + L2, MaxInt);
    if TrimValue then Value := Trim(Value);
    if SkipEmptyKey and (Key = '') then Exit;
    if SkipEmptyValue and (Value = '') then Exit;
    AMap[Key] := Value;
  end
  else if SkipEmptyValue then
    Exit
  else if TrimKey then begin
    Key := Trim(S);
    if SkipEmptyKey and (Key = '') then Exit;
    AMap[Key] := '';
  end
  else
    AMap[S] := '';
end;

begin
  if Str = '' then begin
    Result := nil;
    Exit;
  end;
  Result := Self.Create(Sync, ReadWriteSync);
  L := Length(ItemSeparator);
  L2 := Length(KeyValueSeparator);
  N := 0;
  I := L;
  while (I > 0) and ((Limit = 0) or (N < Limit - 1)) do begin
    I := AnsiPos(ItemSeparator, Str);
    if I > 0 then begin
      SetKeyValue(Result, Copy(Str, 1, I - 1));
      Str := Copy(Str, I + L, MaxInt);
      Inc(N);
    end
  end;
  SetKeyValue(Result, Str);
end;

{ THashMap }

procedure THashMap.Clear;
begin
  FKeys.Clear;
  FValues.Clear;
end;

function THashMap.ContainsKey(const Key: Variant): Boolean;
begin
  Result := FKeys.Contains(Key);
end;

function THashMap.ContainsValue(const Value: Variant): Boolean;
begin
  Result := FValues.Contains(Value);
end;

constructor THashMap.Create(Capacity: Integer; Factor: Single; Sync,
  ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  InitData(THashedList.Create(Capacity, Factor, False),
           TArrayList.Create(Capacity, False));
end;

constructor THashMap.Create(Sync, ReadWriteSync: Boolean);
begin
  Create(16, 0.75, Sync, ReadWriteSync);
end;

{$IFDEF BCB}
constructor THashMap.Create0;
begin
  Create;
end;

constructor THashMap.Create1(Capacity: Integer);
begin
  Create(Capacity);
end;

constructor THashMap.Create2(Capacity: Integer; Factor: Single);
begin
  Create(Capacity, Factor);
end;

constructor THashMap.Create3(Capacity: Integer; Factor: Single; Sync: Boolean);
begin
  Create(Capacity, Factor, Sync);
end;

constructor THashMap.CreateS(Sync: Boolean);
begin
  Create(Sync);
end;
{$ENDIF}

function THashMap.Delete(const Key: Variant): Variant;
begin
  Result := FValues.Delete(FKeys.Remove(Key));
end;

function THashMap.GetCount: Integer;
begin
  Result := FKeys.Count;
end;

function THashMap.Get(const Key: Variant): Variant;
begin
  Result := FValues[FKeys.IndexOf(Key)];
end;

function THashMap.GetKey(const Value: Variant): Variant;
begin
  Result := FKeys[FValues.IndexOf(Value)];
end;

procedure THashMap.InitData(Keys, Values: IList);
begin
  FKeys := Keys;
  FValues := Values;
end;

procedure THashMap.PutAll(const AMap: IMap);
var
  I: Integer;
  K, V: IList;
begin
  K := AMap.Keys;
  V := AMap.Values;
  for I := 0 to AMap.Count - 1 do
    Put(K[I], V[I]);
end;

procedure THashMap.PutAll(const Container: Variant);
var
  I: Integer;
begin
  if VarIsList(Container) then
    PutAll(VarToList(Container))
  else if VarIsMap(Container) then
    PutAll(VarToMap(Container))
  else if VarIsArray(Container) then begin
    for I := VarArrayLowBound(Container, 1) to
             VarArrayHighBound(Container, 1) do
      Put(I, Container[I]);
  end;
end;

procedure THashMap.PutAll(const AList: IList);
var
  I: Integer;
begin
  for I := 0 to AList.Count - 1 do
    Put(I, AList[I]);
end;

procedure THashMap.Put(const Key, Value: Variant);
var
  Index: Integer;
begin
  Index := FKeys.IndexOf(Key);
  if Index > -1 then
    FValues[Index] := Value
  else
    FValues[FKeys.Add(Key)] := Value;
end;

function THashMap.ToList(ListClass: TListClass; Sync,
  ReadWriteSync: Boolean): IList;
var
  I: Integer;
begin
  Result := ListClass.Create(Count, Sync, ReadWriteSync) as IList;
  for I := 0 to Count - 1 do
    if (VarIsOrdinal(FKeys[I])) and (FKeys[I] >= 0)
      and (FKeys[I] <= MaxListSize) then Result.Put(FKeys[I], FValues[I]);
end;

function THashMap.ToArrayList(Sync, ReadWriteSync: Boolean): TArrayList;
var
  I: Integer;
begin
  Result := TArrayList.Create(Count, Sync, ReadWriteSync);
  for I := 0 to Count - 1 do
    if (VarIsOrdinal(FKeys[I])) and (FKeys[I] >= 0)
      and (FKeys[I] <= MaxListSize) then Result.Put(FKeys[I], FValues[I]);
end;

function THashMap.GetKeys: IList;
begin
  Result := FKeys;
end;

function THashMap.GetValues: IList;
begin
  Result := FValues;
end;

{ THashedMap }

constructor THashedMap.Create(Capacity: Integer; Factor: Single;
      Sync, ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  InitData(THashedList.Create(Capacity, Factor, False),
           THashedList.Create(Capacity, Factor, False));
end;

{ TCaseInsensitiveHashMap }

constructor TCaseInsensitiveHashMap.Create(Capacity: Integer; Factor: Single;
      Sync, ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  InitData(TCaseInsensitiveHashedList.Create(Capacity, Factor, False),
           TArrayList.Create(Capacity, False));
end;

{ TCaseInsensitiveHashedMap }

constructor TCaseInsensitiveHashedMap.Create(Capacity: Integer; Factor: Single;
      Sync, ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  InitData(TCaseInsensitiveHashedList.Create(Capacity, Factor, False),
           THashedList.Create(Capacity, Factor, False));
end;

{ TStringBuffer }

constructor TStringBuffer.Create(const AString: string);
begin
{$IFDEF DELPHI2009_UP}
  FDataString := RawByteString(AString);
{$ELSE}
  FDataString := AString;
{$ENDIF}
  FLength := System.Length(FDataString);
  FCapacity := FLength;
  FPosition := FLength;
end;

constructor TStringBuffer.Create(Capacity: Integer);
begin
  FLength := 0;
  FPosition := 0;
  FCapacity := Capacity;
  SetLength(FDataString, Capacity);
end;

procedure TStringBuffer.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TStringBuffer.Insert(const Buffer; Count: Integer): Longint;
begin
  if FPosition = FLength then
    Result := Write(Buffer, Count)
  else begin
    Result := Count;
    if (FLength + Result > FCapacity) then begin
      FCapacity := FLength + Result;
      Grow;
    end;
    Move(PAnsiChar(@FDataString[FPosition + 1])^,
      PAnsiChar(@FDataString[FPosition + Result + 1])^, FLength - FPosition);
    Move(Buffer, PAnsiChar(@FDataString[FPosition + 1])^, Result);
    Inc(FPosition, Result);
    Inc(FLength, Result);
  end;
end;

procedure TStringBuffer.InsertString(const AString: string);
{$IFDEF DELPHI2009_UP}
var
  S: RawByteString;
begin
  S := RawByteString(AString);
  Insert(PAnsiChar(S)^, System.Length(S));
end;
{$ELSE}
begin
  Insert(PAnsiChar(AString)^, System.Length(AString));
end;
{$ENDIF}

function TStringBuffer.Read(var Buffer; Count: Integer): Longint;
begin
  Result := FLength - FPosition;
  if Result > Count then Result := Count;
  if Result > 0 then begin
    Move(PAnsiChar(@FDataString[FPosition + 1])^, Buffer, Result);
    Inc(FPosition, Result);
  end
  else Result := 0;
end;

function TStringBuffer.ReadString(Count: Integer): string;
var
  Len: Integer;
begin
  Len := FLength - FPosition;
  if Len > Count then Len := Count;
  if Len > 0 then begin
    SetString(Result, PAnsiChar(@FDataString[FPosition + 1]), Len);
    Inc(FPosition, Len);
  end;
end;

function TStringBuffer.Seek(Offset: Integer; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := FLength - Offset;
  end;
  if FPosition > FLength then
    FPosition := FLength
  else if FPosition < 0 then FPosition := 0;
  Result := FPosition;
end;

procedure TStringBuffer.SetCapacity(NewCapacity: Integer);
begin
  FCapacity := NewCapacity;
  if FLength > NewCapacity then FLength := NewCapacity;
  if FPosition > NewCapacity then FPosition := NewCapacity;
  SetLength(FDataString, NewCapacity);
end;

procedure TStringBuffer.SetPosition(NewPosition: Integer);
begin
  if NewPosition < 0 then FPosition := 0
  else if NewPosition > FLength then FPosition := FLength
  else FPosition := NewPosition;
end;

function TStringBuffer.ToString: string;
begin
  SetString(Result, PAnsiChar(FDataString), FLength);
end;

function TStringBuffer.Write(const Buffer; Count: Integer): Longint;
begin
  Result := Count;
  if (FPosition + Result > FCapacity) then begin
    FCapacity := FPosition + Result;
    Grow;
  end;
  Move(Buffer, PAnsiChar(@FDataString[FPosition + 1])^, Result);
  Inc(FPosition, Result);
  if FPosition > FLength then FLength := FPosition;
end;

procedure TStringBuffer.WriteString(const AString: string);
{$IFDEF DELPHI2009_UP}
var
  S: RawByteString;
begin
  S := RawByteString(AString);
  Write(PAnsiChar(S)^, System.Length(S));
end;
{$ELSE}
begin
  Write(PAnsiChar(AString)^, System.Length(AString));
end;
{$ENDIF}

{$IFNDEF FPC}
{ TVarObjectType }

procedure TVarObjectType.CastTo(var Dest: TVarData; const Source: TVarData;
  const AVarType: TVarType);
begin
  if (AVarType = varNull) and IsClear(Source) then
    Variant(Dest) := Null
  else if AVarType = varInteger then
    Variant(Dest) := FindVarData(Variant(Source)).VInteger
  else if AVarType = varInt64 then
    Variant(Dest) := FindVarData(Variant(Source)).VInt64
  else if AVarType = varString then
    Variant(Dest) := AnsiString(TObject(FindVarData(Variant(Source)).VPointer).ClassName)
{$IFDEF DELPHI2009_UP}
  else if AVarType = varUString then
    Variant(Dest) := UnicodeString(TObject(FindVarData(Variant(Source)).VPointer).ClassName)
{$ENDIF}
  else if AVarType = varOleStr then
    Variant(Dest) := WideString(TObject(FindVarData(Variant(Source)).VPointer).ClassName)
  else
    RaiseCastError;
end;

procedure TVarObjectType.Clear(var V: TVarData);
begin
  V.VType := varEmpty;
  V.VPointer := nil;
end;

function TVarObjectType.CompareOp(const Left, Right: TVarData;
  const Operation: TVarOp): Boolean;
begin
  Result := False;
  if (Left.VType = varObject) and (Right.VType = varObject) then
    case Operation of
      opCmpEQ:
        Result := Left.VPointer = Right.VPointer;
      opCmpNE:
        Result := Left.VPointer <> Right.VPointer;
    else
      RaiseInvalidOp;
    end
{$IFDEF DELPHI6}
  else if (Left.VType = varObject or varByRef) and
          (Right.VType = varObject) then
    case Operation of
      opCmpEQ:
        Result := PPointer(Left.VPointer)^ = Right.VPointer;
      opCmpNE:
        Result := PPointer(Left.VPointer)^ <> Right.VPointer;
    else
      RaiseInvalidOp;
    end
  else if (Left.VType = varObject) and
          (Right.VType = varObject or varByRef) then
    case Operation of
      opCmpEQ:
        Result := Left.VPointer = PPointer(Right.VPointer)^;
      opCmpNE:
        Result := Left.VPointer <> PPointer(Right.VPointer)^;
    else
      RaiseInvalidOp;
    end
  else if (Left.VType = varObject or varByRef) and
          (Right.VType = varObject or varByRef) then
    case Operation of
      opCmpEQ:
        Result := PPointer(Left.VPointer)^ = PPointer(Right.VPointer)^;
      opCmpNE:
        Result := PPointer(Left.VPointer)^ <> PPointer(Right.VPointer)^;
    else
      RaiseInvalidOp;
    end
{$ENDIF}
  else
    case Operation of
      opCmpEQ:
        Result := False;
      opCmpNE:
        Result := True;
    else
      RaiseInvalidOp;
    end
end;

procedure TVarObjectType.Copy(var Dest: TVarData; const Source: TVarData;
  const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
    VarDataCopyNoInd(Dest, Source)
  else
    VarDataClear(Dest);
    with Dest do
    begin
      VType := Source.VType;
      VPointer := Source.VPointer;
    end;
end;

function TVarObjectType.IsClear(const V: TVarData): Boolean;
begin
  Result := V.VPointer = nil;
end;
{$ENDIF}

var
  HproseClassMap: IMap;
  HproseInterfaceMap: IMap;

procedure RegisterClass(const AClass: TClass; const Alias: string);
begin
  HproseClassMap.BeginWrite;
  try
{$IFDEF CPU64}
    HproseClassMap[Alias] := Int64(AClass);
{$ELSE}
    HproseClassMap[Alias] := Integer(AClass);
{$ENDIF}
  finally
    HproseClassMap.EndWrite;
  end;
end;

procedure RegisterClass(const AClass: TInterfacedClass; const IID: TGUID; const Alias: string);
begin
  HproseInterfaceMap.BeginWrite;
  RegisterClass(AClass, Alias);
  try
    HproseInterfaceMap[Alias] := GuidToString(IID);
  finally
    HproseInterfaceMap.EndWrite;
  end;
end;

function GetClassByAlias(const Alias: string): TClass;
begin
  HproseClassMap.BeginRead;
  try
{$IFDEF CPU64}
    Result := TClass(Int64(HproseClassMap[Alias]));
{$ELSE}
    Result := TClass(Integer(HproseClassMap[Alias]));
{$ENDIF}
  finally
    HproseClassMap.EndRead;
  end;
end;

function GetClassAlias(const AClass: TClass): string;
begin
  HproseClassMap.BeginRead;
  try
{$IFDEF CPU64}
    Result := HproseClassMap.Key[Int64(AClass)];
{$ELSE}
    Result := HproseClassMap.Key[Integer(AClass)];
{$ENDIF}
  finally
    HproseClassMap.EndRead;
  end;
end;

function GetClassByInterface(const IID: TGUID): TClass;
begin
  HproseInterfaceMap.BeginRead;
  try
    Result := GetClassByAlias(HproseInterfaceMap.Key[GuidToString(IID)]);
  finally
    HproseInterfaceMap.EndRead;
  end;
end;

function GetInterfaceByClass(const AClass: TClass): TGUID;
begin
  HproseInterfaceMap.BeginRead;
  try
    Result := StringToGuid(HproseInterfaceMap[GetClassAlias(AClass)]);
  finally
    HproseInterfaceMap.EndRead;
  end;
end;

function ListSplit(ListClass: TListClass; Str: string;
  const Separator: string; Limit: Integer; TrimItem: Boolean;
  SkipEmptyItem: Boolean): IList;
begin
  Result := ListClass.Split(Str, Separator, Limit, TrimItem, SkipEmptyItem);
end;

function MapSplit(MapClass: TMapClass; Str: string;
  const ItemSeparator: string; const KeyValueSeparator: string;
  Limit: Integer; TrimKey: Boolean; TrimValue: Boolean;
  SkipEmptyKey: Boolean; SkipEmptyValue: Boolean): IMap;
begin
  Result := MapClass.Split(Str, ItemSeparator, KeyValueSeparator, Limit,
    TrimKey, TrimValue, SkipEmptyKey, SkipEmptyValue);
end;

{$IFDEF Supports_Generics}
{ TSmartObject<T> }

constructor TSmartObject<T>.Create();
begin
  FObject := T.Create;
end;

function TSmartObject<T>.ClassType: TClass;
begin
  Result := T;
end;

destructor TSmartObject<T>.Destroy;
begin
  FreeAndNil(FObject);
  inherited;
end;

function TSmartObject<T>.Get: TObject;
begin
  Result := FObject;
end;

function TSmartObject<T>.GetValue: T;
begin
  Result := FObject;
end;

class function TSmartObject<T>.New: ISmartObject<T>;
begin
  Result := TSmartObject<T>.Create as ISmartObject<T>;
end;

{$ENDIF}

{ TSmartObject }

function TSmartObject.ClassType: TClass;
begin
  Result := FClass;
end;

constructor TSmartObject.Create(const AClass: TClass);
begin
  FClass := AClass;
  FObject := AClass.Create;
end;

destructor TSmartObject.Destroy;
begin
  FreeAndNil(FObject);
  inherited;
end;

class function TSmartObject.New(const AClass: TClass): ISmartObject;
begin
  Result := TSmartObject.Create(AClass) as ISmartObject;
end;

function TSmartObject.Value: TObject;
begin
  Result := FObject;
end;

initialization

  HproseClassMap := TCaseInsensitiveHashedMap.Create(False, True);
  HproseInterfaceMap := TCaseInsensitiveHashedMap.Create(False, True);
{$IFNDEF FPC}
  VarObjectType := TVarObjectType.Create;
  varObject := VarObjectType.VarType;

finalization
  FreeAndNil(VarObjectType);
{$ENDIF}

end.
