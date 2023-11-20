unit formcodecomments;

{$mode ObjFPC}{$H+}

interface

{
  todo: handle cases where X, Y or Z follows a gcode
}
uses
      Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
      StdCtrls, ComCtrls, Grids, IniFiles;

type

	{ TfrmCodeComts }

  TfrmCodeComts = class(TForm)
		btnBrowse : TButton;
		btnDoParse : TButton;
		btnOpen : TButton;
		btnPopStringList : TButton;
		btnReadGCodeFile : TButton;
		edColWidth : TEdit;
		ed_gcode_fileName : TEdit;
		lblColWidthCap : TLabel;
		lblFileName : TLabel;
		mmo : TMemo;
		pgCtrl : TPageControl;
		pnlBottomGCodeRef : TPanel;
		pnlDoParse : TPanel;
		pnlFile : TPanel;
		sGrid2Test : TStringGrid;
		sGridGCodeRef : TStringGrid;
		tab2Test : TTabSheet;
		tabParsedCodes : TTabSheet;
		tab_gcode_file : TTabSheet;
		procedure btnBrowseClick(Sender : TObject);
  private
    ini_file : TIniFile;
  public

  end;

var
  frmCodeComts : TfrmCodeComts;

implementation

uses
  dataModule;

{$R *.lfm}

{ TfrmCodeComts }

procedure TfrmCodeComts.btnBrowseClick(Sender : TObject);
var
  fName, _fname : String;
begin
  _fname := ed_gcode_fileName.Text;
  // if ed_gcode_fileName has a value and the value is a file
  if ((_fname > '') and (FileExists(_fname))) then
    fName := _fname
  else
    if dmod.opn_dlg.Execute then
      if FileExists(dmod.opn_dlg.Filename) then
        fName := dmod.opn_dlg.FileName
      else
        begin
          ShowMessage('No file selected');
          Exit;
				end;

  iniFile.WriteString(FILE_NAME_SECTION, GCODE_FILE_NAME, fName);
  _fname := iniFile.FileName;
  //iniFile.;
  ed_gcode_fileName.Text := fName;
  //rawCodesFileName := fName;
  //readRawFile(fName);
  //pnlDoParse.Visible := True;
  //tabParsedCodes.Visible := True;
  //edColWidth.Text := IntToStr(sGridRawFile.ColWidths[1]);
end;

end.

