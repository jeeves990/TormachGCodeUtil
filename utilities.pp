unit utilities;

{$mode ObjFPC}{$H+}

interface

uses
      Classes, SysUtils, contnrs;

type

	{ TCodes }

  TCodes = class(TStringList)
    _code, _value : string;
    procedure AddObject(aCode, aValue : string);  reintroduce;
	end;

implementation

{ TCodes }

procedure TCodes.AddObject(aCode, aValue);
begin
  self.AddPair(aCode, aValue);
end;

end.

