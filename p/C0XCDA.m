C0XCDA ; GPL - Fileman Triples CDA Processing ;2/20/13  17:05
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
 ;
tree(where,prefix) ; show a tree starting at a node in MXML. where is passed by value
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
 S ZR=$$LTRIM(ZR) ; get rid of leading blanks
 QUIT ZR
 ;
LDBLNKS(st) ; extrinsic which removes leading blanks from a string - deprecated see LTRIM
 n zr s zr=st
 f  q:$e(zr,1)'=" "  s zr=$e(zr,2,$l(zr))
 q zr
 ;
 ; copied from VPRJT - thanks.
UP(X) ; return uppercase for X
 Q $TR(X,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
LTRIM(X) ; remove spaces from left side
 N POS F POS=1:1:$L(X) Q:$E(X,POS)'=" "
 Q $E(X,POS,$L(X))
 ;
VACCD ; set C0XJOB to the VA CCD
 s C0XJOB=14921
 q
 ;
NLMVS ; set C0XJOB to the NLM Values Set xml
 s C0XJOB=26295
 Q
 ;
agenda(zrtn,docId) ; produce an agenda for the docId in the MXML dom
 ; generally, a first level index to the document
 ; set C0XJOB if you want to use a different $J to locate the dom
 ; zrtn passed by name
 ;
 ;s C0XJOB=26295
 n zi s zi=""
 i '$d(docId) s docId=1
 i '$D(C0XJOB) s C0XJOB=$J
 n dom s dom=$na(^TMP("MXMLDOM",C0XJOB,docId))
 f  s zi=$o(@dom@(1,"C",zi)) q:zi=""  d  ;
 . n zn s zn=@dom@(1,"C",zi)
 . s zn=zn_" "_$g(@dom@(zi,"A","displayName"))
 . s @zrtn@(zn,zi)=""
 q
 ;