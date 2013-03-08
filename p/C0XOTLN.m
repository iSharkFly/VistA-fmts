C0XOTLN ; GPL - Fileman Triples Outline Processing ;2/20/13  17:05
 ;;0.1;C0X;nopatch;noreleasedate;Build 7
 ;Copyright 2013 George Lilly.  Licensed under the terms of the GNU
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
roots(rtn) ; return the root subjects - defined by subjects with no parents 
 ; but with children
 n sn,on,zi
 s sn=$na(^C0X(101,"SOP")) ; subject index
 S on=$na(^C0X(101,"OSP")) ; object index
 s zi=""
 f  s zi=$o(@sn@(zi)) q:zi=""  d  ; for each subject
 . i $d(@on@(zi)) q  ; it is a child 
 . n zj s zj=""
 . n hasChild s hasChild=0
 . f  s zj=$o(@sn@(zi,zj)) q:zj=""  d  ; for each object in this subject
 . . i $d(@sn@(zj)) s hasChild=1
 . s:hasChild rtn($$STR^C0XGET1(zi))=""
 q
 ;
showorg ;
 d roots(.g)
 ;s DEBUG=1
 d showlist(.g2,"g","*")
 q
 ;
showlist(zrtn,lst,prefix) ;
 n zi,zj,zk
 w:$g(DEBUG) !,"entering showlist "_prefix_" ",$o(@lst@(""))
 s zi=""
 f  s zi=$o(@lst@(zi)) q:zi=""  d  ;
 . n zs s zs=$$NSP2^C0XUTIL(zi)
 . ;w !,prefix_" ",zs
 . n tr
 . d triples^C0XGET1(.tr,zs,,,,"array")
 . i '$d(tr) q  ;
 . s zj=""
 . f  s zj=$o(tr(zj)) q:zj=""  d  ;
 . . w !,prefix_"* "_$$NSP2^C0XUTIL($p(tr(zj),"^",2))_" "
 . . n isub s isub=$$isSubject($p(tr(zj),"^",3))
 . . i isub d  ;
 . . . n tr2 s tr2($p(tr(zj),"^",3))=""
 . . . d showlist(.zrtn,"tr2",prefix_"*")
 . . i 'isub w $p(tr(zj),"^",3)
 q
 ;
isSubject(zy) ; extrinsic which returns true if zy is a pointer to a subject
 n zr s zr=0
 i $d(^C0X(101,"SPO",$$IENOF^C0XF2N(zy))) s zr=1
 q zr
 ;
 ; -- some python that does a tree
 ;def tree(node, prefix='|--'):
 ;   txt=('' if (node.text is None) or (len(node.text) == 0) else node.text);
 ;   txt2 = txt.replace('\n','');
 ;   print prefix+cdautil.clean(node.tag)+'  '+txt2;
 ;   for att in node.attrib:
 ;       print prefix+'  : '+cdautil.clean2(att)+'^'+node.attrib[att];
 ;   for child in node:
 ;       tree(child,'|  '+prefix );
tree(where,prefix) ; show a tree starting at a node in MXML. node is passed by name
 ; 
 i $g(prefix)="" s prefix="|--" ; starting prefix
 i '$d(C0XJOB) s C0XJOB=$J
 n node s node=$na(^TMP("MXMLDOM",C0XJOB,1,where))
 n txt s txt=$$CLEAN($$ALLTXT(node))
 w !,prefix_@node_" "_txt
 n zi s zi=""
 f  s zi=$o(@node@("A",zi)) q:zi=""  d  ;
 . w !,prefix_"  : "_zi_"^"_$g(@node@("A",zi))
 f  s zi=$o(@node@("C",zi)) q:zi=""  d  ;
 . d tree(zi,"|  "_prefix)
 q
 ;
show(what) ;
 ;S C0XJOB=26295
 I '$D(C0XJOB) S C0XJOB=$J
 d tree(what)
 q
 ; 
tree2(where,prefix) ; show a tree starting at a node in MXML. node is passed by name
 ; tree2 handles ConceptLists as tables
 i $g(prefix)="" s prefix="|--" ; starting prefix
 i '$d(C0XJOB) s C0XJOB=$J
 n node s node=$na(^TMP("MXMLDOM",C0XJOB,1,where))
 ;n txt s txt=$$CLEAN($$ALLTXT(node))
 n txt d alltxt(.txt,node)
 ;w !,prefix_@node_" "_txt
 n zk s zk=""
 f  s zk=$o(txt(zk)) q:zk=""  d  ;
 . i zk=1 d out(prefix_@node_" "_txt(zk))  q  ;
 . d out(prefix_txt(zk))
 i @node["ns0:ConceptList" d  q  ;
 . d clist(where,prefix)
 n zi s zi=""
 f  s zi=$o(@node@("A",zi)) q:zi=""  d  ;
 . ;w !,prefix_"  : "_zi_"^"_$g(@node@("A",zi))
 . d out(prefix_"  : "_zi_"^"_$g(@node@("A",zi)))
 n grpstart s grpstart=0
 f  s zi=$o(@node@("C",zi)) q:zi=""  d  ;
 . i @node@("C",zi)="ns0:RevisionDate" d newgrp
 . i @node@("C",zi)="ns0:Group" d group(zi)  q  ;
 . d tree2(zi,"|  "_prefix)
 d:grpstart grpout
 q
 ;
newgrp ; kill the group array for a new group
 ;W !,"NEW GROUP"
 k ^TMP("C0XNLMVS",$J,"GROUP")
 q
 ;
group(where) ; add a group node to the group array
 s grpstart=1
 n gn s gn=$na(^TMP("C0XNLMVS",$J,"GROUP"))
 n node s node=$na(^TMP("MXMLDOM",C0XJOB,1))
 n gnum s gnum=$g(@node@(where,"A","ID"))
 i gnum="" d  q  ;
 . w !,"error finding group number ",where
 n var s var=@node@(where,"A","displayName")
 n valref s valref=$o(@node@(where,"C",""))
 i valref="" d  q  ;
 . w !,"error finding value reference ",where
 n val s val=@node@(valref,"T",1)
 s @gn@(gnum,var)=val
 q
 ;
grpout ; output the group array
 ;zwr ^TMP("C0XNLMVS",$J,*)
 ;b
 n gn s gn=$na(^TMP("C0XNLMVS",$J,"GROUP"))
 n grp s grp=""
 f  s grp=$o(@gn@(grp)) q:grp=""  d  ;
 . d out("--------------------------------------------------------------")
 . n attr s attr=""
 . f  s attr=$o(@gn@(grp,attr)) q:attr=""  d  ;
 . . d out(attr_": "_@gn@(grp,attr))
 q
 ;
out(txt) ; add line to output array
 s c0xout=$na(^TMP("C0XOUT",$J))
 n cnt
 s cnt=$o(@c0xout@(""),-1)
 i cnt="" s cnt=0
 s @c0xout@(cnt+1)=txt
 q
 ;
clist(where,prefix,nohead)
 n nd s nd=$na(^TMP("MXMLDOM",C0XJOB,1))
 ;i '$d(nohead) s nohead=0
 ;i 'nohead d  ;
 d out($j("Code",20)_$j("System",10)_$j("Description",20))
 n zzi s zzi=""
 f  s zzi=$o(@nd@(where,"C",zzi)) q:zzi=""  d  ;
 . n code,system,desc
 . s code=$g(@nd@(zzi,"A","code"))
 . s system=$g(@nd@(zzi,"A","codeSystemName"))
 . s desc=$g(@nd@(zzi,"A","displayName"))
 . d out($j(code,20)_$j(system,10)_"  "_desc)
 ;w @nd,":",@nd@("T",1)  
 q
 ;
alltxt(rtn,node) ; handle arrays of text
 m rtn=@node@("T")
 n zj s zj=""
 f  s zj=$o(rtn(zj)) q:zj=""  d  ;
 . s rtn(zj)=$$CLEAN(rtn(zj))
 . s rtn(zj)=$$LDBLNKS(rtn(zj))
 . i rtn(zj)="" k rtn(zj)
 . i (rtn(zj)=" ")&(zj>1) k rtn(zj)
 q
 ;
ALLTXT(where) ; extrinsic which returns all text lines from the node .. concatinated 
 ; together
 n zti s zti=""
 n ztr s ztr=""
 f  s zti=$o(@where@("T",zti)) q:zti=""  d  ;
 . s ztr=ztr_$g(@where@("T",zti))
 q ztr
 ;
CLEAN(STR)	; extrinsic function; returns string - gpl borrowed from the CCR package
 ;; Removes all non printable characters from a string.
 ;; STR by Value
 N TR,I
 F I=0:1:31 S TR=$G(TR)_$C(I)
 S TR=TR_$C(127)
 N ZR S ZR=$TR(STR,TR)
 S ZR=$$LDBLNKS(ZR) ; get rid of leading blanks
 QUIT ZR
 ;
LDBLNKS(st) ; extrinsic which removes leading blanks from a string
 n pos f pos=1:1:$l(st)  q:$e(st,pos)'=" "
 q $e(st,pos,$l(st))
 ;
VACCD ; set C0XJOB to the VA CCD
 s C0XJOB=14921
 q
 ;
NLMVS ; set C0XJOB to the NLM Values Set xml
 s C0XJOB=26295
 Q
 ;
contents(zrtn,ids) ; produce an agenda for the docId 1 in the MXML dom
 ; generally, a first level index to the document
 ; set C0XJOB if you want to use a different $J to locate the dom
 ; zrtn passed by name
 ; ids=1 names them by number ids=0 or null names them by displayname
 ;s C0XJOB=26295
 D NLMVS
 n zi s zi=""
 i '$d(docId) s docId=1
 i '$D(C0XJOB) s C0XJOB=$J
 n dom s dom=$na(^TMP("MXMLDOM",C0XJOB,docId))
 f  s zi=$o(@dom@(1,"C",zi)) q:zi=""  d  ;
 . n zn ;
 . d:$g(ids)  ;
 . . s zn=$tr($g(@dom@(zi,"A","ID")),".","-")_".txt"
 . . s @zrtn@(zn,zi)=""
 . d:'$g(ids)  ;
 . . s zn=$tr($g(@dom@(zi,"A","displayName"))," ","_")_".txt"
 . . s zn=$tr(zn,"()","") ; get rid of parens for valid filename
 . . s zn=$tr(zn,"/","-") ; get rid of slash for valid filename
 . . s @zrtn@(zn,zi)=""
 q
 ;
export ; exports separate files for each value set
 ; one copy in a file with a text name based on the displayName
 n g,zi,fname,where,dirname,gn
 s gn=$na(^TMP("C0XOUT",$J))
 s dirname="/home/wvehr2/valuesets/by-name/"
 s zi=""
 d contents("g") ; first with text names
 f  s zi=$o(g(zi)) q:zi=""  d  ;
 . s fname=zi
 . s where=$o(g(zi,""))
 . k @gn
 . d tree2(where,"| ")
 . n gn2 s gn2=$na(@gn@(1)) ; name for gtf
 . s ok=$$GTF^%ZISH(gn2,3,dirname,fname)
 q
 ;
export2 ; exports separate files for each value set
 ; one copy in a file with a numeric file name based on ID
 n g,zi,fname,where,dirname,gn
 s gn=$na(^TMP("C0XOUT",$J))
 s dirname="/home/wvehr2/valuesets/by-id/"
 s zi=""
 d contents("g",1) ; with id names
 f  s zi=$o(g(zi)) q:zi=""  d  ;
 . s fname=zi
 . s where=$o(g(zi,""))
 . k @gn
 . d tree2(where,"| ")
 . n gn2 s gn2=$na(@gn@(1)) ; name for gtf
 . s ok=$$GTF^%ZISH(gn2,3,dirname,fname)
 q
 ;