{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit HproseSyna;

interface

uses
  blcksock, httpsend, synaip, synafpc, synautil, synsock, HproseClient,
  HproseCommon, HproseIO, HproseSynaHttpClient, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('HproseSynaHttpClient', @HproseSynaHttpClient.Register);
end;

initialization
  RegisterPackage('HproseSyna', @Register);
end.
