C0XPT0 ; VEN/SMH - Get patient data and do something about it ;2013-01-25  5:00 PM
 ;;1.1;FILEMAN TRIPLE STORE;;
 ;
 ; Get all graphs
 NEW RETURN
 DO GRAPHS^C0XGET1(.RETURN) ; TODO: Return could be a global due to large data.
 N I S I="" F  S I=$O(RETURN(I)) Q:I=""  D  ; For each IEN
 . N G S G=""  F  S G=$O(RETURN(I,G)) Q:G=""  D  ; For each graph tied to IEN
 . . D PROGRAPH(G) ; Process Graph
 QUIT
 ;
PROGRAPH(G) ; Process Graph (i.e. Patient)
 NEW RETURN
 N DEM S DEM=$$ONETYPE1^C0XGET3(G,"sp:Demographics")
 I DEM="" QUIT
 ;
 ;  PARAM("NAME")=NAME (last name minimal; recommend full name)
 ;  PARAM("GENDER")=SEX
 ;  PARAM("DOB")=DATE OF BIRTH
 ;  PARAM("MRN")=MEDICAL RECORD NUMBER
 ;
 NEW PARAM
 SET PARAM("NAME")=$$NAME(DEM)
 SET PARAM("GENDER")=$$SEX(DEM)
 SET PARAM("DOB")=$$DOB(DEM)
 SET PARAM("MRN")=$$MRN(DEM)
 NEW RETURN
 D ADDPT(.RETURN,.PARAM)
 ZWRITE RETURN
 N DFN S DFN=$P(RETURN(1),U,2)
 D VITALS(G,DFN)
 D PROBLEMS(G,DFN)
 ;
 QUIT
 ;
NAME(DEMID) ; Public $$; Return VISTA name given the Demographics node ID.
 ;
 IF '$DATA(DEMID) SET $EC=",U1," ; Must pass this in.
 ;
 ; Get name node
 NEW NAMENODE SET NAMENODE=$$object^C0XGET1(DEMID,"v:n")
 IF '$L(NAMENODE) SET $EC=",U1," ; Not supposed to happen.
 ;
 ; Get Last name
 NEW FAMILY SET FAMILY=$$object^C0XGET1(NAMENODE,"v:family-name")
 IF '$L(FAMILY) SET $EC=",U1," ; Not supposed to happen
 ;
 ; Get First name
 NEW GIVEN SET GIVEN=$$object^C0XGET1(NAMENODE,"v:given-name")
 IF '$L(GIVEN) SET $EC=",U1," ; ditto
 ;
 ; Get Additional name (?Middle?)
 NEW MIDDLE SET MIDDLE=$$object^C0XGET1(NAMENODE,"v:additional-name")
 ; This is optional of course
 ;
 QUIT $$UP^DILIBF(FAMILY_","_GIVEN_" "_MIDDLE)
 ;
 ;
DOB(DEMID) ; Public $$; Return Timson Date for DOB given the Dem node ID.
 ;
 IF '$DATA(DEMID) SET $EC=",U1," ; Must pass this in.
 ;
 ; Get DOB.
 NEW DOB S DOB=$$object^C0XGET1(DEMID,"v:bday")
 IF '$L(DOB) SET $EC=",U1," ; ditto
 ;
 ; Convert to Timson Date using %DT
 N X,Y,%DT
 S X=DOB
 D ^%DT
 QUIT Y
 ;
 ;
SEX(DEMID) ; Public $$; Return Sex M or F given the demographics node ID.
 ;
 IF '$DATA(DEMID) SET $EC=",U1," ; Must pass this in.
 ;
 ; Get "gender"
 NEW SEX S SEX=$$object^C0XGET1(DEMID,"foaf:gender")
 IF '$L(SEX) SET $EC=",U1," ; ditto
 ;
 ; Convert to internal value
 N SEXABBR ; Sex Abbreviation
 D CHK^DIE(2,.02,,SEX,.SEXABBR) ; Check value and convert to internal
 ;
 IF SEXABBR="^" QUIT "F" ; Unknown sexes will be female (Sam sez so)
 ELSE  QUIT SEXABBR
 ;
 ;
MRN(DEMID) ; Public $$; Return the Medical Record Number given node ID.
 ;
 IF '$DATA(DEMID) SET $EC=",U1," ; Must pass this in.
 ;
 ; Get subject node, then the identifer under it.
 NEW MRNNODE S MRNNODE=$$object^C0XGET1(DEMID,"sp:medicalRecordNumber")
 NEW MRN S MRN=$$object^C0XGET1(MRNNODE,"dcterms:identifier")
 ;
 ; If it doesn't exist, invent one
 I '$L(MRN) S MRN=$R(928749018234)
 QUIT MRN
 ;
ADDPT(RETURN,PARAM) ; Private Proc; Add Patient to VISTA.
 ; Return RPC style return pass by reference. Pass empty.
 ; PARAM passed by reference.
 ; Required elements include:
 ;  PARAM("NAME")=NAME (last name minimal; recommend full name)
 ;  PARAM("GENDER")=SEX
 ;  PARAM("DOB")=DATE OF BIRTH
 ;  PARAM("MRN")=MEDICAL RECORD NUMBER
 ;
 ; Optional elements include:
 ;  PARAM("POBCTY")=PLACE OF BIRTH [CITY]
 ;  PARAM("POBST")=PLACE OF BIRTH [STATE]
 ;  PARAM("MMN")=MOTHER'S MAIDEN NAME
 ;  PARAM("ALIAS",#)=ALIAS NAME(last^first^middle^suffix)^ALIAS SSN
 ;
 ; These elements are calculated:
 ;  PARAM("PRFCLTY")=PREFERRED FACILITY
 ;  PARAM("SSN")=SOCIAL SECURITY NUMBER OR NULL IF NONE
 ;  PARAM("SRVCNCTD")=SERVICE CONNECTED?
 ;  PARAM("TYPE")=TYPE
 ;  PARAM("VET")=VETERAN (Y/N)?
 ;  PARAM("FULLICN")=INTEGRATION CONTROL NUMBER AND CHECKSUM
 ;
 ;TODO: CHECK THAT PATCH DG*5.3*800 is installed for routine VAFCPTAD to add pt.
 ;I '$$PATCH^XPDUTL("DG*5.3*800") D EN^DDIOL("You need to have patch DG*5.3*800 to add patients")
 ;
 ; Crash if required params aren't present
 N X F X="NAME","GENDER","DOB","MRN" S:'$D(PARAM(X)) $EC=",U1,"
 ;
 ; Calculate ICN and its checksum using MRN; then remove MRN.
 S PARAM("FULLICN")=PARAM("MRN")_"V"_$$CHECKDG^MPIFSPC(PARAM("MRN"))
 ;
 ; Get Preferred Facility from this Facility's number.
 S PARAM("PRFCLTY")=$P($$SITE^VASITE(),U,3) ; Must use Station number here for API.
 I 'PARAM("PRFCLTY") S $EC=",U1," ; crash if Facility is not set-up properly.
 ;
 ; No SSN (for now)
 S PARAM("SSN")=""
 ;
 ; Boiler plate stuff below:
 ; TODO: This could be configurable in a File. WV uses "VISTA OFFICE EHR"
 S PARAM("SRVCNCTD")="N"
 S PARAM("TYPE")="NON-VETERAN (OTHER)"
 S PARAM("VET")="N"
 ;
 ; Now for the finish. Add the patient to VISTA (but only adds it to 2 :-()
 D ADD^VAFCPTAD(.RETURN,.PARAM)
 ;
 I +RETURN(1)=-1 S $EC=",U1," ; It failed.
 E  N PIEN S PIEN=$P(RETURN(1),U,2)
 ;
 ; Add to IHS Patient file using Laygo in case it's already there.
 NEW C0XFDA
 SET C0XFDA(9000001,"?+"_PIEN_",",.01)=PIEN
 SET C0XFDA(9000001,"?+"_PIEN_",",.02)=DT
 SET C0XFDA(9000001,"?+"_PIEN_",",.12)=DUZ ;logged in user IEN (e.g. "13")
 SET C0XFDA(9000001,"?+"_PIEN_",",.16)=DT
 DO UPDATE^DIE("",$NAME(C0XFDA))
 I $D(^TMP("DIERR",$J)) S $EC=",U1,"
 ;
 ; Add medical record number.
 NEW IENS S IENS="?+1,"_PIEN_","
 NEW C0XFDA
 SET C0XFDA(9000001.41,IENS,.01)=+$$SITE^VASITE() ; This time, the IEN of the primary site
 SET C0XFDA(9000001.41,IENS,.02)=PARAM("MRN") ; Put Medical Record Number on Station Number
 DO UPDATE^DIE("",$NAME(C0XFDA))
 I $D(^TMP("DIERR",$J)) S $EC=",U1,"
 QUIT
 ;
VITALS(G,DFN) ; Private EP; Process Vitals for a patient graph.
 ; Vital Sign Sets
 K ^TMP($J) ; Global variable. A patient can have 1000 vital sets.
 D GOPS^C0XGET3($NA(^TMP($J,"VS")),G,"sp:VitalSignSet","rdf:type")
 ;
 ; For each Vital Sign Set, grab encounter
 N S F S=0:0 S S=$O(^TMP($J,"VS",S)) Q:S=""  D
 . N ENC S ENC=$$GSPO1^C0XGET3(G,^TMP($J,"VS",S),"sp:encounter")
 . ZWRITE ENC
 ;
 ; D EN1^GMVDCSAV(.RESULT,DATA)
 QUIT
 ;
PROBLEMS(G,DFN) ; Private EP; Process Problems for a patient graph
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
 . ;S EXPIEN=$P(LEXS("SCT",1),U) ; First match on Snomed CT. Crash if isn't present.
 . ;
 . N STARTDT S STARTDT=$$GSPO1^C0XGET3(G,RETURN(S),"sp:startDate") ; Start Date
 . N X,Y,%DT S X=STARTDT D ^%DT S STARTDT=Y ; Convert STARTDT to internal format
 . ZWRITE CODE
 . ZWRITE TEXT
 . ZWRITE STARTDT
 QUIT
PROBADD(DFN,CODE,TEXT,EXPIEN,STARTDT) ; Add a problem to a patient's record.
	; Input - DFN from Symbol Table
	;
	; Output - ISIRC [return code]
	;          ISIRESUL(0)=1
	;          ISIRESUL(1)=IEN
	;
	N GMPDFN S GMPDFN=DFN ; patient dfn
	;
	; Add unknown provider to database
	N C0XFDA,C0XIEN,C0XERR
	S C0XFDA(200,"?+1,",.01)="PROVIDER,UNKNOWN SMART" ; Name
	S C0XFDA(200,"?+1,",1)="USP" ; Initials
	S C0XFDA(200,"?+1,",28)="SMART" ; Mail Code
	D UPDATE^DIE("E",$NA(C0XFDA),$NA(C0XIEN),$NA(C0XERR))
	N GMPPROV S GMPPROV=C0XIEN(1) ;Provider IEN
	;
	N GMPVAMC S GMPVAMC=$$KSP^XUPARAM("INST")
	;
	N GMPFLD
	S GMPFLD(".01")=ISIMISC("ICDIEN") ;Code IEN
	S GMPFLD(".03")=0 ;hard set
	S GMPFLD(".05")="^"_ISIMISC("EXPNM") ;Expression text
	S GMPFLD(".08")=DT ; today's date (entry?)
	S GMPFLD(".12")=ISIMISC("STATUS") ;Active/Inactive
	S GMPFLD(".13")=ISIMISC("ONSET") ;Onset date
	S GMPFLD("1.01")=ISIMISC("EXPIEN")_"^"_ISIMISC("EXPNM") ;^LEX(757.01 ien,descip
	S GMPFLD("1.03")=ISIMISC("PROVIDER") ;Entered by
	S GMPFLD("1.04")=ISIMISC("PROVIDER") ;Recording provider
	S GMPFLD("1.05")=ISIMISC("PROVIDER") ;Responsible provider
	S GMPFLD("1.06")=1018 ;MEDICAL SERVICE (#49)
	S GMPFLD("1.07")="" ; Date resolved
	S GMPFLD("1.08")="" ; Clinic (#44)
	S GMPFLD("1.09")=DT ;entry date
	S GMPFLD("1.1")=0 ;Service Connected
	S GMPFLD("1.11")=0 ;Agent Orange exposure
	S GMPFLD("1.12")=0 ;Ionizing radiation exposure
	S GMPFLD("1.13")=0 ;Persian Gulf exposure
	S GMPFLD("1.14")=ISIMISC("TYPE") ;Accute/Chronic (A,C)
	S GMPFLD("1.15")="" ;Head/neck cancer
	S GMPFLD("1.16")="" ;Military sexual trauma
	S GMPFLD("10",0)=0 ;auto set ""
	D NEW^GMPLSAVE
	I '$D(DA) Q "-1^Error creating problem"
	S ISIRESUL(0)=1
	S ISIRESUL(1)=DA
	Q 1
 ; Example FDA
 ; SAM(9000011,"88,",.01)="410.90"
 ; SAM(9000011,"88,",.02)="RODGERS,RONALD"
 ; SAM(9000011,"88,",.03)="JUN 13,2011"
 ; SAM(9000011,"88,",.04)=""
 ; SAM(9000011,"88,",.05)="Acute myocardial infarction, unspecified site, episode of care unspecified"
 ; SAM(9000011,"88,",.06)="VOE OFFICE INSTITUTION"
 ; SAM(9000011,"88,",.07)=2
 ; SAM(9000011,"88,",.08)="MAY 29,2011"
 ; SAM(9000011,"88,",.12)="INACTIVE"
 ; SAM(9000011,"88,",.13)="MAY 29,2011"
 ; SAM(9000011,"88,",1.01)="Acute myocardial infarction, unspecified site, episode of care unspecified"
 ; SAM(9000011,"88,",1.02)="PERMANENT"
 ; SAM(9000011,"88,",1.03)="COORDINATOR,ONE"
 ; SAM(9000011,"88,",1.04)="COORDINATOR,ONE"
 ; SAM(9000011,"88,",1.05)="COORDINATOR,ONE"
 ; SAM(9000011,"88,",1.06)="MEDICINE"
 ; SAM(9000011,"88,",1.07)="JUN 13,2011"
 ; SAM(9000011,"88,",1.08)=""
 ; SAM(9000011,"88,",1.09)="MAY 29,2011"
 ; SAM(9000011,"88,",1.1)="NO"
 ; SAM(9000011,"88,",1.11)="NO"
 ; SAM(9000011,"88,",1.12)="NO"
 ; SAM(9000011,"88,",1.13)="NO"
 ; SAM(9000011,"88,",1.14)="CHRONIC"
 ; SAM(9000011,"88,",1.15)=""
 ; SAM(9000011,"88,",1.16)=""
 ; SAM(9000011,"88,",1.17)=""
 ; SAM(9000011,"88,",1.18)=""
