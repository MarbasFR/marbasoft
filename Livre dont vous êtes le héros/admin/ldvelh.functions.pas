unit ldvelh.functions;

interface

uses IBDatabase, IBQuery;

procedure CreateaQuery(aBDD: TIBDatabase; var aQuery: TIBQuery ; OwnsTransaction : boolean = true );
procedure FreeaQuery( var aQuery : TIBQuery; OwnsTransaction : Boolean = true );

implementation

procedure CreateaQuery(aBDD: TIBDatabase; var aQuery: TIBQuery ; OwnsTransaction : boolean = true );
begin
     aQuery := TIBQuery.Create( nil );

     aQuery.Database    := aBDD;
     if not OwnsTransaction then
     begin
          aQuery.Transaction := aBDD.DefaultTransaction ;
          Exit ;
     end;

     aQuery.Transaction := TIBTransaction.Create( nil ) ;
     With aQuery.Transaction do
     begin
       DefaultAction := TACommit;
       Params.Add( 'read_committed' );
       Params.Add( 'rec_version' );
       Params.Add( 'nowait' );
       DefaultDatabase := aBDD
     end;
end;

procedure FreeaQuery( var aQuery : TIBQuery; OwnsTransaction : Boolean = true );Overload;
begin
     if OwnsTransaction then
        aQuery.Transaction.Free;
     aQuery.Free;
end;

end.
