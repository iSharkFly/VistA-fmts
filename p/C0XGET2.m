C0XGET1 ; GPL - Fileman Triples entry point routine ;1/12/12  17:05
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
LSSUBJ(RTN,ZSUBJ,C0XFARY) ; LIST NODES WITH SUBJECT ZSUBJ
 ;
 I '$D(C0XFARY) D INITFARY^C0XF2N("C0XFARY")
 D USEFARY^C0XF2N("C0XFARY")
 Q
 ;
GRAPHS(RTN,C0XFARY) ; LIST ALL GRAPHS
 ;
 I '$D(C0XFARY) D INITFARY^C0XF2N("C0XFARY")
 D USEFARY^C0XF2N("C0XFARY")
 N ZI S ZI=""
 F  S ZI=$O(@C0XTN@("G",ZI)) Q:ZI=""  D  ;
 . S RTN(ZI,$$STR(ZI))=""
 Q
 ;
STR(ZIN,C0XFARY) ; EXTRINSIC RETURNS A STRING
 I '$D(C0XFARY) D INITFARY^C0XF2N("C0XFARY")
 Q $$GET1^DIQ(C0XSFN,ZIN,.01,"E")
 ;
SPO(ZRTN,ZNODE,C0XFARY)
 I '$D(C0XFARY) D INITFARY^C0XF2N("C0XFARY")
 N ZI S ZI=$$NXT(.ZRTN)
 S ZRTN(ZI,"S")=$$S(ZNODE)
 S ZRTN(ZI,"P")=$$P(ZNODE)
 S ZRTN(ZI,"O")=$$O(ZNODE)
 Q
 ;
S(ZNODE,C0XFARY) ; EXTRINSIC RETURNING THE SUBJECT
 Q $$STR($$GET1^DIQ(C0XTFN,ZNODE,.03,"I")) ;
 ;
P(ZNODE,C0XFARY) ; EXTRINSIC RETURNING THE PREDICATE
 Q $$STR($$GET1^DIQ(C0XTFN,ZNODE,.04,"I")) ;
 ;
O(ZNODE,C0XFARY) ; EXTRINSIC RETURNING THE OBJECT
 Q $$STR($$GET1^DIQ(C0XTFN,ZNODE,.05,"I")) ;
 ;
NXT(ZRTN) ;EXTRINSIC FOR THE NEXT NODE IN ARRAY ZRTN, PASSED BY REF
 I '$D(ZRTN) S ZRTN=""
 Q $O(ZRTN(""),-1)+1
 ;
SING(ZRTN,ZG) ; SUBJECTS IN GRAPH
 ;
 I '$D(C0XFARY) D INITFARY^C0XF2N("C0XFARY")
 I '$D(ZRTN) S ZRTN=""
 N ZI,ZN S ZI=""
 F  S ZI=$O(@C0XTN@("GSPO",ZG,ZI)) Q:ZI=""  D  ;
 . S ZRTN($$NXT(.ZRTN),"S")=$$STR(ZI)
 Q
 ;
qparse(qrtn,zquery) ; parses the query
 ; want this to be able to handle the WHERE clause of SPARQL eventually
 ;
 n q1,q2,q3,qq
 ;s qq=$tr(zquery,"  ","^")
 s qq=query ; really want to remove whitespace here
 s q1=$p(qq," ",1)
 i q1["?" s q1=""
 s q2=$p(qq," ",2)
 i q2["?" s q2=""
 s q3=$p(qq," ",3)
 i q3["?" s q3=""
 s qrtn(1)=q1_"^"_q2_"^"_q3 ; more lines to come later
 q
 ;
rpctrip(rtn,query,limit,offset) ; rpc to access triples with a query
 ;
 n zoff,zlim,zcount,zq
 k rtn
 i '$d(limit) s limit=250
 i '$d(offset) s offset=0
 d qparse(.zq,query) ; parse the query
 n qsub,qpred,qobj,qtmp
 W !,zq(1)
 s qsub=$p(zq(1),"^",1)
 s qpred=$p(zq(1),"^",2)
 s qobj=$p(zq(1),"^",3)
 d triples(.qtmp,qsub,qpred,qobj)
 f zcount=offset+1:1:offset+limit q:'$d(qtmp(zcount))  d  ;
 . s rtn(zcount)=qtmp(zcount)
 q
 ;
triples(triplertn,sub,pred,obj,graph,fary) ; returns triples
 I '$D(fary) D  ;
 . D INITFARY^C0XF2N("C0XFARY")
 . S fary="C0XFARY"
 D USEFARY^C0XF2N(fary)
 k triplertn ; start with a clean return
 n zsub,zpred,zobj,zgraph,tmprtn
 s zsub=$$IENOF^C0XF2N($$EXT^C0XUTIL($g(sub)),fary) ; ien of subject
 s zpred=$$IENOF^C0XF2N($$EXT^C0XUTIL($g(pred)),fary) ; ien of predicate
 s zobj=$$IENOF^C0XF2N($$EXT^C0XUTIL($g(obj)),fary) ; ien of object
 s zgraph=$$IENOF^C0XF2N($g(graph),fary) ; ien of graph
 W !,"s:",zsub," p:",zpred," o:",zobj
 d trip(.tmprtn,zsub,zpred,zobj,zgraph,fary)
 n zzz,zrsub,zrpred,zrobj,zgraph,zcnt,zrary
 s zzz=""
 f  s zzz=$o(tmprtn(zzz)) q:zzz=""  d  ;
 . s zrsub=$$GET1^DIQ(C0XTFN,zzz_",",.03,"E")
 . s zrpred=$$GET1^DIQ(C0XTFN,zzz_",",.04,"E")
 . s zrobj=$$GET1^DIQ(C0XTFN,zzz_",",.05,"E")
 . s zrgraph=$$GET1^DIQ(C0XTFN,zzz_",",.02,"E")
 . s zrary(zrsub,zrpred_"^"_zrobj)=""
 ;b
 ;
 i REPLYFMT="JSON" d output(.triplertn,.zrary) q  ; what follows is 'else'
 ;
 ; if no reply format is found we just output an array of triples
 ;
 s zrsub=""
 s zcnt=1
 f  s zrsub=$o(zrary(zrsub)) q:zrsub=""  d  ; organized by subject
 . s zzz=""
 . f  s zzz=$o(zrary(zrsub,zzz)) q:zzz=""  d  ; pred and obj
 . . s triplertn(zcnt)=zrsub_"^"_zzz
 . . s zcnt=zcnt+1
 q
 ;
configfmt(zfmtary) ; configure output routine table
 s zfmtary("REPLYSTART")="LISTSTART^FMQLJSON"
 s zfmtary("LISTSTART")="LISTSTART^FMQLJSON"
 s zfmtary("DICTSTART")="DICTSTART^FMQLJSON"
 s zfmtary("DASSERT")="DASSERT^FMQLJSON"
 s zfmtary("DICTEND")="DICTEND^FMQLJSON"
 s zfmtary("LISTEND")="LISTEND^FMQLJSON"
 s zfmtary("REPLYEND")="REPLYEND^FMQLJSON"
 d USEARY^C0XF2N("zfmtary")
 q
 ;
output(jout,zary) ; 
 n zformat
 d configfmt(.zformat)
 ;d REPLYSTART^FMQLJSON("jout")
 d @REPLYSTART@("jout")
 ;d LISTSTART^FMQLJSON("jout","results")
 d @LISTSTART@("jout","results")
 n zi s zi=""
 f  s zi=$o(zary(zi)) q:zi=""  d  ; for each subject
 . n zii s zii=""
 . ;D DICTSTART^FMQLJSON("jout",zi)
 . D @DICTSTART@("jout",zi)
 . f  s zii=$o(zary(zi,zii)) q:zii=""  d  ; for each pred^obj pair
 . . ;d DASSERT^FMQLJSON("jout",$p(zii,"^",1),$p(zii,"^",2))
 . . d @DASSERT@("jout",$p(zii,"^",1),$p(zii,"^",2))
 . ;D DICTEND^FMQLJSON("jout")
 . D @DICTEND@("jout")
 ;d LISTEND^FMQLJSON("jout")
 d @LISTEND@("jout")
 ;d REPLYEND^FMQLJSON("jout")
 d @REPLYEND@("jout")
 q
 ;
trip(triprtn,nsub,npred,nobj,ngraph,fary) ; returns triples iens
 ; nsub,npred,nobj are all optional
 ; graf is also optional, and will limit the search to a particular ngraph
 ; fary is which triple store (not implemented yet)
 n c0xflag,zi,zx,zt
 s zt=$na(^C0X(101)) ; 
 n zf1,zf2,zf3
 s zf1=$s($g(nsub)="":0,1:1)
 s zf2=$s($g(npred)="":0,1:1)
 s zf3=$s($g(nobj)="":0,1:1)
 s c0xflag="I"_zf1_zf2_zf3
 n itbl
 s itbl("I000","SPO")="d do3(.triprtn,zt,zi)"
 s itbl("I001","OSP")="d do2(.triprtn,zt,zi,nobj)"
 s itbl("I010","PSO")="d do2(.triprtn,zt,zi,npred)"
 s itbl("I011","POS")="d do1(.triprtn,zt,zi,npred,nobj)"
 s itbl("I100","SPO")="d do2(.triprtn,zt,zi,nsub)"
 s itbl("I101","SOP")="d do1(.triprtn,zt,zi,nsub,nobj)"
 s itbl("I110","SPO")="d do1(.triprtn,zt,zi,nsub,npred)"
 s itbl("I111","SPO")="d do0(.triprtn,zt,zi,nsub,npred,nobj)"
 s zi=$o(itbl(c0xflag,""))
 s zx=itbl(c0xflag,zi) ; executable instruction to run
 i $g(ngraph)'="" s zi="G"_zi
 w !,zx
 x zx
 q
 ;
do0(dortn,zt,zi,z1,z2,z3)
 ; looking for only one triple
 n zz
 s zz=$o(@zt@(zi,z1,z2,z3,""))
 i zz'="" s dortn(zz)=""
 q
 ;
do1(dortn,zt,zi,z1,z2) ; have 2, looking for one
 n zr,zx1
 s zx1=""
 f  s zx1=$o(@zt@(zi,z1,z2,zx1)) q:zx1=""  d  ;
 . s zr=$o(@zt@(zi,z1,z2,zx1,""))
 . s dortn(zr)=""
 q
 ;
do2(dortn,zt,zi,z1) ; have one, looking for 2
 n zr,zx1,zx2
 s (zx1,zx2)=""
 f  s zx1=$o(@zt@(zi,z1,zx1)) q:zx1=""  d  ;
 . f  s zx2=$o(@zt@(zi,z1,zx1,zx2)) q:zx2=""  d  ;
 . . s zr=$o(@zt@(zi,z1,zx1,zx2,""))
 . . s dortn(zr)=""
 q
 ;
do3(dortn,zt,zi) ; have none, looking for three
 n zr,zx1,zx2,zx3
 s (zx1,zx2,zx3)=""
 f  s zx1=$o(@zt@(zi,zx1)) q:zx1=""  d  ;
 . f  s zx2=$o(@zt@(zi,zx1,zx2)) q:zx2=""  d  ;
 . . f  s zx3=$o(@zt@(zi,zx1,zx2,zx3)) q:zx3=""  d  ;
 . . . s zr=$o(@zt@(zi,zx1,zx2,zx3,""))
 . . . s dortn(zr)=""
 q
 ;
