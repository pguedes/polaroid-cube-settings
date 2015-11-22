#! /bin/sh
valac --pkg gtk+-3.0 --pkg gmodule-2.0 src/gui.vala src/model.vala src/io.vala src/main.vala -o out/polaroid-cube
