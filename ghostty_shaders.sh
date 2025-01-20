#!/bin/bash

# clone the git repo
#
git clone https://github.com/m-ahdal/ghostty-shaders.git ~/.config/ghostty/shaders

# Copy the results of this command to your Ghostty config
#
ls -al ~/.config/ghostty/shaders | grep glsl | awk -F" " '{print "# custom-shader = shaders/"$9}'
