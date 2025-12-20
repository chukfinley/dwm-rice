#!/bin/bash
case $1 in
post)
sleep 2
DISPLAY=:0 xset dpms force off
sleep 4
DISPLAY=:0 xset dpms force on
;;
esac
