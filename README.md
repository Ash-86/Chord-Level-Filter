# Filter Similar Note Levels: *Plugin for MuseScore 4.x*
 A MuseScore 4.x plugin that selects and copies notes of similiar levels within a measure, a specific range, or the whole staff. Works with multiple staves and voices. 

 ## Usage
 - Select a note(s) at the chord level(s) you wish to filter/select/copy.
   
 - Select an end note to which you want the selection extended.
    
 - If no end note is selected then, the selection will be extended over the current measure.

 - Running the plugin twice consecutively will extend the selection to the whole staff.
   
 - The selection is automatically copied to clipboard.
   
 - Just paste normally using Ctrl+V in any measure you like.  

 - The plugin supports multiple selections across multiple staves and voices simultaneously. 

 - However, if the selected notes are not in adjacent staves, the plugin will only filter/select, but not copy (limitation from Musescore not allowing copying non adjacent staves).

  ## Demo
 https://github.com/Ash-86/Select-Copy-Chord-Levels/assets/108089527/d7b92861-de82-4efb-9167-f7e60b75e5b6

 ## Configuration Options
You can choose the direction the code follows to count note levels. Just comment out the corresponding ***"var counting"*** at the beginning of the code to suit your preference. 
This is useful when having chords with different sizes.
 
 *Examples:* 
 
*If **var counting= "up"**, you can select 2nd notes from the bottom.*
 
![up](https://github.com/Ash-86/Select-Copy-Chord-Levels/assets/108089527/eab7cf17-fb43-4bd8-bd2d-ba731680d3f2)

*If **var counting= "down"**, you can select 2nd notes from the top.*
  
![down](https://github.com/Ash-86/Select-Copy-Chord-Levels/assets/108089527/cddca06c-08fc-498e-8975-93858a3d651b)


 *In both cases, top and bottom notes can be selected.*

 ## Changelog
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


