#!/bin/bash
# Compile / build the .pk3 then boot it up in Zandronum
# Change path below to your zandronum.exe !!
pathZandronum="G:/games/megaman/8bdm/2023/3.3-alpha-r260112-1855\zandronum.exe"

./acc/cbins.exe build

$pathZandronum \
-iwad "G:/games/megaman/8bdm/2023/doom2.wad" \
-file "./acc/dist/megaUI-1.0.0.pk3" \
+sv_cheats 1

# -iwad "G:/games/megaman/8bdm/2023/megagame.wad" \
# -file "G:/games/megaman/8bdm/2023/MM8BDM-v6b.pk3" \

