
import QtQuick 2.0
import MuseScore 3.0

MuseScore {
	title: "Select Similar Levels/Voices"
	description: "Extends selection to chord-notes with the similar chord-level and/or voice across the Staff"
	version: "1.0"
    categoryCode: "Editing-Tools"
    thumbnailName: ""
	


    function makeSelection(fullScore){    

        curScore.startCmd()
        var cursor = curScore.newCursor();
        
        var els = curScore.selection.elements

        //// get ticks of all selected elements
        var ticks=[]
        for (var i in els){
            ticks.push(els[i].parent.parent.tick)    
        }/////////////////////////////////       

        ////// get min and max ticks of selected elements ////
        var t1 = ticks[0];  
        var t2 = ticks[0];
        for (var i in ticks) {        
            if (ticks[i] < t1){
                t1 = ticks[i]       //min 
            }
            if (ticks[i] > t2){
                t2 = ticks[i]       //max
            }
            else {
                continue
            }
        }//////////////////////////////////// 

        /////// if 2 consecutive elements are next to each other, make t1 and t2 beginning and end of score.//// needs revision
        cursor.track=els[0].track
        cursor.rewindToTick(t1)        
        cursor.next()
        if (ticks.includes(cursor.tick)){
            fullScore=true
        }//////////////////
        


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
                t2= cursor.measure.lastSegment.tick-1
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

        curScore.endCmd();
        	
    }

    onRun: {
       
        makeSelection(false)         
        quit()        
	}///end onRun
}	