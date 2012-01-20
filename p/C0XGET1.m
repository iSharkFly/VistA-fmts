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
LSGRFS(RTN,C0XFARY) ; LIST ALL GRAPHS
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
 Q $O(ZRTN(""),-1)+1
 ;
SING(ZRTN,ZG) ; SUBJECTS IN GRAPH
 ;
 I '$D(C0XFARY) D INITFARY^C0XF2N("C0XFARY")
 N ZI,ZN S ZI=""
 F  S ZI=$O(@C0XTN@("GSO",ZG,ZI)) Q:ZI=""  D  ;
 . S ZRTN($$NXT(ZRTN),"S")=$$STR(ZI)
 Q
 ;