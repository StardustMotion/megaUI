- [Zandronum thread]()
- [MM8BDM thread](https://mm8bdm.net/forum/thread/megaui-a-zandronum-ui-library-319)

## MegaUI documentation

- [Intro](#intro)
- [Features](#features)
    - [Simplified rendering](#simplified-rendering)
    - [Screen anchor](#screen-anchor)
    - [Mouse Menu](#mouse-menu)
    - [UI Editor](#ui-editor)
- [Credits](#credits)


# Intro

A library made in ACS aiming for faster UI implementation, and ability to make mouse-interactable menus, in Zandronum.

### [\>\>\> Download v1.0.0\<\<\<](https://allfearthesentinel.com/zandronum/download.php?file=megaui-1.0.0.pk3) [*2026-09-19*]

[![ToVideo](./res/embeddedVideosWhen.png)](https://www.youtube.com/watch?v=gnVInIYzU8s)


### Quick showcase

Load it with Zandronum offline, start a map, then :
- Type `megagame1`, `megagame2`, `megagame3`, or `megagame4` in console to test a few minigames made with this library
- Type `megaui` in console to use the [UI Editor](#ui-editor)

### Mod integration

- **Zandronum >= 3.3 required**. Also make sure your compiler uses the latest [zdefs.acs / zspecial.acs](https://foss.heptapod.net/zandronum/acc)
- Copy [megaUI.acs](../src/acs_source/megaUI.acs) to your mod ; include it with `#include "megaUI.acs"`, and you're done
- After the below feature overview, you can check `megaUI.acs`'s functions (until `API ~ END`), and the 4 `megagameX` minigames' code as examples.
- *Screenshots below are from Mega Man 8-bit Deathmatch, but this can be used in other Zandronum games as well*

# Features


## Simplified rendering

Concise, wrapper functions around `HudMessage/SetHudSize/SetFont` for one-liners
```
// Render DOOMCURS graphic with hudMessageId = 1000
Show(1000, "DOOMCURS", 160, 120, 320, 240, 1.0);    

// Unrender it
Hide(1000);                                         

// Same as Show(), but only render for 1 tic
Draw("DOOMCURS", 160, 120, 320, 240, 1.0);          

// Text rendering 
ShowText(1001, "Bottom text", "BIGFONT", 160, 120, 320, 240, 320, 1.0, MGUI_CENTER) 

// Enable SetHudClipRect graphic cropping
Crop(160, 120, 32, 32, 320);                        

Show(1002, "DOOMCURS", 200, 120, 320, 240, 1.0);    
Show(1003, "DOOMCURS", 240, 120, 320, 240, 1.0);    
Show(1004, "DOOMCURS", 280, 120, 320, 240, 1.0);    

// Disable Crop() effect
Uncrop();                                           

// Shorthand for Hide(1002); Hide(1003); Hide(1004);
HideRange(1002, 3);                                 
```

## Screen anchor

Anchor makes graphic/text **position relative to left/right side of the screen**.

It effectively makes better use of screen space on resolutions wider than 4:3.
```
    // Enable anchoring to left side of screen
    SetAnchor(MGUI_LEFT);
    Show(1005, "FACE", 41, 429, 670, 502, 1.0);
    Show(1006, "MAPCDE1", 146, 448, 670, 502, 1.0);

    // Enable anchoring to right side of screen
    SetAnchor(MGUI_RIGHT);
    Show(1007, "VARHEALT", 156, 131, 189, 142, 1.0);

    // Disable anchoring
    ClearAnchor();
```

The result is given below, on the HUD at the bottom of the screen :

### **[800x600 / 4:3]**

![Anchor0](./res/anchor0.png) 

### **[800x450 / 16:9)** + Anchor **enabled**
![Anchor1](./res/anchor1.png) 

### **[800x450 / 16:9)** + Anchor **disabled**
![Anchor2](./res/anchor2.png)

## Mouse Menu

Use `StartMouseMenu()` to enable a **mouse cursor on screen** ; `EndMouseMenu()` to stop it.

While enabled, use `SetMouseArea()` to register rectangle areas on screen, and you will be notified of **mouse hover/exit/click** on said area via a callback script.

How does your UI react is up for your mod to implement. MegaUI only handles mouse control and send mouse events. 

```
script "Mouse Test" (void) CLIENTSIDE {
    // Render a 32x32 mugshot
    Show(1000, "FACE1", 50, 45, 174, 131, 1.0);     

    // Enable mouse menu mode
    StartMouseMenu("Mouse Test Callback");          

    // Register a 32x32px area (on mugshot's position) that sends mouse events 
    SetMouseArea(1000,  50, 45, 174, 131, 32, 32);  
}

// Mouse events
script "Mouse Test Callback" (int e, int areaId) CLIENTSIDE {
    // On hover
    if(e == MGUI_EVENT_ENTER) {
        log(s:"Mouse entered area ", d:areaId, s:" !!");
    }
    // On fire press
    else if(e == MGUI_EVENT_DOWN) {
        log(s:"Mouse left click (fire) pressed !! Stopping mouse menu.");

        // Disable mouse menu mode
        EndMouseMenu();
    }
}
```

![MouseMenu](./res/mouse0.png)

## UI Editor

An UI editor tool is included. 

It works like a painting software to **design your UI directly in-game**.

Start Zandronum with the MegaUI pk3 and type `megaui` in console to use it.

You can:
- Stamp graphic / text
- Draw interactable mouse areas' hitbox
- Inspect and change their position, hud size ("scale"), alpha, text wrap...
- Generate the ACS code with `megabuild` console command

### Example 
![Editor](./res/editor0.png)

### Generated code
(Use `logfile` Zandronum command to write to disk. *You can use a tool like [this website](https://cleantextkit.com/remove-timestamps/) to trim the logs' timestamps.*)

![Editor](./res/editor1.png)


# Credits
- Zandronum devs for the engine
- Beta testers : PinkRoboBlaster, Heelnavi
- Editor 
    - SFX from Dreamcast BIOS
    - Cursor from Kenney's cursor pixel pack
- Minigames
    - Music from Savaged Regime, Zero Wing, and Allanx
    - Resources from Stepmania assets [<1>](https://josevarela.net/SMArchive/Themes/ThemePreview.php?Category=SM3.9&ID=DDR3rd) / [<2>](https://josevarela.net/SMArchive/NoteSkins/Preview.php?Category=SM3.9&ID=ddr-ps3), Ukiyama's weapon loadout, Cutmanmike's Corruption Cards
- You for reading the docs

