PongViewGL is a fairly lightweight (stupid) graphical
animation program written by Perry R. Cook in 2015.
It's based on a lot of simple GL/glut graphical 
displays I've written since 1995 or so.

There's just one C file + one header, and a make script
for each platform of MacOSX, Linux, and Windows64.

The animation depends on glut, which is no longer 
supported but still lives on as libraries that many
people still use.  Before you try compiling it from
scratch here, check the executables in ../PongViewGLbin
to see if any of those work for you.  If they do,
then look no further (unless you want to hack
the PongViewerGL code yourself).

If you do need to compile, you'll need gcc (that's all
i've tested it on).  If you get complaints about glut
or GL, then you'll need to get and install those.

Windows:  I found an odd combination of glut32 and glut64
that worked for Windows 8.  I also managed to build a 
Win32 version.  The make scripts use gcc (MinGC) to 
build those.  The folder also includes the .dll files
required at run time.  These need to either live in
the same folder from where you run PongViewGL.exe,
or in some directory in your PATH.

Linux:  Planet CCRMA (for Fedora) has glut and gcc 
installed already.  I have not tested other Linux
variants, but I'm sure it can be made to work.

I also managed to get this to work on RaspberryPi!!
The demos with chuck also work, and audio even works
pretty good at some sample rate lower than 44.1.  Try
chuck --srate16000 PongPhysics1.ck | ./PongViewGL 

MacOSX: Again, gcc and glut needed (need to install
XCode, go get glut, etc.)

Once you have it running, try:

chuck PongTest1.ck | ./PongViewGL

to see all of the types of shapes it understands

