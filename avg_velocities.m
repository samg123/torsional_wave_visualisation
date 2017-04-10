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
