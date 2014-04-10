unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, IBDatabase, IBQuery, StrUtils,
  SQLite3, SQLite3Wrap,
  ldvelh.functions,
  ldvelh.classes;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    aBDD: TIBDatabase;
    Button1: TButton;
    Memo2: TMemo;
    Memo3: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Déclarations privées }
    DB     : TSQLite3Database;
  public
    { Déclarations publiques }

    procedure SaveToBDD( sTexte : String );
    procedure AjoutDst( Src, Dst : Integer; sTexte : String );

    procedure MettreEnPage( sTexte : String );

    procedure CreateDB;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.AjoutDst(Src, Dst: Integer; sTexte : String);
var
   aQuery : TIBQuery;
begin
     CreateaQuery( aBDD, aQuery);
     with aQuery do
     begin
       SQL.Add( 'insert into PARAGRAPHES_CHOIX ( uid, SRC_UID, DST_UID, FR_FR ) values( null, :src, :dst, :texte )' );
       ParamByName( 'src' ).AsInteger := Src;
       ParamByName( 'dst' ).AsInteger := Dst;
       ParamByName( 'texte' ).AsWideString := sTexte;
       Transaction.StartTransaction;
       Try
         ExecSQL;
         Transaction.Commit;
       Except
         Transaction.Rollback;
       End;
     end;
     FreeaQuery( aQuery );
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
     MettreEnPage(Memo1.Text);
end;

procedure TForm1.CreateDB;
begin
     // Delete database if it already exists
     DeleteFile('livre.db');

     // Create database and fill it with example data
     Screen.Cursor := crHourGlass;
     DB := TSQLite3Database.Create;
     try
       DB.Open('livre.db');

       // Create table "PARAGRAPHES"
       DB.Execute('CREATE TABLE PARAGRAPHES (uid INTEGER primary key autoincrement, FR_FR TEXT)');
     finally
       Screen.Cursor := crDefault;
     end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     //aBDD.Close;
     DB.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     //aBDD.Open;
     CreateDB;
end;

procedure TForm1.MettreEnPage(sTexte: String);
var
   aLivre : TLivres;
   aParag : TParagraphe;
   aChoix : TChoix;

   nI     : Integer;
   nJ     : Integer;
begin
     aLivre := TLivres.Create;
     aLivre.ParseTexte( sTexte );
     Memo2.Text := aLivre.ToString;
     Memo3.Text := aLivre.ToStr;

     for nI := 0 to aLivre.Count - 1 do
     begin
       aParag := aLivre[nI];
       SaveToBDD( aParag.Lignes.Text );
       //aParag.Lignes.SaveToFile( Format('datas\%d.txt', [aParag.UID] )  );
       (*
       SaveToBDD( aParag.Lignes.Text );
       for nJ := 0 to aParag.Count - 1 do
       begin
         aChoix := aParag[nJ];
         AjoutDst( aParag.UID, aChoix.Dst, aChoix.Lib );
       end;
       *)
     end;


     FreeAndNil( aLivre );
end;

procedure TForm1.SaveToBDD(sTexte: String);
var
   aQuery : TIBQuery;
   Stmt   : TSQLite3Statement;
begin
     // Create database and fill it with example data
     Stmt := DB.Prepare('INSERT INTO PARAGRAPHES (uid, FR_FR) VALUES (null, ?)');
     Try
       Stmt.BindText(1, sTexte );
       Stmt.StepAndReset;
     Finally
       Stmt.Free;
     End;

     Exit;

     CreateaQuery( aBDD, aQuery);
     with aQuery do
     begin
       SQL.Add( 'insert into PARAGRAPHES ( uid, FR_FR ) values( null, :texte)' );
       ParamByName( 'texte' ).AsWideString := sTexte;
       Transaction.StartTransaction;
       Try
         ExecSQL;
         Transaction.Commit;
       Except
         Transaction.Rollback;
       End;
     end;
     FreeaQuery( aQuery );

end;

end.
