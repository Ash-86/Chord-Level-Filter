
import QtQuick 2.5
import MuseScore 3.0



MuseScore {
	title: "Test "
	
    categoryCode: "Editing-Tools"
    thumbnailName: ""
	description: "Extends selection to chord-notes with the similar chord-level and/or voice across the Staff"
	version: "1.0"
      
   
    function noteObject(staff, voice, track, level, tick) {       
        this.staff = staff;
        this.voice = voice;      
        this.track = track;
        this.level = level;
        this.tick = tick;
    }

    function makeSelection(fullScore){    

        curScore.startCmd()
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
                    var level = n
                }
                else {                    
                }
            }  
            note = new noteObject(staff, voice, track, level, tick) 
            Notes.push(note)       
        }       

        ////// get min and max ticks of selected elements ////
        
        


        var tracks=[]  ///get unique tracks of selected notes
        var staves=[]   //get unique staves of selected notes
        var ticks=[]
        for (var i in Notes){
            if(!tracks.includes(Notes[i].track)){
                tracks.push(Notes[i].track)
            }
            if(!staves.includes(Notes[i].staff)){
                staves.push(Notes[i].staff)
            } 
            if(!ticks.includes(Notes[i].tick)){
                ticks.push(Notes[i].tick)
            } 
        }
        tracks.sort()
        staves.sort()
        ticks.sort()


        var voices=[]  ///get unique voices per staff
        for (var i in staves){
            var voic=[]
            for (var n in Notes){
                if(Notes[n].staff==staves[i]){                    
                    if (!voic.includes(Notes[n].voice)){
                        voic.push(Notes[n].voice)
                    }
                }
                else{                    
                }                                
            } 
            voic.sort()           
            voices.push(voic)
        }

        var levels=[] //get unique levels per track
        for (var i in tracks){
            var lev=[]
            for (var n in Notes){
                if(Notes[n].track==tracks[i]){
                    if (!lev.includes(Notes[n].level)) {
                        lev.push(Notes[n].level)
                    }
                }                                
            }
            lev.sort()            
            levels.push(lev)
        }

        

       
        ///////////////////////////////////////////////////////
        var t1= ticks[0]
        var t2= ticks[ticks.length-1]
        cursor.track=tracks[0]
        cursor.rewindToTick(t2)
        cursor.next()
        t2=cursor.tick  /////fix t2 to go till (end of last selected note)/(start of next note)

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
        }////not the best way to make sure the plugin has already run. 

        if (ticks.length==1) {   //// if notes selected belong to same chord or segment or only one note selected, make t1 and t2 start and end ticks of measure 
            cursor.rewindToTick(t1)  
            t1= cursor.measure.firstSegment.tick
            t2= cursor.measure.lastSegment.tick
        }               

        
        if(fullScore){
            var t1=curScore.firstMeasure.firstSegment.tick  /// first tick in score
            var t2=curScore.lastSegment.tick-1              //// last tick in score
        }

        var copy=true            
        for (var i=1; i<staves.length;i++){    //// check if selection are in consecutive staves in order to copy
            if ((staves[i]-staves[i-1]) >1){
                var copy=false
            }            
        }
        
        
        /////////////////////////////////////////////////////////
        if (copy==true){
            for(var s in staves){
                for (var v=0; v<4; v++){
                    var track=staves[s]*4+v
                    cursor.track=track
                    cursor.rewindToTick(t1)
                    
                    if(voices[s].includes(v)){
                        var trackIdx= tracks.indexOf(track)                     

                        while (cursor.segment && (cursor.tick < t2)) {   /// selects notes with same levels on the same track
                            var el= cursor.element
                            if(el.type == Element.CHORD) {  
                                var n= el.notes.length-1   
                                while (n>=0){
                                    if (!levels[trackIdx].includes(n)){
                                            el.remove(el.notes[n])
                                    }                                               
                                    n--                                                
                                }
                                // curScore.selection.select(el.notes[n], true)                                        
                                // }   
                                // else {
                                //     curScore.selection.deselect(el.notes[n])
                                // }
                            }
                            cursor.next()   
                        }                                                
                    }

                    if(!voices[s].includes(v) ){          /// if voice wasnt in selection but exists, delete it.            
                        while (cursor.segment && (cursor.tick < t2)) {   
                            var el= cursor.element
                            if(el.type == Element.CHORD) {                    
                                removeElement(el)
                                if(v!=0){
                                    var el= cursor.element                                                
                                    removeElement(el)
                                }                                
                            }
                            cursor.next()
                        }
                    }
                    
                }///end voices iteration
            }///end staves iteration

            curScore.endCmd();
            // cmd("delete")            
            // curScore.selection.selectRange(t1, t2, staves[0], staves[staves.length-1]+1);   
            // cmd("copy"); 
            // cmd("undo");
            

            // for (var i in tracks){                
            //     cursor.track=tracks[i]
            //     cursor.rewindToTick(t1)
            //     if (cursor.element){
            //         while (cursor.segment && (cursor.tick < t2)) {   /// selects notes with same levels on the same track
            //             var el= cursor.element
            //             if(el.type == Element.CHORD) {                    
            //                 for (var n in el.notes) {                               
            //                     if (levels[i].includes(n)){                             
            //                         curScore.selection.select(el.notes[n], true)
            //                     }                           
            //                 }
            //             }
            //             cursor.next()   
            //         }
            //     }
            // }


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
                                    curScore.selection.select(el.notes[n], true)
                                }                           
                            }
                        }
                        cursor.next()   
                    }
                }
            }
            curScore.endCmd();
        }
          

        	
    }

    // Keys.onDigit0Pressed: {
    //     makeSelection(true)
    // }
    
    

    // Item {
    //     id: pressKey
    //     focus: true
        // Keys.onPressed: {
           
        //     if ( event.key === Qt.Key_Up ){
        //         makeSelection(true)
        //     }
        //     else{
        //         quit()
        //     }
        // }
    // }

    onRun: {
        makeSelection(false)
        // keyPressEvent( QKeyEvent * event ) {
      
        //     if( event->key() == Qt::Key_A ) {
        //         makeSelection(true)
            
        //     }
        // }

        // Item {
        //     focus: true
        //     Keys.onPressed: (event)=> {
        //         if ((event.key == Qt.Key_Enter)) {
        //             makeSelection(true)
        //         }
        //         else{
        //             quit();
        //         }
        //     }
        // }
        quit()
        
	}///end onRun
}	