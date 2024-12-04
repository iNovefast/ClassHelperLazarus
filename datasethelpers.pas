unit DatasetHelpers;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, db;

type

  TProc = procedure of object;

  { TDataSetHelper }
  TDataSetHelper = class helper for TDataSet
  public
    procedure ForEach(Proc: TProc; GotoFirst: Boolean = True; Bookmark: Boolean = True);
  end;

  { TFieldHeper }

  TFieldHeper = class helper for TField
  public
    procedure Edit(ANovoValor: variant);
  end;

  { TFieldBooleanHeper }

  TFieldBooleanHeper = class helper for TBooleanField
  public
    procedure Invert;
    procedure InvertALL;
    procedure SetTrue;
    procedure SetFalse;
    procedure SetALL(AValue: Boolean);
  end;

implementation

{ TDataSetHelper }
procedure TDataSetHelper.ForEach(Proc: TProc; GotoFirst: Boolean; Bookmark: Boolean);
var
  BookmarkSave: TBookmark;
begin
  if Self.IsEmpty then
    Exit;

  DisableControls;
  try
    if Bookmark then
      BookmarkSave := Self.Bookmark;

    if GotoFirst then
      First;

    while not Eof do
    begin
      Proc;
      if Self.tag = 999 then
        Break;
      Next;
    end;

    if (not IsEmpty) and Bookmark then
    begin
      try
        if BookmarkValid(BookmarkSave) then
          Self.Bookmark := BookmarkSave;
      except

      end;
    end;

  finally
    EnableControls;
  end;
end;

{ TFieldHeper }
procedure TFieldHeper.Edit(ANovoValor: variant);
begin
  if not Self.Dataset.Active then
     Exit;

  if Self.Dataset.State in dsEditModes then
     Self.Dataset.Post;

  Self.DataSet.Edit;
  Self.Value := ANovoValor;
  Self.DataSet.Post;
end;

{ TFieldBooleanHeper }
procedure TFieldBooleanHeper.Invert;
begin
  Self.Edit(not Self.Value);
end;

procedure TFieldBooleanHeper.InvertALL;
begin
  Self.DataSet.ForEach(@Self.Invert);
end;

procedure TFieldBooleanHeper.SetTrue;
begin
  Self.Edit(True);
end;

procedure TFieldBooleanHeper.SetFalse;
begin
  Self.Edit(False);
end;

procedure TFieldBooleanHeper.SetALL(AValue: Boolean);
begin
  if AValue then
     Self.DataSet.ForEach(@Self.SetTrue)
  else
    Self.DataSet.ForEach(@Self.SetFalse);
end;

end.

