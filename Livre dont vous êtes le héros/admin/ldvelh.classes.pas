unit ldvelh.classes;

interface

uses SysUtils, Classes, Generics.Collections, StrUtils;

type
  TChoix = class
  public
    Dst : Integer;
    Lib : String;

    RawTexte : String;
    procedure Parse;
  end;

  TParagraphe = class( TObjectList<TChoix>)
  public
    UID      : Integer;
    RawTexte : String;
    CleanedTexte : String;
    Lignes   : TStringList;

    procedure Parse;
    constructor Create;
    destructor  Destroy; Override;
  end;

  TLivres = class( TObjectList<TParagraphe>)
  public
    procedure ParseTexte( aTexte : String );
    function ToString : String; Override;
    function ToStr : String;
  end;

implementation

{ TParagraphe }

constructor TParagraphe.Create;
begin
     inherited;
     Lignes := TStringList.Create;
end;

destructor TParagraphe.Destroy;
begin
     FreeAndNil( Lignes );
     inherited;
end;

procedure TParagraphe.Parse;
var
   sTexte : String;
   sTemp  : String;
   nI     : Integer;

   InPhrase : Boolean;
   aChoix   : TChoix;
   iPos     : Integer;
   s        : String;
   iStart   : Integer;
begin
     Lignes.Clear;

     CleanedTexte := StringReplace( RawTexte, sLineBreak, #13, [rfReplaceAll] );
     CleanedTexte := StringReplace( CleanedTexte, '...', '…', [rfReplaceAll] );
     sTexte := CleanedTexte;

     sTemp := '';
     InPhrase := False;
     for nI := 1 to Length( sTexte ) do
     begin
       sTemp := sTemp + sTexte[nI];

       if sTexte[nI] = '«' then
         InPhrase := True;
       if sTexte[nI] = '»' then
       begin
         InPhrase := False;

         if (sTexte[nI+1] in ['A'..'Z'] ) then
         begin
           if sTemp <> '' then Lignes.Add( sTemp );
           sTemp := '';
         end
         else
         if (sTexte[nI+2] in ['A'..'Z'] ) then
         begin
           if sTemp <> '' then Lignes.Add( sTemp );
           sTemp := '';
         end;


       end;

       if InPhrase then Continue;

       if sTexte[nI] = #13 then
       begin
         sTemp := Trim( sTemp );
         if (sTexte[nI+1] in ['A'..'Z'] ) then
         begin
           if sTemp <> '' then Lignes.Add( sTemp );
           sTemp := '';
         end
         else
           sTemp := Trim( sTemp ) + ' ';
       end;

       //***   Détection fin de phrase   ***//
       if Pos(sTexte[nI], '.!?…') > 0 then
       begin
         sTemp := Trim(sTemp);
         if sTemp <> '' then Lignes.Add( sTemp );
         sTemp := '';
       end;

     end;

     sTemp := Trim( sTemp );
     if sTemp <> '' then Lignes.Add(sTemp);

     //***   On cherche les choix dispos   ***//
     for nI := 0 to Lignes.Count - 1 do
     begin
       sTemp := Lignes[nI];
       s     := sTemp;
       iPos  := Pos('rendez-vous au', LowerCase(sTemp) );
       iStart := 1;
       while iPos > 0 do
       begin
         s := Copy( sTemp, iStart, ( iPos + 14 ) - iStart + 5 );

         aChoix          := TChoix.Create;
         aChoix.RawTexte := s;
         aChoix.Parse;
         Add( aChoix );

         sTemp := Copy( sTemp, iPos + 14, Length( sTemp ) );
         iPos := Pos('rendez-vous au', LowerCase(sTemp) );
       end;
     end;

end;

{ TLivres }

procedure TLivres.ParseTexte(aTexte: String);
var
   aList : TStringList;
   nI    : Integer;

   iUID   : Integer;
   sTemp  : String;
   aPara  : TParagraphe;
begin
     Clear;

     aTexte := StringReplace( aTexte, 'endezvous', 'endez-vous', [rfReplaceAll] );
     aTexte := StringReplace( aTexte, 'endez-vousau', 'endez-vous au', [rfReplaceAll] );

     aList      := TStringList.Create;
     aList.Text := aTexte;
     aPara      := nil;
     for nI := 0 to aList.Count - 1 do
     begin
       sTemp := aList[nI];
       iUID  := StrToInt64Def( sTemp, 0);
       if iUID > 0 then
       begin
         //***   si on a un paragraphe commencé, on le parse   ***//
         if Assigned( aPara ) then aPara.Parse;

         //***   On entame un nouveau paragraphe   ***//
         aPara        := TParagraphe.Create;
         aPara.UID    := iUID;
         Add( aPara );
         Continue;
       end;

       if Assigned( aPara ) then
         aPara.RawTexte := Trim(aPara.RawTexte + sLineBreak + sTemp);
     end;

     //***   si on a un paragraphe commencé, on le parse   ***//
     if Assigned( aPara ) then aPara.Parse;

     FreeAndNil( aList );
end;

function TLivres.ToStr: String;
var
   nI : Integer;
begin
     Result := '';

     for nI := 0 to Count - 1 do
     begin
       Result := Result + Format( '%d', [Items[nI].UID] ) + sLineBreak;
       Result := Result + Items[nI].Lignes.Text;
     end;
end;

function TLivres.ToString: String;
var
   nI : Integer;
begin
     Result := '';

     for nI := 0 to Count - 1 do
     begin
       Result := Result + Format( '%d', [Items[nI].UID] ) + sLineBreak;
       Result := Result + Items[nI].CleanedTexte + sLineBreak;
     end;
end;

{ TChoix }

procedure TChoix.Parse;
var
   iStart : Integer;
   sTexte : String;
   iTexte : String;
   nI     : Integer;
begin
     Dst := 0;
     Lib := '';

     sTexte := LowerCase(RawTexte);
     //Allez-vous tenter,vous aussi, d'échapper à ce démon destructeur (rendez-vous au354), ou vous sentez-vous de taille à l'affronter (rendez-vous au280) ?
     iStart := Pos( 'rendez-vous au', sTexte );

     iTexte := '';
     sTexte := Copy( RawTexte, iStart + 14, Length( RawTexte ) );
     for nI := 1 to Length( sTexte ) do
     begin
       if sTexte[nI] = ' ' then Continue;
       if not (sTexte[nI] in ['0'..'9']) then Break;
       iTexte := iTexte + sTexte[nI];
     end;
     Dst := StrToIntDef( iTexte, 0 );

     //***   On commence par chercher un début de phrase   ***//
     sTexte := Copy( RawTexte, 1, iStart - 1 );

     for nI := 1 to Length(sTexte) do
     begin
       if sTexte[nI] in ['a'..'z', 'A'..'Z'] then Break;
       sTexte[nI] := ' ';
     end;
     Lib := Trim( sTexte );
end;

end.
