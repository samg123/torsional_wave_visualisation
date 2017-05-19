Matlab Torsional Wave Visualisation Program (1.3) by Sam Greenwood (14/05/17)

This program offers 3 ways to visualise torsional wave propogation in the 
earths core as animations. The main program (main.m) relies upon the 5
included external functions: displacements.m, make_cylinder.m, scatterplot.m,
cylinders_2D.m and cylinders_3D.m. These should not need editting as all
options are specified in the input file. One exception may be that ffmpeg may
require the path to it's executable file (explained below).

Three types of animation can be created:

1. Scatter: A 2D equitorial slice view where a random scatter of dots are plotted and
advected according to the data.

2. 2D cylinders: Another 2D equitorial slice view where the radial domain is
averaged to a user specified number of concentric cylinders. These cylinders
are then rotated according to the data.

3. 3D cylinders: A 3D animation of the core represented as a user specified 
number of concentric cylinders. These cylinders are then rotated according to
the data. An optional introduction animation can be included.

For all the animations a colour scheme is used to show velocity, the time in
each frame is displayed in the title and a circle is plotted to show the radius
of the tangent cylinder (inner core radius).

To run the program first edit the input file to your requirements. The format of the input
file must be preserved, the order of the variables being read and what line they are on
in is hard coded and as such will error if this changes.
Then run: main('input.txt') in the matlab command window (where input.txt is the
name of the input file you wish to use). The code will run and a progress bar will show how far through it is.
It first resizes the data by interpolation to your specified number of cylinders and frames,
then creates the plots (which are kept hidden for speed) and saves them as .png files to ./output_torsional.
If the movie format variable in the input file in NOT 0 then it will attempt to call ffmpeg by UNIX command to encode the frames into a movie (see below). 

One aspect to note is that the advection of the texture is vastly exaggerated to demonstrate the sense of motion.
The code was created such that peak velocities on the order of 1 (dimensions don't matter) provide ample motion of
the texture. If you're own velocities are too small or too large then change the velocity scale factor in the input file.
This will multiply the velocities by this factor when advecting the texture but will not affect the colour scale of the plots.

Required Data Format:

The data file must contain velocity values in space and time. These values will be used to advect
the texture in the theta direction (positive = anti-clockwise).
It must be an ascii file with no headers or footers and lxm (rowsxcolumns) in size.
l is the number of radial points and m is the number of temporal points. Both time
space data are assumed to have uniform spacing and the spatial domain starts at radius = 0
with the last row containing data for the outermost radius.

Movie Encoding (requires UNIX):

The indivual frames of the animation are saved to './output_torsional' where
'./' denotes the directory in which matlab is running from. If the ffmpeg command line 
tools are installed then the command to encode the frames into a movie is included within
main.m and will run automatically (ffmpeg can be installed from https://ffmpeg.org/).
If they are not installed then this command can be turned off in the input file
and encoding is left to the user.
Depending on how Matlab is set up it may not recognise the
ffmpeg command. In this case the 'loc' variable in main.m, in the movie_enc function
needs to be set to the location where ffmpeg is installed.

Examples:

Included in this repository is an example data set (simple gaussian pulse) and a dataset
presented in figure 3 of Cox et al (2014). A movie of each style of animation for the
data is provided in the output_torsional folder as is an example input file used to create them.

Contact:

If you have any questions, find any bugs or have any requests for features feel free to contact me at
ee12sg@leeds.ac.uk

Python:

A python version of this code is currently in the works but with no definite ETA. If you would like to
be notified when this has been completed, drop me an email.

Reference:

G. A. Cox, P. W. Livermore, J. E. Mound; Forward models of torsional waves: dispersion 
and geometric effects. Geophys J Int 2014; 196 (3): 1311-1329. doi: 10.1093/gji/ggt414
