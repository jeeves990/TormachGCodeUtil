unit dataModule;

{$mode ObjFPC}{$H+}

interface

uses
      Classes, SysUtils, Dialogs, IniFiles, graphics, StdCtrls;

const
  COLON = ':';
  TAB = #9;
  SPACE = #32;
  INI_FILE_NAME =  'TormachCodes.ini';
  FILE_NAME_SECTION = 'File Name';
  RAW_FILE_NAME_FROMINI = 'Raw file Name';
  GCODE_FILE_NAME = 'GCode File Name';
  OPEN_PAREN = '(';
  CLOSE_PAREN = ')';
  PERCENT_SIGN = '%';
  FIRST_LINE_NUMBER = 'N10';
  GCODES : set of char = ['G', 'M', 'F', 'S', 'T', 'O', 'N'];
  DIGITS : set of char = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  REALPUNCT : set of char = ['.', ',', '+', '-'];
  AXES : set of char = ['X', 'Y', 'Z', 'A'];
  AN_N : set of char = ['N', 'n'];
  //REALDIGITS : set of char = DIGITS + APERIOD;


type

	{ Tdmod }

  Tdmod = class(TDataModule)
		opn_dlg : TOpenDialog;
		procedure DataModuleCreate(Sender : TObject);
		procedure DataModuleDestroy(Sender : TObject);
  private

  public

  end;

var
  iniFile : TIniFile;
  codeList : TStringList;
  dmod : Tdmod;
  REALCHARS : set of char;


function GetTextWidthEx(AText: string; AFont: TFont): integer;
function Get_a_number_from_text(aStr : String) : String;

implementation

{$R *.lfm}

{ Tdmod }

procedure Tdmod.DataModuleCreate(Sender : TObject);
begin
  iniFile := TIniFile.Create(INI_FILE_NAME);
  codeList := TStringList.Create;
  codeList.Sorted := True;
end;

procedure Tdmod.DataModuleDestroy(Sender : TObject);
begin
  iniFile.Free;
end;

function GetTextWidthEx(AText: string; AFont: TFont): integer;
var
  lbl: TLabel;
begin
  Result := 0;
  lbl := Tlabel.Create(nil);
  try
    lbl.Font := AFont;
    lbl.AutoSize := True;
    lbl.Caption := AText;
    Result := lbl.Width;
  finally
    lbl.Free;
  end;
end;

function Get_a_number_from_text(aStr : String) : String;
var
  ndx : Integer;
  workStr : String;
begin
  workStr := aStr;
  ndx := 1;

  // was I passed the whole string?
  if workStr[1] in GCODES then
    begin
  		// if so, remove that first character,
      // i.e., should only return a real number representation
      workStr := Copy(workStr, 1, 999);
		end;

  while workStr[ndx] in REALCHARS do
    begin
      Inc(ndx);
      if ndx > Length(workStr) then
        begin
          //ShowMessage('Get_a_number_from_text string length is wonky');
          Break;
				end;
		end;
  if ndx > 1 then
    Result := Copy(workStr, 1, ndx -1);
end;

begin
  REALCHARS := DIGITS +REALPUNCT;
end.

