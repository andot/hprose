// CodeGear C++Builder
// Copyright (c) 1995, 2010 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HproseCommon.pas' rev: 22.00

#ifndef HprosecommonHPP
#define HprosecommonHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SyncObjs.hpp>	// Pascal unit
#include <SysUtils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hprosecommon
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum THproseResultMode { Normal, Serialized, Raw, RawWithEndTag };
#pragma option pop

typedef System::DynamicArray<System::Variant> TVariants;

typedef TVariants *PVariants;

typedef System::DynamicArray<System::TVarRec> TConstArray;

class DELPHICLASS EHproseException;
class PASCALIMPLEMENTATION EHproseException : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall EHproseException(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EHproseException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EHproseException(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EHproseException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EHproseException(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EHproseException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EHproseException(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EHproseException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EHproseException(void) { }
	
};


class DELPHICLASS EHashBucketError;
class PASCALIMPLEMENTATION EHashBucketError : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall EHashBucketError(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EHashBucketError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EHashBucketError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EHashBucketError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EHashBucketError(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EHashBucketError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EHashBucketError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EHashBucketError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EHashBucketError(void) { }
	
};


class DELPHICLASS EArrayListError;
class PASCALIMPLEMENTATION EArrayListError : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall EArrayListError(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EArrayListError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EArrayListError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EArrayListError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EArrayListError(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EArrayListError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EArrayListError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EArrayListError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EArrayListError(void) { }
	
};


__interface IListEnumerator;
typedef System::DelphiInterface<IListEnumerator> _di_IListEnumerator;
__interface  INTERFACE_UUID("{767477EC-A143-4DC6-9962-A6837A7AEC01}") IListEnumerator  : public System::IInterface 
{
	
public:
	virtual System::Variant __fastcall GetCurrent(void) = 0 ;
	virtual bool __fastcall MoveNext(void) = 0 ;
	__property System::Variant Current = {read=GetCurrent};
};

__interface IList;
typedef System::DelphiInterface<IList> _di_IList;
__interface  INTERFACE_UUID("{DE925411-42B8-4DB3-A00C-B585C087EC4C}") IList  : public Sysutils::IReadWriteSync 
{
	
public:
	System::Variant operator[](int Index) { return Item[Index]; }
	
public:
	virtual System::Variant __fastcall Get(int Index) = 0 ;
	virtual void __fastcall Put(int Index, const System::Variant &Value) = 0 ;
	virtual int __fastcall GetCapacity(void) = 0 ;
	virtual int __fastcall GetCount(void) = 0 ;
	virtual void __fastcall SetCapacity(int NewCapacity) = 0 ;
	virtual void __fastcall SetCount(int NewCount) = 0 ;
	virtual int __fastcall Add(const System::Variant &Value) = 0 ;
	virtual void __fastcall AddAll(const _di_IList ArrayList) = 0 /* overload */;
	virtual void __fastcall AddAll(const System::Variant &Container) = 0 /* overload */;
	virtual void __fastcall Assign(const _di_IList Source) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall Contains(const System::Variant &Value) = 0 ;
	virtual System::Variant __fastcall Delete(int Index) = 0 ;
	virtual void __fastcall Exchange(int Index1, int Index2) = 0 ;
	virtual _di_IListEnumerator __fastcall GetEnumerator(void) = 0 ;
	virtual int __fastcall IndexOf(const System::Variant &Value) = 0 ;
	virtual void __fastcall Insert(int Index, const System::Variant &Value) = 0 ;
	virtual System::UnicodeString __fastcall Join(const System::UnicodeString Glue = L",", const System::UnicodeString LeftPad = L"", const System::UnicodeString RightPad = L"") = 0 ;
	virtual void __fastcall InitLock(void) = 0 ;
	virtual void __fastcall InitReadWriteLock(void) = 0 ;
	virtual void __fastcall Lock(void) = 0 ;
	virtual void __fastcall Unlock(void) = 0 ;
	virtual void __fastcall Move(int CurIndex, int NewIndex) = 0 ;
	virtual int __fastcall Remove(const System::Variant &Value) = 0 ;
	virtual TVariants __fastcall ToArray(void) = 0 /* overload */;
	virtual System::Variant __fastcall ToArray(System::Word VarType) = 0 /* overload */;
	__property System::Variant Item[int Index] = {read=Get, write=Put/*, default*/};
	__property int Capacity = {read=GetCapacity, write=SetCapacity};
	__property int Count = {read=GetCount, write=SetCount};
};

class DELPHICLASS TAbstractList;
class PASCALIMPLEMENTATION TAbstractList : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
public:
	System::Variant operator[](int Index) { return Item[Index]; }
	
private:
	Syncobjs::TCriticalSection* FLock;
	Sysutils::TMultiReadExclusiveWriteSynchronizer* FReadWriteLock;
	
protected:
	virtual System::Variant __fastcall Get(int Index) = 0 ;
	virtual void __fastcall Put(int Index, const System::Variant &Value) = 0 ;
	virtual int __fastcall GetCapacity(void) = 0 ;
	virtual int __fastcall GetCount(void) = 0 ;
	virtual void __fastcall SetCapacity(int NewCapacity) = 0 ;
	virtual void __fastcall SetCount(int NewCount) = 0 ;
	
public:
	__fastcall virtual TAbstractList(int Capacity, bool Sync, bool ReadWriteSync) = 0 /* overload */;
	__fastcall virtual TAbstractList(bool Sync, bool ReadWriteSync) = 0 /* overload */;
	__fastcall virtual ~TAbstractList(void);
	virtual int __fastcall Add(const System::Variant &Value) = 0 ;
	virtual void __fastcall AddAll(const _di_IList ArrayList) = 0 /* overload */;
	virtual void __fastcall AddAll(const System::Variant &Container) = 0 /* overload */;
	virtual void __fastcall Assign(const _di_IList Source);
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall Contains(const System::Variant &Value) = 0 ;
	virtual System::Variant __fastcall Delete(int Index) = 0 ;
	virtual void __fastcall Exchange(int Index1, int Index2) = 0 ;
	virtual _di_IListEnumerator __fastcall GetEnumerator(void);
	virtual int __fastcall IndexOf(const System::Variant &Value) = 0 ;
	virtual void __fastcall Insert(int Index, const System::Variant &Value) = 0 ;
	virtual System::UnicodeString __fastcall Join(const System::UnicodeString Glue, const System::UnicodeString LeftPad, const System::UnicodeString RightPad);
	__classmethod virtual _di_IList __fastcall Split(System::UnicodeString Str, const System::UnicodeString Separator = L",", int Limit = 0x0, bool TrimItem = false, bool SkipEmptyItem = false, bool Sync = true, bool ReadWriteSync = false);
	void __fastcall InitLock(void);
	void __fastcall InitReadWriteLock(void);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
	void __fastcall BeginRead(void);
	void __fastcall EndRead(void);
	bool __fastcall BeginWrite(void);
	void __fastcall EndWrite(void);
	virtual void __fastcall Move(int CurIndex, int NewIndex) = 0 ;
	virtual int __fastcall Remove(const System::Variant &Value) = 0 ;
	virtual TVariants __fastcall ToArray(void) = 0 /* overload */;
	virtual System::Variant __fastcall ToArray(System::Word VarType) = 0 /* overload */;
	__property System::Variant Item[int Index] = {read=Get, write=Put/*, default*/};
	__property int Capacity = {read=GetCapacity, write=SetCapacity, nodefault};
	__property int Count = {read=GetCount, write=SetCount, nodefault};
private:
	void *__IList;	/* IList */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IList()
	{
		_di_IList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IList*(void) { return (IList*)&__IList; }
	#endif
	
};


typedef TMetaClass* TListClass;

class DELPHICLASS TArrayList;
class PASCALIMPLEMENTATION TArrayList : public TAbstractList
{
	typedef TAbstractList inherited;
	
public:
	System::Variant operator[](int Index) { return Item[Index]; }
	
private:
	int FCount;
	int FCapacity;
	TVariants FList;
	
protected:
	virtual System::Variant __fastcall Get(int Index);
	virtual void __fastcall Grow(void);
	virtual void __fastcall Put(int Index, const System::Variant &Value);
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
	virtual int __fastcall Add(const System::Variant &Value);
	virtual void __fastcall AddAll(const _di_IList AList)/* overload */;
	virtual void __fastcall AddAll(const System::Variant &Container)/* overload */;
	virtual void __fastcall Clear(void);
	virtual bool __fastcall Contains(const System::Variant &Value);
	virtual System::Variant __fastcall Delete(int Index);
	virtual void __fastcall Exchange(int Index1, int Index2);
	virtual int __fastcall IndexOf(const System::Variant &Value);
	virtual void __fastcall Insert(int Index, const System::Variant &Value);
	virtual void __fastcall Move(int CurIndex, int NewIndex);
	virtual int __fastcall Remove(const System::Variant &Value);
	virtual TVariants __fastcall ToArray(void)/* overload */;
	virtual System::Variant __fastcall ToArray(System::Word VarType)/* overload */;
	__property System::Variant Item[int Index] = {read=Get, write=Put/*, default*/};
	__property int Count = {read=GetCount, write=SetCount, nodefault};
	__property int Capacity = {read=GetCapacity, write=SetCapacity, nodefault};
public:
	/* TAbstractList.Destroy */ inline __fastcall virtual ~TArrayList(void) { }
	
};


struct THashItem;
typedef THashItem *PHashItem;

struct DECLSPEC_DRECORD THashItem
{
	
public:
	THashItem *Next;
	int Index;
	int HashCode;
};


typedef System::DynamicArray<PHashItem> THashItemDynArray;

typedef bool __fastcall (__closure *TIndexCompareMethod)(int Index, const System::Variant &Value);

class DELPHICLASS THashBucket;
class PASCALIMPLEMENTATION THashBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FCount;
	float FFactor;
	int FCapacity;
	THashItemDynArray FIndices;
	void __fastcall Grow(void);
	void __fastcall SetCapacity(int NewCapacity);
	
public:
	__fastcall THashBucket(int Capacity, float Factor);
	__fastcall virtual ~THashBucket(void);
	PHashItem __fastcall Add(int HashCode, int Index);
	void __fastcall Clear(void);
	void __fastcall Delete(int HashCode, int Index);
	int __fastcall IndexOf(int HashCode, const System::Variant &Value, TIndexCompareMethod CompareProc);
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
	virtual int __fastcall HashOf(const System::Variant &Value);
	virtual bool __fastcall IndexCompare(int Index, const System::Variant &Value);
	virtual void __fastcall Put(int Index, const System::Variant &Value);
	
public:
	__fastcall virtual THashedList(int Capacity, bool Sync, bool ReadWriteSync)/* overload */;
	__fastcall virtual THashedList(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
	__fastcall virtual THashedList(int Capacity, float Factor, bool Sync);
	__fastcall virtual ~THashedList(void);
	virtual int __fastcall Add(const System::Variant &Value);
	virtual void __fastcall Clear(void);
	virtual System::Variant __fastcall Delete(int Index);
	virtual void __fastcall Exchange(int Index1, int Index2);
	virtual int __fastcall IndexOf(const System::Variant &Value);
	virtual void __fastcall Insert(int Index, const System::Variant &Value);
public:
	/* TArrayList.Create0 */ inline __fastcall virtual THashedList(void) : TArrayList() { }
	/* TArrayList.Create1 */ inline __fastcall virtual THashedList(int Capacity) : TArrayList(Capacity) { }
	/* TArrayList.Create2 */ inline __fastcall virtual THashedList(int Capacity, bool Sync) : TArrayList(Capacity, Sync) { }
	/* TArrayList.CreateS */ inline __fastcall virtual THashedList(bool Sync) : TArrayList(Sync) { }
	
};


class DELPHICLASS TCaseInsensitiveHashedList;
class PASCALIMPLEMENTATION TCaseInsensitiveHashedList : public THashedList
{
	typedef THashedList inherited;
	
protected:
	virtual int __fastcall HashOf(const System::Variant &Value);
	virtual bool __fastcall IndexCompare(int Index, const System::Variant &Value);
	
public:
	__fastcall virtual TCaseInsensitiveHashedList(int Capacity, float Factor, bool Sync, bool ReadWriteSync);
public:
	/* THashedList.Create */ inline __fastcall virtual TCaseInsensitiveHashedList(int Capacity, bool Sync, bool ReadWriteSync)/* overload */ : THashedList(Capacity, Sync, ReadWriteSync) { }
	/* THashedList.Create3 */ inline __fastcall virtual TCaseInsensitiveHashedList(int Capacity, float Factor, bool Sync) : THashedList(Capacity, Factor, Sync) { }
	/* THashedList.Destroy */ inline __fastcall virtual ~TCaseInsensitiveHashedList(void) { }
	
public:
	/* TArrayList.Create0 */ inline __fastcall virtual TCaseInsensitiveHashedList(void) : THashedList() { }
	/* TArrayList.Create1 */ inline __fastcall virtual TCaseInsensitiveHashedList(int Capacity) : THashedList(Capacity) { }
	/* TArrayList.Create2 */ inline __fastcall virtual TCaseInsensitiveHashedList(int Capacity, bool Sync) : THashedList(Capacity, Sync) { }
	/* TArrayList.CreateS */ inline __fastcall virtual TCaseInsensitiveHashedList(bool Sync) : THashedList(Sync) { }
	
};


struct DECLSPEC_DRECORD TMapEntry
{
	
public:
	System::Variant Key;
	System::Variant Value;
};


__interface IMapEnumerator;
typedef System::DelphiInterface<IMapEnumerator> _di_IMapEnumerator;
__interface  INTERFACE_UUID("{5DE7A194-4476-42A6-A1E7-CB1D20AA7B0A}") IMapEnumerator  : public System::IInterface 
{
	
public:
	virtual TMapEntry __fastcall GetCurrent(void) = 0 ;
	virtual bool __fastcall MoveNext(void) = 0 ;
	__property TMapEntry Current = {read=GetCurrent};
};

__interface IMap;
typedef System::DelphiInterface<IMap> _di_IMap;
__interface  INTERFACE_UUID("{28B78387-CB07-4C28-B642-09716DAA2170}") IMap  : public Sysutils::IReadWriteSync 
{
	
public:
	System::Variant operator[](System::Variant Key) { return Value[Key]; }
	
public:
	virtual void __fastcall Assign(const _di_IMap Source) = 0 ;
	virtual int __fastcall GetCount(void) = 0 ;
	virtual _di_IList __fastcall GetKeys(void) = 0 ;
	virtual _di_IList __fastcall GetValues(void) = 0 ;
	virtual System::Variant __fastcall GetKey(const System::Variant &Value) = 0 ;
	virtual System::Variant __fastcall Get(const System::Variant &Key) = 0 ;
	virtual void __fastcall Put(const System::Variant &Key, const System::Variant &Value) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall ContainsKey(const System::Variant &Key) = 0 ;
	virtual bool __fastcall ContainsValue(const System::Variant &Value) = 0 ;
	virtual System::Variant __fastcall Delete(const System::Variant &Key) = 0 ;
	virtual _di_IMapEnumerator __fastcall GetEnumerator(void) = 0 ;
	virtual System::UnicodeString __fastcall Join(const System::UnicodeString ItemGlue = L";", const System::UnicodeString KeyValueGlue = L"=", const System::UnicodeString LeftPad = L"", const System::UnicodeString RightPad = L"") = 0 ;
	virtual void __fastcall InitLock(void) = 0 ;
	virtual void __fastcall InitReadWriteLock(void) = 0 ;
	virtual void __fastcall Lock(void) = 0 ;
	virtual void __fastcall Unlock(void) = 0 ;
	virtual void __fastcall PutAll(const _di_IList AList) = 0 /* overload */;
	virtual void __fastcall PutAll(const _di_IMap AMap) = 0 /* overload */;
	virtual void __fastcall PutAll(const System::Variant &Container) = 0 /* overload */;
	virtual _di_IList __fastcall ToList(TListClass ListClass, bool Sync = true, bool ReadWriteSync = false) = 0 ;
	__property int Count = {read=GetCount};
	__property System::Variant Key[System::Variant Value] = {read=GetKey};
	__property System::Variant Value[System::Variant Key] = {read=Get, write=Put/*, default*/};
	__property _di_IList Keys = {read=GetKeys};
	__property _di_IList Values = {read=GetValues};
};

class DELPHICLASS TAbstractMap;
class PASCALIMPLEMENTATION TAbstractMap : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
public:
	System::Variant operator[](System::Variant Key) { return Value[Key]; }
	
private:
	Syncobjs::TCriticalSection* FLock;
	Sysutils::TMultiReadExclusiveWriteSynchronizer* FReadWriteLock;
	
protected:
	void __fastcall Assign(const _di_IMap Source);
	virtual int __fastcall GetCount(void) = 0 ;
	virtual _di_IList __fastcall GetKeys(void) = 0 ;
	virtual _di_IList __fastcall GetValues(void) = 0 ;
	virtual System::Variant __fastcall GetKey(const System::Variant &Value) = 0 ;
	virtual System::Variant __fastcall Get(const System::Variant &Key) = 0 ;
	virtual void __fastcall Put(const System::Variant &Key, const System::Variant &Value) = 0 ;
	
public:
	__fastcall virtual TAbstractMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync) = 0 /* overload */;
	__fastcall virtual TAbstractMap(bool Sync, bool ReadWriteSync) = 0 /* overload */;
	__fastcall virtual ~TAbstractMap(void);
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall ContainsKey(const System::Variant &Key) = 0 ;
	virtual bool __fastcall ContainsValue(const System::Variant &Value) = 0 ;
	virtual System::Variant __fastcall Delete(const System::Variant &Key) = 0 ;
	virtual _di_IMapEnumerator __fastcall GetEnumerator(void);
	virtual System::UnicodeString __fastcall Join(const System::UnicodeString ItemGlue, const System::UnicodeString KeyValueGlue, const System::UnicodeString LeftPad, const System::UnicodeString RightPad);
	__classmethod virtual _di_IMap __fastcall Split(System::UnicodeString Str, const System::UnicodeString ItemSeparator = L";", const System::UnicodeString KeyValueSeparator = L"=", int Limit = 0x0, bool TrimKey = false, bool TrimValue = false, bool SkipEmptyKey = false, bool SkipEmptyValue = false, bool Sync = true, bool ReadWriteSync = false);
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
	virtual void __fastcall PutAll(const System::Variant &Container) = 0 /* overload */;
	virtual _di_IList __fastcall ToList(TListClass ListClass, bool Sync = true, bool ReadWriteSync = false) = 0 ;
	__property int Count = {read=GetCount, nodefault};
	__property System::Variant Key[System::Variant Value] = {read=GetKey};
	__property System::Variant Value[System::Variant Key] = {read=Get, write=Put/*, default*/};
	__property _di_IList Keys = {read=GetKeys};
	__property _di_IList Values = {read=GetValues};
private:
	void *__IMap;	/* IMap */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IMap()
	{
		_di_IMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IMap*(void) { return (IMap*)&__IMap; }
	#endif
	
};


typedef TMetaClass* TMapClass;

class DELPHICLASS THashMap;
class PASCALIMPLEMENTATION THashMap : public TAbstractMap
{
	typedef TAbstractMap inherited;
	
public:
	System::Variant operator[](System::Variant Key) { return Value[Key]; }
	
private:
	_di_IList FKeys;
	_di_IList FValues;
	
protected:
	virtual int __fastcall GetCount(void);
	virtual _di_IList __fastcall GetKeys(void);
	virtual _di_IList __fastcall GetValues(void);
	virtual System::Variant __fastcall GetKey(const System::Variant &Value);
	virtual System::Variant __fastcall Get(const System::Variant &Key);
	virtual void __fastcall Put(const System::Variant &Key, const System::Variant &Value);
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
	virtual bool __fastcall ContainsKey(const System::Variant &Key);
	virtual bool __fastcall ContainsValue(const System::Variant &Value);
	virtual System::Variant __fastcall Delete(const System::Variant &Key);
	virtual void __fastcall PutAll(const _di_IList AList)/* overload */;
	virtual void __fastcall PutAll(const _di_IMap AMap)/* overload */;
	virtual void __fastcall PutAll(const System::Variant &Container)/* overload */;
	virtual _di_IList __fastcall ToList(TListClass ListClass, bool Sync = true, bool ReadWriteSync = false);
	virtual TArrayList* __fastcall ToArrayList(bool Sync = true, bool ReadWriteSync = false);
	__property System::Variant Key[System::Variant Value] = {read=GetKey};
	__property System::Variant Value[System::Variant Key] = {read=Get, write=Put/*, default*/};
	__property int Count = {read=GetCount, nodefault};
	__property _di_IList Keys = {read=GetKeys};
	__property _di_IList Values = {read=GetValues};
public:
	/* TAbstractMap.Destroy */ inline __fastcall virtual ~THashMap(void) { }
	
};


class DELPHICLASS THashedMap;
class PASCALIMPLEMENTATION THashedMap : public THashMap
{
	typedef THashMap inherited;
	
public:
	__fastcall virtual THashedMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
public:
	/* THashMap.Create0 */ inline __fastcall virtual THashedMap(void) : THashMap() { }
	/* THashMap.Create1 */ inline __fastcall virtual THashedMap(int Capacity) : THashMap(Capacity) { }
	/* THashMap.Create2 */ inline __fastcall virtual THashedMap(int Capacity, float Factor) : THashMap(Capacity, Factor) { }
	/* THashMap.Create3 */ inline __fastcall virtual THashedMap(int Capacity, float Factor, bool Sync) : THashMap(Capacity, Factor, Sync) { }
	/* THashMap.CreateS */ inline __fastcall virtual THashedMap(bool Sync) : THashMap(Sync) { }
	
public:
	/* TAbstractMap.Destroy */ inline __fastcall virtual ~THashedMap(void) { }
	
};


class DELPHICLASS TCaseInsensitiveHashMap;
class PASCALIMPLEMENTATION TCaseInsensitiveHashMap : public THashMap
{
	typedef THashMap inherited;
	
public:
	__fastcall virtual TCaseInsensitiveHashMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
public:
	/* THashMap.Create0 */ inline __fastcall virtual TCaseInsensitiveHashMap(void) : THashMap() { }
	/* THashMap.Create1 */ inline __fastcall virtual TCaseInsensitiveHashMap(int Capacity) : THashMap(Capacity) { }
	/* THashMap.Create2 */ inline __fastcall virtual TCaseInsensitiveHashMap(int Capacity, float Factor) : THashMap(Capacity, Factor) { }
	/* THashMap.Create3 */ inline __fastcall virtual TCaseInsensitiveHashMap(int Capacity, float Factor, bool Sync) : THashMap(Capacity, Factor, Sync) { }
	/* THashMap.CreateS */ inline __fastcall virtual TCaseInsensitiveHashMap(bool Sync) : THashMap(Sync) { }
	
public:
	/* TAbstractMap.Destroy */ inline __fastcall virtual ~TCaseInsensitiveHashMap(void) { }
	
};


class DELPHICLASS TCaseInsensitiveHashedMap;
class PASCALIMPLEMENTATION TCaseInsensitiveHashedMap : public THashMap
{
	typedef THashMap inherited;
	
public:
	__fastcall virtual TCaseInsensitiveHashedMap(int Capacity, float Factor, bool Sync, bool ReadWriteSync)/* overload */;
public:
	/* THashMap.Create0 */ inline __fastcall virtual TCaseInsensitiveHashedMap(void) : THashMap() { }
	/* THashMap.Create1 */ inline __fastcall virtual TCaseInsensitiveHashedMap(int Capacity) : THashMap(Capacity) { }
	/* THashMap.Create2 */ inline __fastcall virtual TCaseInsensitiveHashedMap(int Capacity, float Factor) : THashMap(Capacity, Factor) { }
	/* THashMap.Create3 */ inline __fastcall virtual TCaseInsensitiveHashedMap(int Capacity, float Factor, bool Sync) : THashMap(Capacity, Factor, Sync) { }
	/* THashMap.CreateS */ inline __fastcall virtual TCaseInsensitiveHashedMap(bool Sync) : THashMap(Sync) { }
	
public:
	/* TAbstractMap.Destroy */ inline __fastcall virtual ~TCaseInsensitiveHashedMap(void) { }
	
};


class DELPHICLASS TStringBuffer;
class PASCALIMPLEMENTATION TStringBuffer : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::RawByteString FDataString;
	int FPosition;
	int FCapacity;
	int FLength;
	void __fastcall Grow(void);
	void __fastcall SetPosition(int NewPosition);
	void __fastcall SetCapacity(int NewCapacity);
	
public:
	__fastcall TStringBuffer(int Capacity)/* overload */;
	__fastcall TStringBuffer(const System::UnicodeString AString)/* overload */;
	int __fastcall Read(void *Buffer, int Count);
	System::UnicodeString __fastcall ReadString(int Count);
	int __fastcall Write(const void *Buffer, int Count);
	void __fastcall WriteString(const System::UnicodeString AString);
	int __fastcall Insert(const void *Buffer, int Count);
	void __fastcall InsertString(const System::UnicodeString AString);
	int __fastcall Seek(int Offset, System::Word Origin);
	virtual System::UnicodeString __fastcall ToString(void);
	__property int Position = {read=FPosition, write=SetPosition, nodefault};
	__property int Length = {read=FLength, nodefault};
	__property int Capacity = {read=FCapacity, write=SetCapacity, nodefault};
	__property System::RawByteString DataString = {read=FDataString};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TStringBuffer(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::Word varObject;
extern PACKAGE System::TObject* __fastcall VarToObj(const System::Variant &Value)/* overload */;
extern PACKAGE System::TObject* __fastcall VarToObj(const System::Variant &Value, System::TClass AClass)/* overload */;
extern PACKAGE bool __fastcall VarToObj(const System::Variant &Value, System::TClass AClass, /* out */ void *AObject)/* overload */;
extern PACKAGE System::Variant __fastcall ObjToVar(const System::TObject* Value);
extern PACKAGE bool __fastcall VarEquals(const System::Variant &Left, const System::Variant &Right);
extern PACKAGE System::Variant __fastcall VarRef(const System::Variant &Value);
extern PACKAGE System::Variant __fastcall VarUnref(const System::Variant &Value);
extern PACKAGE bool __fastcall VarIsObj(const System::Variant &Value)/* overload */;
extern PACKAGE bool __fastcall VarIsObj(const System::Variant &Value, System::TClass AClass)/* overload */;
extern PACKAGE bool __fastcall VarIsList(const System::Variant &Value);
extern PACKAGE _di_IList __fastcall VarToList(const System::Variant &Value);
extern PACKAGE bool __fastcall VarIsMap(const System::Variant &Value);
extern PACKAGE _di_IMap __fastcall VarToMap(const System::Variant &Value);
extern PACKAGE System::TVarRec __fastcall CopyVarRec(const System::TVarRec &Item);
extern PACKAGE TConstArray __fastcall CreateConstArray(System::TVarRec const *Elements, const int Elements_Size);
extern PACKAGE void __fastcall FinalizeVarRec(System::TVarRec &Item);
extern PACKAGE void __fastcall FinalizeConstArray(TConstArray &Arr);
extern PACKAGE void __fastcall RegisterClass(const System::TClass AClass, const System::UnicodeString Alias);
extern PACKAGE System::TClass __fastcall GetClassByAlias(const System::UnicodeString Alias);
extern PACKAGE System::UnicodeString __fastcall GetClassAlias(const System::TClass AClass);
extern PACKAGE _di_IList __fastcall ListSplit(TListClass ListClass, System::UnicodeString Str, const System::UnicodeString Separator = L",", int Limit = 0x0, bool TrimItem = false, bool SkipEmptyItem = false);
extern PACKAGE _di_IMap __fastcall MapSplit(TMapClass MapClass, System::UnicodeString Str, const System::UnicodeString ItemSeparator = L";", const System::UnicodeString KeyValueSeparator = L"=", int Limit = 0x0, bool TrimKey = false, bool TrimValue = false, bool SkipEmptyKey = false, bool SkipEmptyValue = false);

}	/* namespace Hprosecommon */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE)
using namespace Hprosecommon;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HprosecommonHPP
