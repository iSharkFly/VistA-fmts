C0XPT3	;ISI/MLS,VEN/SMH -- MEDS IMPORT ;2013-04-19  5:42 PM
	;;1.0;FILEMAN TRIPLE STORE;;Jun 26,2012;Build 29
	; (C) Sam Habiel 2013
	; Proprietary code. Stay out!
	;
MEDS(G,DFN) ; Private Proc; Extract Medication Data from a Patient's Graph
	; G - Patient Graph, DFN - you should know this
	K ^TMP($J,"MEDS")
	D ONETYPE^C0XGET3($NA(^TMP($J,"MEDS")),G,"sp:Medication")
	;
	; PRIVATE TO SAM -- PRIVATE TO SAM -- PRIVATE TO SAM
	; Delete the old drugs for this patient
	N DIK,DA
	S DIK="^PS(55,",DA=DFN D ^DIK ; bye bye
	S DIK="^PSRX(" F DA=0:0 S DA=$O(^PSRX(DA)) Q:'DA  D:$P(^(DA,0),U,2)=DFN ^DIK
	S DIK="^OR(100," F DA=0:0 S DA=$O(^OR(100,DA)) Q:'DA  D:+$P(^(DA,0),U,2)=DFN ^DIK
	; PRIVATE TO SAM -- PRIVATE TO SAM -- PRIVATE TO SAM
	;
	; For each medication (C0XI = COUNTER; S = Medication Node as Subject)
	N C0XI,S F C0XI=0:0 S C0XI=$O(^TMP($J,"MEDS",C0XI)) Q:'C0XI  S S=^(C0XI) DO MED1(G,S,DFN)
	K ^TMP($J,"MEDS")
	QUIT
	;
MED1(G,S,DFN) ; Private Procedure; Process each medication in Graph.
	; G = Graph; S = Medication Description ID as subject.
	;
	; 1. Start Date; obtain and then conv to fileman format
	N STARTDT S STARTDT=$$GSPO1^C0XGET3(G,S,"sp:startDate") ; Duh! Start Date.
	D 
	. N %DT,X,Y S X=STARTDT D ^%DT S STARTDT=Y ; New stack level for variables.
	;
	;DEBUG.ASSERT that STARTDT is greater than 1900
	I STARTDT'>2000000 S $EC=",U1,"
	;
	; 2. Frequency
	N FVALUE S FVALUE=$$GSPO1^C0XGET3(G,S,"sp:frequency.sp:value")
	N FUNIT S FUNIT=$$GSPO1^C0XGET3(G,S,"sp:frequency.sp:unit")
	;
	; 3. Dose Quantity
	; Get value, get unit and strip the braces out.
	N DOSE S DOSE=$$GSPO1^C0XGET3(G,S,"sp:quantity.sp:value")
	N DUNIT S DUNIT=$$GSPO1^C0XGET3(G,S,"sp:quantity.sp:unit"),DUNIT=$TR(DUNIT,"{}")
	;
	; 4. Instructions
	N INST S INST=$$GSPO1^C0XGET3(G,S,"sp:instructions")
	;
	; 5. Drug Name and Code
	N RXN S RXN=$$GSPO1^C0XGET3(G,S,"sp:drugName.sp:code"),RXN=$P(RXN,"/",$L(RXN,"/")) ; RxNorm Code
	N DN S DN=$$GSPO1^C0XGET3(G,S,"sp:drugName.dcterms:title") ; Drug Name
	;
	W S," ",FVALUE_FUNIT," ",DOSE," ",DUNIT," ",INST," ",DN," ",RXN,!
	;
	; 6. Get Fill Dates
	N FULF ; Fulfillments
	D GSPO^C0XGET3($NA(FULF),G,S,"sp:fulfillment")
	;
	N FILLS ; Fills array. Contains every time a drug was dispensed.
	N FILL S FILL="" F  S FILL=$O(FULF(FILL)) Q:FILL=""  D
	. N S S S=FULF(FILL) ; New subject; subsumes above one in this loop
	. ;
	. ; Dispense Date
	. N FILLDATE S FILLDATE=$$GSPO1^C0XGET3(G,S,"dcterms:date")
	. D
	. . N %DT,X,Y S X=FILLDATE D ^%DT S FILLDATE=Y
	. I FILLDATE<2000000 W $EC=",U1," ; Converstion error
	. ;
	. S FILLS(RXN,FILLDATE,"sp:dispenseDaysSupply")=$$GSPO1^C0XGET3(G,S,"sp:dispenseDaysSupply") ; Self Explanatory?
	. ;
	. ; Get quantity value and unit
	. S FILLS(RXN,FILLDATE,"sp:quantityDispensed.sp:value")=$$GSPO1^C0XGET3(G,S,"sp:quantityDispensed.sp:value")
	. S FILLS(RXN,FILLDATE,"sp:quantityDispensed.sp:unit")=$TR($$GSPO1^C0XGET3(G,S,"sp:quantityDispensed.sp:unit"),"{}")
	;
	ZWRITE:$D(FILLS) FILLS
	;
	D 
	. N FILDT,FILQTY,FILDAYS
	. S FILDT=$O(FILLS(RXN,""))
	. I FILDT S FILQTY=FILLS(RXN,FILDT,"sp:quantityDispensed.sp:value"),FILDAYS=FILLS(RXN,FILDT,"sp:dispenseDaysSupply")
	. E  S (FILQTY,FILDAYS)=""
	. D PREP(DFN,RXN,INST,FILDT,FILQTY,FILDAYS,.FILLS)
	;
	QUIT
	;
PREP(DFN,RXN,INST,FILDT,FILQTY,FILDAYS,FILLS) ;
	; TODO: 
	; 1. Resolve medication
	; 2. Figure out what to do with meds that have no fill history (omit?)
	; 3. Don't file a med twice! Check ^PXRMINDX to make sure it aint there first
	; 4. Compute the number of refills for original number so that remaining refills aren't displayed as negative
	; 5. Original fill doesn't have a dispense comment
	; 6. Coded sig (FVALUE, FUNIT, DOSE, DUNIT)
	; 7. Fill label log section of Rx? Maybe not.
	;
	I '$$EXIST^C0CRXNLK(RXN) S $EC=",U1," ; Invalid RxNorm code passed.
	;
	N ORZPT,PSODFN S (ORZPT,PSODFN)=DFN  ;"" ;POINTER TO PATIENT FILE (#2)
	N PNTSTAT S PNTSTAT=20 ; NON-VA ;RX PATIENT STATUS FILE (#53)
	N PROV S PROV=$$NP^C0XPT0() ;NEW PERSON FILE (#200)
	I $$ISBRAND^C0CRXNLK(RXN) S RXN=$$BR2GEN^C0CRXNLK(RXN) ; Get Generic Drug for Brand
	N LOCALDRUG S LOCALDRUG=+$$RXN2MEDS^C0CRXNLK(RXN)
	; I 'LOCALDRUG S LOCALDRUG=$$ADDDRUG^C0CRXNAD(RXN)
	I LOCALDRUG N DIK,DA S DIK="^PSDRUG(",DA=LOCALDRUG D ^DIK
	S LOCALDRUG=$$ADDDRUG^C0CRXNAD(RXN)
	W "(debug) Local Drug IEN: "_LOCALDRUG,!
	N PSODRUG S PSODRUG=LOCALDRUG  ;POINTER TO DRUG FILE (#50) ; TODO: HARDCODED; RXN
	S PSODRUG("DEA")=$P($G(^PSDRUG(PSODRUG,0)),U,3)
	N QTY S QTY=FILQTY ; NUMBER ;0;7 NUMBER (Required)
	N DAYSUPLY S DAYSUPLY=FILDAYS ;NUMBER ; 0;8 NUMBER (Required);
	N REFIL S REFIL=0 ;NUMBER ; 0;9 NUMBER (Required)
	N ORDCONV S ORDCONV=1 ;'1' FOR ORDER CONVERTED;'2' FOR EXPIRATION TO CPRS;
	N COPIES S COPIES=1 ;NUMBER
	N MLWIND S MLWIND="W" ; Mail/Window: 'M' or 'W'
	N ENTERBY S ENTERBY=.5 ;NEW PERSON FILE (#200) - POSTMASTER
	N UNITPRICE S UNITPRICE=$P(^PSDRUG(PSODRUG,660),U,6) ;0.009 ;"" ;NUMBER
	N PSOSITE S PSOSITE=$O(^PS(59,0)) ; OUTPATIENT SITE FILE (#59); get first one
	N %,LOGDT D NOW^%DTC S LOGDT=% ;LOGIN DATE ; 2;1 DATE (Required)
	N FILLDT S FILLDT=FILDT ;DATE; First fill date from our data.
	N ISSDT S ISSDT=FILLDT ;DATE
	N DISPDT S DISPDT=ISSDT ;DATE
	N X D
	. N X1,X2
	. S X1=DISPDT,X2=180 D C^%DTC ;Default expiration of T+180
	N EXPIRDT S EXPIRDT=X ;
	N PORDITM S PORDITM=$P($G(^PSDRUG(PSODRUG,2)),U,1) ;PHARMACY ORDERABLE ITEM FILE (#50.7)
	N STATUS S STATUS=0 ;STA;1 SET (Required) ; '0' FOR ACTIVE;
	N TRNSTYP S TRNSTYP=1 ; IB ACTION TYPE FILE (#350.1)
	N LDISPDT S LDISPDT=FILLDT ;    3;1 DATE
	N REASON S REASON="E" ;Activity log ; SET ([E]dit)
	N INIT S INIT=.5 ;NEW PERSON FILE (#200)
	N SIG S SIG=INST ;#51,.01
	;
CREATE ; fall through
	;
	N PSONEW
	D AUTO^PSONRXN ;RX auto number
	I $G(PSONEW("RX #"))="" S $EC=",U1," ; Auto-numbering not turned on!
	N RXNUM S RXNUM=PSONEW("RX #") ; Rx Number, again...
	;
	L +^PSRX(0):0 ; Lock zero node while we get the record.
	N PSOIEN S PSOIEN=$O(^PSRX(" "),-1)+1 ; Next available IEN
	I $D(^PSRX(PSOIEN)) S $EC=",U1," ; Next number not available. File issue.
	S $P(^PSRX(0),U,3)=PSOIEN ; Reset next available number.
	S $P(^PSRX(PSOIEN,0),"^",1)=RXNUM ; 0;1 FREE TEXT (Required)
	L +^PSRX(PSOIEN):0 ; Lock record node
	L -^PSRX(0) ; Unlock zero node, we now got it
	;
	S $P(^PSRX(PSOIEN,0),"^",13)=ISSDT ; 0;13 DATE (Required)
	S $P(^PSRX(PSOIEN,0),"^",2)=ORZPT ;POINTER TO PATIENT FILE (#2)
	S $P(^PSRX(PSOIEN,0),"^",3)=PNTSTAT ;RX PATIENT STATUS FILE (#53)
	S $P(^PSRX(PSOIEN,0),"^",4)=PROV ;NEW PERSON FILE (#200)
	S $P(^PSRX(PSOIEN,0),"^",5)="" ; Outpatient ; LOC ;HOSPITAL LOCATION FILE (#44)
	S $P(^PSRX(PSOIEN,0),"^",6)=PSODRUG ;POINTER TO DRUG FILE (#50) 
	S $P(^PSRX(PSOIEN,0),"^",7)=QTY ;NUMBER ;0;7 NUMBER (Required)
	S $P(^PSRX(PSOIEN,0),"^",8)=DAYSUPLY ;NUMBER ; 0;8 NUMBER (Required)
	S $P(^PSRX(PSOIEN,0),"^",9)=REFIL ;NUMBER ; 0;9 NUMBER (Required)
	S $P(^PSRX(PSOIEN,0),"^",11)=MLWIND ;'M' or 'W'
	S $P(^PSRX(PSOIEN,0),"^",16)=ENTERBY ;NEW PERSON FILE (#200)
	S $P(^PSRX(PSOIEN,0),"^",17)=UNITPRICE ;NUMBER
	S $P(^PSRX(PSOIEN,0),"^",18)=COPIES ;COPIES
	S $P(^PSRX(PSOIEN,0),"^",19)=ORDCONV ;ORDER CONVERTED        0;19 SET ['1' FOR ORDER CONVERTED;'2' FOR EXPIRATION TO CPRS;]
	;
	S $P(^PSRX(PSOIEN,2),"^",1)=LOGDT ;LOGIN DATE ; 2;1 DATE (Required)
	S $P(^PSRX(PSOIEN,2),"^",2)=FILLDT ;FILL DATE
	;S $P(^PSRX(PSOIEN,2),"^",3)=PHARMACIST ; "" ; PHARMACIST ;2;3 POINTER TO NEW PERSON FILE (#200)
	;S $P(^PSRX(PSOIEN,2),"^",4)="" ; LOT #                  2;4 FREE TEXT
	S $P(^PSRX(PSOIEN,2),"^",5)=DISPDT ; DISPENSED DATE         2;5 DATE (Required)
	S $P(^PSRX(PSOIEN,2),"^",6)=EXPIRDT ;"" ; EXPIRATION DATE
	S $P(^PSRX(PSOIEN,2),"^",9)=PSOSITE ;2;9 POINTER TO OUTPATIENT SITE FILE (#59)
	;
	S $P(^PSRX(PSOIEN,3),U,1)=DISPDT ;LAST DISPENSED DATE    3;1 DATE
	;
	N C0XFILL S C0XFILL=""
	N C0XREFCT S C0XREFCT=0
	F  S C0XFILL=$O(FILLS(RXN,C0XFILL)) Q:C0XFILL=""  D
	. S ^PSRX(PSOIEN,"A",0)="^52.3DA"_U_(C0XREFCT+1)_U_(C0XREFCT+1)
	. S $P(^PSRX(PSOIEN,"A",C0XREFCT+1,0),"^",1)=LOGDT ;DATE
	. S $P(^PSRX(PSOIEN,"A",C0XREFCT+1,0),"^",2)="N" ;SET ; Dispensed using external interface
	. S $P(^PSRX(PSOIEN,"A",C0XREFCT+1,0),"^",3)=INIT ;NEW PERSON FILE (#200)
	. S $P(^PSRX(PSOIEN,"A",C0XREFCT+1,0),"^",4)=0 ;NUMBER - RX REFERENCE
	. S $P(^PSRX(PSOIEN,"A",C0XREFCT+1,0),"^",5)="Imported from Smart"
	. ;
	. Q:C0XFILL=FILDT  ; Don't add refill data for first fill!
	. ;
	. ; Increment counter
	. S C0XREFCT=C0XREFCT+1
	. ;
	. S ^PSRX(PSOIEN,1,0)="^52.1DA"_U_(C0XREFCT)_U_(C0XREFCT)
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",1)=C0XFILL ; REFILL DATE [D]
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",2)=MLWIND  ; MAIL/WINDOW [RS]
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",3)="Imported from Smart" ; REMARKS [F]
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",4)=FILLS(RXN,C0XFILL,"sp:quantityDispensed.sp:value") ; QTY [RNJ12,2X]
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",5)=.5 ; PHARMACIST NAME [*P200']
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",6)="" ; LOT [F]
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",7)=.5 ; CLERK CODE [RP200']
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",8)="" ; LOGIN DATE [D]
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",9)="" ; DIVISION [RP59']
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",17)=PROV ; PROVIDER [R*P200X'I]
	. S $P(^PSRX(PSOIEN,1,C0XREFCT,0),"^",19)=C0XFILL ; DISPENSED DATE [RD]
	;
	S ^PSRX(PSOIEN,"OR1")=PORDITM ;PHARMACY ORDERABLE ITEM FILE (#50.7)
	;
	S $P(^PSRX(PSOIEN,"POE"),"^",1)=1 ; POE RX                 POE;1 SET ['1' FOR YES;]
	;
	S $P(^PSRX(PSOIEN,"SIG"),"^",1)=SIG ;SIG;1 FREE TEXT (Required)  medication instruction DIC(51)
	S $P(^PSRX(PSOIEN,"SIG"),"^",2)=0 ;OERR SIG (SET: 0 for NO; 1 for YES)
	;
	S $P(^PSRX(PSOIEN,"STA"),"^",1)=STATUS ;STA;1 SET (Required) ; '0' FOR ACTIVE;
	;
	;S ^PSRX(PSOIEN,"IB")=TRNSTYP ;COPAY TRANSACTION TYPE   IB ACTION TYPE FILE (#350.1)
	S ^PSRX(PSOIEN,"TYPE")=0 ;TYPE OF RX             TYPE;1 NUMBER
	D OERR(PSOIEN),F55,F52(PSOIEN),F525
	L -PSRX(PSOIEN) ; Unlock record
	Q
	;
OERR(PSOIEN)	;UPDATES OR1 NODE
	;THE SECOND PIECE IS KILLED BEFORE MAKING THE CALL
	S $P(^PSRX(PSOIEN,"OR1"),"^",2)=""
	N PSXRXIEN,STAT,PSSTAT,COMM,PSNOO
	S PSXRXIEN=PSOIEN,STAT="SN",PSSTAT="CM",COMM="",PSNOO="W"
	D EN^PSOHLSN1(PSXRXIEN,STAT,PSSTAT,COMM,PSNOO)
	QUIT
F55	; - File data into ^PS(55)
	;S PSODFN=DFN
	S:'$D(^PS(55,PSODFN,"P",0)) ^(0)="^55.03PA^^"
	F PSOX1=$P(^PS(55,PSODFN,"P",0),"^",3):1 Q:'$D(^PS(55,PSODFN,"P",PSOX1))
	S ^PS(55,PSODFN,"P",PSOX1,0)=PSOIEN,$P(^PS(55,PSODFN,"P",0),"^",3,4)=PSOX1_"^"_($P(^PS(55,PSODFN,"P",0),"^",4)+1)
	S:$P($G(^PSRX(PSOIEN,2)),"^",6) ^PS(55,PSODFN,"P","A",$P($G(^PSRX(PSOIEN,2)),"^",6),PSOIEN)=""
	K PSOX1
	Q
F52(PSOIEN)	;; - Re-indexing file 52 entry
	N DIK,DA S DIK="^PSRX(",DA=PSOIEN D IX1^DIK K DIK
	Q
	;
F525	;UPDATE SUSPENSE FILE
	Q:$G(^PSRX(PSOIEN,"STA"))'=5
	S DA=PSOIEN,X=PSOIEN,FDT=$P($G(^PSRX(PSOIEN,2)),"^",2),TYPE=$P($G(^PSRX(PSOIEN,0)),"^",11)
	S DIC="^PS(52.5,",DIC(0)="L",DLAYGO=52.5,DIC("DR")=".02///"_FDT_";.03////"_$P(^PSRX(PSOIEN,0),"^",2)_";.04////"_TYPE_";.05///0;.06////"_DIV_";2///0" K DD,D0 D FILE^DICN K DD,D0
	Q
	;
ADDDRUG(RXN,NDC,BARCODE) ; Public Proc; Add Drug to Drug File
 ; Input: RXN - RxNorm Semantic Clinical Drug CUI by Value. Required.
 ; Input: NDC - Drug NDC by Value. Optional. Pass in 11 digit format without dashes.
 ; Input: BARCODE - Wand Barcode. Optional. Pass exactly as wand reads minus control characters.
 ; Output: None.
 ;
 ; Prelim Checks
 I '$G(RXN) S $EC=",U1," ; Required
 I $L($G(NDC)),$L(NDC)'=11 S $EC=",U1,"
 ;
 N PSSZ S PSSZ=1    ; Needed for the drug file to let me in!
 ;
 ; If RXN refers to a brand drug, get the generic instead.
 I $$ISBRAND^C0CRXNLK(RXN) S RXN=$$BR2GEN^C0CRXNLK(RXN)
 W !,"(debug) RxNorm is "_RXN,!
 ;
 ; Get first VUID for this RxNorm drug
 N VUID S VUID=+$$RXN2VUI^C0CRXNLK(RXN)
 Q:'VUID
 W "(debug) VUID for RxNorm CUI "_RXN_" is "_VUID,!
 ;
 ; IEN in 50.68
 N C0XVUID ; For Searching Compound Index
 S C0XVUID(1)=VUID
 S C0XVUID(2)=1
 N F5068IEN S F5068IEN=$$FIND1^DIC(50.68,"","XQ",.C0XVUID,"AMASTERVUID")
 Q:'F5068IEN
 W "F 50.68 IEN (debug): "_F5068IEN,!
 ;
 ; FDA Array
 N C0XFDA
 ;
 ; Name, shortened
 S C0XFDA(50,"+1,",.01)=$E($$GET1^DIQ(50.68,F5068IEN,.01),1,40)
 ;
 ; File BarCode as a Synonym for BCMA
 I $L($G(BARCODE)) D
 . S C0XFDA(50.1,"+2,+1,",.01)=BARCODE
 . S C0XFDA(50.1,"+2,+1,",1)="Q"
 ;
 ; Brand Names
 N BNS S BNS=$$RXN2BNS^C0CRXNLK(RXN) ; Brands
 I $L(BNS) N I F I=1:1:$L(BNS,U) D
 . N IENS S IENS=I+2
 . S C0XFDA(50.1,"+"_IENS_",+1,",.01)=$$UP^XLFSTR($E($P(BNS,U,I),1,40))
 . S C0XFDA(50.1,"+"_IENS_",+1,",1)="T"
 ;
 ; NDC (string)
 I $G(NDC) S C0XFDA(50,"+1,",31)=$E(NDC,1,5)_"-"_$E(NDC,6,9)_"-"_$E(NDC,10,11)
 ;
 ; Dispense Unit (string)
 S C0XFDA(50,"+1,",14.5)=$$GET1^DIQ(50.68,F5068IEN,"VA DISPENSE UNIT")
 ;
 ; National Drug File Entry (pointer to 50.6)
 S C0XFDA(50,"+1,",20)="`"_$$GET1^DIQ(50.68,F5068IEN,"VA GENERIC NAME","I")
 ;
 ; VA Product Name (string)
 S C0XFDA(50,"+1,",21)=$E($$GET1^DIQ(50.68,F5068IEN,.01),1,70)
 ;
 ; PSNDF VA PRODUCT NAME ENTRY (pointer to 50.68)
 S C0XFDA(50,"+1,",22)="`"_F5068IEN
 ;
 ; DEA, SPECIAL HDLG (string)
 D  ; From ^PSNMRG
 . N CS S CS=$$GET1^DIQ(50.68,F5068IEN,"CS FEDERAL SCHEDULE","I")
 . S CS=$S(CS?1(1"2n",1"3n"):+CS_"C",+CS=2!(+CS=3)&(CS'["C"):+CS_"A",1:CS)
 . S C0XFDA(50,"+1,",3)=CS
 ;
 ; NATIONAL DRUG CLASS (pointer to 50.605) (triggers VA Classification field)
 S C0XFDA(50,"+1,",25)="`"_$$GET1^DIQ(50.68,F5068IEN,"PRIMARY VA DRUG CLASS","I")
 ;
 ; Right Now, I don't file the following which ^PSNMRG does (cuz I don't need them)
 ; - Package Size (derived from NDC/UPN file)
 ; - Package Type (ditto)
 ; - CMOP ID (from $$PROD2^PSNAPIS)
 ; - National Formulary Indicator (from 50.68)
 ;
 ; Next Step is to kill Old OI if Dosage Form doesn't match
 ; Won't do that here as it's assumed any drugs that's added is new.
 ; This happens at ^PSNPSS
 ;
 ; Next Step: Kill off old doses and add new ones. We need to to that.
 ; TODO: Add doses. Happens at EN1^PSSUTIL.
 N C0XERR,C0XIEN
 D UPDATE^DIE("E","C0XFDA","C0XIEN","C0XERR")
 ;
 S:$D(C0XERR) $EC=",U1,"
 ;
 QUIT C0XIEN(1)
