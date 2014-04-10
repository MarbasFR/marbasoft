unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, IBDatabase, IBQuery,

  ipstudio.functionsv4;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    aBDD: TIBDatabase;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }

    procedure SaveToBDD( sTexte : String );
    procedure AjoutDst( Src, Dst : Integer );
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.AjoutDst(Src, Dst: Integer);
var
   aQuery : TIBQuery;
begin
     CreateaQuery( aBDD, aQuery);
     with aQuery do
     begin
       SQL.Add( 'insert into TEST_LINKS ( uid, SRC_UID, DST_UID, FR_FR ) values( null, :src, :dst, null )' );
       ParamByName( 'src' ).AsInteger := Src;
       ParamByName( 'dst' ).AsInteger := Dst;
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
var
   aQuery : TIBQuery;

   nI     : Integer;
   sTexte : String;
   sTemp  : string;
   ActualNumber : Integer;
   DstNumber    : Integer;
   sDst         : String;

   iPos : Integer;
   sParse : String;
   nb     : Integer;
begin
     sTexte := '';
     ActualNumber := 1;
     for nI := 0 to Memo1.Lines.Count - 1 do
     begin
       sTemp := Memo1.Lines[nI];
       if StrToIntDef( sTemp, -1 ) > 0 then
       begin
         if sTexte <> '' then
         begin
           SaveToBDD( sTexte );

           sParse := LowerCase( sTexte );
           iPos := Pos( 'rendez-vous au', sParse );
           while iPos > 0 do
           begin
             sDst := '';
             Nb := 1;
             DstNumber := 0;
             while True do
             begin
               sDst := Trim( sDst + Copy( sParse, iPos + 14 + nb, 1 ) );
               Inc( nb );
               if StrToIntDef( sDst, -1 ) = -1 then Break;
               DstNumber := StrToIntDef( sDst, -1 );
               if (iPos + 14 + nb) > Length( sParse ) then Break;
             end;

             if DstNumber > 0 then
             begin
               AjoutDst( ActualNumber, DstNumber );
             end;

             sParse := Copy( sParse, iPos + 14, Length( sParse ) );
             iPos := Pos( 'rendez-vous au', sParse );
           end;


         end;
         ActualNumber := StrToIntDef( sTemp, -1 );
         sTexte := '';
         Continue;
       end;
       if sTemp <> '' then
         sTexte := sTexte + sLineBreak + sTemp;
       sTexte := Trim( sTexte );
     end;

     if sTexte <> '' then
       SaveToBDD( sTexte );
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     aBDD.Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     aBDD.Open;
end;

procedure TForm1.SaveToBDD(sTexte: String);
var
   aQuery : TIBQuery;
begin
     CreateaQuery( aBDD, aQuery);
     with aQuery do
     begin
       SQL.Add( 'insert into TEST ( uid, FR_FR ) values( null, :texte)' );
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
