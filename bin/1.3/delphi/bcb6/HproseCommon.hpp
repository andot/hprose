// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HproseCommon.pas' rev: 6.00

#ifndef HproseCommonHPP
#define HproseCommonHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <SysUtils.hpp>	// Pascal unit
#include <SyncObjs.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hprosecommon
{
//-- type declarations -------------------------------------------------------
typedef AnsiString RawByteString;

#pragma option push -b-
enum THproseResultMode { Normal, Serialized, Raw, RawWithEndTag };
#pragma option pop

typedef DynamicArray<Variant >  TVariants;

typedef TVariants *PVariants;

typedef DynamicArray<System::TVarRec >  TConstArray;

class DELPHICLASS EHproseException;
class PASCALIMPLEMENTATION EHproseException : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	#pragma option push -w-inl
	/* Exception.Create */ inline __fastcall EHproseException(const AnsiString Msg) : Sysutils::Exception(Msg) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmt */ inline __fastcall EHproseException(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateRes */ inline __fastcall EHproseException(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmt */ inline __fastcall EHproseException(int Ident, const System::TVarRec * Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateHelp */ inline __fastcall EHproseException(const AnsiString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmtHelp */ inline __fastcall EHproseException(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResHelp */ inline __fastcall EHproseException(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmtHelp */ inline __fastcall EHproseException(System::PResStringRec ResStringRec, const System::TVarRec * Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~EHproseException(void) { }
	#pragma option pop
	
};


class DELPHICLASS EHashBucketError;
class PASCALIMPLEMENTATION EHashBucketError : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	#pragma option push -w-inl
	/* Exception.Create */ inline __fastcall EHashBucketError(const AnsiString Msg) : Sysutils::Exception(Msg) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmt */ inline __fastcall EHashBucketError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateRes */ inline __fastcall EHashBucketError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmt */ inline __fastcall EHashBucketError(int Ident, const System::TVarRec * Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateHelp */ inline __fastcall EHashBucketError(const AnsiString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmtHelp */ inline __fastcall EHashBucketError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResHelp */ inline __fastcall EHashBucketError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmtHelp */ inline __fastcall EHashBucketError(System::PResStringRec ResStringRec, const System::TVarRec * Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~EHashBucketError(void) { }
	#pragma option pop
	
};


class DELPHICLASS EArrayListError;
class PASCALIMPLEMENTATION EArrayListError : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	#pragma option push -w-inl
	/* Exception.Create */ inline __fastcall EArrayListError(const AnsiString Msg) : Sysutils::Exception(Msg) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmt */ inline __fastcall EArrayListError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateRes */ inline __fastcall EArrayListError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmt */ inline __fastcall EArrayListError(int Ident, const System::TVarRec * Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateHelp */ inline __fastcall EArrayListError(const AnsiString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateFmtHelp */ inline __fastcall EArrayListError(const AnsiString Msg, const System::TVarRec * Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResHelp */ inline __fastcall EArrayListError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	#pragma option pop
	#pragma option push -w-inl
	/* Exception.CreateResFmtHelp */ inline __fastcall EArrayListError(System::PResStringRec ResStringRec, const System::TVarRec * Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~EArrayListError(void) { }
	#pragma option pop
	
};


__interface IListEnumerator;
typedef System::DelphiInterface<IListEnumerator> _di_IListEnumerator;
__interface INTERFACE_UUID("{767477EC-A143-4DC6-9962-A6837A7AEC01}") IListEnumerator  : public IInterface 
{
	
public:
	virtual Variant __fastcall GetCurrent(void) = 0 ;
	virtual bool __fastcall MoveNext(void) = 0 ;
	__property Variant Current = {read=GetCurrent};
};

__interface IList;
typedef System::DelphiInterface<IList> _di_IList;
__interface INTERFACE_UUID("{DE925411-42B8-4DB3-A00C-B585C087EC4C}") IList  : public IReadWriteSync 
{
	
public:
	Variant operator[](int Index) { return Item[Index]; }
	
public:
	virtual Variant __fastcall Get(int Index) = 0 ;
	virtual void __fastcall Put(int Index, const Variant &Value) = 0 ;
	virtual int __fastcall GetCapacity(void) = 0 ;
	virtual int __fastcall GetCount(void) = 0 ;
	virtual void __fastcall SetCapacity(int NewCapacity) = 0 ;
	virtual void __fastcall SetCount(int NewCount) = 0 ;
	virtual int __fastcall Add(const Variant &Value) = 0 ;
	virtual void __fastcall AddAll(const _di_IList ArrayList) = 0 /* overload */;
	virtual void __fastcall AddAll(const Variant &Container) = 0 /* overload */;
	virtual void __fastcall Assign(const _di_IList Source) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall Contains(const Variant &Value) = 0 ;
	virtual Variant __fastcall Delete(int Index) = 0 ;
	virtual void __fastcall Exchange(int Index1, int Index2) = 0 ;
	virtual _di_IListEnumerator __fastcall GetEnumerator(void) = 0 ;
	virtual int __fastcall IndexOf(const Variant &Value) = 0 ;
	virtual void __fastcall Insert(int Index, const Variant &Value) = 0 ;
	virtual AnsiString __fastcall Join(const AnsiString Glue = ",", const AnsiString LeftPad = "", const AnsiString RightPad = "") = 0 ;
	virtual void __fastcall InitLock(void) = 0 ;
	virtual void __fastcall InitReadWriteLock(void) = 0 ;
	virtual void __fastcall Lock(void) = 0 ;
	virtual void __fastcall Unlock(void) = 0 ;
	virtual void __fastcall Move(int CurIndex, int NewIndex) = 0 ;
	virtual int __fastcall Remove(const Variant &Value) = 0 ;
	virtual TVariants __fastcall ToArray(void) = 0 /* overload */;
	virtual Variant __fastcall ToArray(Word VarType) = 0 /* overload */;
	__property Variant Item[int Index] = {read=Get, write=Put/*, default*/};
	__property int Capacity = {read=GetCapacity, write=SetCapacity};
	__property int Count = {read=GetCount, write=SetCount};
};

class DELPHICLASS TAbstractList;
class PASCALIMPLEMENTATION TAbstractList : public System::TInterfacedObject 
{
	typedef System::TInterfacedObject inherited;
	
public:
	Variant operator[](int Index) { return Item[Index]; }
	
private:
	Syncobjs::TCriticalSection* FLock;
	Sysutils::TMultiReadExclusiveWriteSynchronizer* FReadWriteLock;
	
protected:
	virtual Variant __fastcall Get(int Index) = 0 ;
	virtual void __fastcall Put(int Index, const Variant &Value) = 0 ;
	virtual int __fastcall GetCapacity(void) = 0 ;
	virtual int __fastcall GetCount(void) = 0 ;
	virtual void __fastcall SetCapacity(int NewCapacity) = 0 ;
	virtual void __fastcall SetCount(int NewCount) = 0 ;
	
public:
	__fastcall virtual TAbstractList(int Capacity, bool Sync, bool ReadWriteSync) = 0 /* overload */;
	__fastcall virtual TAbstractList(bool Sync, bool ReadWriteSync) = 0 /* overload */;
	__fastcall virtual ~TAbstractList(void);
	virtual int __fastcall Add(const Variant &Value) = 0 ;
	virtual void __fastcall AddAll(const _di_IList ArrayList) = 0 /* overload */;
	virtual void __fastcall AddAll(const Variant &Container) = 0 /* overload */;
	virtual void __fastcall Assign(const _di_IList Source);
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall Contains(const Variant &Value) = 0 ;
	virtual Variant __fastcall Delete(int Index) = 0 ;
	virtual void __fastcall Exchange(int Index1, int Index2) = 0 ;
	virtual _di_IListEnumerator __fastcall GetEnumerator();
	virtual int __fastcall IndexOf(const Variant &Value) = 0 ;
	virtual void __fastcall Insert(int Index, const Variant &Value) = 0 ;
	virtual AnsiString __fastcall Join(const AnsiString Glue, const AnsiString LeftPad, const AnsiString RightPad);
	/* virtual class method */ virtual _di_IList __fastcall Split(TMetaClass* vmt, AnsiString Str, const AnsiString Separator = ",", int Limit = 0x0, bool TrimItem = false, bool SkipEmptyItem = false, bool Sync = true, bool ReadWriteSync = false);
	void __fastcall InitLock(void);
	void __fastcall InitReadWriteLock(void);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
	void __fastcall BeginRead(void);
	void __fastcall EndRead(void);
	bool __fastcall BeginWrite(void);
	void __fastcall EndWrite(void);
	virtual void __fastcall Move(int CurIndex, int NewIndex) = 0 ;
	virtual int __fastcall Remove(const Variant &Value) = 0 ;
	virtual TVariants __fastcall ToArray(void) = 0 /* overload */;
	virtual Variant __fastcall ToArray(Word VarType) = 0 /* overload */;
	__property Variant Item[int Index] = {read=Get, write=Put/*, default*/};
	__property int Capacity = {read=GetCapacity, write=SetCapacity, nodefault};
	__property int Count = {read=GetCount, write=SetCount, nodefault};
private:
	void *__IList;	/* Hprosecommon::IList */
	
public:
	operator IList*(void) { return (IList*)&__IList; }
	
};


typedef TMetaClass*TListClass;

class DELPHICLASS TArrayList;
class PASCALIMPLEMENTATION TArrayList : public TAbstractList 
{
	typedef TAbstractList inherited;
	
public:
	Variant operator[](int Index) { return Item[Index]; }
	
private:
	int FCount;
	int FCapacity;
	DynamicArray<Variant >  FList;
	
protected:
	virtual Variant __fastcall Get(int Index);
	virtual void __fastcall Grow(void);
	virtual void __fastcall Put(int Index, const Variant &Value);
	virtual int __fastcall GetCapacity(void);
	virtual int __fastcall GetCount(void);
	virtual void __fastcall SetCapacity(int NewCapacity);
	virtual void __fastcall SetCount(int NewCount);
	
public:
	__fastcall virtual TArrayList(int Capacity, bool Sync, bool ReadWriteSync)/* overload */;
	__fastcall virtual TArrayList(bool Sync, bool ReadWriteSync)/* overload */;
	__fastcall virtual TArrayList(void);
	__fastcall virtual TArrayList(int Capacity);
	__fastcall virtual TArrayList(int Capacity, bool Sync);
	__fastcall virtual TArrayList(bool Sync);
	virtual int __fastcall Add(const Variant &Value);
	virtual void __fastcall AddAll(const _di_IList AList)/* overload */;
	virtual void __fastcall AddAll(const Variant &Container)/* overload */;
	virtual void __fastcall Clear(void);
	virtual bool __fastcall Contains(const Variant &Value);
	virtual Variant __fastcall Delete(int Index);
	virtual void __fastcall Exchange(int Index1, int Index2);
	virtual int __fastcall IndexOf(const Variant &Value);
	virtual void __fastcall Insert(int Index, const Variant &Value);
	virtual void __fastcall Move(int CurIndex, int NewIndex);
	virtual int __fastcall Remove(const Variant &Value);
	virtual TVariants __fastcall ToArray()/* overload */;
	virtual Variant __fastcall ToArray(Word VarType)/* overload */;
	__property Variant Item[int Index] = {read=Get, write=Put/*, default*/};
	__property int Count = {read=GetCount, write=SetCount, nodefault};
	__property int Capacity = {read=GetCapacity, write=SetCapacity, nodefault};
public:
	#pragma option push -w-inl
	/* TAbstractList.Destroy */ inline __fastcall virtual ~TArrayList(void) { }
	#pragma option pop
	
};


struct THashItem;
typedef THashItem *PHashItem;

#pragma pack(push, 4)
struct THashItem
{
	THashItem *Next;
	int Index;
	int HashCode;
} ;
#pragma pack(pop)

typedef DynamicArray<PHashItem >  THashItemDynArray;

typedef bool __fastcall (__closure *TIndexCompareMethod)(int Index, const Variant &Value);

class DELPHICLASS THashBucket;
class PASCALIMPLEMENTATION THashBucket : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	int FCount;
	float FFactor;
	int FCapacity;
	DynamicArray<PHashItem >  FIndices;
	void __fastcall Grow(void);
	void __fastcall SetCapacity(int NewCapacity);
	
public:
	__fastcall THashBucket(int Capacity, float Factor);
	__fastcall virtual ~THashBucket(void);
	PHashItem __fastcall Add(int HashCode, int Index);
	void __fastcall Clear(void);
	void __fastcall Delete(int HashCode, int Index);
	int __fastcall IndexOf(int HashCode, const Variant &Value, TIndexCompareMethod CompareProc);
	PHashItem __fastcall Modify(int OldHashCode, int NewHashCode, int Index);
	__property int Count = {read=FCount, nodefault};
	__property int Capacity = {read=FCapacity, write=SetCapacity, nodefault};
};


class DELPHICLASS THashedList;
class PASCALIMPLEMENTATION THashedList : public TArrayList 
{
	typedef TArrayList inherited;
	
private:
	THashBucket* FHashBucket;
	
protected:
	virtual int __fastcall HashOf(const Variant &Value);
	virtual bool __fastcall IndexCompare(int Index, const Variant &Value);
	virtual void __fastcall Put(int Index, const Variant &Value);
	
public:
	__fastcall virtual THashedList(int Capacity, bool Sync, bool ReadWriteSync)/* overload */;
	__fastcall virtual THashedList(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
	__fastcall virtual THashedList(int Capacity, float Factor, bool Sync);
	__fastcall virtual ~THashedList(void);
	virtual int __fastcall Add(const Variant &Value);
	virtual void __fastcall Clear(void);
	virtual Variant __fastcall Delete(int Index);
	virtual void __fastcall Exchange(int Index1, int Index2);
	virtual int __fastcall IndexOf(const Variant &Value);
	virtual void __fastcall Insert(int Index, const Variant &Value);
public:
	#pragma option push -w-inl
	/* TArrayList.Create0 */ inline __fastcall virtual THashedList(void) : TArrayList() { }
	#pragma option pop
	#pragma option push -w-inl
	/* TArrayList.Create1 */ inline __fastcall virtual THashedList(int Capacity) : TArrayList(Capacity) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TArrayList.Create2 */ inline __fastcall virtual THashedList(int Capacity, bool Sync) : TArrayList(Capacity, Sync) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TArrayList.CreateS */ inline __fastcall virtual THashedList(bool Sync) : TArrayList(Sync) { }
	#pragma option pop
	
};


class DELPHICLASS TCaseInsensitiveHashedList;
class PASCALIMPLEMENTATION TCaseInsensitiveHashedList : public THashedList 
{
	typedef THashedList inherited;
	
protected:
	virtual int __fastcall HashOf(const Variant &Value);
	virtual bool __fastcall IndexCompare(int Index, const Variant &Value);
	
public:
	__fastcall virtual TCaseInsensitiveHashedList(int Capacity, float Factor, bool Sync, bool ReadWriteSync);
public:
	#pragma option push -w-inl
	/* THashedList.Create */ inline __fastcall virtual TCaseInsensitiveHashedList(int Capacity, bool Sync, bool ReadWriteSync)/* overload */ : THashedList(Capacity, Sync, ReadWriteSync) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashedList.Create3 */ inline __fastcall virtual TCaseInsensitiveHashedList(int Capacity, float Factor, bool Sync) : THashedList(Capacity, Factor, Sync) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashedList.Destroy */ inline __fastcall virtual ~TCaseInsensitiveHashedList(void) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TArrayList.Create0 */ inline __fastcall virtual TCaseInsensitiveHashedList(void) : THashedList() { }
	#pragma option pop
	#pragma option push -w-inl
	/* TArrayList.Create1 */ inline __fastcall virtual TCaseInsensitiveHashedList(int Capacity) : THashedList(Capacity) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TArrayList.Create2 */ inline __fastcall virtual TCaseInsensitiveHashedList(int Capacity, bool Sync) : THashedList(Capacity, Sync) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TArrayList.CreateS */ inline __fastcall virtual TCaseInsensitiveHashedList(bool Sync) : THashedList(Sync) { }
	#pragma option pop
	
};


struct TMapEntry
{
	Variant Key;
	Variant Value;
} ;

__interface IMapEnumerator;
typedef System::DelphiInterface<IMapEnumerator> _di_IMapEnumerator;
__interface INTERFACE_UUID("{5DE7A194-4476-42A6-A1E7-CB1D20AA7B0A}") IMapEnumerator  : public IInterface 
{
	
public:
	virtual TMapEntry __fastcall GetCurrent(void) = 0 ;
	virtual bool __fastcall MoveNext(void) = 0 ;
	__property TMapEntry Current = {read=GetCurrent};
};

__interface IMap;
typedef System::DelphiInterface<IMap> _di_IMap;
__interface INTERFACE_UUID("{28B78387-CB07-4C28-B642-09716DAA2170}") IMap  : public IReadWriteSync 
{
	
public:
	Variant operator[](Variant Key) { return Value[Key]; }
	
public:
	virtual void __fastcall Assign(const _di_IMap Source) = 0 ;
	virtual int __fastcall GetCount(void) = 0 ;
	virtual _di_IList __fastcall GetKeys(void) = 0 ;
	virtual _di_IList __fastcall GetValues(void) = 0 ;
	virtual Variant __fastcall GetKey(const Variant &Value) = 0 ;
	virtual Variant __fastcall Get(const Variant &Key) = 0 ;
	virtual void __fastcall Put(const Variant &Key, const Variant &Value) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall ContainsKey(const Variant &Key) = 0 ;
	virtual bool __fastcall ContainsValue(const Variant &Value) = 0 ;
	virtual Variant __fastcall Delete(const Variant &Key) = 0 ;
	virtual _di_IMapEnumerator __fastcall GetEnumerator(void) = 0 ;
	virtual AnsiString __fastcall Join(const AnsiString ItemGlue = ";", const AnsiString KeyValueGlue = "=", const AnsiString LeftPad = "", const AnsiString RightPad = "") = 0 ;
	virtual void __fastcall InitLock(void) = 0 ;
	virtual void __fastcall InitReadWriteLock(void) = 0 ;
	virtual void __fastcall Lock(void) = 0 ;
	virtual void __fastcall Unlock(void) = 0 ;
	virtual void __fastcall PutAll(const _di_IList AList) = 0 /* overload */;
	virtual void __fastcall PutAll(const _di_IMap AMap) = 0 /* overload */;
	virtual void __fastcall PutAll(const Variant &Container) = 0 /* overload */;
	virtual _di_IList __fastcall ToList(TMetaClass* ListClass, bool Sync = true, bool ReadWriteSync = false) = 0 ;
	__property int Count = {read=GetCount};
	__property Variant Key[Variant Value] = {read=GetKey};
	__property Variant Value[Variant Key] = {read=Get, write=Put/*, default*/};
	__property _di_IList Keys = {read=GetKeys};
	__property _di_IList Values = {read=GetValues};
};

class DELPHICLASS TAbstractMap;
class PASCALIMPLEMENTATION TAbstractMap : public System::TInterfacedObject 
{
	typedef System::TInterfacedObject inherited;
	
public:
	Variant operator[](Variant Key) { return Value[Key]; }
	
private:
	Syncobjs::TCriticalSection* FLock;
	Sysutils::TMultiReadExclusiveWriteSynchronizer* FReadWriteLock;
	
protected:
	void __fastcall Assign(const _di_IMap Source);
	virtual int __fastcall GetCount(void) = 0 ;
	virtual _di_IList __fastcall GetKeys(void) = 0 ;
	virtual _di_IList __fastcall GetValues(void) = 0 ;
	virtual Variant __fastcall GetKey(const Variant &Value) = 0 ;
	virtual Variant __fastcall Get(const Variant &Key) = 0 ;
	virtual void __fastcall Put(const Variant &Key, const Variant &Value) = 0 ;
	
public:
	__fastcall virtual TAbstractMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync) = 0 /* overload */;
	__fastcall virtual TAbstractMap(bool Sync, bool ReadWriteSync) = 0 /* overload */;
	__fastcall virtual ~TAbstractMap(void);
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall ContainsKey(const Variant &Key) = 0 ;
	virtual bool __fastcall ContainsValue(const Variant &Value) = 0 ;
	virtual Variant __fastcall Delete(const Variant &Key) = 0 ;
	virtual _di_IMapEnumerator __fastcall GetEnumerator();
	virtual AnsiString __fastcall Join(const AnsiString ItemGlue, const AnsiString KeyValueGlue, const AnsiString LeftPad, const AnsiString RightPad);
	/* virtual class method */ virtual _di_IMap __fastcall Split(TMetaClass* vmt, AnsiString Str, const AnsiString ItemSeparator = ";", const AnsiString KeyValueSeparator = "=", int Limit = 0x0, bool TrimKey = false, bool TrimValue = false, bool SkipEmptyKey = false, bool SkipEmptyValue = false, bool Sync = true, bool ReadWriteSync = false);
	void __fastcall InitLock(void);
	void __fastcall InitReadWriteLock(void);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
	void __fastcall BeginRead(void);
	void __fastcall EndRead(void);
	bool __fastcall BeginWrite(void);
	void __fastcall EndWrite(void);
	virtual void __fastcall PutAll(const _di_IList AList) = 0 /* overload */;
	virtual void __fastcall PutAll(const _di_IMap AMap) = 0 /* overload */;
	virtual void __fastcall PutAll(const Variant &Container) = 0 /* overload */;
	virtual _di_IList __fastcall ToList(TMetaClass* ListClass, bool Sync = true, bool ReadWriteSync = false) = 0 ;
	__property int Count = {read=GetCount, nodefault};
	__property Variant Key[Variant Value] = {read=GetKey};
	__property Variant Value[Variant Key] = {read=Get, write=Put/*, default*/};
	__property _di_IList Keys = {read=GetKeys};
	__property _di_IList Values = {read=GetValues};
private:
	void *__IMap;	/* Hprosecommon::IMap */
	
public:
	operator IMap*(void) { return (IMap*)&__IMap; }
	
};


typedef TMetaClass*TMapClass;

class DELPHICLASS THashMap;
class PASCALIMPLEMENTATION THashMap : public TAbstractMap 
{
	typedef TAbstractMap inherited;
	
public:
	Variant operator[](Variant Key) { return Value[Key]; }
	
private:
	_di_IList FKeys;
	_di_IList FValues;
	
protected:
	virtual int __fastcall GetCount(void);
	virtual _di_IList __fastcall GetKeys();
	virtual _di_IList __fastcall GetValues();
	virtual Variant __fastcall GetKey(const Variant &Value);
	virtual Variant __fastcall Get(const Variant &Key);
	virtual void __fastcall Put(const Variant &Key, const Variant &Value);
	void __fastcall InitData(_di_IList Keys, _di_IList Values);
	
public:
	__fastcall virtual THashMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
	__fastcall virtual THashMap(bool Sync, bool ReadWriteSync)/* overload */;
	__fastcall virtual THashMap(void);
	__fastcall virtual THashMap(int Capacity);
	__fastcall virtual THashMap(int Capacity, float Factor);
	__fastcall virtual THashMap(int Capacity, float Factor, bool Sync);
	__fastcall virtual THashMap(bool Sync);
	virtual void __fastcall Clear(void);
	virtual bool __fastcall ContainsKey(const Variant &Key);
	virtual bool __fastcall ContainsValue(const Variant &Value);
	virtual Variant __fastcall Delete(const Variant &Key);
	virtual void __fastcall PutAll(const _di_IList AList)/* overload */;
	virtual void __fastcall PutAll(const _di_IMap AMap)/* overload */;
	virtual void __fastcall PutAll(const Variant &Container)/* overload */;
	virtual _di_IList __fastcall ToList(TMetaClass* ListClass, bool Sync = true, bool ReadWriteSync = false);
	virtual TArrayList* __fastcall ToArrayList(bool Sync = true, bool ReadWriteSync = false);
	__property Variant Key[Variant Value] = {read=GetKey};
	__property Variant Value[Variant Key] = {read=Get, write=Put/*, default*/};
	__property int Count = {read=GetCount, nodefault};
	__property _di_IList Keys = {read=GetKeys};
	__property _di_IList Values = {read=GetValues};
public:
	#pragma option push -w-inl
	/* TAbstractMap.Destroy */ inline __fastcall virtual ~THashMap(void) { }
	#pragma option pop
	
};


class DELPHICLASS THashedMap;
class PASCALIMPLEMENTATION THashedMap : public THashMap 
{
	typedef THashMap inherited;
	
public:
	__fastcall virtual THashedMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
public:
	#pragma option push -w-inl
	/* THashMap.Create0 */ inline __fastcall virtual THashedMap(void) : THashMap() { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create1 */ inline __fastcall virtual THashedMap(int Capacity) : THashMap(Capacity) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create2 */ inline __fastcall virtual THashedMap(int Capacity, float Factor) : THashMap(Capacity, Factor) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create3 */ inline __fastcall virtual THashedMap(int Capacity, float Factor, bool Sync) : THashMap(Capacity, Factor, Sync) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.CreateS */ inline __fastcall virtual THashedMap(bool Sync) : THashMap(Sync) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TAbstractMap.Destroy */ inline __fastcall virtual ~THashedMap(void) { }
	#pragma option pop
	
};


class DELPHICLASS TCaseInsensitiveHashMap;
class PASCALIMPLEMENTATION TCaseInsensitiveHashMap : public THashMap 
{
	typedef THashMap inherited;
	
public:
	__fastcall virtual TCaseInsensitiveHashMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
public:
	#pragma option push -w-inl
	/* THashMap.Create0 */ inline __fastcall virtual TCaseInsensitiveHashMap(void) : THashMap() { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create1 */ inline __fastcall virtual TCaseInsensitiveHashMap(int Capacity) : THashMap(Capacity) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create2 */ inline __fastcall virtual TCaseInsensitiveHashMap(int Capacity, float Factor) : THashMap(Capacity, Factor) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create3 */ inline __fastcall virtual TCaseInsensitiveHashMap(int Capacity, float Factor, bool Sync) : THashMap(Capacity, Factor, Sync) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.CreateS */ inline __fastcall virtual TCaseInsensitiveHashMap(bool Sync) : THashMap(Sync) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TAbstractMap.Destroy */ inline __fastcall virtual ~TCaseInsensitiveHashMap(void) { }
	#pragma option pop
	
};


class DELPHICLASS TCaseInsensitiveHashedMap;
class PASCALIMPLEMENTATION TCaseInsensitiveHashedMap : public THashMap 
{
	typedef THashMap inherited;
	
public:
	__fastcall virtual TCaseInsensitiveHashedMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
public:
	#pragma option push -w-inl
	/* THashMap.Create0 */ inline __fastcall virtual TCaseInsensitiveHashedMap(void) : THashMap() { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create1 */ inline __fastcall virtual TCaseInsensitiveHashedMap(int Capacity) : THashMap(Capacity) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create2 */ inline __fastcall virtual TCaseInsensitiveHashedMap(int Capacity, float Factor) : THashMap(Capacity, Factor) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.Create3 */ inline __fastcall virtual TCaseInsensitiveHashedMap(int Capacity, float Factor, bool Sync) : THashMap(Capacity, Factor, Sync) { }
	#pragma option pop
	#pragma option push -w-inl
	/* THashMap.CreateS */ inline __fastcall virtual TCaseInsensitiveHashedMap(bool Sync) : THashMap(Sync) { }
	#pragma option pop
	
public:
	#pragma option push -w-inl
	/* TAbstractMap.Destroy */ inline __fastcall virtual ~TCaseInsensitiveHashedMap(void) { }
	#pragma option pop
	
};


class DELPHICLASS TStringBuffer;
class PASCALIMPLEMENTATION TStringBuffer : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	AnsiString FDataString;
	int FPosition;
	int FCapacity;
	int FLength;
	void __fastcall Grow(void);
	void __fastcall SetPosition(int NewPosition);
	void __fastcall SetCapacity(int NewCapacity);
	
public:
	__fastcall TStringBuffer(int Capacity)/* overload */;
	__fastcall TStringBuffer(const AnsiString AString)/* overload */;
	int __fastcall Read(void *Buffer, int Count);
	AnsiString __fastcall ReadString(int Count);
	int __fastcall Write(const void *Buffer, int Count);
	void __fastcall WriteString(const AnsiString AString);
	int __fastcall Insert(const void *Buffer, int Count);
	void __fastcall InsertString(const AnsiString AString);
	int __fastcall Seek(int Offset, Word Origin);
	AnsiString __fastcall ToString();
	__property int Position = {read=FPosition, write=SetPosition, nodefault};
	__property int Length = {read=FLength, nodefault};
	__property int Capacity = {read=FCapacity, write=SetCapacity, nodefault};
	__property AnsiString DataString = {read=FDataString};
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~TStringBuffer(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Word varObject;
extern PACKAGE PVarData __fastcall FindVarData(const Variant &Value);
extern PACKAGE bool __fastcall VarIsType(const Variant &V, Word AVarType)/* overload */;
extern PACKAGE bool __fastcall VarIsType(const Variant &V, const Word * AVarTypes, const int AVarTypes_Size)/* overload */;
extern PACKAGE bool __fastcall VarIsCustom(const Variant &V);
extern PACKAGE bool __fastcall VarIsOrdinal(const Variant &V);
extern PACKAGE bool __fastcall VarIsFloat(const Variant &V);
extern PACKAGE bool __fastcall VarIsNumeric(const Variant &V);
extern PACKAGE bool __fastcall VarIsStr(const Variant &V);
extern PACKAGE bool __fastcall VarIsEmpty(const Variant &V);
extern PACKAGE bool __fastcall VarIsNull(const Variant &V);
extern PACKAGE System::TObject* __fastcall VarToObj(const Variant &Value)/* overload */;
extern PACKAGE System::TObject* __fastcall VarToObj(const Variant &Value, TMetaClass* AClass)/* overload */;
extern PACKAGE bool __fastcall VarToObj(const Variant &Value, TMetaClass* AClass, /* out */ void *AObject)/* overload */;
extern PACKAGE Variant __fastcall ObjToVar(const System::TObject* Value);
extern PACKAGE bool __fastcall VarEquals(const Variant &Left, const Variant &Right);
extern PACKAGE Variant __fastcall VarRef(const Variant &Value);
extern PACKAGE Variant __fastcall VarUnref(const Variant &Value);
extern PACKAGE bool __fastcall VarIsObj(const Variant &Value)/* overload */;
extern PACKAGE bool __fastcall VarIsObj(const Variant &Value, TMetaClass* AClass)/* overload */;
extern PACKAGE bool __fastcall VarIsList(const Variant &Value);
extern PACKAGE _di_IList __fastcall VarToList(const Variant &Value);
extern PACKAGE bool __fastcall VarIsMap(const Variant &Value);
extern PACKAGE _di_IMap __fastcall VarToMap(const Variant &Value);
extern PACKAGE System::TVarRec __fastcall CopyVarRec(const System::TVarRec &Item);
extern PACKAGE TConstArray __fastcall CreateConstArray(const System::TVarRec * Elements, const int Elements_Size);
extern PACKAGE void __fastcall FinalizeVarRec(System::TVarRec &Item);
extern PACKAGE void __fastcall FinalizeConstArray(TConstArray &Arr);
extern PACKAGE void __fastcall RegisterClass(const TMetaClass* AClass, const AnsiString Alias);
extern PACKAGE TMetaClass* __fastcall GetClassByAlias(const AnsiString Alias);
extern PACKAGE AnsiString __fastcall GetClassAlias(const TMetaClass* AClass);
extern PACKAGE _di_IList __fastcall ListSplit(TMetaClass* ListClass, AnsiString Str, const AnsiString Separator = ",", int Limit = 0x0, bool TrimItem = false, bool SkipEmptyItem = false);
extern PACKAGE _di_IMap __fastcall MapSplit(TMetaClass* MapClass, AnsiString Str, const AnsiString ItemSeparator = ";", const AnsiString KeyValueSeparator = "=", int Limit = 0x0, bool TrimKey = false, bool TrimValue = false, bool SkipEmptyKey = false, bool SkipEmptyValue = false);

}	/* namespace Hprosecommon */
using namespace Hprosecommon;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HproseCommon
