unit frmTormachGCode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
	StdCtrls, ComCtrls
  ;

type

  { TfrmTormach }

  TfrmTormach = class(TForm)
		btnBrowse : TButton;
		btnOpen : TButton;
		btnDoParse : TButton;
		btnReadGCodeFile : TButton;
		btnPopStringList : TButton;
		btnDoAnnotate : TButton;
		edFileName : TEdit;
		edColWidth : TEdit;
		lblColWidthCap : TLabel;
		lblFileName : TLabel;
    Notebook1: TNotebook;
		opnDlg : TOpenDialog;
		pnlBottomGCodeRef : TPanel;
		pnlDoParse : TPanel;
		pgCtrl : TPageControl;
		pnlExeParse : TPanel;
		pnlFile : TPanel;
		sGridGCodeRef : TStringGrid;
		sGridRawFile : TStringGrid;
		sGrid2Test : TStringGrid;
		tabRawCodes : TTabSheet;
		tabParsedCodes : TTabSheet;
		tab2Test : TTabSheet;
  	procedure btnBrowseClick(Sender : TObject);
		procedure btnDoAnnotateClick(Sender : TObject);
	  procedure btnDoParseClick(Sender : TObject);
		procedure btnPopStringListClick(Sender : TObject);
  	procedure btnReadGCodeFileClick(Sender : TObject);
	  procedure edFileNameChange(Sender : TObject);
  	procedure FormCreate(Sender : TObject);
  private
    rawCodesFileName : string;
		procedure handleExtraValue(aRow : integer; aCode, aValue: string);
    function readRawFile(fn : String): Boolean;
    procedure populateTestGrid;
  public

  end;

var
  frmTormach: TfrmTormach;
  iniPath : string;

implementation

uses
  dataModule, formAnnotateGCode;

{$R *.lfm}

{ TfrmTormach }

procedure TfrmTormach.FormCreate(Sender : TObject);
begin
  pgCtrl.ActivePage := tabRawCodes;
  pnlDoParse.Visible := False;
  tabParsedCodes.Visible := False;
  sGridRawFile.ExtendedColSizing := True;
  sGridGCodeRef.ExtendedColSizing := True;
  iniPath := Application.Location;
  dmod := Tdmod.Create(self);

  rawCodesFileName := EmptyStr;
  edFileName.Text := iniFile.ReadString(FILE_NAME_SECTION, RAW_FILE_NAME_FROMINI, EmptyStr);
  btnOpen.Enabled := False;
  if ((edFileName.Text > EmptyStr) and (FileExists(edFileName.Text))) then
    rawCodesFileName := edFileName.Text;
    btnOpen.Enabled := True;
end;

procedure TfrmTormach.btnBrowseClick(Sender : TObject);
var
  fName, _fname : String;
begin
  _fname := edFileName.Text;
  // if edFileName has a value and the value is a file
  if ((_fname > EmptyStr) and (FileExists(_fname))) then
    fName := _fname
  else
    if opnDlg.Execute then
      if FileExists(opnDlg.Filename) then
        fName := opnDlg.FileName
      else
        begin
          ShowMessage('No file selected');
          Exit;
				end;

  iniFile.WriteString(FILE_NAME_SECTION, RAW_FILE_NAME_FROMINI, fName);
  _fname := iniFile.FileName;
  //iniFile.;
  edFileName.Text := fName;
  rawCodesFileName := fName;
  readRawFile(fName);
  pnlDoParse.Visible := True;
  tabParsedCodes.Visible := True;
  edColWidth.Text := IntToStr(sGridRawFile.ColWidths[1]);

end;

procedure TfrmTormach.btnDoAnnotateClick(Sender : TObject);
begin
  if not Assigned(fmAnnotateGCode) then
    fmAnnotateGCode := TfmAnnotateGCode.Create(Application);
  fmAnnotateGCode.Show;
end;

procedure TfrmTormach.btnDoParseClick(Sender : TObject);
var
  iRow, iCol, _delim : integer;
  _str : string;
  _code, _value : string;
  valueLength : integer;
begin
  if sGridRawFile.RowCount = 0 then
  begin
    ShowMessage('There is no file in the "Raw file" stringgrid');
    pgCtrl.ActivePage := tabRawCodes;
    Exit;
  end;

  sGridGCodeRef.Visible := False;
  valueLength := 0;
  try
  for iRow := 0 to sGridRawFile.RowCount -1 do
    begin
      _delim := 0;
      //_str := Trim(sGridRawFile.Cells[1, irow]);
      _str := sGridRawFile.Cells[1, irow];
      _delim := Pos(COLON, _str);
      if _delim = 0 then
        begin
          _delim := Pos(TAB, _str);
				end
			else
        begin
          ShowMessage('Value at row ' +IntToStr(iRow) + ' has no delimiter');
          Exit;
			  end;
      _code := Trim(Copy(_str, 0, _delim -1));
      _value := Trim(Copy(_str, _delim +1));
      handleExtraValue(iRow, _code, _value);
      if valueLength < Length(_value) then
        valueLength := Length(_value);
		end;

	finally
    sGridGCodeRef.Visible := True;
	end;
	sGridGCodeRef.ColWidths[1] := valueLength;
  pgCtrl.ActivePage := tabParsedCodes;
end;

procedure TfrmTormach.btnPopStringListClick(Sender : TObject);
var
  iRow, iCol : integer;
  _code, subVal, _value : string;
begin
  iRow := 0;
  iCol := 0;
  codeList.Clear;
  codeList.Sorted := True;
  for iRow := 0 to sGridGCodeRef.RowCount -1 do
    begin
      _code := sGridGCodeRef.Cells[0, iRow];
      subVal := sGridGCodeRef.Cells[1, iRow];
      if subVal > EmptyStr then
        _code := _code +SPACE +subVal;
      _value := sGridGCodeRef.Cells[2, iRow];
      codeList.AddPair(_code, _value);
		end;
  pgCtrl.ActivePage := tab2Test;
  populateTestGrid;
end;

procedure TfrmTormach.handleExtraValue(aRow : integer; aCode, aValue : string);
var
  firstCode, secondCode: string;
  iPos : integer;
begin
  firstCode := EmptyStr;
  secondCode := EmptyStr;
  iPos := Pos(SPACE, aCode);
  if iPos = 0 then
    sGridGCodeRef.InsertRowWithValues(aRow, [aCode, ' ', aValue])
  else
    begin
      firstCode := Copy(aCode, 1, iPos -1);
      secondCode := Copy(aCode, iPos +1);
      sGridGCodeRef.InsertRowWithValues(aRow, [firstCode, secondCode, aValue] );
		end;
end;

procedure TfrmTormach.btnReadGCodeFileClick(Sender : TObject);
begin
  //formGCodeFile.Show;
end;

procedure TfrmTormach.edFileNameChange(Sender : TObject);
begin
  sGridRawFile.Clear;
  sGridGCodeRef.Clear;
end;

function TfrmTormach.readRawFile(fn : String) : Boolean;
var
  txtf : TextFile;
  _str : string;
  lnCnt, codeLength : integer;
begin
  readRawFile := False;
  lnCnt := 0;
  codeLength := 0;
  sGridRawFile.Clear;

  sGridRawFile.Visible := False;
  AssignFile(txtf, rawCodesFileName);
  try
    Reset(txtf);
    ReadLn(txtf, _str);
    while not EOF(txtf) do
    begin
      if Length(_str) > 3 then
        begin
          sGridRawFile.InsertRowWithValues(lnCnt, [IntToStr(lnCnt +1), _str]);
        end;
      if Length(_str) > codeLength then
        codeLength := Length(_str);
    ReadLn(txtf, _str);
    Inc(lnCnt);
		end;
    readRawFile:= True;
	finally
    CloseFile(txtf);
    sGridRawFile.Visible := True;
  end;

  sGridRawFile.ColWidths[1] := codeLength;
end;

procedure TfrmTormach.populateTestGrid;
var
  iRow : Integer;
  _name, _value : string;
begin
  sGrid2Test.Clear;
  for iRow := 0 to codeList.Count -1 do
    begin
      _name := Trim(codeList.Names[iRow]);
      _value := Trim(codeList.ValueFromIndex[iRow]);
      sGrid2Test.InsertRowWithValues(iRow, [_name, _value]);
		end;
  sGrid2Test.Options := sGrid2Test.Options + [goColSizing];
end;

end.

