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

import QtQuick 2.5
import MuseScore 3.0
import "core.js" as Core

/**
 * 2.0:  Split in independant plugins (counting up vs. counting down)
 */
MuseScore {
    menuPath: "Plugins.Filter Similar Note levels"
    description: "Selects and copies notes of similiar levels within a measure, a specific range, or the whole staff. Works with multiple staves and voices."
    version: "2.0"

    //4.4 title: "Filter Similar Note levels"
    //4.4 thumbnailName: "thumbnail.jpg"
    //4.4 categoryCode: "Editing-Tools"

    Component.onCompleted: {
        if (mscoreMajorVersion >= 4) {
            title = "Filter Similar Note levels"
            thumbnailName = "thumbnail.jpg"
            categoryCode = "Editing-Tools"
        }
    }

    onRun: {
        
        var els = curScore.selection.elements

        if (((typeof els[0])!=="undefined") && (els[0].type == Element.NOTE)) {
            /**
            * @param up true|false(default) Counting notes up (from bottom) or down (from top)
            * @param forceFullScore true|false(default) Force analysing the full score whatever is the selection
            * @param strictCounting true|false(default, original mode) In strict mode, selecting notes 1,3 from 2-notes chord, only the 1st note of that chord will be selected. In non strict mode, the notes 1,2 will be selected
            * @param expandToFullScore true(default)|false 
            */
            Core.makeSelection(true, false, false, false);
            return;
        } else {
            console.log("Invalid selection");
            if (els.length>0) 
                  console.log("els[0]="+els[0].userName());
            else
                  console.log("no selection");

            return;
        }
    }


}