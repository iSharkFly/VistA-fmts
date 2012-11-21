C0XMULTI ;GPL - Multi tasking with the triplestore ;3/22/12  17:05
 ;;0.1;C0X;nopatch;noreleasedate;Build 7
 ;Copyright 2011 George Lilly.  Licensed under the terms of the GNU
 ;General Public License See attached copy of the License.
 ;
 ;This program is free software; you can redistribute it and/or modify
 ;it under the terms of the GNU General Public License as published by
 ;the Free Software Foundation; either version 2 of the License, or
 ;(at your option) any later version.
 ;
 ;This program is distributed in the hope that it will be useful,
 ;but WITHOUT ANY WARRANTY; without even the implied warranty of
 ;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ;GNU General Public License for more details.
 ;
 ;You should have received a copy of the GNU General Public License along
 ;with this program; if not, write to the Free Software Foundation, Inc.,
 ;51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 ;
 Q
 ;
INIT ; initialize control queues
 ;
 K ^TMP("RXMISSINGTOTAL")
 K ^TMP("RXFOUNDTOTAL")
 K ^TMP("C0X","LOADPV")
 ;
 N C0XPATDM
 D subjects^C0XGET1(.C0XPATDM,"sage:patientLegacyAccountNumber") ; all patient subjects
 K ^TMP("C0X","LOADPV")
 M ^TMP("C0X","LOADPV","HOLD")=C0XPATDM
 S ^TMP("C0X","LOADPV","COUNT","HOLD")=$$COUNT^JJOHMMUT(.C0XPATDM)
 S ^TMP("C0X","LOADPV","THROTTLE")=1000
 Q
 ;
MINUS(PLACE)
 ;
 ;L +$NA(@PLACE),1
 I $G(@PLACE)'<1 D  ; 
 . S @PLACE=@PLACE-1
 ;L -$NA(@PLACE)
 Q
 ;
PLUS(PLACE)
 ;
 ;L +$NA(@PLACE),1
 S @PLACE=$G(@PLACE)+1
 ;L -$NA(@PLACE)
 Q
 ;
H2Q(NUM) ; PUT A BATCH OF ITEMS FROM HOLD TO QUEUE
 N ZI,ZJ
 F ZI=1:1:NUM D  ;
 . S ZJ=$O(^TMP("C0X","LOADPV","HOLD",""))
 . I ZJ="" Q  ; NO MORE
 . K ^TMP("C0X","LOADPV","HOLD",ZJ) ; REMOVE FROM HOLD
 . S ^TMP("C0X","LOADPV","QUEUE",ZJ)="" ; ADD TO QUEUE
 . N GN
 . S GN=$NA(^TMP("C0X","LOADPV","COUNT","HOLD"))
 . D MINUS(GN)
 . S GN=$NA(^TMP("C0X","LOADPV","COUNT","QUEUE"))
 . D PLUS(GN)
 Q
 ;
Q2R() ; return a patient to run
 ;
 N ZZ,ZP
 S ZZ=$O(^TMP("C0X","LOADPV","QUEUE",""))
 I ZZ="" Q "" ; no more
 K ^TMP("C0X","LOADPV","QUEUE",ZZ) ; remove from queue queue
 S ZP=$NA(^TMP("C0X","LOADPV","COUNT","QUEUE"))
 D MINUS(ZP) ; DECREMENT QUEUE COUNT
 S ^TMP("C0X","LOADPV","RUN",ZZ)="" ;add to run queue
 S ZP=$NA(^TMP("C0X","LOADPV","COUNT","RUN"))
 D PLUS(ZP) ; increment Run count
 Q ZZ
 ;
R2D(ZWHAT) ; MOVE ZWHAT FROM RUN QUEUE TO DONE QUEUE
 K ^TMP("C0X","LOADPV","RUN",ZWHAT)
 S ^TMP("C0X","LOADPV","DONE",ZWHAT)=""
 S GN=$NA(^TMP("C0X","LOADPV","COUNT","DONE"))
 D PLUS(GN)
 S GN=$NA(^TMP("C0X","LOADPV","COUNT","RUN"))
 D MINUS(GN)
 Q
 ;
ZTLOAD ; take items out of hold and start up taskman jobs to process
 ; use throttle to know how many
 N ZMAX
 S ZMAX=$G(^TMP("C0X","LOADPV","THROTTLE"))
 I +ZMAX=0 D  ;
 . S ^TMP("C0X","LOADPV","THROTTLE")=100
 . S ZMAX=100
 N COUNTS
 M COUNTS=^TMP("C0X","LOADPV","COUNT")
 I COUNTS("HOLD")=0 Q  ; 
 N ZADDS
 S ZADDS=ZMAX-$G(COUNTS("QUEUE"))-$G(COUNTS("RUN"))
 W !,"ZADDS=",ZADDS
 I ZADDS>0 D  ;
 . D H2Q(ZADDS) ; move some new items from hold to queue
 . D LAUNCH(ZADDS)
 Q
 ;
LAUNCH(ZADDS) ; launch ZADDS number of workers in taskman
 N ZJ
 F ZJ=1:1:ZADDS D  ;
 . N C0XST
 . S C0XST("ZTDTH")=$H ; force it to start now
 . W !,$$NODEV^XUTMDEVQ("EN^JJOHMMP5","LOADPV",,.C0XST,1) ; 
 . ; add a bunch of new taskman tasks
 Q
 ;
SHOW ;
 ZWR ^TMP("C0X","LOADPV","THROTTLE")
 ZWR ^TMP("C0X","LOADPV","COUNT",*)
 Q
 ;
EN ; load patient viewer from batch job.. one at a time
 ;
 S C0XPVFN=172.901 ; file number for patient viewer file
 S C0XALFN=172.9011 ; allergy subfile number
 S C0XPRFN=172.9012 ; problem subfile number
 S C0XMDFN=172.9013 ; medication subfile number
 S C0XIMFN=172.9014 ; immunization subfile number
 S C0XNTFN=172.9016 ; notes subfile number
 S C0XLBFN=172.9018 ; lab subfile number
 S C0XVTFN=172.9019 ; vitals subfile number
 S C0XIDFN=172.9015 ; identifier subfile number
 S C0XDEFN=172.9017 ; demographics subfile number
 N C0XPATDM ; array of patient demographics pointers
 S C0XPATDM=$NA(^TMP("C0X","LOADPV"))
 N C0XPAT ; current patient
 S C0XPAT=$$Q2R ; POP A PATIENT OFF THE QUEUE TO RUN
 I C0XPAT="" Q  ; no more to process
 ;
 ; create the processing control table
 S C0XTYPE("personal")="D PTALGY^JJOHMMP4" ; allergy type
 S C0XTYPE("patprob")="D PTPROB^JJOHMMP4" ; problem type
 S C0XTYPE("patrx")="D PTMED^JJOHMMP4" ; medications type
 S C0XTYPE("catalog")="D PTNOTES^JJOHMMP4" ; notes type
 S C0XTYPE("vitalsigns")="D PTVITAL^JJOHMMP4" ; vitals type
 S C0XTYPE("vacination")="D PTIMMUN^JJOHMMP4" ; immunizations type
 ;
 ;I '$D(C0XPATDM) B  ;
 ;N ZI S ZI=""
 ;F  S ZI=$O(C0XPATDM(ZI)) Q:ZI=""  D  ;
 S ZI=C0XPAT
 D  ; process one patient
 . N C0XDEMOS
 . D triples^C0XGET1(.C0XDEMOS,ZI,,,,"raw") ; get patient demographics
 . N C0XNAME
 . S C0XNAME=$$PTNAME^JJOHMMP4(.C0XDEMOS,ZI)
 . S C0XPAT=$G(C0XDEMOS(ZI,"sage:patientLegacyAccountNumber"))
 . I C0XPAT="" D  Q  ;
 . . W !,"Error finding Patient Pointer",ZI
 . N C0XINDX ; index of patient clinical subrecords
 . D subjects^C0XGET1(.C0XINDX,,C0XPAT)
 . N DOYN S DOYN=0 ; default is don't process this patient
 . N C0XPROC ; clinical records to process
 . N ZJ S ZJ=""
 . F  S ZJ=$O(C0XINDX(ZJ)) Q:ZJ=""  D  ;
 . . N ZTYPE
 . . S ZTYPE=$$object^C0XGET1(ZJ,"rdf:type")
 . . I '$D(C0XTYPE(ZTYPE)) D  Q  ; type not supported
 . . . W !,"SKIPPING: ",ZTYPE
 . . S C0XPROC(ZJ,ZTYPE)=""
 . . W !,"FOUND: ",ZTYPE," ",ZJ,!
 . . S DOYN=1
 . Q:DOYN=0 ; didn't find any clinical data to add
 . K C0XFDA
 . S C0XFDA(C0XPVFN,"?+1,",.01)=C0XNAME
 . D UPDIE^JJOHMMP4 ; create the patient record in the Patient Viewer if not there
 . N C0XIEN
 . S C0XIEN=$O(^C0XVPV(172.901,"B",C0XNAME,""))
 . I C0XIEN="" D  Q  ;
 . . W !,"PROBLEM WITH THE B CROSS REFERENCE.. TOO SMALL"
 . . B
 . D PATIENT^JJOHMMP4 ; process demographics
 . ; COMMENT OUT THE NEXT TWO LINES TO DO A FULL LOAD
 . ; THIS WILL ONLY LOAD THE DEMOGRAPHICS
 . D R2D(ZI) ; 
 . Q
 . ; END DEMO ONLY FIX
 . S ZJ=""
 . F  S ZJ=$O(C0XPROC(ZJ)) Q:ZJ=""  D  ;
 . . N C0XARY
 . . d triples^C0XGET1(.C0XARY,ZJ,,,,"raw")
 . . I '$D(C0XARY) B  ; 
 . . S ZSUB=ZJ
 . . X C0XTYPE($O(C0XPROC(ZJ,"")))
 D R2D(ZI) ; mark this patient as done
 Q
 ;
INDEX(ZIEN,ZN,ZG,ZS,ZP,ZO) ; HARD SET THE INDEX FOR ONE ENTRY
 S C0X(101,"B",ZN,ZIEN)="" ; the B index
 S C0X(101,"G",ZG,ZIEN)="" ; the G for Graph index
 S C0X(101,"SPO",ZS,ZP,ZO,ZIEN)=""
 S C0X(101,"SOP",ZS,ZO,ZP,ZIEN)=""
 S C0X(101,"OPS",ZO,ZP,ZS,ZIEN)=""
 S C0X(101,"OSP",ZO,ZS,ZP,ZIEN)=""
 S C0X(101,"PSO",ZP,ZS,ZO,ZIEN)=""
 S C0X(101,"POS",ZP,ZO,ZS,ZIEN)=""
 ;S ^C0X(101,"GOPS",ZG,ZO,ZP,ZS,ZIEN)=""
 ;S ^C0X(101,"GOSP",ZG,ZO,ZS,ZP,ZIEN)=""
 ;S ^C0X(101,"GPSO",ZG,ZP,ZS,ZO,ZIEN)=""
 ;S ^C0X(101,"GPOS",ZG,ZP,ZO,ZS,ZIEN)=""
 ;S ^C0X(101,"GSPO",ZG,ZS,ZP,ZO,ZIEN)=""
 ;S ^C0X(101,"GSOP",ZG,ZS,ZO,ZP,ZIEN)=""
 Q
 ;
REINDX ; reindex pa
 Q
 ;
NOTES ; user the browser instead of listman
 N PAT
 S DIC=172.901,DIC(0)="AEMQ" D ^DIC
 I Y<1 Q  ; 
 S PAT=$P(Y,U,1)
 D LIST^DIC(172.9016,","_PAT_",","1;2;3;") ; get title, date and file names
 N ZI S ZI=0
 N GN,ZARY,ZN
 S ZN=0
 S DIR(0)="SO^"
 S GN=$NA(^TMP("DILIST",$J,"ID"))
 F  S ZI=$O(@GN@(ZI)) Q:ZI=""  D  ;
 . S ZN=ZN+1
 . S ZARY(ZN)=@GN@(ZI,3)
 . S DIR(0)=DIR(0)_ZI_":"_@GN@(ZI,3)_";"
 . S DIR("L",ZN)=ZN_" "_@GN@(ZI,1)_" SAGE "_@GN@(ZI,2)_" "_@GN@(ZI,3)
 S DIR("L")=""
 I ZN=0 Q  ;
 D ^DIR
 I +Y<1 Q  ;
 N ZNOTE,ZTMP,ZSIZE
 S ZNOTE=$NA(^TMP("C0XPV",$J))
 K @ZNOTE
 D IMPORT^JJOHMMUT(ZARY(Y),"ZTMP")
 N ZN S ZN=0
 S ZI=""
 F  S ZI=$O(ZTMP(ZI)) Q:ZI=""  D  ;
 . S ZN=ZN+1
 . S @ZNOTE@(ZN,0)=ZTMP(ZI)
 . S ZSIZE=ZN
 ;S ZSIZE=$O(@ZNOTE@(""),-1)
 S $P(@ZNOTE@(0),U,4)=ZSIZE
 D WP^VALM(ZNOTE,ZARY(Y))
 Q
 ;
NOTES2 ; 
 N PAT
 S DIC=172.901,DIC(0)="AEMQ" D ^DIC
 I Y<1 Q  ; 
 S PAT=$P(Y,U,1)
 D LIST^DIC(172.9016,","_PAT_",","1;2;3;") ; get title, date and file names
 N ZI S ZI=""
 N GN,ZARY,ZN
 S ZN=0
 S DIR(0)="SO^"
 S GN=$NA(^TMP("DILIST",$J,"ID"))
 F  S ZI=$O(@GN@(ZI)) Q:ZI=""  D  ;
 . S ZN=ZN+1
 . S ZARY(ZN)=@GN@(ZI,3)
 . S DIR(0)=DIR(0)_ZI_":"_@GN@(ZI,3)_";"
 . S DIR("L",ZN)=ZN_" "_@GN@(ZI,1)_" SAGE "_@GN@(ZI,2)_" "_@GN@(ZI,3)
 I ZN=0 D  Q  ;
 . W !,"NO NOTES FOR THIS PATIENT"
 S DIR("L")=""
 D ^DIR
 I Y<1 Q  ;
 N ZNOTE,ZTMP,ZSIZE
 S ZNOTE=$NA(^TMP("C0XPV",$J))
 K @ZNOTE
 D IMPORT^JJOHMMUT(ZARY(Y),"ZTMP")
 S ZSIZE=$O(ZTMP(""),-1)
 ;S $P(@ZNOTE@(0),U,4)=ZSIZE
 N ZJ S ZJ=""
 N ZN S ZN=0
 F  S ZJ=$O(ZTMP(ZJ)) Q:ZJ=""  D  ;
 . S ZN=ZN+1
 . S @ZNOTE@(ZN)=$$CLEAN(ZTMP(ZJ))
 D BROWSE^DDBR(ZNOTE,"N",ZARY(Y))
 Q
 ;
BROWSE ;
 N I,ZNOTE
 S ZNOTE=$NA(^TMP("C0XPV",$J))
 F I=1:1:300 S @ZNOTE@(I)="THIS IS LINE "_I
 D BROWSE^DDBR(ZNOTE,"N","GPLTEST")
 Q
 ;
CLEAN(ZX) ; extrinsic cleans one line of text
 N X,Y
 S X=ZX
 I $E(X,1,5)="bodyg" D  ;
 . S $E(X,1,6)="" ; get rid of bodygx at the beginning of the line
 . N XX S XX=$E(X,1,1)
 . I ($A(XX)>47)&($A(XX)<58) S $E(X,1,1)=""
 I $E(X,1,4)="body" S $E(X,1,4)=""
 I $E(X,1,5)="ebody" S $E(X,1,5)=""
 N ZI F ZI=1:1:$L(X) D  ;
 . I $A($E(X,ZI,ZI))<32 S $E(X,ZI,ZI)="*"
 . I $A($E(X,ZI,ZI))>126 S $E(X,ZI,ZI)="*"
 Q X
 ;
