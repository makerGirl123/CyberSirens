#!/bin/sh
#searching for possible unwanted files based on file types
#searches for photos, audio, video, executables, and scripts

#photos
find /home -name *.jpg > unwanted.txt
find /home -name *.jpeg >> unwanted.txt
find /home -name *.png >> unwanted.txt
#audio/video
find /home -name *.mp3 >> unwanted.txt
find /home -name *.mp4 >> unwanted.txt
find /home -name *.wav >> unwanted.txt
#executable/scripts
find /home -name *.exe >> unwanted.txt
find /home -name *.vbs >> unwanted.txt
find /home -name *.xls >> unwanted.txt
find /home -name *.js >> unwanted.txt
find /home -name *.rb >> unwanted.txt
find /home -name *.py >> unwanted.txt
find /home -name *.pyc >> unwanted.txt