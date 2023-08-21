//==============================================================================
// Select/Copy Chord Levels v1.0                                          
// https://github.com/Ash-86/Select-Copy-Chord-Levels                     
//                                                                        
//  Copyright (C)2023 Ashraf El Droubi (Ash-86)                           
//                                                                        
//  This program is free software: you can redistribute it and/or modify  
//  it under the terms of the GNU General Public License as published by  
//  the Free Software Foundation, either version 3 of the License, or     
//  (at your option) any later version.                                   
//                                                                        
//  This program is distributed in the hope that it will be useful,       
//  but WITHOUT ANY WARRANTY; without even the implied warranty of        
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         
//  GNU General Public License for more details.                          
//                                                                        
//  You should have received a copy of the GNU General Public License     
//  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
//===============================================================================

import QtQuick 2.5
import MuseScore 3.0

MuseScore {
	title: "Select/Copy Chord levels Down"
	description: "Extends selection to notes with the similar chord-levels and/or voices over the selected range"
	version: "1.0"
    categoryCode: "Editing-Tools"
    thumbnailName: "thumbnail.jpg"	    
  
    
    function noteObject(staff, voice, track, level, tick) {       
        this.staff = staff;
        this.voice = voice;      
        this.track = track;
        this.level = level;
        this.tick = tick;
    }
      
    function makeSelection(fullScore){    

        /// choose counting direction /////
       
        // var counting="up"   
        var counting="down"

        //////////////////////////////////
        

        var cursor = curScore.newCursor();               
        var els = curScore.selection.elements 

        
        var note=[]
        var Notes=[]
    
        for (var i in els){
            var track = els[i].track
            var staff = ~~(track/4)  
            var voice = track%4        
            var tick = els[i].parent.parent.tick       

            var pitch=els[i].pitch
            var chord = els[i].parent
            for (var n in chord.notes){
                if (pitch==chord.notes[n].pitch){                   
                    if (counting=="up") {var level = n} 
                    if (counting=="down") {var level = chord.notes.length-1-n}  
                    if (level==chord.notes.length-1) {
                        level=100  /// special number for bottom or top notes -depending on counting direction
                    }
                }                
            }  
            note = new noteObject(staff, voice, track, level, tick) 
            Notes.push(note)       
        }       

        
        var tracks=[]  ///get unique tracks of selected notes
        var staves=[]   //get unique staves of selected notes
        var ticks=[]     //get unique ticks of selected notes
        for (var i in Notes){
            var sensor=0
            for(var t in tracks){
               if(tracks[t]==Notes[i].track){
                  sensor++
               }
            } 
            if (sensor==0) {tracks.push(Notes[i].track)}
       
            var sensor=0
            for (var s in staves){            
               if(staves[s]==Notes[i].staff){
                sensor++
                }
            }
            if (sensor==0) {staves.push(Notes[i].staff)}
            
            var sensor=0
            for(var t in ticks){
               if(ticks[t]==Notes[i].tick){
                  sensor++
               }
            } 
            if (sensor==0) {ticks.push(Notes[i].tick)}
        }
       staves.sort()
       tracks.sort()
       ticks.sort()

        
        var voices=[];  ///get unique voices per staff        
        for (var i in staves){
            var voic=[]            
            for (var n in Notes){
                var sensor=0
                if(Notes[n].staff==staves[i]){                    
                    for (var v in voic){                    
                        if (voic[v]==Notes[n].voice){ 
                            sensor++ 
                        }
                    }                
                    if (sensor==0){ 
                        voic.push(Notes[n].voice)
                    }
                }
            }            
            voic.sort();           
            voices.push(voic)
        }
        
        var levels=[] //get unique levels per track
        for (var i in tracks){
            var lev=[]
            for (var n in Notes){
                var sensor=0
                if(Notes[n].track==tracks[i]){
                    for (var l in lev){                    
                       if (lev[l]==Notes[n].level){
                            sensor++ 
                        }
                    }
                    if (sensor==0) { 
                        lev.push(Notes[n].level)
                    }
                }
            } 
            lev.sort()         
            levels.push(lev)
        }


        console.log("staves : ", staves,"voices : ", voices[0],voices[1], "tracks : ",tracks,"levels : " ,levels[0],levels[1], levels[2]  )

       
        ///////////////////////////////////////////////////////
        var t1 = ticks[0];  
        // var t2 = ticks[ticks.length-1];  /// supposed to get max tick but, apparently ticks.sort()  does not work properly if note is selected in first measure and end note in second measure!!! no clue why
        var t2 = ticks[0]
        for (var t in ticks){    ///get max and min ticks
            if (ticks[t]<t1) { t1=ticks[t] }
            if (ticks[t]>t2) { t2=ticks[t] }
        }
        cursor.track=tracks[0]
        cursor.rewindToTick(t2)
        cursor.next()
        t2=cursor.tick      /////fix t2 to go till (end of last selected note)/(start of next note)

        for (var i in tracks){  ////// check if plugin has run once, if so, extends ticks to cover full score. 
            cursor.track=tracks[i]
            cursor.rewindToTick(t1)
            cursor.next()
            for (var n in Notes){
                if (Notes[n].track==tracks[i]){  //check if note belongs to current track
                    if (Notes[n].tick==cursor.tick){ // check it the nots's tick is adjacent to first 
                        var fullScore=true
                    }                    
                }                
            }
        }////not the best way to make sure the plugin has already run. Perhaps one can get the last entry in history and check if plugin had already run once. 


        if (ticks.length==1) {   //// if notes selected belong to same chord or segment or only one note selected, make t1 and t2 start and end ticks of measure            
            cursor.rewindToTick(t1)                      
            t1= cursor.measure.firstSegment.tick
            t2= cursor.measure.lastSegment.tick
        }
        
       
        if(fullScore){
            var t1=curScore.firstMeasure.firstSegment.tick  /// first tick in score
            var t2=curScore.lastSegment.tick+1                //// last tick in score
        }

        console.log("t1= ",t1, "t2= ",t2)       


        var copy=true            
        for (var i=1; i<staves.length;i++){    //// check if selection are in consecutive staves in order to copy. 
            if ((staves[i]-staves[i-1]) >1){
                var copy=false
            }            
        }
        
        curScore.startCmd()
        /////////////////////////////////////////////////////////
        if (copy==true){
            var notesDeleted=0
            for(var s in staves){
                for (var v=0; v<4; v++){
                    var track=staves[s]*4+v
                    cursor.track=track
                    cursor.rewindToTick(t1)
                    var sensor=0
                    for (var i in voices[s]) {
                        if (voices[s][i]==v){
                            sensor++
                        }
                    }
                    
                    if(sensor>0){
                        var trackIdx= tracks.indexOf(track)
                        console.log(levels[trackIdx])
                        while (cursor.segment && (cursor.tick < t2)) {   /// selects notes with same levels on the same track
                            var el= cursor.element
                            if(el.type == Element.CHORD) {
                                                   
                                var n= el.notes.length-1   
                                while (n>=0){                                   
                                    var levelsensor=0
                                    for (var l in levels[trackIdx]){                                    
                                        if (levels[trackIdx][l]==n ){                                         
                                            levelsensor++
                                        }
                                        if (n==el.notes.length-1 && levels[trackIdx][l]==100){  /// check for top or bottom note
                                            levelsensor++
                                        }
                                    }
                                    if (levelsensor==0){
                                            if (counting=="up") {el.remove(el.notes[n])}  
                                            if (counting=="down") {el.remove(el.notes[el.notes.length-1-n])}  
                                            notesDeleted++
                                    }                                                                              
                                    n--                                                
                                }
                            }
                            cursor.next()   
                        }                                                
                    }

                    if(sensor<=0 ){          /// if voice wasnt in selection but exists, delete it.            
                        while (cursor.segment && (cursor.tick < t2)) {   
                            var el= cursor.element
                            if(el.type == Element.CHORD) {                    
                                removeElement(el)
                                notesDeleted++
                                if(v!=0){
                                    var el= cursor.element                                                
                                    removeElement(el)
                                    notesDeleted++
                                }                                
                            }
                            cursor.next()
                        }
                    }
                    
                }///end voices iteration
            }///end staves iteration

            curScore.endCmd();                       
            curScore.selection.selectRange(t1, t2, staves[0], staves[staves.length-1]+1);   
            cmd("copy");
            if (notesDeleted>0) {
                cmd("undo");    ///dont want it to undo if no notes where deleted, otherwise it will undo preveious action in history, whatever that was
            }
            

            for (var i in tracks){                
                cursor.track=tracks[i]
                cursor.rewindToTick(t1)
                if (cursor.element){
                    while (cursor.segment && (cursor.tick < t2)) {   /// selects notes with same levels on the same track
                        var el= cursor.element
                        if(el.type == Element.CHORD) {                    
                            for (var n in el.notes){
                                for (var l in levels[i]){
                                    if (levels[i][l]==n){
                                        if (counting=="up") {curScore.selection.select(el.notes[n], true) }      
                                        if (counting=="down") {curScore.selection.select(el.notes[el.notes.length-1-n], true) }    
                                    }
                                } 
                            }
                            if (levels[i].includes(100)){   /// check top or bottom note 
                                if (counting=="down") {curScore.selection.select(el.notes[0], true)}
                                if (counting=="up") {curScore.selection.select(el.notes[el.notes.length-1], true)}
                            }   
                        } 
                        cursor.next()   
                    }
                }
            }


        }

        if (copy==false){
            for (var i in tracks){                
                cursor.track=tracks[i]
                cursor.rewindToTick(t1)
                if (cursor.element){
                    while (cursor.segment && (cursor.tick <= t2)) {   /// selects notes with same levels on the same track
                        var el= cursor.element
                        if(el.type == Element.CHORD) {                    
                            for (var n in el.notes) {                               
                                if (levels[i].includes(n)){                             
                                    if (counting=="up") {curScore.selection.select(el.notes[n], true)}  
                                    if (counting=="down") {curScore.selection.select(el.notes[el.notes.length-1-n], true)}  
                                }
                            }
                            if (levels[i].includes(100)){   /// check bottom note 
                                if (counting=="down") {curScore.selection.select(el.notes[0], true)}
                                if (counting=="up") { curScore.selection.select(el.notes[el.notes.length-1], true)}
                            }                           
                        }
                        cursor.next()   
                    }
                }
            }
            curScore.endCmd()
        }
    }

    onRun: {
        var els = curScore.selection.elements 

        if (els[0].type==Element.CHORD || els[0].type==Element.NOTE) {
            makeSelection(false)
            quit() 
        }
        else{                   
            quit()  
        }
	}
}	



    
