// Borland C++ Builder
// Copyright (c) 1995, 2002 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HproseIdHttpClient.pas' rev: 6.00

#ifndef HproseIdHttpClientHPP
#define HproseIdHttpClientHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <IdURI.hpp>	// Pascal unit
#include <HproseClient.hpp>	// Pascal unit
#include <HproseCommon.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hproseidhttpclient
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS THproseIdHttpClient;
class PASCALIMPLEMENTATION THproseIdHttpClient : public Hproseclient::THproseClient 
{
	typedef Hproseclient::THproseClient inherited;
	
private:
	Hprosecommon::_di_IList FHttpPool;
	Iduri::TIdURI* FIdUri;
	Classes::TStringList* FHeaders;
	AnsiString FProxyHost;
	int FProxyPort;
	AnsiString FProxyUser;
	AnsiString FProxyPass;
	AnsiString FUserAgent;
	
protected:
	virtual System::TObject* __fastcall GetInvokeContext(void);
	virtual Classes::TStream* __fastcall GetOutputStream(System::TObject* &Context);
	virtual void __fastcall SendData(System::TObject* &Context);
	virtual Classes::TStream* __fastcall GetInputStream(System::TObject* &Context);
	virtual void __fastcall EndInvoke(System::TObject* &Context);
	
public:
	__fastcall virtual THproseIdHttpClient(Classes::TComponent* AOwner);
	__fastcall virtual ~THproseIdHttpClient(void);
	virtual void __fastcall UseService(const AnsiString AUri);
	
__published:
	__property Classes::TStringList* Headers = {read=FHeaders};
	__property AnsiString ProxyHost = {read=FProxyHost, write=FProxyHost};
	__property int ProxyPort = {read=FProxyPort, write=FProxyPort, nodefault};
	__property AnsiString ProxyUser = {read=FProxyUser, write=FProxyUser};
	__property AnsiString ProxyPass = {read=FProxyPass, write=FProxyPass};
	__property AnsiString UserAgent = {read=FUserAgent, write=FUserAgent};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall Register(void);

}	/* namespace Hproseidhttpclient */
using namespace Hproseidhttpclient;
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HproseIdHttpClient
