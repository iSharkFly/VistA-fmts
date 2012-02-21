C0XLEX ; GPL - Fileman Triples Lexicon experiments ;10/13/11  17:05
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
CLEAR ; DELETE THE FILESTORE
 K ^C0X(101)
 K ^C0X(201)
 S ^C0X(101,0)="C0X TRIPLE^172.101I^^"
 S ^C0X(201,0)="C0X STRING^172.201I^^"
 Q
 ;
LOADOWL ; INITIALIZE THE TRIPLE STORE - THIS DELETES THE GLOBALS AND
 ;
 S FARY="C0XFARY"
 S C0XFARY("C0XDIR")="/home/glilly/vistaowl/"
 D USEFARY^C0XF2N(FARY)
 D IMPORT^C0XF2N("VistAOWL-2.owl",C0XDIR,,FARY)
 Q
 ;
LOADLEX ;
 S FARY="C0XFARY"
 D INITFARY^C0XF2N(FARY)
 D USEFARY^C0XF2N(FARY)
 S C0XFARY("C0XDIR")="/home/glilly/Lex/LexGeorgeTriples/" ;
 D USEFARY^C0XF2N(FARY)
 S SMART(1)="LexClassNTypeGeorge.xml"
 S SMART(2)="LexRelatedICD9George.xml"
 S SMART(3)="LexDiseasesGeorge.xml"
 N ZI S ZI=""
 F  S ZI=$O(SMART(ZI)) Q:ZI=""  D  ; for each smart file
 . D IMPORT^C0XF2N(SMART(ZI),C0XDIR,,FARY) ; import to the triplestore
 Q