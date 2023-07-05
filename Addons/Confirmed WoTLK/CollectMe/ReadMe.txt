New Author Added

Because Merla is unable to continue updates for Collect Me, Tolerant has agreed to keep up the minor updates for now. Please continue to post about any missing pets, mounts or incorrect information and they will do their best to resolve those issues promptly. Feel free to post suggestions or ideas, however they might not be put into effect anytime soon. They will be noted and hopefully be seen in a future release.
Merla is taking a break

Due to real life issues I had to stop playing World Of Warcraft, and so the add-on will no longer be updated by me. If anyone wants to continue the work on Collect Me, feel free to use whatever you want of the code. If you are an add-on author and you would like to help the original project rather than creating a new one, please send me a message and I'll add you as an author to the project. I'd like to thank all, who used this add-on in the past, especially those who gave feedback and reported errors.
Introduction

Collect Me keeps track of your companions (minipets) and mounts in the game and can show you your missing pets and mounts with additional information where to get them. It also can summon companions randomly with a priority list.
Basic Features

    * Ignore List
    * Filters
    * Source-information of pets and mounts
    * 3d model preview (sometimes ;) )
    * Priority-based random pet-summoning
    * auto-summoning on moving 

Known Bugs

On some occasions the Collect Me Summon Button doesn't show up directly after log-in in. A simple workaround should be the slash command:
/cm randomcompanion
Usage
Slash Commands

    * /collectme or /cm will bring up the main window.
    * /cm config or /cm options will bring up the options directly.
    * /cm randomcompanion will summon a random companion by using the priority list.
    * You also can use the "Collect Me" button in the Blizzard Pet/Mount Tab to start the add-on. 

The Main Window

When you start the Main Window the add-on will automatically build a mount and pet list based on your faction, class and professions.
By hovering over a pet or mount with the mouse you will receive additional information where to get it.
Ignore List

You can add pets to an ignore list by right-clicking on them, if you don't want them or you can't get them by any reasons.
Filters

In addition to the Ignore List, you can add some pre-configured filters in the option menu. Those filters will hide companions and mounts from both, the missing and the ignore list. This will allow you to keep the list small to bring in some general survey. By combining the filters and the ignore list you should have a good compromise of speed and detail.
Priority-based random companion summoning

The add-on can summon a random companion by using the slash command /cm randomcompanion. I highly recommend to use a macro for this.
To manage the priority list, go into the CollectMe options and select the subcategory: Random Companion. There you'll find a list of every companion you have and you can assign them priorities between 0 and 10 (default value for new companions is 5).

    * 0: If you set a companion to zero it will never be summoned.
    * 1-10: The higher the priority, the higher the chance that the companion will be summoned. 

NOTE: The chance depends not only on the companion priority but on all priorities of all companions.
Example

    * Companion A) 5
    * Companion B) 0
    * Companion C) 10
    * Companion D) 10 

That gives A a chance of 20% to be summoned. B will never be summoned (0 %). C and D have both a chance of 40% to be summoned.
The Collect Me Summon Button

By default you'll have a button where you can see the next companion which will be summoned. The companion is calculated by the priority list.
By left-clicking the companion will be summoned.
By right-clicking the companion will be skipped and a new companion will be calculated.
By shift-left-clicking the companion it will be de-summoned if already summoned.
You can simply drag the button to a place where you want. To lock it, go to the Collect Me Options. If you don't like the button and prefer the slash command instead you can easily hide the button in the options too.
3D Model Preview

By left-clicking on a mount or a companion you can bring up a window with a 3d preview of the mount or companion.
NOTE: You can only see models from your local cache. If the model has not been seen in-game, the preview window will remain empty. There is currently no possibility to workaround that fact.
Additional Information

    * Collect Me should work on all languages but the tool-tips with the Source-information will remain English. If someone likes to translate them, feel free to do it and send it to me so i can implement it.
    * If you have a pet or mount which the add-on doesn't know, you will receive a message in the default chat frame. Please let me know, so that I can add the pet or mount to the add-on.
    * I don't have the possibility to check the add-on on all possible professions/class/faction combos. So if you encounter any errors please let me know. 

Thanks

    * SkeeveSM for his add-on TheCollector which inspired me and where I've taken the base interface and some ideas and algorithms.
    * warcraftpets.com
    * warcraftmounts.com 