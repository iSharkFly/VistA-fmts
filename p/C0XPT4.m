C0XPT4 ; VEN/SMH - Encounter Processing;2013-05-03  5:11 PM
 ;;1.0;FILEMAN TRIPLE STORE;
 ; (c) 2013 Sam Habiel
 ; Currently proprietary code. Stay out!!!
 ;
ENC(G,DFN) ; Extract and then process encounters; PEP
	;
	; ---PRIVATE TO SAM---
	D DELALL(DFN) ; Delete all Encounters period...
	; ---PRIVATE TO SAM---
	;
	K ^TMP($J,"ENC") ; data location
	D ONETYPE^C0XGET3($NA(^TMP($J,"ENC")),G,"sp:Encounter") ; extract encounters
	W "Encounters: ",!
	N S F S=0:0 S S=$O(^TMP($J,"ENC",S)) Q:S=""  W S," ",^(S) D  W !
	. N STARTDATE S STARTDATE=$$GSPO1^C0XGET3(G,S,"sp:startDate")
	. S STARTDATE=$$FMDATE(STARTDATE)
	. W " ",STARTDATE
	. D HISTENC(STARTDATE,DFN) ; Historical Encounter Private API
	K ^TMP($J,"ENC") ; data location
	QUIT
	;
	;
FMDATE(STARTDATE) ; Internal to fix start date
	; Replace 00:00:00 with 00:00:01. Fileman doesn't understand null time for midnight except as .24 for yesterday
	; and replace the space with an @ because Fileman needs that to figure out that time comes next after date
	I STARTDATE["00:00:00" S $E(STARTDATE,$L(STARTDATE))=1
	S STARTDATE=$P(STARTDATE," ")_"@"_$P(STARTDATE," ",2)
	; Conv to Fileman
	D
	. N X,Y,%DT
	. S X=STARTDATE,%DT="TS" D ^%DT
	. S STARTDATE=Y
	Q STARTDATE
	;
	;
HISTENC(DATE,DFN,FTLOC,COMMENT) ; Private Proc; Historical Encounter Filing into the VISIT file
	; Input:
	; - DATE: FM DATE of VISIT (Scalar) - Required
	; - DFN (Scalar) - Required
	; - FTLOC: Free Text Location - Optional. Defaults to SMART LOCATION
	; - COMMENT: Free Text Comment - Optional. Defaults to Imported from Smart
	; Output:
	; - Creates V file entries for the historical encounter
	;
	; Handle required and optional variables...
	N X F X="DATE","DFN" I '$D(@X) S $EC=",U1," ; Check for the present of required input variables
	S FTLOC=$G(FTLOC,"SMART LOCATION") ; Get default if not supplied
	S COMMENT=$G(COMMENT,"Imported from Smart") ; ditto
	;
	; Get package name
	N PKG S PKG=$O(^DIC(9.4,"B","FILEMAN TRIPLE STORE",0)) I 'PKG S $EC=",U1,"
	;
	; Source
	N SRC S SRC="FMTS PATIENT IMPORTER"
	;
	; Input Array for $$DATA2PCE
	N C0XDATA
	S C0XDATA("ENCOUNTER",1,"ENC D/T")=DATE
	S C0XDATA("ENCOUNTER",1,"PATIENT")=DFN
	S C0XDATA("ENCOUNTER",1,"HOS LOC")=$$HL^C0XPT0()
	S C0XDATA("ENCOUNTER",1,"SERVICE CATEGORY")="A" ; Ambulatory
	S C0XDATA("ENCOUNTER",1,"OUTSIDE LOCATION")="FROM THE WIDE WORLD"
	S C0XDATA("ENCOUNTER",1,"ENCOUNTER TYPE")="P" ; Primary
	S C0XDATA("PROVIDER",1,"NAME")=$$NP^C0XPT0()
	; Diangosis and procedure necessary so visit will show up in ^SDE.
	S C0XDATA("DX/PL",1,"DIAGNOSIS")=$O(^ICD9("BA","V70.3 ",0))
	S C0XDATA("PROCEDURE",1,"PROCEDURE")=$O(^ICPT("B","99201",0))
	S C0XDATA("PROCEDURE",1,"QTY")=1
	;
	N C0XVISIT,C0XERR ; Visit, Error
	N XQORMUTE S XQORMUTE=1 ; Unwinder: Shut the hell up. Don't execute disabled protocols rather than whining about them.
	N OK S OK=$$DATA2PCE^PXAPI($NA(C0XDATA),PKG,SRC,.C0XVISIT,,,.C0XERR)
	I OK<1 S $EC=",U1,"
	QUIT
	;
	;
DELALL(DFN) ; Private Proc; Delete ALL ALL ALL encounter information for the patient.
	; BE VERY CAREFUL USING THIS...
	; Walk through the C X-Ref for this patient
	N I S I=9000010  ; Hit the VISIT file LAST as some xrefs in other files point to it!
	N DIK,DA
	F  S I=$O(^DIC(I)) Q:I'<9000011  D  ; For each V File...
	. N OR S OR=$$ROOT^DILFD(I,"",0)  ; Open Root for ^DIK
	. N CR S CR=$$ROOT^DILFD(I,"",1)  ; Closed Root for @CR@("C")
	. ; W OR," ",CR ; DEBUG
	. ; W ": " ; DEBUG
	. S DIK=OR ; File root to kill
	. N J S J="" F  S J=$O(@CR@("C",DFN,J)) Q:'J  S DA=J D ^DIK ; each entry to kill
	. ; W ! ; DEBUG
	;
	; Visit file
	N I S I=""
	S DIK="^AUPNVSIT("
	F  S I=$O(^AUPNVSIT("C",DFN,I)) Q:'I  S DA=I D ^DIK ;ditto
	;
	; Outpatient encounter file
	N I S I=""
	; W "SCE: " ; Debug
	S DIK="^SCE(" ; ditto
	F  S I=$O(^SCE("C",DFN,I)) Q:'I  S DA=I D ^DIK ; ditto
	QUIT
	;
	;
TEST ; Test creating an encounter using DATA2PCE^PXAPI
	; Thank you Kevin Muldrum!
	; This code comes from EDP aka EDIS.
	N DFN S DFN=188 ; One of those Ducks
	;S LOC=$$GET^XPAR(DUZ(2)_";DIC(4,","EDPF LOCATION")
	N LOC S LOC=2 ; DR OFFICE
	N EDPKG,EDPSRC,OK,EDPDATA,EDPVISIT,ERR
	S EDPKG=$O(^DIC(9.4,"B","EMERGENCY DEPARTMENT",0))
	S EDPSRC="EDP TRACKING LOG"
	S EDPDATA("ENCOUNTER",1,"PATIENT")=DFN
	S EDPDATA("ENCOUNTER",1,"HOS LOC")=LOC
	S EDPDATA("ENCOUNTER",1,"SERVICE CATEGORY")="A"
	S EDPDATA("ENCOUNTER",1,"ENCOUNTER TYPE")="P"
	S EDPDATA("ENCOUNTER",1,"ENC D/T")=$$NOW^XLFDT
	;
	S EDPDATA("DX/PL",1,"DIAGNOSIS")=$O(^ICD9("BA","V70.3 ",0))
	S EDPDATA("PROCEDURE",1,"PROCEDURE")=$O(^ICPT("B","99201",0))
	S EDPDATA("PROCEDURE",1,"QTY")=1
	S EDPDATA("PROVIDER",1,"NAME")=23
	;
	S OK=$$DATA2PCE^PXAPI("EDPDATA",EDPKG,EDPSRC,.EDPVISIT,23,1,.ERR)
	W OK
	Q
	;
	;
TEST2 ; Test creating an historical event
	;
	N DFN S DFN=188
	N LOC S LOC=1
	N PKG S PKG=$O(^DIC(9.4,"B","FILEMAN TRIPLE STORE",0))
	I 'PKG S $EC=",U1,"
	;
	N SRC S SRC="FMTS TEST"
	;
	N C0XDATA
	S C0XDATA("ENCOUNTER",1,"ENC D/T")=$$NOW^XLFDT
	S C0XDATA("ENCOUNTER",1,"PATIENT")=DFN
	S C0XDATA("ENCOUNTER",1,"SERVICE CATEGORY")="E" ; EVENT
	S C0XDATA("ENCOUNTER",1,"OUTSIDE LOCATION")="FROM THE WIDE WORLD"
	S C0XDATA("ENCOUNTER",1,"ENCOUNTER TYPE")="P" ; Primary
	S C0XDATA("ENCOUNTER",1,"COMMENT")="Testing"
	;
	N OK,C0XVISIT,ERR
	S OK=$$DATA2PCE^PXAPI($NA(C0XDATA),PKG,SRC,.C0XVISIT,,,.ERR)
	QUIT
TEST3 ; Test creating a real event
	;
	N DFN S DFN=190
	N LOC S LOC=$$HL^C0XPT0()
	N PKG S PKG=$O(^DIC(9.4,"B","FILEMAN TRIPLE STORE",0))
	I 'PKG S $EC=",U1,"
	;
	N SRC S SRC="FMTS TEST"
	;
	N C0XDATA
	S C0XDATA("ENCOUNTER",1,"ENC D/T")=$$NOW^XLFDT
	S C0XDATA("ENCOUNTER",1,"PATIENT")=DFN
	S C0XDATA("ENCOUNTER",1,"HOS LOC")=LOC
	S C0XDATA("ENCOUNTER",1,"SERVICE CATEGORY")="A" ; Ambulatory
	S C0XDATA("ENCOUNTER",1,"OUTSIDE LOCATION")="FROM THE WIDE WORLD"
	S C0XDATA("ENCOUNTER",1,"ENCOUNTER TYPE")="P" ; Primary
	S C0XDATA("PROVIDER",1,"NAME")=$$NP^C0XPT0()
	S C0XDATA("DX/PL",1,"DIAGNOSIS")=$O(^ICD9("BA","V70.3 ",0))
	S C0XDATA("PROCEDURE",1,"PROCEDURE")=$O(^ICPT("B","99201",0))
	S C0XDATA("PROCEDURE",1,"QTY")=1
	;
	N OK,C0XVISIT,ERR
	S OK=$$DATA2PCE^PXAPI($NA(C0XDATA),PKG,SRC,.C0XVISIT,,,.ERR)
	;ZWRITE OK,C0XVISIT
	;ZWRITE:$D(ERR) ERR
	QUIT
