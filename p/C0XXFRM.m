C0XXFRM ; GPL - Fileman Triples utilities ;11/07/11  17:05
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
TEST1 ; test GRAPHY
 ;
 S G("possibleMatch",18262)=""
 S G("possibleMatch",18262,"DOB")="19520606^19520606"
 S G("possibleMatch",18262,"FNAME")="GEORGE^GEORGE PHILLIP"
 S G("possibleMatch",18262,"LNAME")="LILLY^LILLY"
 S G("possibleMatch",18262,"SSN")=310449999
 S G("possibleMatch",18263)=""
 S G("possibleMatch",18263,"DOB")="19520606^19531031"
 S G("possibleMatch",18263,"FNAME")="GEORGE^FRANCIS JAMES"
 S G("possibleMatch",18263,"LNAME")="LILLY^LILLY"
 S G("possibleMatch",18263,"SSN")=3232221111
 S GRAPH="/test/gpl/graph"
 S SUBJECT="/test/gpl/match"
 D GRAPHY("G2","G",GRAPH,SUBJECT) ; CONVERT TO GRAPH
 W !
 ZWR G2
 ;
 Q
 ;
TEST2 ; test ARRAYIFY
 ;
 Q
 ;
GRAPHY(ZOUT,ZIN,ZGRF,ZSUB,ZWHICH) ; turn a mumps array into triples
 W !,"GRAPHY: ZOUT=",ZOUT," ZIN=",ZIN," ZSUB=",ZSUB," ZWHICH=",$G(ZWHICH),!
 N ZI S ZI=$G(ZWHICH)
 N ZP
 S ZP=$O(@ZIN@(ZI))
 W !,"ZP=",ZP
 I ZP="" Q  ; THE WAY OUT
 N ZJ S ZJ=""
 F  S ZJ=$O(@ZIN@(ZP,ZJ)) Q:ZJ=""  D  ; for each object
 . N ZO
 . S ZO=$$ANONS^C0XF2N ; anonomous subject
 . S @ZOUT@(ZSUB,ZP,ZO)=""
 . S @ZOUT@(ZO,"rdf:id",ZJ)=""
 . N ZK S ZK=""
 . F  S ZK=$O(@ZIN@(ZP,ZJ,ZK)) Q:ZK=""  D  ;
 . . S @ZOUT@(ZO,ZK,$G(@ZIN@(ZP,ZJ,ZK)))=""
 . . D GRAPHY(ZOUT,$NA(@ZIN@(ZP,ZJ,ZK)),ZGRF,ZO)
 ;
 Q
 ;
ARRAYIFY(ZOUT,ZIN,ZWHICH) ; turn triples into a mumps array (opposite of GRAPHY)
 ;
 Q
 ;