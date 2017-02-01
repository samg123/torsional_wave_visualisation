#####Torsional Wave Visualisation Program (1.0) by Sam Greenwood (1/02/17)

This program offers 3 ways to visualise torsional wave propogation in the 
earths core as animations. The main program (main.m) relies upon the 5
included external functions: displacements.m, make_cylinder.m, scatterplot.m,
cylinders_2D.m and cylinders_3D.m. These should not need editting as all
options can be specified within main.m.

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

#####Required Data Format:

There must be two data files, both delimited text files. The first contains
the velocity data for each radial point at each point in time. As such the data
is a table lxm (rowsxcolumns) in size, where l is the number of radial points and m is the
number of temporal points. All velocities are assumed to be angular velocity and
the radial domain is assumed to be uniformly spaced from the center of the Earth
to the radius of the outer core.

The second data file contains m data values and are the times of each time step.
They are assumed to be uniformly spaced and have the same units as used for the
velocity (e.g. velocity and time data should be rad/year and years).

#####Movie Encoding

The indivual frames of the animation are saved to './output_torsional' where
'./' denotes the directory in which matlab is running from. How the frames are
encoded into a movie is left to the user. The recommended method is with ffmpeg.
If the ffmpeg command line tools are installed then the encoding command is
included within main.m and will run automatically. If they are not installed then
this command can be turned off by the user with the mov_out variable.

#####Examples

Included in this repository is an example data set (example_vel.txt and
example_time.txt) and an example movie of each style of animation for this data.
The data is a simple gaussian wave travelling outwards.

If you have any questions or find any bugs feel free to contact me at
ee12sg@leeds.ac.uk
