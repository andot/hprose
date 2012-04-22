// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HproseIO.pas' rev: 6.00

#ifndef HproseIOHPP
#define HproseIOHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <HproseCommon.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

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
	Variant __fastcall Unserialize(char Tag, Word VType, TMetaClass* AClass)/* overload */;
	Byte __fastcall ReadByte(void);
	__int64 __fastcall ReadInt64(char Tag);
	Variant __fastcall ReadShortIntArray(int Count);
	Variant __fastcall ReadSmallIntArray(int Count);
	Variant __fastcall ReadWordArray(int Count);
	Variant __fastcall ReadIntegerArray(int Count);
	Variant __fastcall ReadCurrencyArray(int Count);
	Variant __fastcall ReadLongWordArray(int Count);
	Variant __fastcall ReadInt64Array(int Count);
	Variant __fastcall ReadSingleArray(int Count);
	Variant __fastcall ReadDoubleArray(int Count);
	Variant __fastcall ReadBooleanArray(int Count);
	Variant __fastcall ReadWideStringArray(int Count);
	Variant __fastcall ReadDateTimeArray(int Count);
	Variant __fastcall ReadList(TMetaClass* AClass, int Count)/* overload */;
	Variant __fastcall ReadRef();
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
	Variant __fastcall Unserialize(Word VType = (Word)(0xc), TMetaClass* AClass = 0x0)/* overload */;
	void __fastcall CheckTag(char expectTag);
	char __fastcall CheckTags(const AnsiString expectTags);
	AnsiString __fastcall ReadUntil(char Tag);
	int __fastcall ReadInt(char Tag);
	int __fastcall ReadInteger(bool IncludeTag = true);
	Variant __fastcall ReadLong(bool IncludeTag = true);
	Extended __fastcall ReadDouble(bool IncludeTag = true);
	System::Currency __fastcall ReadCurrency(bool IncludeTag = true);
	Variant __fastcall ReadNull();
	Variant __fastcall ReadEmpty();
	bool __fastcall ReadBoolean(void);
	Extended __fastcall ReadNaN(void);
	Extended __fastcall ReadInfinity(bool IncludeTag = true);
	System::TDateTime __fastcall ReadDate(bool IncludeTag = true);
	System::TDateTime __fastcall ReadTime(bool IncludeTag = true);
	Variant __fastcall ReadBytes(bool IncludeTag = true);
	wchar_t __fastcall ReadUTF8Char(bool IncludeTag = true);
	WideString __fastcall ReadString(bool IncludeTag = true, bool IncludeRef = true);
	AnsiString __fastcall ReadGuid(bool IncludeTag = true);
	Variant __fastcall ReadList(Word ElementType, TMetaClass* AClass = 0x0, bool IncludeTag = true)/* overload */;
	Variant __fastcall ReadMap(TMetaClass* AClass = 0x0, bool IncludeTag = true);
	Variant __fastcall ReadObject(TMetaClass* AClass = 0x0, bool IncludeTag = true);
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
	bool __fastcall WriteRef(const Variant &Value, bool CheckRef)/* overload */;
	void __fastcall WriteRef(int Value)/* overload */;
	int __fastcall WriteClass(System::TObject* Instance);
	void __fastcall WriteRawByteString(const AnsiString S);
	void __fastcall WriteShortIntArray(void *P, int Count);
	void __fastcall WriteSmallIntArray(void *P, int Count);
	void __fastcall WriteWordArray(void *P, int Count);
	void __fastcall WriteIntegerArray(void *P, int Count);
	void __fastcall WriteCurrencyArray(void *P, int Count);
	void __fastcall WriteLongWordArray(void *P, int Count);
	void __fastcall WriteInt64Array(void *P, int Count);
	void __fastcall WriteSingleArray(void *P, int Count);
	void __fastcall WriteDoubleArray(void *P, int Count);
	void __fastcall WriteBooleanArray(void *P, int Count);
	void __fastcall WriteWideStringArray(void *P, int Count);
	void __fastcall WriteDateTimeArray(void *P, int Count);
	void __fastcall WriteVariantArray(void *P, int Count);
	
public:
	__fastcall THproseWriter(Classes::TStream* AStream);
	void __fastcall Serialize(const Variant &Value)/* overload */;
	void __fastcall Serialize(const System::TVarRec * Value, const int Value_Size)/* overload */;
	void __fastcall WriteInteger(int I);
	void __fastcall WriteLong(__int64 L)/* overload */;
	void __fastcall WriteLong(const AnsiString L)/* overload */;
	void __fastcall WriteDouble(Extended D);
	void __fastcall WriteCurrency(System::Currency C);
	void __fastcall WriteNull(void);
	void __fastcall WriteEmpty(void);
	void __fastcall WriteBoolean(bool B);
	void __fastcall WriteNaN(void);
	void __fastcall WriteInfinity(bool Positive);
	void __fastcall WriteUTF8Char(wchar_t C);
	void __fastcall WriteDateTime(const System::TDateTime ADateTime, bool CheckRef = true);
	void __fastcall WriteBytes(const Variant &Bytes, bool CheckRef = true);
	void __fastcall WriteString(const WideString S, bool CheckRef = true);
	void __fastcall WriteArray(const Variant &Value, bool CheckRef = true)/* overload */;
	void __fastcall WriteArray(const System::TVarRec * Value, const int Value_Size)/* overload */;
	void __fastcall WriteList(Hprosecommon::_di_IList AList, bool CheckRef = true);
	void __fastcall WriteMap(Hprosecommon::_di_IMap AMap, bool CheckRef = true);
	void __fastcall WriteObject(System::TObject* AObject, bool CheckRef = true);
	void __fastcall Reset(void);
	__property Classes::TStream* Stream = {read=FStream};
public:
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~THproseWriter(void) { }
	#pragma option pop
	
};


class DELPHICLASS THproseFormatter;
class PASCALIMPLEMENTATION THproseFormatter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static AnsiString __fastcall Serialize(TMetaClass* vmt, System::TObject* Value)/* overload */;
	/*         class method */ static AnsiString __fastcall Serialize(TMetaClass* vmt, const Variant &Value)/* overload */;
	/*         class method */ static AnsiString __fastcall Serialize(TMetaClass* vmt, const System::TVarRec * Value, const int Value_Size)/* overload */;
	/*         class method */ static Variant __fastcall Unserialize(TMetaClass* vmt, const AnsiString Data, Word VType = (Word)(0xc), TMetaClass* AClass = 0x0);
public:
	#pragma option push -w-inl
	/* TObject.Create */ inline __fastcall THproseFormatter(void) : System::TObject() { }
	#pragma option pop
	#pragma option push -w-inl
	/* TObject.Destroy */ inline __fastcall virtual ~THproseFormatter(void) { }
	#pragma option pop
	
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
extern PACKAGE AnsiString __fastcall HproseSerialize(System::TObject* Value)/* overload */;
extern PACKAGE AnsiString __fastcall HproseSerialize(const Variant &Value)/* overload */;
extern PACKAGE AnsiString __fastcall HproseSerialize(const System::TVarRec * Value, const int Value_Size)/* overload */;
extern PACKAGE Variant __fastcall HproseUnserialize(const AnsiString Data, Word VType = (Word)(0xc), TMetaClass* AClass = 0x0);

}	/* namespace Hproseio */
using namespace Hproseio;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HproseIO
