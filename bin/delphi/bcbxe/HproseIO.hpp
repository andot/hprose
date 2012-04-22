// CodeGear C++Builder
// Copyright (c) 1995, 2010 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HproseIO.pas' rev: 22.00

#ifndef HproseioHPP
#define HproseioHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <HproseCommon.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hproseio
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS THproseReader;
class PASCALIMPLEMENTATION THproseReader : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TStream* FStream;
	Hprosecommon::_di_IList FRefList;
	Hprosecommon::_di_IList FClassRefList;
	Hprosecommon::_di_IMap FAttrRefMap;
	System::Variant __fastcall Unserialize(char Tag, System::Word VType, System::TClass AClass)/* overload */;
	System::Byte __fastcall ReadByte(void);
	__int64 __fastcall ReadInt64(char Tag);
	unsigned __int64 __fastcall ReadUInt64(char Tag);
	System::Variant __fastcall ReadShortIntArray(int Count);
	System::Variant __fastcall ReadSmallIntArray(int Count);
	System::Variant __fastcall ReadWordArray(int Count);
	System::Variant __fastcall ReadIntegerArray(int Count);
	System::Variant __fastcall ReadCurrencyArray(int Count);
	System::Variant __fastcall ReadLongWordArray(int Count);
	System::Variant __fastcall ReadInt64Array(int Count);
	System::Variant __fastcall ReadUInt64Array(int Count);
	System::Variant __fastcall ReadSingleArray(int Count);
	System::Variant __fastcall ReadDoubleArray(int Count);
	System::Variant __fastcall ReadBooleanArray(int Count);
	System::Variant __fastcall ReadWideStringArray(int Count);
	System::Variant __fastcall ReadDateTimeArray(int Count);
	System::Variant __fastcall ReadList(System::TClass AClass, int Count)/* overload */;
	System::Variant __fastcall ReadRef(void);
	void __fastcall ReadClass(void);
	void __fastcall ReadRaw(const Classes::TStream* OStream, char Tag)/* overload */;
	void __fastcall ReadInfinityRaw(const Classes::TStream* OStream, char Tag);
	void __fastcall ReadNumberRaw(const Classes::TStream* OStream, char Tag);
	void __fastcall ReadDateTimeRaw(const Classes::TStream* OStream, char Tag);
	void __fastcall ReadUTF8CharRaw(const Classes::TStream* OStream, char Tag);
	void __fastcall ReadBytesRaw(const Classes::TStream* OStream, char Tag);
	void __fastcall ReadStringRaw(const Classes::TStream* OStream, char Tag);
	void __fastcall ReadGuidRaw(const Classes::TStream* OStream, char Tag);
	void __fastcall ReadComplexRaw(const Classes::TStream* OStream, char Tag);
	
public:
	__fastcall THproseReader(Classes::TStream* AStream);
	__fastcall virtual ~THproseReader(void);
	System::Variant __fastcall Unserialize(System::Word VType = (System::Word)(0xc), System::TClass AClass = 0x0)/* overload */;
	void __fastcall CheckTag(char expectTag);
	char __fastcall CheckTags(const System::RawByteString expectTags);
	System::UnicodeString __fastcall ReadUntil(char Tag);
	int __fastcall ReadInt(char Tag);
	int __fastcall ReadInteger(bool IncludeTag = true);
	System::Variant __fastcall ReadLong(bool IncludeTag = true);
	System::Extended __fastcall ReadDouble(bool IncludeTag = true);
	System::Currency __fastcall ReadCurrency(bool IncludeTag = true);
	System::Variant __fastcall ReadNull(void);
	System::Variant __fastcall ReadEmpty(void);
	bool __fastcall ReadBoolean(void);
	System::Extended __fastcall ReadNaN(void);
	System::Extended __fastcall ReadInfinity(bool IncludeTag = true);
	System::TDateTime __fastcall ReadDate(bool IncludeTag = true);
	System::TDateTime __fastcall ReadTime(bool IncludeTag = true);
	System::Variant __fastcall ReadBytes(bool IncludeTag = true);
	System::WideChar __fastcall ReadUTF8Char(bool IncludeTag = true);
	System::WideString __fastcall ReadString(bool IncludeTag = true, bool IncludeRef = true);
	System::AnsiString __fastcall ReadGuid(bool IncludeTag = true);
	System::Variant __fastcall ReadList(System::Word ElementType, System::TClass AClass = 0x0, bool IncludeTag = true)/* overload */;
	System::Variant __fastcall ReadMap(System::TClass AClass = 0x0, bool IncludeTag = true);
	System::Variant __fastcall ReadObject(System::TClass AClass = 0x0, bool IncludeTag = true);
	void __fastcall Reset(void);
	Classes::TMemoryStream* __fastcall ReadRaw(void)/* overload */;
	void __fastcall ReadRaw(const Classes::TStream* OStream)/* overload */;
	__property Classes::TStream* Stream = {read=FStream};
};


class DELPHICLASS THproseWriter;
class PASCALIMPLEMENTATION THproseWriter : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TStream* FStream;
	Hprosecommon::_di_IList FRefList;
	Hprosecommon::_di_IList FClassRefList;
	bool __fastcall WriteRef(const System::Variant &Value, bool CheckRef)/* overload */;
	void __fastcall WriteRef(int Value)/* overload */;
	int __fastcall WriteClass(System::TObject* Instance);
	void __fastcall WriteRawByteString(const System::RawByteString S);
	void __fastcall WriteShortIntArray(void *P, int Count);
	void __fastcall WriteSmallIntArray(void *P, int Count);
	void __fastcall WriteWordArray(void *P, int Count);
	void __fastcall WriteIntegerArray(void *P, int Count);
	void __fastcall WriteCurrencyArray(void *P, int Count);
	void __fastcall WriteLongWordArray(void *P, int Count);
	void __fastcall WriteInt64Array(void *P, int Count);
	void __fastcall WriteUInt64Array(void *P, int Count);
	void __fastcall WriteSingleArray(void *P, int Count);
	void __fastcall WriteDoubleArray(void *P, int Count);
	void __fastcall WriteBooleanArray(void *P, int Count);
	void __fastcall WriteWideStringArray(void *P, int Count);
	void __fastcall WriteDateTimeArray(void *P, int Count);
	void __fastcall WriteVariantArray(void *P, int Count);
	
public:
	__fastcall THproseWriter(Classes::TStream* AStream);
	void __fastcall Serialize(const System::Variant &Value)/* overload */;
	void __fastcall Serialize(System::TVarRec const *Value, const int Value_Size)/* overload */;
	void __fastcall WriteInteger(int I);
	void __fastcall WriteLong(__int64 L)/* overload */;
	void __fastcall WriteLong(unsigned __int64 L)/* overload */;
	void __fastcall WriteLong(const System::RawByteString L)/* overload */;
	void __fastcall WriteDouble(System::Extended D);
	void __fastcall WriteCurrency(System::Currency C);
	void __fastcall WriteNull(void);
	void __fastcall WriteEmpty(void);
	void __fastcall WriteBoolean(bool B);
	void __fastcall WriteNaN(void);
	void __fastcall WriteInfinity(bool Positive);
	void __fastcall WriteUTF8Char(System::WideChar C);
	void __fastcall WriteDateTime(const System::TDateTime ADateTime, bool CheckRef = true);
	void __fastcall WriteBytes(const System::Variant &Bytes, bool CheckRef = true);
	void __fastcall WriteString(const System::WideString S, bool CheckRef = true);
	void __fastcall WriteArray(const System::Variant &Value, bool CheckRef = true)/* overload */;
	void __fastcall WriteArray(System::TVarRec const *Value, const int Value_Size)/* overload */;
	void __fastcall WriteList(Hprosecommon::_di_IList AList, bool CheckRef = true);
	void __fastcall WriteMap(Hprosecommon::_di_IMap AMap, bool CheckRef = true);
	void __fastcall WriteObject(System::TObject* AObject, bool CheckRef = true);
	void __fastcall Reset(void);
	__property Classes::TStream* Stream = {read=FStream};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~THproseWriter(void) { }
	
};


class DELPHICLASS THproseFormatter;
class PASCALIMPLEMENTATION THproseFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod System::RawByteString __fastcall Serialize(System::TObject* Value)/* overload */;
	__classmethod System::RawByteString __fastcall Serialize(const System::Variant &Value)/* overload */;
	__classmethod System::RawByteString __fastcall Serialize(System::TVarRec const *Value, const int Value_Size)/* overload */;
	__classmethod System::Variant __fastcall Unserialize(const System::RawByteString Data, System::Word VType = (System::Word)(0xc), System::TClass AClass = 0x0);
public:
	/* TObject.Create */ inline __fastcall THproseFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~THproseFormatter(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE char HproseTagInteger;
extern PACKAGE char HproseTagLong;
extern PACKAGE char HproseTagDouble;
extern PACKAGE char HproseTagNull;
extern PACKAGE char HproseTagEmpty;
extern PACKAGE char HproseTagTrue;
extern PACKAGE char HproseTagFalse;
extern PACKAGE char HproseTagNaN;
extern PACKAGE char HproseTagInfinity;
extern PACKAGE char HproseTagDate;
extern PACKAGE char HproseTagTime;
extern PACKAGE char HproseTagUTC;
extern PACKAGE char HproseTagBytes;
extern PACKAGE char HproseTagUTF8Char;
extern PACKAGE char HproseTagString;
extern PACKAGE char HproseTagGuid;
extern PACKAGE char HproseTagList;
extern PACKAGE char HproseTagMap;
extern PACKAGE char HproseTagClass;
extern PACKAGE char HproseTagObject;
extern PACKAGE char HproseTagRef;
extern PACKAGE char HproseTagPos;
extern PACKAGE char HproseTagNeg;
extern PACKAGE char HproseTagSemicolon;
extern PACKAGE char HproseTagOpenbrace;
extern PACKAGE char HproseTagClosebrace;
extern PACKAGE char HproseTagQuote;
extern PACKAGE char HproseTagPoint;
extern PACKAGE char HproseTagFunctions;
extern PACKAGE char HproseTagCall;
extern PACKAGE char HproseTagResult;
extern PACKAGE char HproseTagArgument;
extern PACKAGE char HproseTagError;
extern PACKAGE char HproseTagEnd;
extern PACKAGE System::RawByteString __fastcall HproseSerialize(System::TObject* Value)/* overload */;
extern PACKAGE System::RawByteString __fastcall HproseSerialize(const System::Variant &Value)/* overload */;
extern PACKAGE System::RawByteString __fastcall HproseSerialize(System::TVarRec const *Value, const int Value_Size)/* overload */;
extern PACKAGE System::Variant __fastcall HproseUnserialize(const System::RawByteString Data, System::Word VType = (System::Word)(0xc), System::TClass AClass = 0x0);

}	/* namespace Hproseio */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE)
using namespace Hproseio;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HproseioHPP
