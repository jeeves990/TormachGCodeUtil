unit formAnnotateGCode;

{$mode ObjFPC}{$H+}

interface

uses
      Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
			ComCtrls, Grids, Types, StrUtils;
//, syshelp;

type

	{ TfmAnnotateGCode }

  TfmAnnotateGCode = class(TForm)
		btnBrowse : TButton;
		btnOpen : TButton;
		edCurLine : TEdit;
		edGCodeFileName : TEdit;
		Label1 : TLabel;
		lblMmoFileName : TLabel;
		lblGCodeFileName : TLabel;
		lsBoxWork : TListBox;
		mmoGCodeFile : TMemo;
		mmoTopComments : TMemo;
		Panel1 : TPanel;
		pgCtrl : TPageControl;
		pnl4Memo : TPanel;
		pnlAnnotatedGCode : TPanel;
		pnlTop : TPanel;
		pnlBottom : TPanel;
		sGridAnnotated : TStringGrid;
		splt_leftMost : TSplitter;
		Splitter2 : TSplitter;
		Splitter3 : TSplitter;
		Splitter4 : TSplitter;
		tabAnnotated : TTabSheet;
		tabWorkSheet : TTabSheet;
		procedure btnBrowseClick(Sender : TObject);
		procedure btnOpenClick(Sender : TObject);
		procedure FormCreate(Sender : TObject);
		procedure FormDestroy(Sender : TObject);
		procedure mmoGCodeFileDblClick(Sender : TObject);
		procedure mmoGCodeFileKeyUp(Sender : TObject; var Key : Word;
					Shift : TShiftState);
  private
    gCodeFileName : String;
    list_of_gCode : TStringList;
    ara_ofParsedIds  : TStringDynArray;
    function GetFileName : string;
		function ReadGCodeFile : Boolean;
    procedure ReadTopComments;
		procedure SetMmoLineLength(const long_ln : String);
		function Split2GCodeValues(aLine : String) : TStringList;
  public

  end;

var
  fmAnnotateGCode : TfmAnnotateGCode;

implementation

uses dataModule, LCLType, LazSysUtils;

{$R *.lfm}

{ TfmAnnotateGCode }

procedure TfmAnnotateGCode.btnBrowseClick(Sender : TObject);
begin
  gCodeFileName := EmptyStr;
  gCodeFileName := GetFileName;
  edGCodeFileName.Text := gCodeFileName;
end;

procedure TfmAnnotateGCode.btnOpenClick(Sender : TObject);
begin
  list_of_gCode.Clear;
  try
    mmoGCodeFile.Hide;
    ReadGCodeFile;
	finally
    mmoGCodeFile.Show;
	end;
end;

procedure TfmAnnotateGCode.FormCreate(Sender : TObject);
var
  _str : String;
begin
  _str := iniFile.ReadString(FILE_NAME_SECTION,GCODE_FILE_NAME, EmptyStr);
  edGCodeFileName.Text := _str;
  list_of_gCode := TStringList.Create;
  ara_ofParsedIds := TStringDynArray.Create;

  if (_str > EmptyStr) and (FileExists(_str)) then
    begin
  		gCodeFileName := _str;
      ReadGCodeFile;
		end;
end;

procedure TfmAnnotateGCode.FormDestroy(Sender : TObject);
begin
  list_of_gCode.Free;
  //ara_ofParsedIds.Free;
end;

procedure TfmAnnotateGCode.mmoGCodeFileDblClick(Sender : TObject);
// mmoGCodeFileDblClick handles exactly one line of the *.nc file
var
  _str : String;
  iRow : Integer;
begin
  // issue: mmoGCodeFile.CaretPos.y differs because of line wrap
  //    solution: Kloogy: turned off WordWrap on mmoGCodeFile
  sGridAnnotated.Clean([gzNormal, gzFixedRows]);
  iRow := mmoGCodeFile.CaretPos.y; // get index into list_of_gCode
  _str := list_of_gCode[iRow]; // get current row from the list NOT the TStringGrid;
  edCurLine.Text := _str;
  //ParseLineOfCode(_str);
  Split2GCodeValues(_str);
end;

procedure TfmAnnotateGCode.mmoGCodeFileKeyUp(Sender : TObject; var Key : Word;
			Shift : TShiftState);
begin
  if Key in [VK_UP, VK_DOWN, 33, 34] then
    mmoGCodeFileDblClick(Sender);
end;

function TfmAnnotateGCode.Split2GCodeValues(aLine : String) : TStringList;

    {----------------------------------------}
    function getComment(aln : String): String;
    {----------------------------------------}
    // aln begins with OPEN_PAREN, i.e., a comment has been found
    var
      ii : integer;
    begin
      getComment := aln[1];
      ii := 2;
      // read until CLOSE_PAREN is found;
      while aln[ii] <> CLOSE_PAREN do
        begin
          Result := Result +aln[ii];
          Inc(ii);
				end;
      //if aln[ii] = CLOSE_PAREN then
      Result := Result +aln[ii];
		end;

    {----------------------------------------}

var
  kpGCode : Char;
  workStr, codeValue : String;
  str_ln : Integer;
  ndx : Integer;
label
  do_final;
begin
  ndx := codeList.Count;
  sGridAnnotated.Cells[1, 0] := EmptyStr;
  aLine := UpperCase(Trim(aLine));
  // aLine will be pared down as elements are processed and deleted from the front end
  self.lsBoxWork.Clear;
  sGridAnnotated.RowCount := 1;
  while Length(aLine) > 0 do
    try
      try
        if aLine[1] = OPEN_PAREN then
          begin
            workStr := getComment(aLine);
            lsBoxWork.Items.Add(workStr);
            goto do_final;
					end;

        // is the current char in GCODES
      	if aLine[1] in GCODES then
         begin
           kpGCode := aLine[1];
           Delete(aLine, 1, 1); // remove that GCODE
           workStr := Get_a_number_from_text(aLine);
           str_ln := Length(workStr);

           workStr := AddChar(kpGCode, workStr, str_ln +1);

           lsBoxWork.Items.Add(workStr);

           if kpGCode in AN_N then
             begin
               sGridAnnotated.Cells[1, 0] := 'Line #:' +workStr;
             end
           else
             begin
               sGridAnnotated.RowCount := sGridAnnotated.RowCount +1;
               sGridAnnotated.Cells[0, sGridAnnotated.RowCount -1] := workStr;
               codeValue := EmptyStr;
               //if codeList.Find(workStr, ndx) then
                 begin
                   codeValue := codeList.Values[workStr];
                   sGridAnnotated.Cells[1, sGridAnnotated.RowCount -1] := codeValue;

								 end;
						 end;
           goto do_final;
      		end;

         if aLine[1] in AXES then // get a real number
           begin
             kpGCode := aLine[1];
             Delete(aLine, 1, 1); // remove that GCODE
             workStr := Get_a_number_from_text(aLine);
             lsBoxWork.Items.Add(kpGCode +workStr);
             sGridAnnotated.RowCount := sGridAnnotated.RowCount +1;
             sGridAnnotated.Cells[0, sGridAnnotated.RowCount -1] := kpGCode +workStr;
             goto do_final;
				   end;

          begin
            if aLine[1] = PERCENT_SIGN then
              begin
                lsBoxWork.Items.Add(PERCENT_SIGN);
                goto do_final;
							end;
            // TODO: do something with any remainder of the processed string
					end;

do_final:
			finally
        if aLine[1] = PERCENT_SIGN then
          begin
            aLine := EmptyStr;
					end
        else
          begin

						// handle possible addition of GCODE "back" to workStr
            // because aLine does not have the GCODE
            if not (workStr[1] in GCODES) then
              Delete(aLine, 1, Length(workStr))
            else
              Delete(aLine, 1, Length(workStr) -1);
            aLine := UpperCase(Trim(aLine));

					end;
			end;

		except
      on E : Exception do
        ShowMessage(E.Message);
      //if mmoGCodeFile.CaretPos.y > mmoGCodeFile.Lines.Count -1 then
        ; //mmoGCodeFile.CaretPos.Y := mmoGCodeFile.Lines.Count -1;
		end;
end;

function TfmAnnotateGCode.GetFileName : string;
begin
  dmod.opn_dlg.FileName := EmptyStr;
  if dmod.opn_dlg.Execute then
    begin
      GetFileName := dmod.opn_dlg.FileName;
		end;
end;

procedure TfmAnnotateGCode.ReadTopComments;
{
  read to first commented line (begins with open parenthesis
  then read until no commented line
}
var
  i, iMax, iStart : Integer;
  _str, sub_str : String;
  first_char : String;
begin
  mmoTopComments.Clear;
  i := 0;
  iStart := 0;
  iMax := mmoGCodeFile.Lines.Count;
 	_str := Trim(mmoGCodeFile.Lines[i]);
  if LeftStr(_str, 1) = PERCENT_SIGN then
    begin
      mmoTopComments.Append(_str);
      iStart := 1;
		end;

  // find first commented line
  for i := iStart to iMax -1 do
    begin

    	_str := Trim(mmoGCodeFile.Lines[i]);
      if _str = EmptyStr then
        Continue;

      first_char := LeftStr(_str, 1);

      case first_char of
        OPEN_PAREN : Break;
      else
        mmoTopComments.Append(_str);
			end;
		end;

  // then  read until line begins with 'N100', i.e., the first line number
  for i := i +1 to iMax -1 do
    begin
      _str := Trim(mmoGCodeFile.Lines[i]);
      if Length(_str) < 3 then
        Continue;
      sub_str := Copy(_str, 0, 3);
      if sub_str = FIRST_LINE_NUMBER then
        Break;
      mmoTopComments.Append(_str);
		end;
end;

function TfmAnnotateGCode.ReadGCodeFile : Boolean;
var
  txtf : TextFile;
  _str : string;
  long_line : String;
begin
  long_line := EmptyStr;
  ReadGCodeFile := False;
  AssignFile(txtf, gCodeFileName);
  try
    Reset(txtf);
    if EOF(txtf) then
      begin
        ShowMessage(gCodeFileName +' is an empty file');
        Exit;
			end;
    mmoGCodeFile.Clear;

    ReadLn(txtf, _str);
    while not EOF(txtf) do
      begin
        mmoGCodeFile.Append(_str);
        list_of_gCode.Add(_str);
        if Length(_str) > Length(long_line) then
          long_line := _str;
        ReadLn(txtf, _str);
			end;
    if _str <> EmptyStr then
      begin
  			mmoGCodeFile.Append(_str);
        list_of_gCode.Add(_str);
        if Length(_str) > Length(long_line) then
          long_line := _str;
			end;
    ReadGCodeFile := True;
    iniFile.WriteString(FILE_NAME_SECTION, GCODE_FILE_NAME, gCodeFileName);
        lblMmoFileName.Caption := gCodeFileName;
    SetMmoLineLength(long_line);
    ReadTopComments;
  finally
    CloseFile(txtf);
    mmoGCodeFile.SelStart := 1;  // does this scroll to top?
	end;
end;

procedure TfmAnnotateGCode.SetMmoLineLength(const long_ln: String);
begin
  mmoGCodeFile.Width := GetTextWidthEx(long_ln, mmoGCodeFile.Font);
end;

end.

