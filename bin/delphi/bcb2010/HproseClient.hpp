// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Hproseclient.pas' rev: 21.00

#ifndef HproseclientHPP
#define HproseclientHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Hprosecommon.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hproseclient
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *THproseCallback1)(const System::Variant &Result);

typedef void __fastcall (__closure *THproseCallback2)(const System::Variant &Result, const Hprosecommon::TVariants Args);

typedef void __fastcall (__closure *THproseErrorEvent)(const System::UnicodeString Name, const Sysutils::Exception* Error);

class DELPHICLASS THproseClient;
class PASCALIMPLEMENTATION THproseClient : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	THproseErrorEvent FErrorEvent;
	
protected:
	System::UnicodeString FUri;
	virtual System::TObject* __fastcall GetInvokeContext(void) = 0 ;
	virtual Classes::TStream* __fastcall GetOutputStream(System::TObject* &Context) = 0 ;
	virtual void __fastcall SendData(System::TObject* &Context) = 0 ;
	virtual Classes::TStream* __fastcall GetInputStream(System::TObject* &Context) = 0 ;
	virtual void __fastcall EndInvoke(System::TObject* &Context) = 0 ;
	System::Variant __fastcall DoInput(Hprosecommon::TVariants &Args, System::Word ReturnType, System::TClass ReturnClass, Hprosecommon::THproseResultMode ResultMode, Classes::TStream* InStream)/* overload */;
	System::Variant __fastcall DoInput(System::Word ReturnType, System::TClass ReturnClass, Hprosecommon::THproseResultMode ResultMode, Classes::TStream* InStream)/* overload */;
	void __fastcall DoOutput(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, Classes::TStream* OutStream)/* overload */;
	void __fastcall DoOutput(const System::UnicodeString Name, const Hprosecommon::TVariants Args, bool ByRef, Classes::TStream* OutStream)/* overload */;
	
public:
	virtual void __fastcall UseService(const System::UnicodeString AUri);
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, System::Word ReturnType, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, System::TClass ReturnClass, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, System::Word ReturnType = (System::Word)(0xc), System::TClass ReturnClass = 0x0, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, System::Word ReturnType, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, System::TClass ReturnClass, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual System::Variant __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, System::Word ReturnType = (System::Word)(0xc), System::TClass ReturnClass = 0x0, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, THproseCallback1 Callback, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, THproseCallback1 Callback, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, THproseCallback1 Callback, System::Word ReturnType, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, System::Word ReturnType, Hprosecommon::THproseResultMode ResultMode)/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, THproseCallback1 Callback, System::TClass ReturnClass, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, System::TClass ReturnClass, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, THproseCallback1 Callback, System::Word ReturnType = (System::Word)(0xc), System::TClass ReturnClass = 0x0, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, System::TVarRec const *Args, const int Args_Size, THproseCallback1 Callback, THproseErrorEvent ErrorEvent, System::Word ReturnType = (System::Word)(0xc), System::TClass ReturnClass = 0x0, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, THproseErrorEvent ErrorEvent, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, System::Word ReturnType, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, THproseErrorEvent ErrorEvent, System::Word ReturnType, bool ByRef, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, System::TClass ReturnClass, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, THproseErrorEvent ErrorEvent, System::TClass ReturnClass, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, System::Word ReturnType = (System::Word)(0xc), System::TClass ReturnClass = 0x0, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	HIDESBASE virtual void __fastcall Invoke(const System::UnicodeString Name, Hprosecommon::TVariants &Args, THproseCallback2 Callback, THproseErrorEvent ErrorEvent, System::Word ReturnType = (System::Word)(0xc), System::TClass ReturnClass = 0x0, bool ByRef = true, Hprosecommon::THproseResultMode ResultMode = (Hprosecommon::THproseResultMode)(0x0))/* overload */;
	
__published:
	__property System::UnicodeString Uri = {read=FUri, write=UseService};
	__property THproseErrorEvent OnError = {read=FErrorEvent, write=FErrorEvent};
public:
	/* TComponent.Create */ inline __fastcall virtual THproseClient(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~THproseClient(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Hproseclient */
using namespace Hproseclient;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HproseclientHPP
