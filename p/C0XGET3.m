C0XGET3 ; VEN/SMH - Sam's Getters... let's try to make them simple ;2013-02-20  11:50 AM
 ;;1.1;FILEMAN TRIPLE STORE;
 ;
IEN(N) ; Public $$; Resolved IEN of a stored string such as "rdf:type" in Strings File
 I +N=N Q N ; We are given the IEN, just return it back
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
 ; Supports forward relational navigation for predicates using "." as separator
 N EP S EP=$P(P,".",2,99) ; Extended Predicate
 S P=$P(P,".") ; Predicate becomes the first piece
 N O S O=$O(^C0X(101,"GSPO",$$IEN(G),$$IEN(S),$$IEN(P),""))
 Q:O="" "" ; Another end point for recursion
 Q:$L(EP) $$GSPO1(G,O,EP) ; if we have an extended predicate, recurse
 Q ^C0X(201,O,0) ; this is the end point of the recursion.
 ;
GSPO(R,G,S,P) ; Public Proc; Get Objects for a Graph/Subject/Predicate combination
 ; Supports forward relational navigation for predicates using "." as separator
 ; R is global style RPC reference
 ; Extended Predicates are assumed to have only one object
 ; This routine doesn't process multiple objects for the extended predicate.
 N EP S EP=$P(P,".",2,99) ; Extended Predicate
 S P=$P(P,".") ; Predicate becomes the first piece
 N O S O=""
 F  S O=$O(^C0X(101,"GSPO",$$IEN(G),$$IEN(S),$$IEN(P),O)) Q:O=""  D  ; For each object
 . I $L(EP) D  ; If we have an extended predicate...
 . . I EP="*" N P S P="" F  S P=$O(^C0X(101,"GSPO",$$IEN(G),$$IEN(O),P)) Q:P=""  D  ; If all predicates (EP=*) for each predicate
 . . . S @R@(O,$$NSP^C0XUTIL(P))=$$GSPO1(G,O,P) ; Return (Object, namespaced predicate)=value
 . . E  S @R@(O)=$$GSPO1(G,O,EP)  ; If Extended Predicate, resolve the predicate to get ultimate object
 . E  S @R@(O)=^C0X(201,O,0) ; Otherwise, just return the object
 QUIT
