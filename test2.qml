
import QtQuick 2.5
import MuseScore 3.0



MuseScore {
	title: "Test 2 "
	description: "Extends selection to chord-notes with the similar chord-level and/or voice across the Staff"
	version: "1.0"
    categoryCode: "Editing-Tools"
    thumbnailName: ""	

    
    function displayMessageDlg(msg) {
        ctrlMessageDialog.text = qsTr(msg);
        ctrlMessageDialog.visible = true;
    }

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
            var staff = track/4   
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
        for (var i in Notes){
            if(!tracks.includes(Notes[i].track)){
                tracks.push(Notes[i].track)
            }
            if(!staves.includes(Notes[i].staff)){
                staves.push(Notes[i].staff)
            } 
        }


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
                    if (!lev.includes(Notes[n].level)){
                        lev.push(Notes[n].level)
                    }
                }
                else{                    
                }                
            }            
            levels.push(lev)
        }



       
        ///////////////////////////////////////////////////////
        var t1 = Notes[0].tick;  
        var t2 = Notes[0].tick;
        for (var i in Notes) {        
            if (Notes[i].tick < t1){
                t1 = Notes[i].tick
            }
            if (Notes[i].tick > t2){
                t2 = Notes[i].tick
            }
            else {                
            }
        }
        

        // cursor.rewindToTick(Notes[0].tick)  
        // cursor.setDuration(1,4)
        // cursor.addRest()
        // var e=cursor.element
        // removeElement(e)
        

        if (t2==t1) {   //// if notes selected belong to same chord or segment or only one note selected, make t1 and t2 start and end ticks of measure            
            cursor.rewindToTick(t2)                      
            t1= cursor.measure.firstSegment.tick
            t2= cursor.measure.lastSegment.tick-1
        }
        
       
        if(fullScore){
            var t1=curScore.firstMeasure.firstSegment.tick  /// first tick in score
            var t2=curScore.lastSegment.tick-1                //// last tick in score
        }

                    

        // var voiceSelected=[false,false,false,false]
        
        if (staves.length==1){
            for (var v=0;  v<4; v++){
                cursor.staff=staves[0]
                cursor.voice=v
                if (cursor.element){
                    cursor.rewindToTick(t1)
                    while (cursor.segment && (cursor.tick <= t2)) {   /// selects notes with same levels on the same track
                        var el= cursor.element
                        if(el.type == Element.CHORD) {                    
                            for (var n in el.notes) {                               
                                curScore.selection.select(el.notes[n], true)                                
                            }
                        }
                        cursor.next()   
                    }
                }
            }           

            // for(var i in voices){                
               
            //     var trackIdx=tracks.indexOf(staves[0]+voices[i])
            //     cursor.rewindToTick(t1)
            //     while (cursor.segment && (cursor.tick <= t2)) {   /// selects notes with same levels on the same track
            //         var el= cursor.element
            //         if(el.type == Element.CHORD) {                    
            //             for (var n in el.notes) {                                
            //                 if(levels[trackIdx].includes(n)){
            //                     curScore.selection.deselect(el.notes[n])
            //                 }                                
            //             }
            //         }
            //         cursor.next()   
            //     }
                
            // }

            // cmd("delete")


            //     cursor.rewindToTick(t1)
            //     if (cursor.element && !tracks.includes(track) && v!=0){
            //         // cursor.rewindToTick(t1)
            //         while (cursor.segment && (cursor.tick <= t2)) {   /// selects notes with same levels on the same track
            //             var el= cursor.element
            //             if(el.type == Element.CHORD) {                    
            //                 for (var n in el.notes) {
            //                     curScore.selection.select(el.notes[n], true)
            //                 }
            //             }
            //             cursor.next() 
            //         } 
            //         cmd("delete")
                    
            //         cursor.rewindToTick(t1)
            //         while (cursor.segment && (cursor.tick <= t2)) {   /// selects notes with same levels on the same track
            //             var el= cursor.element
            //             if(el.type == Element.REST) { 
            //                 curScore.selection.select(el, true)
            //             }                        
            //             cursor.next() 
            //         } 
            //         cmd("delete")
            //     }
                                   
            // }

            // for (var i in tracks){
            //     cursor.track=tracks[i]
            //     cursor.rewindToTick(t1)
            //     while (cursor.segment && (cursor.tick < t2)) {   /// selects notes with same levels on the same track
            //         var el= cursor.element
            //         if(el.type == Element.CHORD) {                    
            //             for (var n in el.notes) {                     
            //                 if(levels[i].includes(n)){
            //                     curScore.selection.deselect(el.notes[n])
            //                 }
            //                 else{
            //                     continue
            //                 }                   
            //             }        
            //         }
            //         cursor.next()   
            //     }                  
            // }

            // cursor.rewindToTick(t2)
            // cursor.next()
            // t2=cursor.tick  
            // cmd("delete")
            // curScore.selection.selectRange(t1, t2, cursor.staffIdx, cursor.staffIdx+1);
            // cmd("copy")
            // cmd("undo")

               
        }

        curScore.endCmd();
        	
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