function scatterplot(user,V)

% Creates a random texture on a 2D equatorial slice in the form of data
% points and advects them as decribed by the matrix 'vel'. 
% The data is grouped by it's colour and then each group is scatter plotted
% (e.g. all data points that use colourscheme(40,:) are plotted, then
% colourscheme(41,:) .... etc.) This saves plotting each data
% point individually.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load user defined variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
np = user.n;
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

%Set the file naming template.
tmpl = ['./output_torsional/',tmpl,'_%04d'];
name_counter=1;


% Create circles representing the cylinders tangent to the Core Mantle
% Boundary and the Inner core (cx/y and tcx/y respectively).
cmb = zeros(150,2);
cmb(:,2) = np;
for i =0:149
    cmb(i+1,1) = 2*(pi/150)*i;
end
[cmbx,cmby] = pol2cart(cmb(:,1),cmb(:,2));

icb = zeros(150,2);
icb(:,2) = np*(1221/3480);
for i =0:149
    icb(i+1,1) = 2*(pi/150)*i;
end
[icbx,icby] = pol2cart(icb(:,1),icb(:,2));


% Generate random texture at coordinates -np < x < np and -np < y < np.
% (np = number of radial points in data)

x = [1:np];
f = sum(x.^1)/n_tex;
x = ceil(x.^1/f);

c = 1;
data = zeros(n_tex,4);
for i = 1:np
    for j = 1:x(i)
       data(c,1) = 2*pi*rand(1);
       data(c,2) = i;
       if data(c,2) == 0
           data(c,2) = 1;
       else
       end
    c = c+1;
    end   
end

%For each velocity point define the index of the colour in the matrix
%'colourscheme'
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

half = ceil(size(colourscheme,1)/2);

%Set up figure
close all
h=figure('Visible','off','Position', [100, 100, 1000, 900]); 

plot(cmbx,cmby,'k-')
hold on
plot(icbx,icby,'k-','LineWidth',1)

axis square
set(gca,'XTick',ticks*np,'XTickLabel',lables)
xlabel(x_axis,'FontSize',fs)
set(gca,'YTick',ticks*np,'YTickLabel',lables)
ylabel(y_axis,'FontSize',fs)
colormap(colourscheme)
c=colorbar;
caxis([-cbar_range,cbar_range])
title(c,ct)

tt = linspace(time(1),time(2),nframes);
step = (time(2)-time(1))/nframes;

bar = waitbar(0,'');
% Start the loop
for t = 1:nframes
   %Advect the texture
   for i = 1:size(data,1)
       
       for j = 1:np
           flag=0;
           
        if data(i,2) == j
           %Advect the texture and assign it a colour.
           data(i,3) = V(j,t)/step;
           data(i,4) = half+fraction(j,t); 
           data(i,1) = data(i,1) + V(j,t)*step*user.factor;
           flag=1;
        end

        
        if flag == 1
            break
        end
       end

   end

    %Sort by 4th column (colour) for plotting
    data=sortrows(data,4);
    [Xs,Ys] = pol2cart(data(:,1),data(:,2));
       
    %Sequentially plot data grouped by it's colour.
    temp = 1;
    j=1;
    count = 1;
    plots = struct([]);
    flag = 0;
    for i = 1:size(colourscheme,1)
        while data(j,4)==i
            j = j+1;
            if j == size(data,1)
                flag=1;
                break
            end
        end
        if j > temp
            colour = colourscheme(i,:);
            plots{count} = plot(Xs(temp:(j-1)),Ys(temp:(j-1)),'LineStyle','none','Marker','.','Color',colour,'MarkerSize',tex_size);
            count = count+1;
            hold on
            temp = j;
        else
        end
        if flag == 1
            break
        end
    end
    
    %plot the last colour (previous loop doesn't cover it)
    colour = colourscheme(data(size(data,1),4),:);
    plots{count} = plot(Xs(temp:size(data,1)),Ys(temp:size(data,1)),'LineStyle','none','Marker','.','Color',colour,'MarkerSize',tex_size);
    hold on
   
    
    %Set the title of the plot
    text = [num2str(tt(t)),titletext];
    title(text,'FontSize',tfs)

     
    %Save the image file
    fnam=sprintf(tmpl,name_counter); 
    print(fnam,'-dpng')
    
    %Update the waitbar
    text=['Saving frame ', num2str(name_counter),' to: ./output\_torsional/'];
    waitbar(t/nframes,bar,text)
    
    
    %Clear texture for replotting in next iteration
    for i = 1:length(plots)
        delete(plots{i})
    end
         
    name_counter = name_counter + 1;
end
close(h)
delete(bar)
end






