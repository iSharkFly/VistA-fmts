C0XGET3 ; VEN/SMH - Sam's Getters... let's try to make them simple ;2013-01-25  4:59 PM
 ;;1.1;FILEMAN TRIPLE STORE;
 ;
IEN(N) ; Public $$; Resolved IEN of a stored string such as "rdf:type" in Strings File
 Q $$IENOF^C0XGET1($$EXT^C0XUTIL(N))
 ;
 ;
 ;
GOPS1(G,O,P) ; Public $$; Get Subject for A Graph/Object/Predicate combination
 N S S S=$O(^C0X(101,"GOPS",$$IEN(G),$$IEN(O),$$IEN(P),""))
 Q:S="" ""
 Q ^C0X(201,S,0)
GOPS(R,G,O,P) ; Public Proc; Get Subjects for A Graph/Object/Predicate combination
 ; R is global style RPC reference
 N S S S=""
 F  S S=$O(^C0X(101,"GOPS",$$IEN(G),$$IEN(O),$$IEN(P),S)) Q:S=""  S @R@(S)=^C0X(201,S,0)
 QUIT
ONETYPE1(G,O) ; Public $$; Get Subject for Graph/Object of a specific type
 ; This is a conveince call to GOPS1 with Predicate="rdf:type"
 Q $$GOPS1(G,O,"rdf:type")
ONETYPE(R,G,O) ; Public Proc; Get Subjects for Graph/Object of a specific type
 ; R is global style RPC reference
 ; This is a conveince call to GOPS with Predicate="rdf:type"
 D GOPS(R,G,O,"rdf:type")
 QUIT
GSPO1(G,S,P) ; Public $$; Get Object for A Graph/Subject/Predicate combination
 N O S O=$O(^C0X(101,"GSPO",$$IEN(G),$$IEN(S),$$IEN(P),""))
 Q:O="" ""
 Q ^C0X(201,O,0)
