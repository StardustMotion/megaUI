# API

- [General rendering](#general-rendering)
- [Mouse menu](#mouse-menu)
    - [Example](#mouse-menu-example)
    - [Events](#mouse-menu-events)
    - [Misc](#mouse-menu-misc)

# General rendering

**Notes**
- If you prefer using raw SetHudSize/SetFont/HudMessage/SetHudClipRect ; or ACSUtils rendering functions instead of the below functions, you can.
    - However, [Anchoring](#anchoring) and [SetTextColor()](#void-settextcolorstr-code) only work when drawing with MegaUI's functions.
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
Like `Show()` but for text.

- `wrap` same as `SetHudClipRect`'s `wrapwidth` *(set to 0 for default/no wrap)*
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

### `void SetTextColor(str code)`
Change the default text color of subsequent `DrawText()`/`ShowText()` calls, by automatically applying a `\c[code]` TEXTCOLO prefix to them.

**Example**
```
// These two blocks display the same result

// Block A
SetTextColor("g");
ShowText(1000, "Red text A"
ShowText(1001, "Red text B"
SetTextColor("N3");
ShowText(1002, "Neon Orange text A"

// Block B
ShowText(1000, "\cgRed text A"
ShowText(1001, "\cgRed text B"
ShowText(1002, "\c[N3]Neon Orange text A"
```

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
## Cropping
```
Crop(160, 120, 16, 16, 320);                        // Enable cropping
Show(1005, "32x32PIC", 160, 120, 320, 240, 1.0);    // Only the 16x16 bottom right of this sprite will be rendered
Uncrop();                                           // Disable it
```

### `void Crop(int left, int top, int width, int height, int hudWidth)`
Same as `SetHudClipRect()` : it hides pixels outside of the crop area ; until `Uncrop()` is called

The extra `hudWidth` parameter is required for [anchor](#void-setanchorint-anchorvalue) support. It must match the element that will be cropped's `hudWidth`

---

### `void Uncrop(void)`
Stop previous `Crop()`'s effect


---

## Anchoring

```
SetAnchor(MGUI_LEFT);
Show(1006, "MUGSHOT", 30, 240, 320, 240, 1.0);  // Will be anchored to left side of screen
SetAnchor(MGUI_RIGHT);
Show(1006, "WEAPON", 280, 240, 320, 240, 1.0);  // Will be anchored to right side of screen
ClearAnchor();                                  // Stop anchor's effect
```


### `void SetAnchor(int anchorValue)`
Keep subsequent `Draw()`, `Show()` and `SetMouseArea()` calls at a fixed offset from the screen edge, even if player has a wider game resolution than 4:3.
- `anchorValue = MGUI_LEFT` : offset from left edge
- `anchorValue = MGUI_RIGHT` : offset from right edge

Stop the effect with `ClearAnchor()`

---

### `void ClearAnchor()`
Stops `SetAnchor()`'s effect



---



# Mouse menu

General workflow:
1) Use `StartMouseMenu()` to enable the mouse menu and display the cursor
2) Register interactive 2D rectangles ("mouse areas") with `SetMouseArea()`
3) Add or remove event handlers with `AddMouseEnter()`, `AddMouseExit()`, `AddMouseDown()`, etc.
4) Use `EndMouseMenu()` to disable the mouse menu

## Mouse menu example

```
script "Mouse Menu Example" (void) CLIENTSIDE {
    int x =             160, 
        y =             120, 
        hudWidth =      320, 
        hudHeight =     240;

    StartMouseMenu();

    // Render a 32x32 mugshot ; register an interactable mouse area on it
    Show(1000, "FACE1", x, y, hudWidth, hudHeight, 1.0);     
    SetMouseArea(50, x, y, hudWidth, hudHeight, 32, 32);  

    // Let's add "on mouse hover"/"on mouse left click" event handlers on that mouse area
    AddMouseEnter(50, "Mouse Menu On Enter");
    AddMouseDown(50, "Mouse Menu On Click");

    // Let's add "on any right click on the screen" event handler
    AddMouseAltDown(MGUI_SCREEN_AREA, "Mouse Menu On Right Click");
}

script "Mouse Menu On Enter" (int areaId, int e) CLIENTSIDE {
    Log(s:"Mouse entered areaId = ", d:areaId); // areaId == 50
}

script "Mouse Menu On Click" (int areaId, int e) CLIENTSIDE {
    Log(s:"Mouse left clicked on areaId = ", d:areaId); // areaId == 50
}

script "Mouse Menu On Right Click" (int areaId, int e) CLIENTSIDE {
    Log(s:"Mouse has right clicked ; ending mouse menu");
    EndMouseMenu();
    Hide(1000);
}
```

---

### `bool StartMouseMenu(void)`
Enables the mouse menu, and start displaying the cursor.

Returns `false` if could not start due to another mod already using the mouse menu.

---

### `void EndMouseMenu()`
Stops the running mouse menu.

---

### `void SetMouseArea(int areaId, int x, int y, int hudWidth, int hudHeight, int width, int height)`
Registers (or update) a mouse area's bounding box with id `areaId`.

- `areaId` must be 0 <= areaId <= 2,147,483,646
- `width`/`height` is the area's dimensions, as if it was a graphic file
- If overlapping areas share the same [event](#mouse-menu-events) type, the mouse will interact with the one having the lower `areaId` value.

--- 
### `bool CheckMouseArea(int areaId)`
Returns `true` if the mouse is currently hovering over `areaId`.


--- 
### `void DeleteMouseArea(int areaId)`
Unregisters a `SetMouseArea()` defined area and all its [events](#mouse-menu-events).

---
### `void DeleteMouseAreaRange(int areaId, int count)`
Shorthand for `count` consecutive `DeleteMouseArea()` calls, starting from `areaId`.

So `DeleteMouseAreaRange(0, 3)` is same as `DeleteMouseArea(0); DeleteMouseArea(1); DeleteMouseArea(2);`


---

## Mouse menu events

```
script "Various event handling styles" (void) CLIENTSIDE {
    SetMouseArea(51, 40, 120, 320, 240, 32, 32);
    SetMouseArea(52, 80, 120, 320, 240, 32, 32);
    SetMouseArea(53, 120, 120, 320, 240, 32, 32);

    // Area 51, Enter event : 1 script
    AddMouseEnter(51, "On Area 51 Enter");

    // Any area, Exit event : 1 script
    AddMouseExit(51, "On Any Area Exit");
    AddMouseExit(52, "On Any Area Exit");
    AddMouseExit(53, "On Any Area Exit");

    // Area 52, Down + AltDown event : 1 script
    AddMouseDown(52, "On Area 52 Any Click");
    AddMouseAltDown(52, "On Area 52 Any Click");
}

script "On Area 51 Enter" (void) {
    Log(s:"Area 51 with event type MGUI_EVENT_ENTER triggered");
}

script "On Any Area Exit" (int areaId) {
    Log(s:"Area ", d:areaId, s:" with event type MGUI_EVENT_EXIT triggered");
}

script "On Area 52 Any Click" (int areaId, int e) {
    if(e == MGUI_EVENT_DOWN)
        Log(s:"Area 52 with event type MGUI_EVENT_DOWN triggered");
    else if(e == MGUI_EVENT_ALT_DOWN)
        Log(s:"Area 52 with event type MGUI_EVENT_ALT_DOWN triggered");
}
```

### `void AddMouseEnter(int areaId, int scriptName)`
### `void AddMouseExit(int areaId, int scriptName)`
### `void AddMouseDown(int areaId, int scriptName)`
### `void AddMouseUp(int areaId, int scriptName)`
### `void AddMouseAltDown(int areaId, int scriptName)`
### `void AddMouseAltUp(int areaId, int scriptName)`

Sets `areaId`'s event handler script to `scriptName`.
- The event handler script's received arguments are  `int areaId, int e` :
    - `areaId` : the mouse area that triggered the event
    - `e` : event type as per the below table.

| Method | Role | `e` value |
| - | - | - |
| `AddMouseEnter()` | Mouse enters area | `MGUI_EVENT_ENTER` |
| `AddMouseExit()` | Mouse leaves area | `MGUI_EVENT_EXIT` |
| `AddMouseDown()` | Mouse left (mainfire) button press on area | `MGUI_EVENT_DOWN` |
| `AddMouseUp()` | Mouse left (mainfire) button release on area | `MGUI_EVENT_UP` |
| `AddMouseAltDown()` | Mouse right (altfire) button press on area | `MGUI_EVENT_ALT_DOWN` |
| `AddMouseAltUp()` | Mouse right (altfire) button release on area | `MGUI_EVENT_ALT_UP` |

- To set a event handler script to the entire screen area, you can use the special `areaId` value `MGUI_SCREEN_AREA`.

--- 

### `void AddAllMouseEvents(int areaId, int scriptName)`
A shorthand for calling the six previous `AddMouse` functions.

---

### `void RemoveMouseEnter(int areaId)`
### `void RemoveMouseExit(int areaId)`
### `void RemoveMouseDown(int areaId)`
### `void RemoveMouseUp(int areaId)`
### `void RemoveMouseAltDown(int areaId)`
### `void RemoveMouseAltUp(int areaId)`

Remove the event handler script from `areaId` (if it has one).

**Example**
```
// This mouse menu reacts when alternating left and right clicks (anywhere on screen, using MGUI_SCREEN_AREA)
script "Alternate clicks" (void) CLIENTSIDE {
    StartMouseMenu();
    AddMouseDown(MGUI_SCREEN_AREA, "On left click");
}

script "On left click" (void) {
    Log(s:"You left clicked");
    RemoveMouseDown(MGUI_SCREEN_AREA);
    AddMouseAltDown(MGUI_SCREEN_AREA, "On right click");
}

script "On right click" (void) {
    Log(s:"You right clicked");
    RemoveMouseAltDown(MGUI_SCREEN_AREA);
    AddMouseDown(MGUI_SCREEN_AREA, "On left click");
}
```

---

### `void RemoveAllMouseEvents(int areaId, int scriptName)`
A shorthand for calling the six previous `RemoveMouse` functions.

---



## Mouse menu misc

### `void SetMouseSpeed(int speed)`
Change mouse speed multiplier (default 1.0)

---

### `void SetCustomMouse(str graphic, int offsetX, int offsetY, int hudWidth, int hudHeight)`
Customizes the mouse cursor.

- `graphic` the mouse graphic
- `offsetX` and `offsetY` position offset

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
Draw("SOMETHNG", (GetMouseX() * hudWidth) >> 16, (GetMouseY() * hudHeight) >> 16, hudWidth, hudHeight, 1.0);
```

--- 

### `int GetRawMouseDeltaX(void)`
### `int GetRawMouseDeltaY(void)`

Get the **physical mouse**'s position difference since previous tic. This has no unit, so just try and see.
