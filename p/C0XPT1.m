C0XPT1 ; VEN/SMH - Obtain and Store Problems ;2013-02-19  11:55 AM
 ;;1.1;FILEMAN TRIPLE STORE;;
 ;
PROBLEMS(G,DFN) ; Private EP; Process Problems for a patient graph
 ; Delete existing problems if they are present
 ; PS: This is a risky operation if somebody points to the original data.
 ; PS2: Another idea is just to quit here if Patient has problems already.
 I $D(^AUPNPROB("AC",DFN)) DO  ; Patient already has problems.
 . N DIK S DIK="^AUPNPROB("  ; Global to kill
 . N DA F DA=0:0 S DA=$O(^AUPNPROB("AC",DFN,DA)) Q:'DA  D ^DIK  ; Kill each entry
 ;
 ; Process incoming problems
 N RETURN ; Local return variable. I don't expect a patient to have more than 50 problems.
 D ONETYPE^C0XGET3($NA(RETURN),G,"sp:Problem") ; Get all problems for patient
 N S F S=0:0 S S=$O(RETURN(S)) Q:'S  D  ; For each problem
 . N PROBNM S PROBNM=$$GSPO1^C0XGET3(G,RETURN(S),"sp:problemName") ; Snomed-CT coding info
 . N CODEURL S CODEURL=$$GSPO1^C0XGET3(G,PROBNM,"sp:code") ; Snomed-CT Code URL
 . N TEXT S TEXT=$$GSPO1^C0XGET3(G,PROBNM,"dcterms:title") ; Snomed-CT Code description
 . ;
 . N CODE ; Actual Snomed code rather than URL
 . S CODE=$P(CODEURL,"/",$L(CODEURL,"/")) ; Get last / piece
 . N EXPIEN ; IEN in the EXPESSION file
 . N LEXS ; Return from Lex call
 . D EN^LEXCODE(CODE) ; Lex API
 . S EXPIEN=$P(LEXS("SCT",1),U) ; First match on Snomed CT. Crash if isn't present.
 . ;
 . N STARTDT S STARTDT=$$GSPO1^C0XGET3(G,RETURN(S),"sp:startDate") ; Start Date
 . N X,Y,%DT S X=STARTDT D ^%DT S STARTDT=Y ; Convert STARTDT to internal format
 . D PROBADD(DFN,CODE,TEXT,EXPIEN,STARTDT) ; Add problem to VISTA.
 QUIT
 ;
PROBADD(DFN,CODE,TEXT,EXPIEN,STARTDT) ; Add a problem to a patient's record.
	; Input 
	; DFN - you know what that is
	; CODE - SNOMED code; not used alas; for the future.
	; TEXT - SNOMED Text
	; EXPIEN - IEN of Snomed CT Expression in the Expressions File (757.01)
	; STARTDT - Internal Date of when the problem was first noted.
	;
	; Output:
	; NONE
	; Crash expected if code fails to add a problem.
	;
	;
	;
	N GMPDFN S GMPDFN=DFN ; patient dfn
	;
	; Add unknown provider to database
	N GMPPROV S GMPPROV=$$NP^C0XPT0() ;Smart Provider IEN
	;
	N GMPVAMC S GMPVAMC=$$KSP^XUPARAM("INST") ; Problem Institution. Ideally, the external one. But we are taking a shortcut here.
	;
	N GMPFLD ; Input array
	S GMPFLD(".01")="" ;Code IEN - API will assign 799.9.
	; .02 field (Patient IEN) not used. Pass variable GMPDFN instead.
	S GMPFLD(".03")=DT ;Date Last Modified
	S GMPFLD(".05")="^"_TEXT ;Expression text
	S GMPFLD(".08")=DT ; today's date (entry?)
	S GMPFLD(".12")="A" ;Active/Inactive
	S GMPFLD(".13")=STARTDT ;Onset date
	S GMPFLD("1.01")=EXPIEN_U_TEXT ;^LEX(757.01 ien,descip
	S GMPFLD("1.03")=GMPPROV ;Entered by
	S GMPFLD("1.04")=GMPPROV ;Recording provider
	S GMPFLD("1.05")=GMPPROV ;Responsible provider
	S GMPFLD("1.06")="" ; SERVICE FILE - LEAVE BLANK(#49)
	S GMPFLD("1.07")="" ; Date resolved
	S GMPFLD("1.08")="" ; Clinic (#44)
	S GMPFLD("1.09")=DT ;entry date
	S GMPFLD("1.1")=0 ;Service Connected
	S GMPFLD("1.11")=0 ;Agent Orange exposure
	S GMPFLD("1.12")=0 ;Ionizing radiation exposure
	S GMPFLD("1.13")=0 ;Persian Gulf exposure
	S GMPFLD("1.14")="C" ;Accute/Chronic (A,C)
	S GMPFLD("1.15")="" ;Head/neck cancer
	S GMPFLD("1.16")="" ;Military sexual trauma
	S GMPFLD("10",0)=0 ; Note. No note.
	;
	;
	N DA ; Return variable
	D NEW^GMPLSAVE ; API call
	I '$D(DA) S $EC=",U1," ; Fail here if API fails.
	QUIT
	;
	;
