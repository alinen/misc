#! /python/bin
# This script using ImageMagic's convert utility to create thumbnails
# https://www.imagemagick.org/Usage/thumbnails/

import os
import os.path

def createThumbnail(inputPath, outputPath, filename):
    f, ext = os.path.splitext(filename)

    width = img.size[0]
    height = img.size[1]
    aspect = width/height
    newheight = 64.0
    newwidth = newheight * aspect
    size = newwidth, newheight

    thumbnail = img.thumbnail(size, Image.ANTIALIAS)
    img.save(outputPath+f+".thumbnail.png", "PNG")
    return img

inputPath = "media/hide/experiments/"
outputPath = "media/"
#filename = "1Dattractor1.png"
#createImageThumbnail(inputPath, outputPath, filename)

import images2gif

frames = images2gif.readGif(inputPath+"animationTest.gif",False)
for frame in frames:
    width = frame.size[0]
    height = frame.size[1]
    aspect = width/height
    newheight = 64.0
    newwidth = newheight * aspect
    frame.thumbnail((newwidth,newheight), Image.ANTIALIAS)

frames[0].save(outputPath+"test"+".thumbnail.png", "PNG")
images2gif.writeGif('test.gif', frames)

#img = Image.open(inputPath+"animationTest.gif")
#img.load()
