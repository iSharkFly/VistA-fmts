C0XPT2 ; VEN/SMH - Get and Store Allergies/ADRs ;2013-05-01  9:54 AM
 ;;1.1;FILEMAN TRIPLE STORE;;
	; (C) Sam Habiel 2013
	; Proprietary code. Stay out!
 ;
ADR(G,DFN) ;  Private Proc; Extract Allergies and ADRs from Graph and add to Patient's Record
	; Input: G, Patient Graph, DFN, you should know that that is; Both by value.
	;
	; Try No known allergies first.
	N NKA S NKA=$$ONETYPE1^C0XGET3(G,"sp:AllergyExclusion") ; Get NKA node
	;
	; Add NKA to record.
	; We don't really care about the return value. If patient already has
	; allergies, we just keep them.
	I $L(NKA) N % S %=$$NKA(DFN) QUIT  ; If it exists, let's try to file it into VISTA
	;
	; If we are here, it means that the patient has allergies. Fun!
	; Process incoming allergies
	N RETURN ; Local return variable. I don't expect a patient to have more than 50 allergies.
	D ONETYPE^C0XGET3($NA(RETURN),G,"sp:Allergy") ; Get all allergies for patient
	;
	N S F S=0:0 S S=$O(RETURN(S)) Q:'S  D  ; For each allergy
	. ; Get the SNOMED code for the category
	. N ALLERGYTYPE
	. N SNOCAT S SNOCAT=$$GSPO1^C0XGET3(G,RETURN(S),"sp:category.sp:code"),SNOCAT=$P(SNOCAT,"/",$L(SNOCAT,"/"))
	. I SNOCAT=414285001 S ALLERGYTYPE="F" ; Food
	. E  I SNOCAT=416098002 S ALLERGYTYPE="D" ; Drug
	. I '$D(ALLERGYTYPE) S $EC=",U1," ; Crash if neither of these is true.
	. ;
	. N ALLERGEN,ALLERGENI ; Allergen, Internal Allergen
	. I ALLERGYTYPE="F" D  ; Food
	. . S ALLERGEN=$$UP^XLFSTR($$GSPO1^C0XGET3(G,RETURN(S),"sp:otherAllergen.dcterms:title")) ; uppercase the allergen
	. . I ALLERGEN="PEANUT" S ALLERGEN="PEANUTS" ; TODO: temporary fix
	. . S ALLERGENI=$$GMRA(ALLERGEN) ; Get internal representation for GMRA call
	. ;
	. ; Otherwise, it's a drug. But we need to find out if it's a class,
	. ; ingredient, canonical drug, etc. Unfortunately, Smart examples don't
	. ; show such variety. The only one specified is a drug class.
	. ; Therefore
	. ; TODO: Handle other drug items besides drug class
	. ;
	. E  D  ; Drug Class
	. . N DC S DC=$$GSPO1^C0XGET3(G,RETURN(S),"sp:drugClassAllergen.sp:code") ; drug class
	. . I '$L(DC) QUIT  ; edit this line out when handling other items
	. . S ALLERGEN=$P(DC,"/",$L(DC,"/")) ; Get last piece
	. . ; TODO: Resolve drug class properly. Need all of RxNorm for that.
	. . N STR S STR=$$UP^XLFSTR($$GSPO1^C0XGET3(G,RETURN(S),"sp:drugClassAllergen.dcterms:title"))
	. . I ALLERGEN="N0000175503" S ALLERGENI=STR_U_"23;PS(50.605," ; hard codeded for sulfonamides
	. . ;
	. ; DEBUG.ASSERT THAT allergen Internal isn't empty
	. I '$L(ALLERGENI) S $EC=",U1,"
	. ;
	. ; Get Severity (Mild or Severe) - We get free text rather than SNOMED
	. N SEVERITY S SEVERITY=$$UP^XLFSTR($$GSPO1^C0XGET3(G,RETURN(S),"sp:severity.dcterms:title"))
	. I '$L(SEVERITY) S $EC=",U1,"
	. ;
	. ; Get Reaction - We get free text rather than SNOMED
	. N REACTION S REACTION=$$UP^XLFSTR($$GSPO1^C0XGET3(G,RETURN(S),"sp:allergicReaction.dcterms:title"))
	. I '$L(REACTION) S $EC=",U1,"
	. ;
	. ; Now that we have determined the allergy, add it
	. D FILEADR(DFN,ALLERGENI,REACTION,SEVERITY,ALLERGYTYPE) ; Internal API
	QUIT
	;
NKA(DFN) ; Public $$; Add no known allergies to patient record
	N ORDFN S ORDFN=DFN ; CPRS API requires this one
	N ORY ; Return value: 0 - Everything is okay; -1^msg: Patient already has allergies
	D NKA^GMRAGUI1 ; API
	QUIT $G(ORY) ; Not always returned
	;
GMRA(NAME)	; $$ Private - Retrieve GMRAGNT for food allergy from 120.82
	; Input: Brand Name, By Value
	; Output: Entry Name^IEN;File Root for IEN
	N C0PIEN S C0PIEN=$$FIND1^DIC(120.82,"","O",NAME,"B")
	Q:C0PIEN $$GET1^DIQ(120.82,C0PIEN,.01)_"^"_C0PIEN_";GMRD(120.82,"
	QUIT "" ; no match otherwise
	;
TYPE(GMRAGNT)	; $$ Private - Get allergy Type (Drug, food, or other)
	; Input: Allergen, formatted as Allergen^IEN;File Root
	; Output: Type (internal)^Type (external) e.g. D^Drug
	N C0PIEN S C0PIEN=+$P(GMRAGNT,U,2)
	I GMRAGNT["GMRD(120.82," Q $$GET1^DIQ(120.82,C0PIEN,"ALLERGY TYPE","I")_U_$$GET1^DIQ(120.82,C0PIEN,"ALLERGY TYPE","E")
	Q "D^Drug" ; otherwise, it's a drug
	;
FILEADR(DFN,AGENT,REACTION,SEVERITY,TYPE,DATE)	; Private Proc - File Drug Reaction
	; This is very messy right now. The more use this gets, the better idea
	; I will have of how much data resolution this API should expect and how
	; much it should do itself.
	;
	K ^TMP($J,"ADR")
	S ^TMP($J,"ADR","GMRAGNT")=AGENT ; Agent Free Text^Agent in variable pointer format
	S ^TMP($J,"ADR","GMRATYPE")=TYPE ; F(ood), D(rug), or O(ther) or combination.
	S ^TMP($J,"ADR","GMRANATR")="U^Unknown" ; Mechanism: Allergic, Pharmacologic, or Unknown
	S ^TMP($J,"ADR","GMRAORIG")=$$NP^C0XPT0 ; New Person generated for SMART
	S ^TMP($J,"ADR","GMRAORDT")=$G(DATE,$$NOW^XLFDT) ; Origination Date; Ideally, would have a date for the allergy.
	S ^TMP($J,"ADR","GMRACHT",0)=1 ; Mark Chart as allergy document; don't know why; CPRS does that.
	S ^TMP($J,"ADR","GMRACHT",1)=$$NOW^XLFDT ; Chart documentation date; don't know why; CPRS does that.
	S ^TMP($J,"ADR","GMRAOBHX")="h^HISTORICAL" ; or o^Observered
	S ^TMP($J,"ADR","GMRACMTS",0)=1 ; Comments
	S ^TMP($J,"ADR","GMRACMTS",1)=SEVERITY ; Store severity in the comments (Severity in VISTA only applies to observed allergies)
	S ^TMP($J,"ADR","GMRASYMP",0)=1 ; One Symptom
	;
	; Find IEN of Reaction from S/S file. We say "Q - Don't transform; X - exact match only; Screen on VUID status"
	N RXN S RXN=$$FIND1^DIC(120.83,,"QX",REACTION,"B^D","I '$$SCREEN^XTID(120.83,.01,Y_"","")") ; Get Reaction IEN
	I RXN S ^TMP($J,"ADR","GMRASYMP",1)=RXN_U_REACTION ; Coded reaction
	E  S ^TMP($J,"ADR","GMRASYMP",1)="FT"_U_REACTION ; Free Text Reaction
	;
	N ORY ; Return value 0: success; -1: failure; discarded.
	D UPDATE^GMRAGUI1("",DFN,$NA(^TMP($J,"ADR")))
	K ^TMP($J,"ADR")
	QUIT
