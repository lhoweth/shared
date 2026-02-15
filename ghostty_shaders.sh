#!/bin/bash

# clone the git repo
if cd ~/.config/ghostty/shaders; then git pull; else git clone https://github.com/m-ahdal/ghostty-shaders.git ~/.config/ghostty/shaders; fi

# Copy the results of this command to your Ghostty config
sed -i '/ custom-shader/d' ~/.config/ghostty/config
echo -e "$( ls -al ~/.config/ghostty/shaders | grep glsl | awk -F" " '{print "# custom-shader = shaders/"$9 }END{print "\n"}' )" >> ~/.config/ghostty/config
