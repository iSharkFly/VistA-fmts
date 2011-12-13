C0XUTIL ; GPL - Fileman Triples utilities ;11/07/11  17:05
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
NSP(ZX) ; OUTPUT TRANSFORM EXTRINSIC
 ;
 N ZR
 ; I WOULD REALLY LIKE TO NOT HAVE THE FILE NUMBER HARD CODED HERE
 ; ANYONE KNOW HOW I COULD DO THAT?  :) GPL
 S ZR=$$GET1^DIQ(172.201,ZX_",",.01)
 I '$D(C0XNSP) S C0XNSP=1 ; DEFAULT ON
 I C0XNSP=0 Q ZR ; SWITCHED OFF
 I '$D(C0XVOC) D VOCINIT ; INITIALIZE THE VOCABULARIES
 N ZI,ZJ,ZK S ZI=""
 N DONE S DONE=0
 F  S ZI=$O(C0XVOC(ZI)) Q:(DONE=1)!(ZI="")  D  ;
 . ;W !,ZI
 . S ZJ=C0XVOC(ZI)
 . S ZK=$P(ZR,ZJ,2)
 . ;W !,"ZK=",ZK
 . I ZK'="" D  ; BINGO
 . . S ZR=ZI_":"_ZK
 . . S DONE=1
 Q ZR
 ;
VOCINIT ; INITIALIZE VOCABULARIES
 S C0XVOC("dcterms")="http://purl.org/dc/terms/"
 S C0XVOC("rdf")="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 S C0XVOC("sp")="http://smartplatforms.org/terms#"
 S C0XVOC("qds")="http://cms.gov/pqri/qds/"
 S C0XVOC("smart")="http://sandbox-api.smartplatforms.org/records/"
 S C0XVOC("snomed")="http://www.ihtsdo.org/snomed-ct/concepts/"
 S C0XVOC("rxnorm")="http://rxnav.nlm.nih.gov/REST/rxcui/"
 S C0XVOC("loinc")="http://loinc.org/codes/"
 S C0XVOC("file")="/home/glilly/fmts/trunk/samples/"
 S C0XVOC("foaf")="http://xmlns.com/foaf/0.1/"
 Q
 ;