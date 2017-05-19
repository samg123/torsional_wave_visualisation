function cylinders_2D(user,V)

% Approximates the core to a set number of cylinders and produces a 2D
% animation of an equatorial slice. The cylinders are plotted and change
% colour according to the their velocity. To give the sense of motion a
% number of data points (dots) are plotted on top and advected.
%
%INPUTS
% n = number of cylinders
% time = time data
% V = Averaged Displacement data (output from displacements.m)
% colourcheme = colour scale to use
% tmpl = Template for naming scheme for output images
% user = Matlab Structure containing user defined variables.
% nframes = number of frames for animation
%
%OUPUTS
%no variables are output, instead images are saved to ./output_torsional/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load user defined variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = user.n;
time = user.times;
n_tex = user.n_tex;
tex_size = user.tex_size;
x_axis = user.ax_lables(1);
y_axis = user.ax_lables(2);
tfs = user.fs(1);
fs = user.fs(2);
cbar_range = user.cbar_range;
ct = user.ct;
titletext = user.titletext;
ticks = user.ticks;
lables = user.lables;
tmpl = user.tmpl;
nframes = user.nframes;
colourscheme = colormap(user.cs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmpl = ['./output_torsional/',tmpl,'_%04d'];
name_counter =1;

% Setup circle data points at the tangent cylinder and CMB
circle = zeros(151,2);
circle(:,2) = 1221/3480;
for i =0:150
    circle(i+1,1) = 2*(pi/150)*i;
end
[cx,cy] = pol2cart(circle(:,1),circle(:,2));

cmb = zeros(151,2);
cmb(:,2) = 1;
for i =0:150
    cmb(i+1,1) = 2*(pi/150)*i;
end
[cmbx,cmby] = pol2cart(cmb(:,1),cmb(:,2));


%Set up the texture points
x = [1:n];
f = sum(x.^1)/n_tex;
x = ceil(x.^1/f);

c = 1;
data = zeros(n_tex,2);
for i = 1:length(x)
    for j = 1:x(i)
    data(c,1) = 2*pi*(j/x(i));
    data(c,2) = i/n - 0.5/n;
    c = c+1;
    end 
end

%Set up figure
close all
h=figure('Visible','off','Position', [100, 100, 1000, 900]);

%Plot the ICB and CMB circles
plot(cx,cy,'k-','LineWidth',1)
hold on
plot(cmbx,cmby,'k-','LineWidth',1)

colormap(colourscheme)
c=colorbar;
caxis([-cbar_range, cbar_range])
title(c,ct);
set(gca,'XTick',ticks,'XTickLabel',lables)
xlabel(x_axis,'FontSize',fs)
set(gca,'YTick',ticks,'YTickLabel',lables)
ylabel(y_axis,'FontSize',fs)
axis square


%For each velocity point define the index of the colour in the matrix
%colourscheme
half = floor(size(colourscheme,1)/2);
fraction = round(half.*V./cbar_range);
for i = 1:size(fraction,1)
    for j = 1:size(fraction,2)
        if fraction(i,j) > half
            fraction(i,j) = half;
        elseif fraction(i,j) < 1-half
            fraction(i,j) = 1-half;
        end
    end
end

%Draw the cylinders
theta=linspace(0,2*pi);
half = ceil(size(colourscheme,1)/2);
for i = 1:n    
   rin = (i-1)/n;
   rout = i/n;
   colour = colourscheme(half+fraction(i,1),:);
   draw{i} = patch([rout*cos(theta),rin*cos(theta)],[rout*sin(theta),rin*sin(theta)],colour,'linestyle','none');
   hold on
end


tt = linspace(time(1),time(2),nframes);
step = (time(2)-time(1))/nframes;

bar = waitbar(0,'');
% Start the loop
for t = 1:nframes

    for i = 1:size(data,1)          
        
        %Set the colour of the cylinders by velocity
        if i == 1
            for j = 1:n
                colour = colourscheme(half+fraction(j,t),:);
                set(draw{j},'FaceLighting','none','Facecolor',colour)
            end
        end
        
        %Advect the texture
        for j = 1:n
            rad = j/n - 0.5/n;
            if data(i,2) == rad       
                data(i,1) = data(i,1) + V(j,t)*step*user.factor;
            end
        end
    end
  
    %Plot the texture
    [X,Y] = pol2cart(data(:,1),data(:,2));
    sc = plot(X,Y,'k.','MarkerSize',tex_size);

    %Set the title of the plot
    text = [num2str(tt(t)),titletext];
    title(text,'FontSize',tfs)

    %Save the image file
    fnam=sprintf(tmpl,name_counter);
    print(fnam,'-dpng')

    %Update waitbar
    text=['Saving frame ', num2str(name_counter),' to: ./output\_torsional/'];
    waitbar(t/nframes,bar,text)

    name_counter = name_counter + 1;
    delete(sc)
end  
close(h)
delete(bar)
end

