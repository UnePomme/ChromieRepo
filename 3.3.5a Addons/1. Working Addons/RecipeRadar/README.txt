
Recipe Radar

(by Jay Miller [jnmiller@cryptofreak.org])

http://www.cryptofreak.org/projects/reciperadar

$Id: README.txt 1031 2008-03-27 05:41:46Z jnmiller $


Installation
~~~~~~~~~~~~
You've probably already installed the addon.  In case you're not sure how
to do it, unzip the archive to your

   ... \World of Warcraft\Interface\AddOns

directory.  A new directory called 'RecipeRadar' should appear, along with
several files and subdirectories.  That should be all you need to do to
use Recipe Radar.

When you get in game, you may want to map a key to toggle Recipe Radar.
You should be able to find the option to do this in your Key Bindings menu,
all the way at the bottom.  Otherwise, you can hit the new icon on your
minimap to open Recipe Radar or use the slash command, '/rrdr'.


Bugs
~~~~
If you spot a bug in this software, *please let me know!*  The best way
to do so is to hit the bug tracker at

   http://sourceforge.net/tracker/?group_id=165127

and leave a short report on what was happening at the time.  If possible,
please include the version of Recipe Radar that caused the bug and the
language of your WoW client.

Also in the bugs category are misplaced vendors.  The location information
for all of the vendors in the Recipe Radar database was retrieved in a 
mostly automated way, so some coordinates are incorrect.  If you come upon
a vendor whose mapped location does not match their actual location, please
let me know!  The most helpful thing you can do is this quick process:

   1) Target the mis-mapped vendor.
   2) Move your character exactly on top of the vendor.
   3) Enter the following slash command on a single line:

      /script SetMapToCurrentZone() local x, y = GetPlayerMapPosition("player")  RecipeRadar_Print(format("'%s': [%.3f, %.3f]", UnitName("target"), x, y))

   4) Record the text you see.  It should resemble this:
   
      'Drac Roughcut': [0.356, 0.489]
   
   5) File a bug report and include this text.

Thank you very much for your help!


Acknowledgements
~~~~~~~~~~~~~~~~
- I'd like to thank Nimrah for passing on Technetium's TGAtoBLP2 code.
  It dropped the almost 50 maps from 343k each to 130k each!
- Esamynn is responsible for Astrolabe, a high-quality, generic mapping
  addon that Recipe Radar now relies on.


Thanks for trying Recipe Radar!  Enjoy!
