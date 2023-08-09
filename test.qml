
import QtQuick 2.5
import MuseScore 3.0


MuseScore {
	title: "Test "
	description: "Extends selection to chord-notes with the similar chord-level and/or voice across the Staff"
	version: "1.0"
    categoryCode: "Editing-Tools"
    thumbnailName: ""	


    // function get1Max (array, min, max) {
    //     max = array[0];  //set min and max as the first element
    //     min = array[0];
    //     for (var i in array) {        
    //         if (array[i] < min){
    //             min = array[i]
    //         }
    //         if (array[i] > max){
    //             max = array[i]
    //         }
    //         else {
    //             continue
    //         }
    //     } 
    //     return min, max      
    // }


    function makeSelection(fullScore){    

        curScore.startCmd()
        var cursor = curScore.newCursor();
        
        var els = curScore.selection.elements

        //// get unique ticks and unique tracks and unique levels of all selected elements
        var ticks=[]
        var tracks=[]
        var levels=[]
        for (var i in els){
            if ( !ticks.includes(els[i].parent.parent.tick)){
                ticks.push(els[i].parent.parent.tick)
            }
            if (!tracks.includes(els[i].track)) {
                tracks.push(els[i].track)
            } 
            var pitch=els[i].pitch  
            var chord = els[i].parent
            for (var n in chord.notes){
                if (pitch==chord.notes[n].pitch){                   
                    var level=n
                }              
            }//////////////
            if (!levels.includes(level)) {
                levels.push(level)
            } 


        }/////////////////////////////////       
        ticks.sort()
        var t1= ticks[0]
        var t2= ticks[ticks.length-1]
       
        ////// get min and max ticks of selected elements ////
        // var t1 = ticks[0];  
        // var t2 = ticks[0];
        // for (var i in ticks) {        
        //     if (ticks[i] < t1){
        //         t1 = ticks[i]       //min 
        //     }
        //     if (ticks[i] > t2){
        //         t2 = ticks[i]       //max
        //     }
        //     else {
        //         continue
        //     }
        // }//////////////////////////////////// 

        /////// if 2 consecutive elements are next to each other, make t1 and t2 beginning and end of score.
        cursor.track=els[0].track
        cursor.rewindToTick(t1)        
        cursor.next()
        if (ticks.includes(cursor.tick)){
            fullScore=true
        }
        


        for (var i in els){   

            /////// get level //////
            var pitch=els[i].pitch  
            var chord = els[i].parent
            for (var n in chord.notes){
                if (pitch==chord.notes[n].pitch){                   
                    var level=n
                }
                else {
                    continue
                }
            }///////////////////

            cursor.track = els[i].track
            
            
            if(fullScore){
                var t1=curScore.firstMeasure.firstSegment.tick  /// first tick in score
                var t2=curScore.lastSegment.tick                //// last tick in score
            }
            if (t1==t2) {   //// if notes selected belong to same chord or segment, make t1 and t2 start and end ticks of measure
                cursor.rewindToTick(els[i].parent.parent.tick)  
                t1= cursor.measure.firstSegment.tick
                t2= cursor.measure.lastSegment.tick
                cursor.rewindToTick(t2)
                cursor.prev()
                t2=cursor.tick
            }            
           
            cursor.rewindToTick(t1)
        
            while (cursor.segment && (cursor.tick <= t2)) {   /// selects notes with same levels on the same track
                var el= cursor.element
                if(el.type == Element.CHORD) {                    
                    curScore.selection.select(el.notes[level], true)                    
                }
                cursor.next()   
            }
        }

        if (tracks.length==1 && tracks[0]%4==0){
            
            
            cursor.rewindToTick(t1)
        
            while (cursor.segment && (cursor.tick <= t2)) {   /// selects notes with same levels on the same track
                var el= cursor.element
                if(el.type == Element.CHORD) {
                    for (var n in el.notes){
                        if(levels.includes(n)){
                            curScore.selection.deselect(el.notes[n])
                        }
                        else{
                            curScore.selection.select(el.notes[n], true)
                        }  
                    }                
                }
                cursor.next()   
            }

            if(fullscore){
                var t3=t2
            }
            else{
                cursor.rewindToTick(t2)
                cursor.next()
                var t3=cursor.tick 
            }
            
            cmd("delete")
            curScore.selection.selectRange(t1, t3, cursor.staffIdx, cursor.staffIdx+1);
            cmd("copy")
            // cmd("undo")  

            // cursor.rewindToTick(t1)
        
            // while (cursor.segment && (cursor.tick <= t2)) {   /// selects notes with same levels on the same track
            //     var el= cursor.element
            //     if(el.type == Element.CHORD) {   
            //         for (var n in el.notes){
            //             if(!levels.includes(n)){
            //                 curScore.selection.deselect(el.notes[n])
            //             }
            //             else{
            //                 curScore.selection.select(el.notes[n], true)
            //             }  
            //         } 
            //     }
            //     cursor.next()
            // }        

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
        // cursor=curScore.newCursor()
        // var els = curScore.selection.elements

        // var prevTick=0
        // var prevTrack=0
        // var prevlevel=0
        
        

        // for (var i in els){
        //     var tick=els[i].parent.parent.tick  //// get ticks of all selected elements
        //     var track = els[i].track            

        //     var pitch=els[i].pitch
        //     var chord = els[i].parent
        //     for (var n in chord.notes){
        //         if (pitch==chord.notes[n].pitch){                   
        //             var level=n
        //         }
        //         else {
        //             continue
        //         }
        //     } 

            
        //     cursor.rewindToTick(tick)

        //     if (track==prevTrack && level==prevLevel) {
        //         makeSelection(true)
        //         quit()
        //     }       
        //     else{
        //         prevTick=tick
        //         prevTrack=track
        //         prevLevel=level
        //     }
        // }     
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