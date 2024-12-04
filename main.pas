unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, memds, DB, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids;

type

  { TMainForm }

  TMainForm = class(TForm)
    btnCalcularForEach: TButton;
    btnCalcularNormal: TButton;
    btnAdicionar: TButton;
    btnInverter: TButton;
    btnMarcarCondicao: TButton;
    cdsHelper: TMemDataset;
    cdsHelperCalcular: TBooleanField;
    cdsHelperCod: TLongintField;
    cdsHelperDescricao: TStringField;
    cdsHelperQtd: TLongintField;
    cdsHelperTotal: TCurrencyField;
    cdsHelperValor: TCurrencyField;
    ckbCalcular: TCheckBox;
    dtsHelper: TDataSource;
    DBGrid1: TDBGrid;
    procedure btnCalcularForEachClick(Sender: TObject);
    procedure btnCalcularNormalClick(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnInverterClick(Sender: TObject);
    procedure btnMarcarCondicaoClick(Sender: TObject);
  private
    procedure ExecutarCalculos;
  public

  end;

var
  MainForm: TMainForm;

implementation
  uses DatasetHelpers;

{$R *.lfm}

{ TMainForm }
procedure TMainForm.ExecutarCalculos;
begin
  if cdsHelperCalcular.AsBoolean then
    cdsHelperTotal.Edit(cdsHelperValor.AsInteger * cdsHelperQtd.AsInteger);
end;

procedure TMainForm.btnCalcularForEachClick(Sender: TObject);
begin
  cdsHelper.ForEach(@ExecutarCalculos);
end;

procedure TMainForm.btnInverterClick(Sender: TObject);
begin
  cdsHelperCalcular.InvertALL;
end;

procedure TMainForm.btnMarcarCondicaoClick(Sender: TObject);
begin
  cdsHelperCalcular.SetALL(ckbCalcular.Checked);
end;

procedure TMainForm.btnCalcularNormalClick(Sender: TObject);
var
  BookmarkSave: TBookmark;
begin
  if cdsHelper.IsEmpty then
    Exit;

  BookmarkSave := cdsHelper.Bookmark;

  cdsHelper.DisableControls;
  try
    cdsHelper.First;

    while not cdsHelper.Eof do
    begin

      if cdsHelperCalcular.AsBoolean then
      begin
        cdsHelper.Edit;
        cdsHelperTotal.Ascurrency := cdsHelperValor.AsInteger * cdsHelperQtd.AsInteger;
        cdsHelper.Post;
      end;

      cdsHelper.Next;
    end;

    if (not cdsHelper.IsEmpty) then
    begin
      if cdsHelper.BookmarkValid(BookmarkSave) then
        cdsHelper.Bookmark := BookmarkSave;
    end;

  finally
    cdsHelper.EnableControls;
  end;

end;

procedure TMainForm.btnAdicionarClick(Sender: TObject);
var
  i: Integer;
begin
  if not cdsHelper.Active then
     cdsHelper.Open;

  i := cdsHelper.RecordCount + 1;

  cdsHelper.Insert;
  cdsHelper.fieldByName('Cod').AsInteger := i;
  cdsHelper.fieldByName('Descricao').AsString := 'Desc ' + IntToStr(i);

  Randomize;
  cdsHelper.fieldByName('Qtd').AsInteger := Random(10) + 1;

  Randomize;
  cdsHelper.fieldByName('Valor').AsCurrency := Random(100) /  cdsHelper.fieldByName('Qtd').AsInteger;
  cdsHelper.fieldByName('Calcular').AsBoolean := cdsHelper.fieldByName('Qtd').AsInteger > 5;
  cdsHelper.Post;
end;


end.

