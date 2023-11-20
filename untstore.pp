unit untStore;

//{$mode DELPHI}
{$mode ObjFPC}
{$H+}

interface

uses
      Classes, SysUtils, StrUtils, Contnrs, fgl, dialogs
      ;

type

	{ TGCodeRecord }
	FGCodeRecord = class(TObject)
	  gcode : string;
	  gcodeAlias : string;
	  gcodeValue : string;
	  gcodeLength : Integer;
	end;

  FGCodeList = specialize TFPGObjectList<FGCodeRecord>;

	{ FGCodeStore }

  FGCodeStore = class
    private
      lst : FGCodeList;
      storage : TObjectList;
      fileName : String;
      procedure LoadFromFile(fname : String);
      procedure LoadFromFile;
			procedure MakeAlias (var _rec : FGCodeRecord );
      function FindGCodeValue(gCode : String) : String;
      procedure AddRec(rec : FGCodeRecord);
      Constructor Create(AOwner: TComponent);
    public
	end;

implementation

uses dataModule;

{ FGCodeStore }

procedure FGCodeStore.LoadFromFile(fname : String);
{  add a new fileName  }
var
  opnDlg : TOpenDialog;
  locFName : String;
begin
  locFName := EmptyStr;
  if fname <> EmptyStr then
    locFName := fname;

  opnDlg := TOpenDialog.Create(nil);
  try
    opnDlg.FileName := locFName;
    if opnDlg.Execute then
      begin
        Self.fileName := opnDlg.FileName;
        LoadFromFile;
      end;
  finally
    opnDlg.Free;
  end;
end;

procedure FGCodeStore.MakeAlias(var _rec : FGCodeRecord );
var
  intValue : Integer;
  workStr : String;
begin
  workStr := _rec.gcode;
  Delete(workStr, 2, 999);
  intValue := StrToInt(workStr);
  if intValue = 0 then
    _rec.gcodeAlias := _rec.gcode[1] +'00'
  else
    _rec.gcodeAlias := _rec.gcode;
end;

procedure FGCodeStore.AddRec (rec : FGCodeRecord );
begin
  if not Assigned(rec) then
    Exit;
  self.MakeAlias(rec);
  lst.Add(rec);
end;

constructor FGCodeStore.Create (AOwner : TComponent );
begin
	inherited Create;
  storage := TObjectList.Create(True);
end;

procedure FGCodeStore.LoadFromFile ;
{  prerequisite: fileName is already set  }
var
  txtf : TextFile;
  _str, _code, _value : String;
  _delim : Integer;
  rec : FGCodeRecord;
begin
  lst.Clear;
  AssignFile(txtf, self.fileName);
  try
    Reset(txtf);
    ReadLn(txtf, _str);
    while not EOF(txtf) do
    begin
      if Length(_str) > 3 then
        begin
          _delim := Pos(COLON, _str);
          if _delim = 0 then
            begin
              _delim := Pos(TAB, _str);
    				end
    			else
            begin
              //ShowMessage('Value at row ' +IntToStr(iRow) + ' has no delimiter');
              Exit;
    			  end;
          _code := Trim(Copy(_str, 0, _delim -1));
          _value := Trim(Copy(_str, _delim +1));
          rec := FGCodeRecord.Create;
          rec.gcode := _code;
          rec.gcodeLength := Length(_code);
          rec.gcodeValue := _value;
          self.AddRec(rec);
        end;
      //if Length(_str) > codeLength then
      //  codeLength := Length(_str);
      ReadLn(txtf, _str);
		end;
	finally
    CloseFile(txtf);
  end;

end;

function FGCodeStore .FindGCodeValue (gCode : String ): String ;
  {
     some gCode's may not be fully formed, e.g., G0 may appear as G00
  }
var
  dx : Integer;
  rec : FGCodeRecord;
const
  fmtMsg = 'GCode [%s] not found';
begin
  Result := EmptyStr;
  dx := 0;
  while dx < lst.Count do
    begin
      rec := lst[dx];
      if (gCode = rec.gcode) or (gCode = rec.gcodeAlias) then
        begin
          Result := rec.gcodeValue;
          Exit;
				end;
      Inc(dx);
		end;
  ShowMessage(Format(fmtMsg, [gCode]));
end;

end.


