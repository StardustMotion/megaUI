# API

### - [General rendering](#general-rendering)
### - [Mouse menu](#mouse-menu)

# General rendering

**Notes**
- If you prefer using raw SetHudSize/SetFont/HudMessage/SetHudClipRect ; or ACSUtils rendering functions instead of the below functions, you can.
    - However, [anchoring](#void-setanchorint-anchorvalue) only works when drawing with MegaUI's functions.
- All functions are expected to run in CLIENTSIDE context, on the affected player. So, **use [NamedExecuteClientScript](https://wiki.zandronum.com/ExecuteClientScript)**
    - ***Like any CLIENTSIDE context**, for a CLIENT => SERVER request (like "get a weapon", "change my velocity" etc), use [NamedRequestScriptPuke](https://wiki.zandronum.com/RequestScriptPuke)*


---

### `void Show(int hudMessageId, str graphic, int x, int y, int hudWidth, int hudHeight, int alpha)`

Renders a graphic. Stay on screen until erased with `Hide()`. Note that **x and y are non-fixed ints**

Internally shorthand for :
```
SetHudSize(hudWidth, hudHeight, true);
SetFont(graphic);
HudMessageBold(s:"A"; HUDMSG_PLAIN|HUDMSG_ALPHA, hudMessageId, CR_UNTRANSLATED, x << 16, y<<16, 0x8000000, alpha);
```
**Examples:**

```
Show(1000, "SOMEPIC", 160, 120, 320, 240, 1.0); // Draw SOMEPIC in middle of screen
Show(1001, "SOMEPIC", 160, 40, 640, 480, 0.5); // Draw 50% opaque SOMEPIC at reduced size, at screen top
```

---

### `void Draw(str graphic, int x, int y, int hudWidth, int hudHeight, int alpha)`
Same as `Show()`, but is drawn for 1 tic only. Does not need hudMessageId ; it always uses 0.

`Draw()` elements will always be rendered on top of `Show()` elements.

--- 

### `void ShowText(int hudMessageId, str text, str font, int x, int y, int hudWidth, int hudHeight, int wrap, int alpha, int flags)`
Like `Show()` but for text. Particular parameters :

- `wrap` same as `SetHudClipRect`'s `wrapwidth` 
- `flags` additive flags :
    - `MGUI_CENTER` to center text (internally SetHudSize's `x |= 0.4`)
    - `MGUI_TYPEON` for delayed text typing (internally `HUDMSG_TYPEON`). Specify delay duration as `(MGUI_TYPEON|duration)`

**Examples**
```
ShowText(1002, "Bottom text", "SMALLFONT", 160, 200, 320, 240, 0, 1.0, 0);                // Basic text draw
ShowText(1002, "Loading...", "BIGFONT", 160, 120, 320, 240, 0, 1.0, MGUI_TYPEON|0.08);    // 0.08s per character typing "Loading..." in middle of the screen
ShowText(1003, "A big block of text that will be forced to take several lines due to small wrapping ; and it's centered ; and it uses delayed typing", 
    "BIGFONT", 160, 120, 320, 240, 80, 1.0, MGUI_CENTER|MGUI_TYPEON|0.02);
```

---

### `void DrawText(str text, str font, int x, int y, int hudWidth, int hudHeight, int wrap, int alpha, int flags)`
Like `Draw()` but for text.

--- 

### `void Hide(int hudMessageId)`
Removes a previously `Show()`/`ShowText()` rendered element.

Internally shorthand for `HudMessageBold(s:""; HUDMSG_PLAIN, hudMessageId, 0, 0, 0, 0, 0); `

**Example**
```
Show(1000, "SOMEPIC", 160, 120, 320, 240, 1.0);
delay(35);
Hide(1000); // Hide SOMEPIC
```

---

### `void HideRange(int hudMessageId, int count)`
Shorthand for `count` consecutive `Hide()` calls, starting from `hudMessageId`.

So `HideRange(1000, 3)` is same as `Hide(1000); Hide(1001); Hide(1002);`

---
### `void Crop(int left, int top, int width, int height, int hudWidth)`
Same as `SetHudClipRect()` : it hides pixels outside of the crop area ; until `Uncrop()` is called

The extra `hudWidth` parameter is required for [anchor](#void-setanchorint-anchorvalue) support. It must match the element that will be cropped's `hudWidth`

---

### `void Uncrop(void)`
Stop previous `Crop()`'s effect


**Cropping example**
```
Crop(                   160, 120, 16, 16,   320);           // Enable cropping
Show(1005, "32x32PIC",  160, 120,           320, 240, 1.0); // Only the 16x16 bottom right of this sprite will be rendered
Uncrop();                                                   // Disable it
```



---
### `void SetAnchor(int anchorValue)`
Keeps subsequent `Draw()`/`Show()` calls at a fixed offset from the screen edge, even if player has a wider game resolution than 4:3.
- `anchorValue = MGUI_LEFT` : offset from left edge
- `anchorValue = MGUI_RIGHT` : offset from right edge

Stop the effect with `ClearAnchor()`

---

### `void ClearAnchor()`
Stops `SetAnchor()`'s effect


**Anchoring example**
```
SetAnchor(MGUI_LEFT);
Show(1006, "MUGSHOT", 30, 240, 320, 240, 1.0);  // Will be anchored to left side of screen
SetAnchor(MGUI_RIGHT);
Show(1006, "WEAPON", 280, 240, 320, 240, 1.0);  // Will be anchored to right side of screen
ClearAnchor();                                  // Stop anchor's effect
```




---



# Mouse menu
### `bool StartMouseMenu(str scriptName)`
Enables mouse menu. It will send mouse events to the given `scriptName` callback script with the arguments `(int e, int areaId)` :

- `e` event type, either
    - `MGUI_EVENT_ENTER`    on mouse entering an area
    - `MGUI_EVENT_EXIT`     on mouse exiting an area
    - `MGUI_EVENT_DOWN`     on fire button press
    - `MGUI_EVENT_UP`       on fire button release
    - `MGUI_EVENT_ALT_DOWN` on altfire button press
    - `MGUI_EVENT_ALT_UP`   on altfire button release
- `areaId` the mouse area id that triggered it
    - For fire/altfire button actions, if no area is hovered, `areaId`'s value will be `MGUI_NULL_AREA`

The function returns `false` if it could not start due to another mod already using the mouse menu, or if the callback script does not exist.

---

### `void EndMouseMenu()`
Stops the ongoing mouse menu

---

### `void SetMouseArea(int areaId, int x, int y, int hudWidth, int hudHeight, int width, int height)`
Registers an area that sends mouse events. 

- `width`/`height` is the area's dimensions, as if it was a graphic file.
- `areaId` must be >= 0
- When the mouse is within several areas, only the one with lowest `areaId` will trigger events (similar to hudMessage id priority) 

--- 
### `int GetMouseArea(void)`
Returns the currently hovered mouse areaId, or `MGUI_NULL_AREA` if none

--- 
### `void DeleteMouseArea(int areaId)`
Unregisters a `SetMouseArea()` defined area

---
### `void DeleteMouseAreaRange(int areaId, int count)`
Shorthand for `count` consecutive `DeleteMouseArea()` calls, starting from `areaId`.

So `DeleteMouseAreaRange(0, 3)` is same as `DeleteMouseArea(0); DeleteMouseArea(1); DeleteMouseArea(2);`


**Simple mouse setup example**

```
script "Mouse Test" (void) CLIENTSIDE {

    // Enable mouse menu mode. Receive mouse events in the given script
    StartMouseMenu("Mouse Test Callback");          

    int x = 50, y = 45, hudWidth = 174, hudHeight = 131;

    // Render some 32x32 mugshot
    Show(1000, "FACE1", x, y, hudWidth, hudHeight, 1.0);     

    // Register a 32x32px area centered on mugshot's position (effectively covering the mugshot's surface) that will send mouse events
    SetMouseArea(1000,  x, y, hudWidth, hudHeight, 32, 32);  
}

// Mouse events handler
script "Mouse Test Callback" (int e, int areaId) CLIENTSIDE {
    switch(e) {

        case MGUI_EVENT_ENTER:
            log(s:"Mouse entered area ", d:areaId, s:" !!");
            break;

        case MGUI_EVENT_EXIT:
            log(s:"Mouse exited area ", d:areaId, s:" !!");
            break;

        case MGUI_EVENT_DOWN:
            // Only proceed if clicked on a registered area
            if(areaId == MGUI_NULL_AREA)
                terminate;
            else 
                log(s:"Left clicked on area ", d:areaId, s:" !!");
            break;
        
        // Proceed on right click, whether or not an area was clicked
        case MGUI_EVENT_ALT_DOWN:
            // Interrupt the mouse menu
            log(s:"Right clicked! Ending mouse menu.");
            EndMouseMenu();
            Hide(1000);
            break;
    }
}
```




---

### `void SetMouseSpeed(int speed)`
Change mouse speed multiplier (default 1.0)

---

### `void SetCustomMouse(str graphic, int offsetX, int offsetY, int hudWidth, int hudHeight)`
Customizes the mouse cursor. Particular parameters :


- `graphic` the mouse graphic
- `offsetX` and `offsetY` position offset. If 0 and 0, `graphic` will be drawn centered on mouse's position

**Examples**

```
SetCustomMouse("DOOMCURS", 7, 14, 320, 240);    // A classic screen pointer - drawn at bottom right hand corner of mouse position
SetCustomMouse("RETICLE", 0, 0, 80, 60);        // A big reticle centered on mouse position
```

---
### `int GetMouseX(void)`
### `void SetMouseX(int value)`
### `int GetMouseY(void)`
### `void SetMouseY(int value)`
Get or set the mouse menu's mouse current position.

- A default 4:3 resolution like 800x600's value will be within `[0.0, 1.0]` 
- Wider resolution can exceed the range, like `[-0.5, 1.5]` for a theoretical 8:3 resolution

**Examples**
```
// Resets the mouse to the center of the screen
SetMouseX(0.5);
SetMouseY(0.5);

// Classic use case : render something on mouse's position
int hudWidth = 320, hudHeight = 240;
Draw("ITEM", (GetMouseX() * hudWidth) >> 16, (GetMouseY() * hudHeight) >> 16, hudWidth, hudHeight, 1.0);
```

--- 

### `int GetRawMouseDeltaX(void)`
### `int GetRawMouseDeltaY(void)`

Get the **physical mouse**'s position difference since previous tic. This has no unit, so just try and see.
