# Chord Level Filter: *Plugin for MuseScore*
 A MuseScore 3.x/4.x plugin that selects and copies notes of similiar levels within a measure, a specific range, or the whole staff. Works with multiple staves and voices. 

 ## Usage 

 - Select a note(s) at the chord level(s) you wish to filter/select/copy.
   
 - Select an end note to which you want the selection extended.
    
 - If no end note is selected then, the selection will be extended to measure or score according to configuration.

 - Running the plugin twice consecutively will extend the selection to the whole staff.
   
 - The selection is automatically copied to clipboard. Paste normally using Ctrl+V.  

 - Works with multiple voices and staves. 


 ## Configuration Options
Change plugin parameters to whatever best suits your workflow:

***counting direction***: up|down

***strictCounting*** : effective when having chords of different sizes. sets behavior for top/bottom note selections.

***defaultExpansion***: single note/chord selections expand to measure|fullScore.

hint: assign a shortcut for quick action.

 ## Demo  
 
*Unstrict counting up:*
 
![up](https://github.com/Ash-86/Select-Copy-Chord-Levels/assets/108089527/eab7cf17-fb43-4bd8-bd2d-ba731680d3f2)

*Unstrict counting down:*
  
![down](https://github.com/Ash-86/Select-Copy-Chord-Levels/assets/108089527/cddca06c-08fc-498e-8975-93858a3d651b)

*Strict counting up:*

https://github.com/user-attachments/assets/a348be65-ac34-4bde-9fb1-e5776bb81359

*Strict counting down:*

https://github.com/user-attachments/assets/cdf853bb-06de-410e-b156-5dc88445eafe


 ## Changelog
 ### v2.0
 - Improvement: New configuration to select the full score or the current measure (original) in case of a single note selection
 - Improvement: New configuration to have a strict or unstrict (original) counting of the notes
 - Improvement: Split into 3 plugins 
    - Strict counting up, 
    - Strict counting up, 
    - Unstric counting up
 ### v1.1
 - Bug fix: Fixed selection in non-adjacent staves
 ### v1.1
 - Plugin name changed to Filter Similar Note Levels
 - Bug fix: Running the plugin when an annotation is selected doesn't crash the system anymore.
 - Bug fix: Selection now extends till the end of the score correctly.
 - Top notes can now be selected when there are chords with different sizes.
 - You can now choose whether you like the levels counted top-down or bottom-up. see **Configuration Options**. 

 
 ## Download and Installation
 Download folder, unzip and move it to your MuseScore plugin folder.  
 For more details on installation see [link](https://musescore.org/en/handbook/3/plugins#installation).

 
 ## Feedback
 Please feel free to send any suggestions, bug reports, or just let me know if you find the plugin helpful  :)

 ## Support 
 Making this plugin took time, effort and love.   
 If you appreciate this plugins and find it helpful, you can buy me a beer
 [here](https://www.paypal.com/donate/?hosted_button_id=BH676KMHGVHC8) :)


