unit SpellCheck;

interface
uses
  Classes, SysUtils, uHunSpellLib;

type
  TSpellCheck = class(TComponent)
  private
    FAffFileName: string;
    FDictFileName: string;
    FLoadedActive: Boolean;
    FSpell: Pointer;
    procedure SetActive(const Value: Boolean);
    procedure SetAffFileName(const Value: string);
    procedure SetDictFileName(const Value: string);
    function GetActive: Boolean;
  protected
    procedure Loaded; override;
  public
    destructor Destroy; override;

    procedure Open; dynamic;
    procedure Close; dynamic;

    function IsMisspelled(const AWord: string): Boolean; dynamic;
    procedure GetSuggestions(const AWord: string; const Lines: TStrings); dynamic;
    function AddWord(const AWord: string): Boolean; dynamic;

  published
    property Active: Boolean read GetActive write SetActive;
    property AffFileName: string read FAffFileName write SetAffFileName;
    property DictFileName: string read FDictFileName write SetDictFileName;
  end;

  procedure Register;

implementation

procedure Register;
begin
  RegisterComponentsProc('SpellCheck', [TSpellCheck]);
end;

{ TSpellCheck }

function TSpellCheck.AddWord(const AWord: string): Boolean;
begin
  Result := False;
  if (not Active) then Exit;
  uHunSpellLib.hunspell_put_word(FSpell, PAnsiChar(AnsiString(AWord)));
  Result := True;
end;

procedure TSpellCheck.Close;
begin
  if not Active then Exit;
  uHunSpellLib.hunspell_uninitialize(FSpell);
  FSpell := nil;
end;

destructor TSpellCheck.Destroy;
begin
  Close;
  inherited;
end;

function TSpellCheck.GetActive: Boolean;
begin
  Result := (FSpell <> nil);
end;

procedure TSpellCheck.GetSuggestions(const AWord: string; const Lines: TStrings);
var
  i, Len: Integer;
  wrds,wrdswork: PPAnsiChar;
begin
  if (not Active) then Exit;

  if not uHunSpellLib.hunspell_spell(FSpell, PAnsiChar(AnsiString(AWord))) then
  begin
    Len := uHunSpellLib.hunspell_suggest(FSpell, PAnsiChar(AnsiString(AWord)), wrds);
    wrdswork := wrds;
    for i := 1 to Len do
    begin
      Lines.Add(UTF8Encode(wrdswork^));
      Inc(wrdswork, SizeOf(Pointer));
    end; {for}
    uHunSpellLib.hunspell_suggest_free(FSpell, wrds, Len);
  end; {if}
end;

function TSpellCheck.IsMisspelled(const AWord: string): Boolean;
begin
  if (not Active) then
    Result := True
  else
    Result := not uHunSpellLib.hunspell_spell(FSpell, PAnsiChar(AnsiString(AWord)));
end;

procedure TSpellCheck.Loaded;
begin
  inherited;
  SetActive(FLoadedActive);
end;

procedure TSpellCheck.Open;
begin
  if Active then Exit;
  if not uHunSpellLib.LoadLibHunspell('') then Exit;
  FSpell := uHunSpellLib.hunspell_initialize(PAnsiChar(AnsiString(FAffFileName)), PAnsiChar(AnsiString(FDictFileName)));
end;

procedure TSpellCheck.SetActive(const Value: Boolean);
begin
  if (csLoading in ComponentState) then
    FLoadedActive := Value
  else
    if Value then
      Open
    else
      Close;
end;

procedure TSpellCheck.SetAffFileName(const Value: string);
begin
  Close;
  FAffFileName := Value;
end;

procedure TSpellCheck.SetDictFileName(const Value: string);
begin
  Close;
  FDictFileName := Value;
end;

end.
