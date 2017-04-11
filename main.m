% Torsional Wave Visualisation Program v1.2 by Sam Greenwood (11/4/17)
%
% This is the main program from which everything is controlled. The other
% included functions shoulnd't need editting. Edit the User Defined
% Variables (below) as appropriate. Once these have been editted, run the
% program and answer the questions in the command window in the main Matlab
% window. The program will then generate the individual frames for the
% animation and save them to './output_torsional'. The external functions
% should be in the same directory as this program otherwise an addpath
% command is needed for Matlab to recognise them.
% See my github for the latest version of this code:
% https://github.com/samg123/torsional_wave_visualisation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User Defined Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Vfile = 'example_vel.txt';      % File containing velocity data. Data is assumed to have units radians per unit time.
vel=dlmread(Vfile);             %Load the data
 
t_start = 0;                    %Set the time array, enter the start and end values for the simulation time.
t_end = 20;                     %Time units are assumed to be the same used in the velocity.
time = linspace(t_start,t_end,size(vel,2));



    
plot_type = 2;                  %Type of plot to generate. 1 = scatter plot, 2 = 2D cylinders, 3 = 3Dcylinders
    
n = 15;                         %Number of cylinders to approximate to (taken to be 100 for scatter plot)

user.nframes=100;               %Number of frames in the movie

mov_fps = 24;                   %Movie framerate (must be smaller than number of frames). 
    
user.n_tex = 300;               %number of texture points (recommended 300 for 2D/3D plots and 5000 for scatter plot)
    
user.tex_size = 20;             %Texture point marker size





mov_fmt = '.mp4';               %Output movie file format, can set to any format available to ffmpeg.
%ffmpeg_loc = '/usr/bin/';      %Requires ffmpeg cl tools. Set mov_fmt = 0 to skip encoding movie. May
                                %need to tell Matlab the location of ffmpeg if it doesn't recognise it
                                %(using the ffmpeg_loc variable)
    
intro_anim=0;                   %intro animation for 3D animation. (on=1, off=0)
    
user.x_axis=sprintf('Radius');  %Text for x axis label
    
user.y_axis=sprintf('Radius');  %Text for y axis label
    
user.fs = 10;                   %font size for x/y axis
    
user.tfs = 15;                  %font size for title
    
user.cbar_range = max(abs(vel(:)));  %Range of values for color scale to represent (will run from -cbar_range to cbar_range)
    
user.ct = ['Velocity'];         %Colorbar title
    
user.titletext = [' Years'];    %Unit of time values in 'time' array. This will be printed in the title e.g 1.45 Years
        
user.ticks = [-1,-0.3509,0,0.3509,1]; %Positions of Tick marks for x/y axis (must be >-1 and <1 inclusively)
    
user.lables = {'CMB','TC','0','TC','CMB'}; %Labels for these tick marks
    
user.az = -110;                 %az and el are the azimuth/elevation for the 3D view.
user.el = 20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define a colourscheme (the one defined below runs blue through white to red).
% Comment out and set 'cs' to equal a different colourscheme if desired (e.g cs = jet)

% user.cs = zeros(61,3);
% for i = 1:31
%     C = (i-1)/30;
%     user.cs(i,:) = [C,C,1];
% end
% 
% for i = 1:30
%     C = 1-(i/30);
%     user.cs(31+i,:) = [1,C,C];
% end
user.cs = jet;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


%Calculate number of iterations code must run and set up waitbar
if plot_type == 3
    user.ncalcs = 2*user.nframes + n + 124*intro_anim;
else
    user.ncalcs = 2*user.nframes + n;
end
user.bar = waitbar(0,'');

%Determine plot type, average velocities and run it.
if plot_type > 1
    V = avg_velocities(vel,n,user.nframes);
    
    if plot_type == 2
        user.tmpl = '2D';
        cylinders_2D(n,time,V,user)
    elseif plot_type == 3
        user.tmpl = '3D';
        cylinders_3D(n,time,V,user,intro_anim)
    else
    end
    
elseif plot_type ==1
    V = avg_velocities(vel,100,user.nframes);
    
    user.tmpl = 'scatter';
    scatterplot(100,time,V,user)
    
elseif plot_type ~=1 && plot_type ~=2 && plot_type ~=3
    error('!!plot_type must be 1,2 or 3!!')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Movie Encoding
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Call Matlab to run the ffmpeg unix command. Matlab may recognise the
% ffmpeg command line tool. If not uncomment the ffmpeg_loc variable and set to
% the path where ffmpeg is installed.

if mov_fmt ~= 0
    if exist('ffmpeg_loc','var') == 1
        loc = ffmpeg_loc;
    else
        loc = '';
    end
    
    command = [loc,'ffmpeg -framerate ',num2str(mov_fps),' -i ./output_torsional/',user.tmpl,'_%04d.png ./output_torsional/',user.tmpl,mov_fmt];
    unix(command);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    text = sprintf('\n \n If the movie has encoded correctly, would you like to delete the indivual .png frames? (y/n) \n CAUTION: ALL .PNG FILES IN THE DIRECTORY ./OUTPUT_TORSIONAL WILL BE DELETED! \n');
    choice = input(text,'s');
    if choice == 'y'
        unix('rm ./output_torsional/*.png');
    elseif choice == 'n'
    else
        disp('Neither y/n specified')
    end
    
else
end

disp('FINISHED')

