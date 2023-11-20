unit frmGCodeFile;

{$mode ObjFPC}{$H+}

interface

uses
      Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
      dataModule;

type

			{ TformGCodeFile }

      TformGCodeFile = class(TForm)
				btnRewriteGCode : TButton;
				btnBrowse4GCodeFile : TButton;
				edGCodeFileName : TEdit;
				lblGCodeFileName : TLabel;
		  	mmoCommentedGCode : TMemo;
			  mmoRawGCode : TMemo;
  			pnlBottom : TPanel;
		  	pnlTop : TPanel;
			  pnlClient : TPanel;
  			Splitter1 : TSplitter;
				procedure btnBrowse4GCodeFileClick(Sender : TObject);
      private
        procedure readGCode;
      public

      end;

var
      formGCodeFile : TformGCodeFile;

implementation

uses
  frmTormachGCode;
{$R *.lfm}

{ TformGCodeFile }

procedure TformGCodeFile.readGCode;
var
  txtf : TextFile;
  _str : string;
  lnCnt: integer;
begin
  lnCnt := 0;
  mmoRawGCode.Clear;
  mmoCommentedGCode.Clear;
  {
  AssignFile(txtf, frmTormach.opnDlg.FileName);
  try
    Reset(txtf);
    ReadLn(txtf, _str);
    while not EOF(txtf) do
    begin
      mmoRawGCode.Append(_str);
      _str := EmptyStr;
      ReadLn(txtf, _str);
      Inc(lnCnt);
		end;
    if _str > EmptyStr then
      mmoRawGCode.Append(_str);
	finally
    CloseFile(txtf);
  end;
  }
end;

procedure TformGCodeFile.btnBrowse4GCodeFileClick(Sender : TObject);
begin
  {
  if frmTormach.opnDlg.Execute then
  begin
    if fileExists(frmTormach.opnDlg.Filename) then
    begin
      edGCodeFileName.Text := frmTormach.opnDlg.Filename;
      readGCode;
		end;
	end
  else
    ShowMessage('No file selected');
  }
end;

end.

