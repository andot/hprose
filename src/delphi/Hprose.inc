// Delphi version

{$ifdef VER140}
  {$define DELPHI6}
  {$define DELPHI6_UP}
{$endif}

{$ifdef VER150}
  {$define DELPHI7}
  {$define DELPHI7_UP}
{$endif}

{$ifdef VER160}
  {$define DELPHI8}
  {$define DELPHI8_UP}
{$endif}

{$ifdef VER170}
  {$define DELPHI2005}
  {$define DELPHI2005_UP}
{$endif}

{$ifdef VER180}
  {$define DELPHI2006}
  {$define DELPHI2006_UP}
{$endif}

{$ifdef VER185}
  {$define DELPHI2007}
  {$define DELPHI2007_UP}
{$endif}

{$ifdef VER200}
  {$define DELPHI2009}
  {$define DELPHI2009_UP}
{$endif}

{$ifdef VER210}
  {$define DELPHI2010}
  {$define DELPHI2010_UP}
{$endif}

{$ifdef VER220}
  {$define DELPHI2011}
  {$define DELPHI2011_UP}
{$endif}

{$ifdef VER230}
  {$define DELPHI2012}
  {$define DELPHI2012_UP}
{$endif}

{$ifdef DELPHI2012_UP}
  {$define DELPHI2011_UP}
{$endif}

{$ifdef DELPHI2011_UP}
  {$define DELPHI2010_UP}
{$endif}

{$ifdef DELPHI2010_UP}
  {$define DELPHI2009_UP}
{$endif}

{$ifdef DELPHI2009_UP}
  {$define DELPHI2007_UP}
{$endif}

{$ifdef DELPHI2007_UP}
  {$define DELPHI2006_UP}
{$endif}

{$ifdef DELPHI2006_UP}
  {$define DELPHI2005_UP}
{$endif}

{$ifdef DELPHI2005_UP}
  {$define DELPHI8_UP}
{$endif}

{$ifdef DELPHI8_UP}
  {$define DELPHI7_UP}
{$endif}

{$ifdef DELPHI7_UP}
  {$define DELPHI6_UP}
{$endif}

// Delphi features

{$ifdef DELPHI2005_UP}
  {$define Supports_For_In}
  {$define Supports_Inline}
  {$define Supports_Nested_Constants}
  {$define Supports_Nested_Types}
{$endif}

{$ifdef DELPHI2006_UP}
  {$define Supports_Static}
{$endif}

{$ifdef DELPHI2009_UP}
  {$define Supports_Unicode}
  {$define Supports_Generics}
{$endif}

// Free Pascal

{$ifdef FPC}
  {$mode DELPHI}
{$endif}

{$ifdef CPUX64}
  {$define CPU64}
{$endif}

{$H+}
