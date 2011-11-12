C0XF2N ; GPL - Fileman Triples entry point routine ;10/13/11  17:05
 ;;0.1;C0X;nopatch;noreleasedate;Build 5
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
 ; This is based on C0XMAIN but experiments with a fast load for triples
 ; that will write directly to the fileman global
 ; The file 172.101 is a F2N design style for triples, which means
 ; that it is a Flat file with no subfiles, all fields at the root
 ; ... it is a "2" file solution which means all strings are stored in
 ; ...    strings file and pointed to by the triples file
 ; ... it is an N file because it has generated Node IDs instead of
 ; ...   DINUM which would use the IEN for the Node ID.
 ; gpl 11/04/2011
 ;
INITFARY(ZFARY) ; INITIALIZE FILE NUMBERS AND OTHER USEFUL THINGS
 ; FOR THE DEFAULT TRIPLE STORE. USE OTHER VALUES FOR SUPPORTING ADDITIONAL
 ; TRIPLE STORES
 I $D(@ZFARY) Q  ; ALREADY INITIALIZED
 S @ZFARY@("C0XTFN")=172.101 ; TRIPLES FILE NUMBER
 S @ZFARY@("C0XSFN")=172.201 ; TRIPLES STRINGS FILE NUMBER
 S @ZFARY@("C0XTN")=$NA(^C0X(101)) ; TRIPLES GLOBAL NAME
 S @ZFARY@("C0XSN")=$NA(^C0X(201)) ; STRING FILE GLOBAL NAME
 S @ZFARY@("C0XDIR")="/home/glilly/fmts/trunk/samples/"
 S @ZFARY@("BLKLOAD")=1 ; this file supports block load
 S @ZFARY@("FMTSSTYLE")="F2N" ; fileman style
 D USEFARY(ZFARY)
 Q
 ;
USEFARY(ZFARY) ; INITIALIZES VARIABLES SAVED IN ARRAY ZFARY
 N ZI S ZI=""
 F  S ZI=$O(@ZFARY@(ZI)) Q:ZI=""  D  
 . ;N ZX
 . S ZX="S "_ZI_"="""_@ZFARY@(ZI)_""""
 . ;W !,ZX
 . X ZX
 Q
 ;
FILEIN ; INTERACTIVE ENTRY POINT FOR OPTION TO READ IN A FILE
 I '$D(C0XFARY) D INITFARY("C0XFARY")
 D USEFARY("C0XFARY")
 S DIR(0)="F^3:240"
 S DIR("A")="File Directory"
 S DIR("B")=C0XDIR
 D ^DIR
 I Y="^" Q  ;
 S C0XDIR=Y
 S C0XFARY("C0XDIR")=Y
 S DIR(0)="F^3:240"
 S DIR("A")="File Name"
 I '$D(C0XFN) S DIR("B")="qds.rdf"
 E  S DIR("B")=C0XFN
 D ^DIR
 I Y="" Q  ;
 I Y="^" Q  ;
 S C0XFN=Y
 D IMPORT(C0XFN,C0XDIR,,"C0XFARY")
 K C0XFDA
 Q
 ;
IMPORT(FNAME,INDIR,INURL,FARY) ; EXTRINSIC THAT READS A FILE FROM THE STANDARD 
 ; DIRECTORY, LOADS IT INTO THE TRIPLESTORE AS TEXT, AND RETURNS THE
 ; NODE NAME OF THE TEXT TRIPLE
 ; INDIR IS THE OPTIONAL DIRECTORY (DEFAUTS TO STANDARD DIR)
 ; INURL IS THE OPTIONAL URI FOR ACCESSING THE FILE FROM THE TRIPLE STORE
 ; FARY IS THE OPTIONAL FILE ARRAY OF THE TRIPLE STORE TO USE
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 D USEFARY(FARY)
 N ZD,ZTMP
 I '$D(INDIR) S INDIR=C0XDIR ; DIRECTORY OF THE RDF FILE
 I $G(INURL)="" D  ;
 . ;N ZN2 S ZN2=$P(FNAME,".",1)_"_"_$P(FNAME,".",2) ; REMOVE THE DOT 
 . ;S INURL=FDIR_ZN2
 . S INURL=INDIR_FNAME
 N ZTMP
 S ZTMP=$NA(^TMP("C0X",$J,"FILEIN",1)) ; WHERE TO PUT THE INCOMING FILE
 K @ZTMP ; MAKE SURE IT'S CLEAR
 S C0XSTART=$$NOW^XLFDT
 W !,"STARTED: ",C0XSTART
 W !,"READING IN: ",FNAME
 I '$$FILEREAD(ZTMP,INDIR,FNAME,4) D  Q  ; QUIT IF NO SUCCESS
 . W !,"ERROR READING FILE: ",INDIR,FNAME 
 S ZRDF=$NA(^TMP("C0X",$J,"FILEIN")) ; WITHOUT THE SUBSCRIPT
 W !,$O(@ZRDF@(""),-1)," LINES READ"
 D INSRDF(ZRDF,INURL,FARY) ; IMPORT AND PROCESS THE RDF
 K INURL
 K C0XFDA
 K ^TMP("MXMLDOM",$J)
 Q
 ;
WGET(ZURL,FARY) ; GET FROM THE INTERNET AN RDF FILE AND INSERT IT
 ;
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 D USEFARY(FARY)
 ;N ZLOC,ZTMP
 K ZTMP
 S ZLOC=$NA(^TMP("C0X","WGET",$J))
 K @ZLOC
 S C0XSTART=$$NOW^XLFDT
 W !,"STARTED: ",C0XSTART
 W !,"DOWNLOADING: ",ZURL
 S OK=$$httpGET^%zewdGTM(ZURL,.ZTMP)
 M @ZLOC=ZTMP
 S C0XLINES=$O(@ZLOC@(""),-1)
 W !,C0XLINES," LINES READ"
 S C0XDLC=$$NOW^XLFDT ; DOWNLOAD COMPLETE
 W !,"DOWNLOAD COMPLETE AT ",C0XDLC
 S C0XDIFF=$$FMDIFF^XLFDT(C0XDLC,C0XSTART,2)
 W !," ELAPSED TIME: ",C0XDIFF," SECONDS"
 I C0XDIFF'=0  W !," APPROXIMATELY ",$P(C0XLINES/C0XDIFF,".")," LINES PER SEC"
 D INSRDF(ZLOC,ZURL,FARY)
 Q
 ;
INSRDF(ZRDF,ZNAME,FARY) ; INSERT AN RDF FILE INTO THE STORE AND PROCESS
 ; ZRDF IS PASSED BY NAME
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 D USEFARY(FARY)
 S BATCNT=0 ; BATCH COUNTER
 S BATMAX=10000 ; TRY BATCHES OF THIS SIZE
 N ZGRAPH,ZSUBJECT
 S ZGRAPH="_:G"_$$LKY9 ; RANDOM GRAPH NAME
 S ZSUBJECT=$$ANONS ; RANDOM ANOYMOUS SUBJECT
 D ADD(ZGRAPH,ZSUBJECT,"fmts:url",ZNAME,FARY)
 N ZTXTNM
 S ZTXTNM="_TXT_INCOMING_RDF_FILE_"_ZNAME_"_"_$$LKY9 ; NAME FOR TEXT NODE
 D ADD(ZGRAPH,ZSUBJECT,"fmts:rdfSource",ZTXTNM,FARY)
 D SWUPDIE(.C0XFDA) ; TRY IT OUT
 K C0XCNT ;RESET FOR NEXT TIME
 D STORETXT(ZRDF,ZTXTNM,FARY)
 W !,"ADDED: ",ZGRAPH," ",ZSUBJECT," fmts:rdfSource ",ZTXTNM
 D PROCESS(.G,ZRDF,ZNAME,ZGRAPH,FARY) ; PARSE AND INSERT THE RDF
 Q
 ;
STORETXT(ZTXT,ZNAME,FARY) ; STORE TEXT IN THE TRIPLESTORE AT ZNAME
 ;
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 D USEFARY(FARY)
 N ZIEN
 S ZIEN=$$IENOF(ZNAME,FARY) ; GET THE IEN
 D CLEAN^DILF
 K ZERR
 D WP^DIE(C0XSFN,ZIEN_",",1,,ZTXT,"ZERR")
 I $D(ZERR) D  ;
 . ZWR ZERR
 Q
 ; 
GETTXT(ZRTN,ZNAME,FARY) ; RETURNS RDF SOURCE OR OTHER TEXT
 ; ZRTN IS PASSED BY REFERENCE
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 D USEFARY(FARY)
 N ZIEN
 S ZIEN=$$IENOF(ZNAME)
 S OK=$$GET1^DIQ(C0XSFN,ZIEN_",",1,,"ZRTN")
 Q
 ;
WHERETXT(ZNAME,FARY) ; EXTRINSIC WHICH RETURNS THE NAME OF THE GLOBAL
 ; WHERE THE TEXT IS LOCATED. NAME IS THE NAME OF THE STRING
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 D USEFARY(FARY)
 N ZIEN
 S ZIEN=$$IENOF(ZNAME)
 Q $NA(@C0XSN@(ZIEN,1))
 ;
FILEREAD(ZINTMP,ZDIR,ZFNAME,ZLVL) ; READS A FILE INTO ZINTMP USING FTG^%ZISH
 ; ZINTMP IS PASSED BY NAME AND INCLUDES THE NEW SUBSCRIPT
 ; IE ^TMP("C0X","FILEIN",1)
 ; ZLVL IN THIS CASE WOULD BE 3 INCREMENTING THE 1
 ; EXTRINSIC WHICH RETURNS THE RESULT OF FTG^%ZISH
 S OK=$$FTG^%ZISH(ZDIR,FNAME,ZINTMP,ZLVL)
 Q OK
 ;
TESTPROC ; TEST PROCESS WITH EXISTING SMALL RDF FILE
 S ZIN=$NA(^TMP("C0X",12226,"FILEIN"))
 S ZGRAPH="/test/rdfFile"
 S ZM="/test/rdfFile/meta"
 D PROCESS(.G,ZIN,ZGRAPH,ZM)
 Q
 ;
PROCESS(ZRTN,ZRDF,ZGRF,ZMETA,FARY) ; PROCESS AN INCOMING RDF FILE
 ; ZRTN IS PASS BY REFERENCE AND RETURNS MESSAGES ABOUT THE PROCESSING
 ; ZRDF IS PASSED BY NAME AND IS THE GLOBAL CONTAINING THE RDF FILE
 ; ZGRF IS THE NAME OF THE GRAPH TO USE IN THE TRIPLE STORE FOR RESULTS
 ; ZMETA IS OPTIONAL AND IS THE NAME OF THE GRAPH TO STORE METADATA
 ;
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 D USEFARY(FARY)
 ;N BATCNT
 ;N BATMAX
 ; -- first parse the rdf file with the MXML parser
 ;S C0XDOCID=$$PARSE^C0CNHIN(ZRDF,"C0XARRAY") ; PARSE WITH MXML
 S C0XDLC2=$$NOW^XLFDT ; START OF PARSE
 S C0XDOCID=$$EN^MXMLDOM(ZRDF,"W")
 K @ZRDF ; DON'T NEED INPUT BUFFER ANYMORE
 ; -- assign the MXLM dom global name to ZDOM
 S ZDOM=$NA(^TMP("MXMLDOM",$J,C0XDOCID))
 S C0XNODE=$O(@ZDOM@(""),-1)
 W !,C0XNODE," XML NODES PARSED"
 S C0XPRS=$$NOW^XLFDT ; PARSE COMPLETE
 W !,"PARSE COMPLETE AT ",C0XPRS
 S C0XDIFF=$$FMDIFF^XLFDT(C0XPRS,C0XDLC2,2)
 W !," ELAPSED TIME: ",C0XDIFF," SECONDS"
 I C0XDIFF'=0 D  ;
 . W !," APPROXIMATELY ",$P(C0XNODE/C0XDIFF,".")," NODES PER SECOND"
 ; -- populate the metagraph to point to the graph with status unfinished
 S METAS=$$ANONS ; GET AN ANONOMOUS RANDOM SUBJECT
 I '$D(ZMETA) S ZMETA="_:G"_$$LKY9 ; RANDOM GRAPH NAME FOR METAGRAPH
 D ADD(ZMETA,METAS,"fmts:about",ZGRF,FARY) ; POINT THE META TO THE GRAPH
 D ADD(ZMETA,METAS,"fmts:status","unfinished",FARY) ; mark as unfinished
 W !,"INSERTING GRAPH: ",ZGRF
 ;S C0XDATE=$$FMDTOUTC^C0CUTIL($$NOW^XLFDT,"DT")
 S C0XDATE=$$NOW^XLFDT
 D ADD(ZMETA,METAS,"fmts:dateTime",C0XDATE,FARY)
 D SWUPDIE(.C0XFDA) ; commit the metagraph changes to the triple store
 ; -- 
 ; -- pull out the vocabularies in the RDF statement. marked with xmlns:
 ; -- put them in a local variable for quick reference
 ; -- TODO: create a graph for vocabularies and validate incoming against it
 ;
 S C0XVOC=""
 N ZI,ZJ,ZK S ZI=""
 F  S ZI=$O(@ZDOM@(1,"A",ZI)) Q:ZI=""  D  ; FOR EACH xmlns
 . S ZVOC=$P(ZI,"xmlns:",2)
 . I ZVOC'="" S C0XVOC(ZVOC)=$G(@ZDOM@(1,"A",ZI))
 ;W !,"VOCABS:" ZWR C0XVOC
 ;
 ; -- look for children called rdf:Description. quit if none. not an rdf file
 ;
 S ZI=$O(@ZDOM@(1,"C",""))
 I $G(@ZDOM@(1,"C",ZI))'="rdf:Description" D  Q  ; not an rdf file
 . W !,"Error. Not an RDF file. Cannot process."
 ;
 ; -- now process the rdf description children
 ;
 S ZI=""
 S (C0XSUB,C0XPRE,C0XOBJ)="" ; INITIALIZE subject, object and predicate
 F  S ZI=$O(@ZDOM@(1,"C",ZI)) Q:ZI=""  D  ;
 . ; -- we are skipping any child that is not rdf:Description
 . ; -- TODO: check to see if this is right in general
 . ;
 . IF $G(@ZDOM@(1,"C",ZI))'="rdf:Description" D  Q  ;
 . . W !,"SKIPPING NODE: ",ZI
 . ; -- now looking for the subject for the triples
 . S ZX=$G(@ZDOM@(ZI,"A","rdf:about"))
 . I ZX'="" D  ; we have the subject
 . . ;W " about: ",ZX
 . . S C0XSUB=ZX
 . E  D  ;
 . . S ZX=$G(@ZDOM@(ZI,"A","rdf:nodeID")) ; node id is another style of subject
 . . I ZX'="" D  ;
 . . . S C0XSUB=ZX
 . I C0XSUB="" S C0XSUB=$$ANONS ; DEFAULT TO BLANK SUBJECT
 . ; 
 . ; -- we now have the subject. the children of this node have the rest
 . ;
 . S ZJ="" ; for the children of the rdf:Description nodes
 . F  S ZJ=$O(@ZDOM@(ZI,"C",ZJ)) Q:ZJ=""  D  ; for each child
 . . S C0XPRE=@ZDOM@(ZJ) ; the predicate without a prefix
 . . S ZX=$G(@ZDOM@(ZJ,"A","xmlns")) ; name space
 . . I ZX'="" S C0XPRE=ZX_C0XPRE ; add the namespace prefix
 . . I C0XPRE[":" D  ; expand using vocabulary
 . . . N ZB,ZA
 . . . S ZB=$P(C0XPRE,":",1)
 . . . S ZA=$P(C0XPRE,":",2)
 . . . I $G(C0XVOC(ZB))'="" D  ;
 . . . . S C0XPRE=C0XVOC(ZB)_ZA ; expanded 
 . . S ZY=$G(@ZDOM@(ZJ,"A","rdf:resource")) ; potential object
 . . I ZY'="" D  Q ; 
 . . . S C0XOBJ=ZY ; object
 . . . D ADD(ZGRF,C0XSUB,C0XPRE,C0XOBJ) ; finally. our first real triple
 . . ; -- this is an else because of the quit above
 . . S ZX=$G(@ZDOM@(ZJ,"A","rdf:nodeID")) ; fishing for nodeId object
 . . I ZX'="" D  Q  ; got one
 . . . S C0XOBJ=ZX ; we are using the incoming nodeIDs as object/subject 
 . . . ; without change... this could be foolish .. look at it again later
 . . . D ADD(ZGRF,C0XSUB,C0XPRE,C0XOBJ) ; go for it and add a node
 . . S C0XOBJ=$G(@ZDOM@(ZJ,"T",1)) ; hopefully an object is here
 . . I C0XOBJ="" D  Q  ; not a happy situation
 . . . W !,"ERROR, NO OBJECT FOUND FOR NODE: ",ZJ
 . . D ADD(ZGRF,C0XSUB,C0XPRE,C0XOBJ) ; go for it and add a node
 S C0XTRP=$$NOW^XLFDT ; PARSE COMPLETE
 W !,"TRIPLES COMPLETE AT ",C0XTRP
 S C0XDIFF=$$FMDIFF^XLFDT(C0XTRP,C0XPRS,2)
 W !," ELAPSED TIME: ",C0XDIFF," SECONDS"
 I C0XDIFF'=0 D  ;
 . W !," APPROXIMATELY ",$P(C0XCNT/C0XDIFF,".")," TRIPLES PER SECOND"
 W !,"INSERTING ",C0XCNT," TRIPLES"
 I $D(C0XFDA) D  ;
 . I $G(BLKLOAD) D  ;
 . . D BULKLOAD(.C0XFDA)
 . E  D  ;
 . . D UPDIE(.C0XFDA) ; commit the updates to the file
 ; next, mark the graph as finished
 S C0XINS=$$NOW^XLFDT ; PARSE COMPLETE
 W !,"INSERTION COMPLETE AT ",C0XPRS
 S C0XDIFF=$$FMDIFF^XLFDT(C0XINS,C0XTRP,2)
 W !," ELAPSED TIME: ",C0XDIFF," SECONDS"
 I C0XDIFF'=0 W !," APPROXIMATELY ",$P(C0XCNT/C0XDIFF,".")," NODES PER SECOND"
 S C0XEND=$$NOW^XLFDT
 W !," ENDED AT: ",C0XEND
 S C0XDIFF=$$FMDIFF^XLFDT(C0XEND,C0XSTART,2)
 W !," ELAPSED TIME: ",C0XDIFF," SECONDS"
 I C0XDIFF'=0 W !," APPROXIMATELY ",$P(C0XCNT/C0XDIFF,".")," TRIPLES PER SECOND"
 Q
 ;
SHOW(ZN) ;
 ZWR ^TMP("MXMLDOM",$J,1,ZN,*)
 Q
 ;
ANONS() ; RETURNS AN ANONOMOUS SUBJECT
 Q "_:S"_$$LKY9
 ;
NEWG(NGRAPH,NMETA) ; CREATES A NEW META GRAPH, MARKS IT AS UNFINISHED
 ; THEN CREATES A NEW GRAPH AND POINTS THE METAGRAPH TO IT
 ; NGRAPH AND NMETA ARE PASSED BY REFERENCE AND ARE THE RETURN
 S NGRAPH="G"_$$LKY9
 S NMETA=NGRAPH_"A"
 Q
 ;
ADD(ZG,ZS,ZP,ZO,FARY) ; ADD A TRIPLE TO THE TRIPLESTORE. ALL VALUES ARE TEXT
 ; THE FDA IS SET UP BUT THE FILES ARE NOT UPDATED. CALL UPDIE TO COMPLETE
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 D USEFARY(FARY)
 I '$D(C0XCNT) S C0XCNT=0
 N ZNODE
 S ZNODE="N"_$$LKY17
 N ZNARY ; GET READY TO CALL IENOFA
 S ZNARY("ZG",ZG)=""
 S ZNARY("ZS",ZS)=""
 S ZNARY("ZP",ZP)=""
 S ZNARY("ZO",ZO)=""
 D IENOFA(.ZIENS,.ZNARY,FARY) ; RESOLVE/ADD STRINGS
 ;S ZGIEN=$$IENOF(ZG) ; LAYGO TO GET IEN
 ;S ZSIEN=$$IENOF(ZS)
 ;S ZPIEN=$$IENOF(ZP)
 ;S ZOIEN=$$IENOF(ZO)
 ;I $D(C0XFDA) D UPDIE ; ADD THE STRINGS IF NEEDED
 S BATCNT=BATCNT+1
 S C0XCNT=C0XCNT+1
 I $G(BLKLOAD)=1 D  ; we are using bulk load
 . S C0XFDA(C0XTFN,BATCNT,.01)=ZNODE
 . S C0XFDA(C0XTFN,BATCNT,.02)=$O(ZIENS("IEN","ZG",""))
 . S C0XFDA(C0XTFN,BATCNT,.03)=$O(ZIENS("IEN","ZS",""))
 . S C0XFDA(C0XTFN,BATCNT,.04)=$O(ZIENS("IEN","ZP",""))
 . S C0XFDA(C0XTFN,BATCNT,.05)=$O(ZIENS("IEN","ZO",""))
 E  D  ;
 . S C0XFDA(C0XTFN,"?+"_BATCNT_",",.01)=ZNODE
 . S C0XFDA(C0XTFN,"?+"_BATCNT_",",.02)=$O(ZIENS("IEN","ZG",""))
 . S C0XFDA(C0XTFN,"?+"_BATCNT_",",.03)=$O(ZIENS("IEN","ZS",""))
 . S C0XFDA(C0XTFN,"?+"_BATCNT_",",.04)=$O(ZIENS("IEN","ZP",""))
 . S C0XFDA(C0XTFN,"?+"_BATCNT_",",.05)=$O(ZIENS("IEN","ZO",""))
 I BATCNT=BATMAX D  ; BATCH IS DONE
 . I $G(BLKLOAD) D  ; bulk load
 . . D BULKLOAD(.C0XFDA) ; bulk load the batch
 . E  D  ; no bulk load
 . . D UPDIE(.C0XFDA)
 . K C0XFDA
 . S BATCNT=0 ; RESET COUNTER
 ; REMEMBER TO CALL UPDIE WHEN YOU'RE DONE
 Q
 ;
LKY9() ;EXTRINIC THAT RETURNS A RANDOM 9 DIGIT NUMBER. USED FOR GENERATING
 ; UNIQUE NODE AND GRAPH NAMES
 N ZN,ZI
 S ZN=""
 F ZI=1:1:9 D  ;
 . S ZN=ZN_$R(10)
 Q ZN
 ;
LKY17() ;EXTRINIC THAT RETURNS A RANDOM 9 DIGIT NUMBER. USED FOR GENERATING
 ; UNIQUE NODE AND GRAPH NAMES
 N ZN,ZI
 S ZN=""
 F ZI=1:1:17 D  ;
 . S ZN=ZN_$R(10)
 Q ZN
 ;
IENOF(ZSTRING,FARY) ; EXTRINSIC WHICH RETURNS THE IEN OF ZS IN THE STRINGS FILE
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 N ZIEN
 S ZIEN=$O(@C0XSN@("B",ZSTRING,""))
 I ZIEN="" D  ;
 . S C0XFDA2(C0XSFN,"+1,",.01)=ZSTRING
 . D UPDIE(.C0XFDA2)
 . S ZIEN=$O(@C0XSN@("B",ZSTRING,""))
 . K C0XFDA2
 Q ZIEN
 ;
IENOFA(ZOUTARY,ZINARY,FARY) ; RESOLVE STRINGS TO IEN IN STRINGS FILE 
 ; OR ADD THEM IF
 ; MISSING. ZINARY AND ZOUTARY ARE PASSED BY REFERENCE 
 ; ZINARY LOOKS LIKE ZINARY("VAR","VAL")=""
 ; RETURNS IN ZOUTARY OF THE FORM ZOUTARY("IEN","VAR",IEN)=""
 I '$D(FARY) D  ;
 . D INITFARY("C0XFARY")
 . S FARY="C0XFARY"
 K ZOUTARY ; START WITH CLEAN RESULTS
 K C0XFDA2 ; USE A SEPARATE FDA FOR THIS
 N ZI S ZI=""
 N ZV,ZIEN
 N ZCNT S ZCNT=0
 F  S ZI=$O(ZINARY(ZI)) Q:ZI=""  D  ; LOOK FOR MISSING STRINGS
 . S ZV=$O(ZINARY(ZI,""))
 . I $O(@C0XSN@("B",ZV,""))="" D  ;
 . . S ZCNT=ZCNT+1
 . . S C0XFDA2(C0XSFN,"+"_ZCNT_",",.01)=ZV
 I $D(C0XFDA2) D  ;
 . D UPDIE(.C0XFDA2) ; ADD MISSING STRINGS
 . K C0XFDA2 ; CLEAN UP
 F  S ZI=$O(ZINARY(ZI)) Q:ZI=""  D  ; NOT GET ALL IENS
 . S ZV=$O(ZINARY(ZI,""))
 . S ZIEN=$O(@C0XSN@("B",ZV,"")) ; THEY SHOULD BE THERE NOW
 . I ZIEN="" D  ;
 . . W !,"ERROR ADDING STRING: ",ZV
 . . B
 . S ZOUTARY("IEN",ZI,ZIEN)=""
 Q
 ;
BULKLOAD(ZBFDA) ; BULK LOADER FOR LOADING TRIPLES INTO FILE 172.101
 ; USING GLOBAL SETS INSTEAD OF UPDATE^DIE
 ; QUITS IF FILE IS NOT 172.101
 ; EXPECTS AN FDA WITHOUT STRINGS FOR THE IENS, STARTING AT 1
 ; QUITS IF FIRST ENTRY IS NOT IENS 1
 ; ASSUMES THAT THE LAST IENS IS THE COUNT OF ENTRIES
 ; ZBFDA IS PASSED BY REFERENCE
 ;
 ; -- reserves a block of iens from file 172.101 by locking the zero node
 ; -- ^C0X(101,0) and adding the count of entries to piece 2 and 3
 ; -- then unlocking to minimize the duration of the lock
 ;
 W !,"USING BULKLOAD"
 I '$D(ZBFDA) Q  ; EMPTY FDA
 I $O(ZBFDA(""))'=172.101 Q  ; WRONG FILE
 N ZCNT,ZP3,ZP4
 ; -- find the number of nodes to insert
 S ZCNT=$O(ZBFDA(172.101,""),-1)
 I ZCNT="" D  Q  ;
 . W !,"ERROR IN BULK LOAD - INVALID NODE COUNT"
 . B
 ; -- lock the zero node and reserve a block of iens to insert
 W !,"LOCKING ZERO NODE"
 LOCK +^C0X(101,0)
 S ZP3=$P(^C0X(101,0),U,3)
 S ZP4=$P(^C0X(101,0),U,4)
 S $P(^C0X(101,0),U,3)=ZP3+ZCNT+1
 S $P(^C0X(101,0),U,4)=ZP4+ZCNT+1
 LOCK -^C0X(101,0)
 N ZI,ZN,ZG,ZS,ZP,ZO,ZIEN,ZBASE
 S ZBASE=ZP3 ; the last ien in the file
 W !,"ZERO NODE UNLOCKED, IENS RESERVED=",ZCNT
 W !,$$NOW^XLFDT
 S ZI=""
 F  S ZI=$O(ZBFDA(172.101,ZI)) Q:ZI=""  D  ;
 . S ZN=$G(ZBFDA(172.101,ZI,.01)) ; node name
 . I ZN="" D BLKERR Q  ; 
 . S ZG=$G(ZBFDA(172.101,ZI,.02)) ; graph pointer
 . I ZG="" D BLKERR Q  ; 
 . S ZS=$G(ZBFDA(172.101,ZI,.03)) ; subject pointer
 . I ZS="" D BLKERR Q  ; 
 . S ZP=$G(ZBFDA(172.101,ZI,.04)) ; predicate pointer
 . I ZP="" D BLKERR Q  ; 
 . S ZO=$G(ZBFDA(172.101,ZI,.05)) ; object pointer
 . I ZO="" D BLKERR Q  ; 
 . S ZIEN=ZI+ZBASE ; the new ien
 . S ^C0X(101,ZIEN,0)=ZN_U_ZG_U_ZS_U_ZP_U_ZO ; set the zero node
 . S ^C0X(101,"B",ZN,ZIEN)="" ; the B index
 . S ^C0X(101,"G",ZG,ZIEN)="" ; the G for Graph index
 . S ^C0X(101,"SPO",ZS,ZP,ZO)=""
 . S ^C0X(101,"SOP",ZS,ZO,ZP)=""
 . S ^C0X(101,"OPS",ZO,ZP,ZS)=""
 . S ^C0X(101,"OSP",ZO,ZS,ZP)=""
 . S ^C0X(101,"GOPS",ZG,ZO,ZP,ZS)=""
 . S ^C0X(101,"GOSP",ZG,ZO,ZS,ZP)=""
 . S ^C0X(101,"GPSO",ZG,ZP,ZS,ZO)=""
 . S ^C0X(101,"GSPO",ZG,ZS,ZP,ZO)=""
 Q
 ;
BLKERR ; 
 W !,"ERROR IN BULK LOAD",! ZWR ZBFDA(ZI)
 B
 Q
 ;
SWUPDIE(ZFDA) ; SWITCH BETWEEN UPDIE AND BULKLOAD
 . I $G(BLKLOAD) D  ; bulk load
 . . D BULKLOAD(.ZFDA) ; bulk load the batch
 . E  D  ; no bulk load
 . . D UPDIE(.ZFDA)
 . K ZFDA
 Q
 ; 
UPDIE(ZFDA) ; INTERNAL ROUTINE TO CALL UPDATE^DIE AND CHECK FOR ERRORS
 ; ZFDA IS PASSED BY REFERENCE
 ;ZWR ZFDA
 ;B
 K ZERR
 D CLEAN^DILF
 D UPDATE^DIE("","ZFDA","","ZERR")
 I $D(ZERR) S ZZERR=ZZERR ; ZZERR DOESN'T EXIST, 
 ; INVOKE THE ERROR TRAP IF TASKED
 ;. W "ERROR",!
 ;. ZWR ZERR
 ;. B
 K ZFDA
 Q
 ;
