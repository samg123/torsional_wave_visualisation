function main_test(input_file)
%Load user parameters
user = read_data(input_file);

%Load data file and print key values to screen
vel = dlmread(user.vfile);
print_var(user)

%Check for optional user settings
if sum(abs(user.cbar_range)) == 0
    user.cbar_range = [-max(abs(vel(:))),max(abs(vel(:)))];
end
if user.mov_fmt == '0'
    movie_toggle = 0;
else
    movie_toggle = 1;
end

%check for existence of output directory
a=exist('output_torsional','dir');
if a == 0
    mkdir ./output_torsional
end

%OpenGL must be used
set(gcf,'Renderer','OpenGL');
close all

%Calculate number of iterations code must run and set up waitbar
if user.plot_type == 3
    user.ncalcs = 2*user.nframes + user.n + 124*user.intro_anim;
else
    user.ncalcs = 2*user.nframes + user.n;
end

%Determine plot type, average velocities and run it.
if user.plot_type > 1
    V = avg_velocities(vel,user.n,user.nframes);
    
    if user.plot_type == 2
        user.tmpl = '2D';
        cylinders_2D(user,V)
    elseif user.plot_type == 3
        user.tmpl = '3D';
        cylinders_3D(user,V)
    else
    end
    
elseif user.plot_type ==1
    user.n = 100;
    V = avg_velocities(vel,100,user.nframes);
    
    user.tmpl = 'scatter';
    scatterplot(user,V)
    
elseif plot_type ~=1 && plot_type ~=2 && plot_type ~=3
    error('!!plot_type must be 1,2 or 3!!')
end 
    
%Encode the movie
if movie_toggle == 1
    movie_enc(user)
    
    text = sprintf('\n \n If the movie has encoded correctly, would you like to delete the indivual .png frames? (y/n) \n CAUTION: ALL .PNG FILES IN THE DIRECTORY ./OUTPUT_TORSIONAL WILL BE DELETED! \n');
    choice = input(text,'s');
    if choice == 'y'
        unix('rm ./output_torsional/*.png');
    elseif choice == 'n'
    else
        disp('Neither y/n specified')
    end
end
    
close all
disp('FINISHED')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function user = read_data(input_file)
%Read every 3rd line, starting from the 3rd in the input file. The order in
%which the variables are read in are hard-coded and must be consistent
%across different input files.

%Open the file and skip 2 lines.
fid = fopen(input_file);
skip2(fid);

%Read in the variables and save them to 'user'.
user.plot_type = str2num(fgetl(fid));
skip2(fid);

user.n =str2num(fgetl(fid));
skip2(fid);

user.nframes = str2num(fgetl(fid));
skip2(fid);

user.n_tex = str2num(fgetl(fid));
skip2(fid);

user.tex_size = str2num(fgetl(fid));
skip2(fid);

user.intro_anim = str2num(fgetl(fid));
skip2(fid);

user.vfile = fgetl(fid);
skip2(fid);

user.times = str2num(fgetl(fid));
skip2(fid);

user.cbar_range = str2num(fgetl(fid));
skip2(fid);

user.factor = str2num(fgetl(fid));
skip2(fid);

user.mov_fmt = fgetl(fid);
skip2(fid);

user.mov_fps = str2num(fgetl(fid));
skip2(fid);

user.titletext = [' ',fgetl(fid)];
skip2(fid);

user.ct = fgetl(fid);
skip2(fid);

user.cs = fgetl(fid);
skip2(fid);

user.ax_lables =  strsplit(fgetl(fid),',');
skip2(fid);

user.ticks = str2num(fgetl(fid));
skip2(fid);

user.lables =  strsplit(fgetl(fid),',');
skip2(fid);

user.fs = str2num(fgetl(fid));
skip2(fid);

user.view = str2num(fgetl(fid));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function skip2(fid)
%Skip 2 lines in the input file
fgetl(fid);
fgetl(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_var(user)
disp(['Data file: ',user.vfile])

if user.plot_type == 1
    a = 'Scatter plot (1)';
elseif user.plot_type == 2
    a = '2D cylinders (2)';
elseif user.plot_type == 3
    if user.intro_anim == 1
        a = '3D cylinders (2) with intro animation';
    else
         a = '3D cylinders (2)';
    end
end

disp(['Plot: ',a])
if user.plot_type > 1
    disp(['Number of cylinders: ',num2str(user.n)])
end
disp(['Number of cylinders: ',num2str(user.n)])
disp(['Number of frames: ',num2str(user.nframes)])

if user.mov_fmt == '0'
    b = 'No';
else
    b = 'Yes';
end
disp(['Encoding movie: ',b])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function movie_enc(user)

%May need to define the ffmpeg executable path, usually at '/usr/bin/'
loc = '';

if user.plot_type == 1
    tmpl = 'scatter';
elseif user.plot_type == 2
    tmpl = '2D';
else
    tmpl = '3D';
end

command = [loc,'ffmpeg -framerate ',num2str(user.mov_fps),' -i ./output_torsional/',tmpl,'_%04d.png ./output_torsional/',tmpl,'.',user.mov_fmt];
unix(command);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function V = avg_velocities(vel,n,nframes)
%Averages velocities given in vel into a matrix V that is nxnframes large.

%The average velocity over the width of the cylinder or over a given time
%step is found by integrating the data over that range and then dividing by
%that range. The code averages over the smaller dimension of vel first and
%then the larger to save computing time.


%Define width of each cylinder (dx) and time step (dt) and create arrays to
%store the averaged velocities
dx = (size(vel,1)-1)/n;
dt = (size(vel,2)-1)/nframes;
V = zeros(n,nframes);

%Based on size of vel, choose which dimension to average over first.
if size(vel,1) > size(vel,2)
    toggle = 1;
    loop1 = 1:size(vel,2);
    loop2 = 1:n;
    loop3 = 1:nframes; 
    spacing1 = dx;
    spacing2 = dt;
    intermediate_vel = zeros(n,size(vel,2));
else
    toggle = 2;
    loop1 = 1:size(vel,1);
    loop2 = 1:nframes;
    loop3 = 1:n;
    spacing1 = dt;
    spacing2 = dx;
    intermediate_vel = zeros(size(vel,1),nframes);
end

bar = waitbar(0,'');
ncalcs = length(loop1)+length(loop2);

for j = loop1
    waitbar(j/ncalcs,bar,'Averaging velocties')
    
    start_int = 1;
    %Fit splines to data over larger dimension and define function for integrating
    if toggle == 1;
        pp = spline(1:size(vel,1),vel(:,j));
    else
        pp = spline(1:size(vel,2),vel(j,:));
    end
    func = @(x,pp) ppval(pp,x); 
    for i = loop2
        %Define the limits of integration and integrate to find average.
        end_int = start_int+spacing1;
        
        %Store the velocities averaged over 1 dimension.
        if toggle == 1;
            intermediate_vel(i,j) = integral(@(x)func(x,pp),start_int,end_int)/spacing1;
        else
            intermediate_vel(j,i) = integral(@(x)func(x,pp),start_int,end_int)/spacing1;
        end
        start_int = end_int;
    end
end
     


for i = loop2
    waitbar((length(loop1)+i)/ncalcs,bar,'Averaging velocties')
    
    start_int = 1;
    %Fit splines to data over other dimension and define function for integratingg
    if toggle == 1
        pp = spline(1:size(intermediate_vel,2),intermediate_vel(i,:));
    else
        pp = spline(1:size(intermediate_vel,1),intermediate_vel(:,i));
    end
    func = @(x,pp) ppval(pp,x); 
    
    for j = loop3
        %Define the limits of integration and integrate to find average.
        end_int = start_int+spacing2;
        
        %Store the velocities averaged over both dimensions
        if toggle == 1
            V(i,j) = integral(@(x)func(x,pp),start_int,end_int)/spacing2;
        else
            V(j,i) = integral(@(x)func(x,pp),start_int,end_int)/spacing2;
        end
        start_int = end_int;
    end
end
delete(bar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    
    
