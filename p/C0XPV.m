C0XPV ; GPL - Patient Viewer utilities ;11/07/11  17:05
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
CREATE(ZRTN,DFN,PART,FORM) ; CREATE A PATIENT RDF FILE. ALSO INSERT IT INTO THE
 ; triple store
 N ZARY ; array of values from the NHIN extract
 I '$D(PART) S PART="" ; NULL MEANS ALL
 D EN^C0SNHIN(.ZARY,DFN,"")
 I '$D(ZARY) Q  ; no information for this patient
 N ZGRF S ZGRF="/dewdrop/patient/"_DFN
 D DELGRAPH^C0XF2N(ZGRF) ; delete the graph from the triplestore
 N ZSUB S ZSUB=""  ; start out with null subject
 N ZTRIP ; place to put triples
 N ZI S ZI=""
 F  S ZI=$O(ZARY(ZI)) Q:ZI=""  D  ; for each clinical section
 . N ZJ S ZJ=""
 . F  S ZJ=$O(ZARY(ZI,ZJ)) Q:ZJ=""  D  ; for each occurance
 . . S ZSUB=ZGRF_"/"_ZI_"/"_ZJ ; ie /dewdrop/patient/32/allergy/1
 . . S ZTRIP(ZSUB,"sp:belongsTo",ZGRF)="" ; upward reference
 . . S ZTRIP(ZSUB,"rdf:type",ZI)="" ; ie rdf:type allergy
 . . N ZK S ZK=""
 . . F  S ZK=$O(ZARY(ZI,ZJ,ZK)) Q:ZK=""  D  ; for each predicate
 . . . S ZTRIP(ZSUB,ZK,ZARY(ZI,ZJ,ZK))="" ; ie entered@value 3110624.1909
 B
 D PUTGRAF^C0XXFRM("ZTRIP",ZGRF) ; insert the graph into the triplestore
 D getGraph^C0XGET1(.ZRTN,ZGRF,"rdf") ; return the graph in RDF format
 Q
 ;