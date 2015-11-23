#! /bin/sh
(cd resources && glib-compile-resources --generate-source polaroid-cube-settings.resources)
valac --pkg gtk+-3.0 --pkg gmodule-2.0 src/gui.vala src/model.vala src/io.vala src/main.vala resources/polaroid-cube-settings.resources.c -o out/polaroid-cube
