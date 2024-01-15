//==============================================================================
// Filter Similar Note Levels v1.0
// https://github.com/Ash-86/Filter-Similar-Note-Levels
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


/**
* @param up true|false(default) Counting notes up (from bottom) or down (from top)
* @param fullScore true|false(default) Force analysing the full score whatever is the selection
* @param strictCounting true|false(default, original mode) In strict mode, selecting notes 1,3 from 2-notes chord, only the 1st note of that chord will be selected. In non strict mode, the notes 1,2 will be selected
* @param expandToFullScore true(default)|false 
*/
function makeSelection(up, forceFullScore, strictCounting, expandToFullScore) {

    /// choose counting direction /////
    var counting = (up)?"up":"down";
    /// expand single selection to score or measure ? ///
    var defaultExpand=((typeof expandToFullScore === "undefined")||expandToFullScore)?"score":"measure";
    var strict=(strictCounting)?true:false;
    var fullScore=(fullScore)?true:false;
    

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
        
        console.log("els["+i+"]: "+els[i].userName());
        
        for (var n in chord.notes){
            if (pitch==chord.notes[n].pitch){                   
                if (counting=="up") {var level = n} 
                if (counting=="down") {var level = chord.notes.length-1-n}  
                if (!strict && (level==chord.notes.length-1)) {
                    level=100  /// special number for bottom or top notes -depending on counting direction
                }
            }                
        }  
        note = {staff:staff, voice:voice, track:track, level:level, tick:tick}  
        Notes.push(note)       
    }       

    
    var tracks=[]  ///get unique tracks of selected notes
    var staves=[]   //get unique staves of selected notes
    var ticks=[]     //get unique ticks of selected notes
    for (var i in Notes){
        if(!tracks.some(function(x){return x==Notes[i].track})){
            tracks.push(Notes[i].track)
        }       
        if(!staves.some(function(x){return x==Notes[i].staff})){
            staves.push(Notes[i].staff)
        }                       
        if(!ticks.some(function(x){return x==Notes[i].tick})){                          
            ticks.push(Notes[i].tick)
        }
    }
       staves.sort(function(a,b){return a-b})
       tracks.sort(function(a,b){return a-b})
       ticks.sort(function(a,b){return a-b})

    
    var voices=[];  ///get unique voices per staff        
    for (var i in staves){
        var voic=[]            
        for (var n in Notes){                
            if(Notes[n].staff==staves[i]){                    
                if (!voic.some(function(x){return x==Notes[n].voice})){ 
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
            if(Notes[n].track==tracks[i]){
                if (!lev.some(function(x){return x==Notes[n].level})){                            
                    lev.push(Notes[n].level)
                }
            }
        } 
        lev.sort()         
        levels.push(lev)
    }


    console.log("staves : ", staves,"voices : ", voices[0],voices[1], "tracks : ",tracks,"levels : " ,levels[0],levels[1], levels[2]  )

   
    ///////////////////////////////////////////////////////
        var t1 = ticks[0];  // min tick
        var t2 = ticks[ticks.length-1]; //max tick 

    cursor.track=tracks[0]
    cursor.rewindToTick(t2)
    cursor.next()
    if (cursor.tick==0){  //check if end of track or staff
        cursor.rewindToTick(t2)
        var endOfMeasureTick=cursor.measure.lastSegment.tick
        var endOfStaffTick= curScore.lastSegment.tick
        if (endOfMeasureTick==endOfStaffTick){
            var t2=curScore.lastSegment.tick+1 
        }
        else{
            t2= cursor.measure.lastSegment.tick  //in case of end of voice but not staff
        }             
    }
    else{
        t2=cursor.tick      /////fix t2 to go till (end of last selected note)/(start of next note)
    }


    /////////////////////////////  check if plugin has run once, if so, extends ticks to cover full score. 
    for (var i in tracks){   
        cursor.track=tracks[i]
        cursor.rewindToTick(t1)
        cursor.next()
        for (var n in Notes){
            if (Notes[n].track==tracks[i]){  //check if note belongs to current track
                if (Notes[n].tick==cursor.tick){ // check it the nots's tick is adjacent to first 
                    console.log("2nd call of the plugin, switching to fullscore mode");
                    fullScore=true
                }                    
            }                
        }
    }////not the best way to make sure the plugin has already run. Perhaps one can get the last entry in history and check if plugin had already run once. 


    if (ticks.length==1) {   //// if notes selected belong to same chord or segment or only one note selected, make t1 and t2 start and end ticks of measure    
        if(defaultExpand==="measure") {
            console.log("Single chord selection, extending to measure");
            cursor.rewindToTick(t1)                      
            t1= cursor.measure.firstSegment.tick
            t2= cursor.measure.lastSegment.tick
        } else {
            console.log("Single chord selection, extending to score");
            fullScore=true;
        }
    }
    
   
    if(fullScore){
        console.log("fullScore mode");
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
                if (voices[s].some(function(x){return x==v})){
                    var trackIdx= tracks.indexOf(track)
                    console.log(levels[trackIdx])
                    while (cursor.segment && (cursor.tick < t2)) {   /// selects notes with same levels on the same track
                        var el= cursor.element
                        if(el.type == Element.CHORD) {
                            for (var n= el.notes.length-1; n>=0; n--){                                   
                                var levelsensor=0
                                if (levels[trackIdx].some(function(x){return x==n})){                                         
                                    levelsensor++
                                }
                                if (n==el.notes.length-1 && levels[trackIdx].some(function(x){return x==100})){  /// check for top or bottom note
                                    levelsensor++
                                }
                                if (levelsensor==0){
                                        if (counting=="up") {el.remove(el.notes[n])}  
                                        if (counting=="down") {el.remove(el.notes[el.notes.length-1-n])}  
                                        notesDeleted++
                                } 
                            }
                        }
                        cursor.next()   
                    }                                                
                }

                if (!voices[s].some(function(x){return x==v})){           /// if voice wasnt in selection but exists, delete it.            
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
                            if (levels[i].some(function(x){return x==n})){ 
                                if (counting=="up") {curScore.selection.select(el.notes[n], true) }      
                                if (counting=="down") {curScore.selection.select(el.notes[el.notes.length-1-n], true) }    
                            }                                
                        }
                        if (levels[i].some(function(x){return x==100})){   /// check top or bottom note 
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
                while (cursor.segment && (cursor.tick < t2)) {   /// selects notes with same levels on the same track
                    var el= cursor.element
                    if(el.type == Element.CHORD) {                    
                        for (var n in el.notes) { 
                            if (levels[i].some(function(x){return x==n})){                           
                                if (counting=="up") {curScore.selection.select(el.notes[n], true)}  
                                if (counting=="down") {curScore.selection.select(el.notes[el.notes.length-1-n], true)}  
                            }
                        }
                        if (levels[i].some(function(x){return x==100})){   /// check bottom note 
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