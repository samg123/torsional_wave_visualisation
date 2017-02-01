% Torsional Wave Visualisation Program 1.0 by Sam Greenwood (27/9/16)
%
% This program offers 3 ways to visualise torsional wave propogation in the
% earths core as movies. 4 external functions are provided with this program:
% 3 for the different visualisations and one for drawing cylinders. Of the
% visualisations, the first 2 show a 2D equatorial slice and the 3rd
% shows a full 3D representation of the core. 'scatterplot.m' generates a
% random set of data points across the equatorial slice then advects them
% acording to the velocity at that radius. 'cylinders_2D.m' and
% 'cylinders_3D.m' approximate the core to a user defined number of
% rotating concentic cylinders. All three types of animation output a series 
% of sequentially numbered png images saved into a folder named 'output'.
% This program is also sent up to encode them into a movie by using ffmpeg
% on a unix system. If ffmpeg is not installed or the system is not based
% on unix commands then the Movie Encoding section of this code is not
% needed. It is left to the user to decide how they would like the frames
% encoded into a movie.
% If you would like to be notified of any further updates to this code or
% have any questions, feel free to contact me at ee12sg@leeds.ac.uk


% Data formats:
% Velocity data needs to be a matrix of mxn (rowsxcolumns) where m=number
% of radial points and n=number of time steps, hence giving the velocity
% for every radius at each time step.

% Time data needs to be an array of length 1xn  with the value of time at each time
% step. This will be used to calculate the advection for all time as well as be displayed
% in the title of the plot. 

% Both velocity data and time data files must only contain the columns and
% rows (delimeted) of numbers. No headers or footers are assumed.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User Defined Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File containing velocity data
    Vfile = 'Grace_varyingB.txt';
% File containing time array
    Tfile = 'Grace_time.txt';
%Load the data
    vel=dlmread(Vfile);
    time=dlmread(Tfile);
    
%Naming template for output frames. They will be named as 'tmpl'_xxxx.png
%where xxxx will be the number of the frame.
    user.tmpl = 'grace';
%Output movie filename (set mov_out = 0 to skip encoding movie. Requires ffmpeg cl tools)
    mov_out = 'Grace_scatter.mp4';
%Number of frames in the movie
    user.nframes=100;
%intro animation for 3D animation. (on=1, off=0)
    intro_anim=1;
%number of texture points
    user.n_tex = 3000;
%Text for x axis label
    user.x_axis=sprintf('Radius/ km');
%Text for y axis label
    user.y_axis=sprintf('Radius/ km');
%font size for x/y axis
    user.fs = 10;
%font size for title
    user.tfs = 15;
%Data range for the colorbar to represent
    user.cbar_range = [-max(abs(vel(:))), max(abs(vel(:)))];
%Colorbar title
    user.ct = ['Velocity'];
%Unit of time values in 'time' array. This will be printed in the title e.g 1.45 Years
    user.titletext = [' Years'];
 % Tick marks for x/y axis (must be >-1 and <1 inclusively)
    user.ticks = [-1,-0.3509,0,0.3509,1];
%Labels for these tick marks
    user.lables = {'3480','TC','0','TC','3480'};
%az and el are the starting azimuth/elevation for the 3D view.
    user.az = -110;
    user.el = 20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Check with user directory output is ok to use
a=exist('output_torsional','dir');
if a == 0
    mkdir ./output_torsional
elseif a == 7
    text = sprintf('output_torsional  already exists. Is it ok to write files to it? (y/n) \n CAUTION: MATLAB WILL OVERWRITE FILES OF THE SAME NAME \n');
    an = input(text,'s');
    if an == 'n'
        error('Rename existing folder') 
    else
    end
end



%OpenGL must be used
set(gcf,'Renderer','OpenGL');
close(1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define a colourscheme (the one defined below runs blue through white to red).
% Set 'cs' to equal a different colourscheme if desired (e.g cs = jet)

% cs = zeros(61,3);
% for i = 1:31
%     C = (i-1)/30;
%     cs(i,:) = [C,C,1];
% end
% 
% for i = 1:30
%     C = 1-(i/30);
%     cs(31+i,:) = [1,C,C];
% end
cs = jet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ceil(user.n_tex/10) > size(vel,1)
    np = size(vel,1);
else
    np = ceil(user.n_tex/10);
end

%Ask user for choice of plot and run relavant program.
text = sprintf('Which type of plot would you like? (enter 1/2/3) \n 1. Scatter Plot \n 2. 2D cylinder approximation \n 3. 3D cylinder approximation \n ');
choice = input(text);

if choice > 1
    n = input('how many cylinders would you like to approximate to?: \n');
    V = displacements(vel,n,time,user.nframes);
    if choice == 2
        cylinders_2D(n,time,V,user,cs)
    elseif choice == 3
        cylinders_3D(n,time,V,user,cs,intro_anim)
    else
    end
elseif choice ==1
    V = displacements(vel,np,time,user.nframes);
    scatterplot(np,time,V,user,cs)
elseif choice ~=1 && choice ~=2 && choice ~=3
    error('!!Please enter 1,2 or 3!!')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movie Encoding
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Call Matlab to run the ffmpeg unix command. The framerate can be changed
% by placing a different number after '-framerate'. 
if mov_out ~= 0
    command = ['ffmpeg -framerate 24 -i ./output_torsional/',user.tmpl,'_%04d.png ./output_torsional/',mov_out];
    unix(command);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    text = sprintf('If the movie has encoded correctly, would you like to delete the indivual .png frames? (y/n) \n CAUTION: ALL .PNG FILES IN THE DIRECTORY ./OUTPUT WILL BE DELETED! \n');
    choice = input(text,'s');
    if choice == 'y'
        unix('rm ./output_torsional/*.png');
    elseif choice == 'n'
    else
        disp('Neither y/n specified')
    end
    
else
end



