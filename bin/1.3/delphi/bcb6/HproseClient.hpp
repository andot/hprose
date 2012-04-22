// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HproseClient.pas' rev: 6.00

#ifndef HproseClientHPP
#define HproseClientHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <SysUtils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <HproseCommon.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hproseclient
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *THproseCallback1)(const Variant &Result);

typedef void __fastcall (__closure *THproseCallback2)(const Variant &Result, const Hprosecommon::TVariants Args);

typedef void __fastcall (__closure *THproseErrorEvent)(const AnsiString Name, const Sysutils::Exception* Error);

class DELPHICLASS THproseClient;
class PASCALIMPLEMENTATION THproseClient : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	THproseErrorEvent FErrorEvent;
	
protected:
	AnsiString FUri;
	virtual System::TObject* __fastcall GetInvokeContext(void) = 0 ;
	virtual Classes::TStream* __fastcall GetOutputStream(System::TObject* &Context) = 0 ;
	virtual void __fastcall SendData(System::TObject* &Context) = 0 ;
	virtual Classes::TStream* __fastcall GetInputStream(System::TObject* &Context) = 0 ;
	virtual void __fastcall EndInvoke(System::TObject* &Context) = 0 ;
	Variant __fastcall DoInput(Hprosecommon::TVariants &Args, Word ReturnType, TMetaClass* ReturnClass, Hprosecommon::THproseResultMode ResultMode, Classes::TStream* InStream)/* overload */;
	Variant __fastcall DoInput(Word ReturnType, TMetaClass* ReturnClass, Hprosecommon::THproseResultMode ResultMode, Classes::TStream* InStream)/* overload */;
	void __fastcall DoOutput(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, Classes::TStream* OutStream)/* overload */;
	void __fastcall DoOutput(const AnsiString Name, const Hprosecommon::TVariants Args, bool ByRef, Classes::TStream* OutStream)/* overload */;
	
public:
	virtual void __fastcall UseService(const AnsiString AUri);
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, Word ReturnType, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, TMetaClass* ReturnClass, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, Word ReturnType = (Word)(0xc), TMetaClass* ReturnClass = 0x0, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, Word ReturnType, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, TMetaClass* ReturnClass, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual Variant __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, Word ReturnType = (Word)(0xc), TMetaClass* ReturnClass = 0x0, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, THproseCallback1 Callback, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, THproseCallback1 Callback, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, THproseCallback1 Callback, Word ReturnType, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, Word ReturnType, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, THproseCallback1 Callback, TMetaClass* ReturnClass, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, TMetaClass* ReturnClass, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, THproseCallback1 Callback, Word ReturnType = (Word)(0xc), TMetaClass* ReturnClass = 0x0, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, const System::TVarRec * Args, const int Args_Size, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, Word ReturnType = (Word)(0xc), TMetaClass* ReturnClass = 0x0, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, THproseErrorEvent ErrorEvent, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, Word ReturnType, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, THproseErrorEvent ErrorEvent, Word ReturnType, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, TMetaClass* ReturnClass, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, THproseErrorEvent ErrorEvent, TMetaClass* ReturnClass, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, Word ReturnType = (Word)(0xc), TMetaClass* ReturnClass = 0x0, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const AnsiString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, THproseErrorEvent ErrorEvent, Word ReturnType = (Word)(0xc), TMetaClass* ReturnClass = 0x0, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	
__published:
	__property AnsiString Uri = {read=FUri, write=UseService};
	__property THproseErrorEvent OnError = {read=FErrorEvent, write=FErrorEvent};
public:
	#pragma option push -w-inl
	/* TComponent.Create */ inline __fastcall virtual THproseClient(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	#pragma option pop
	#pragma option push -w-inl
	/* TComponent.Destroy */ inline __fastcall virtual ~THproseClient(void) { }
	#pragma option pop
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Hproseclient */
using namespace Hproseclient;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HproseClient
