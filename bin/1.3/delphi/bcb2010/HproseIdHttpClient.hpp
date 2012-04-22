// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Hproseidhttpclient.pas' rev: 21.00

#ifndef HproseidhttpclientHPP
#define HproseidhttpclientHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Hprosecommon.hpp>	// Pascal unit
#include <Hproseclient.hpp>	// Pascal unit

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
	Classes::TStringList* FHeaders;
	System::UnicodeString FProxyHost;
	int FProxyPort;
	System::UnicodeString FProxyUser;
	System::UnicodeString FProxyPass;
	System::UnicodeString FUserAgent;
	int FTimeout;
	
protected:
	virtual System::TObject* __fastcall GetInvokeContext(void);
	virtual Classes::TStream* __fastcall GetOutputStream(System::TObject* &Context);
	virtual void __fastcall SendData(System::TObject* &Context);
	virtual Classes::TStream* __fastcall GetInputStream(System::TObject* &Context);
	virtual void __fastcall EndInvoke(System::TObject* &Context);
	
public:
	__fastcall virtual THproseIdHttpClient(Classes::TComponent* AOwner);
	__fastcall virtual ~THproseIdHttpClient(void);
	
__published:
	__property Classes::TStringList* Headers = {read=FHeaders};
	__property System::UnicodeString ProxyHost = {read=FProxyHost, write=FProxyHost};
	__property int ProxyPort = {read=FProxyPort, write=FProxyPort, nodefault};
	__property System::UnicodeString ProxyUser = {read=FProxyUser, write=FProxyUser};
	__property System::UnicodeString ProxyPass = {read=FProxyPass, write=FProxyPass};
	__property System::UnicodeString UserAgent = {read=FUserAgent, write=FUserAgent};
	__property int Timeout = {read=FTimeout, write=FTimeout, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall Register(void);

}	/* namespace Hproseidhttpclient */
using namespace Hproseidhttpclient;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HproseidhttpclientHPP
