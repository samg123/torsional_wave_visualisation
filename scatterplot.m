function scatterplot(np,time,V,user,colourscheme)

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
n_tex = user.n_tex;
x_axis = user.x_axis;
y_axis = user.y_axis;
fs = user.fs;
tfs = user.tfs;
cbar_range = user.cbar_range;
ct = user.ct;
titletext = user.titletext;
ticks = user.ticks;
lables = user.lables;
tmpl = user.tmpl;
nframes = user.nframes;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

%set the index for the colourscale.
half = floor(size(colourscheme,1)/2);
fraction = round(half.*V./max(abs(V(:))));
half = ceil(size(colourscheme,1)/2);

%Set up figure
h=figure('Visible','off'); 

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
caxis(cbar_range)
title(c,ct)

% Start the loop

bar = waitbar(0,'');

tt = linspace(time(1),max(time),nframes);
step = (max(time)-time(1))/nframes;

for t = 1:nframes
   %Advect the texture
   for i = 1:size(data,1)
       
       for j = 1:np
           flag=0;
           
        if data(i,2) == j
            
           data(i,3) = V(j,t)/step;
           data(i,4) = half+fraction(j,t); 
           data(i,1) = data(i,1) + V(j,t)*step;
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
       
    temp = 1;
    j=1;
    count = 1;
    % Sequentially plot data grouped by it's colour.
    plots = struct([]);
    for i = 1:size(colourscheme,1)
        while data(j,4)==i
            j = j+1;
            if j == size(data,1)
                break
            end
        end
        if j > temp
            colour = colourscheme(i,:);
            plots{count} = plot(Xs(temp:(j-1)),Ys(temp:(j-1)),'LineStyle','none','Marker','.','Color',colour);
            count = count+1;
            hold on
            temp = j;
        else
        end
    end
    
    %plot the last colour (previous loop doesn't cover it)
    colour = colourscheme(data(size(data,1),4),:);
    plots{count} = plot(Xs(temp:size(data,1)),Ys(temp:size(data,1)),'LineStyle','none','Marker','.','Color',colour);
    hold on
   
    
    %Add title
    text = [num2str(tt(t)),titletext];
    title(text,'FontSize',tfs)

     
    %Save the image filee
    fnam=sprintf(tmpl,name_counter); 
    print(fnam,'-dpng')
    text=['Saving frame ', num2str(name_counter),' to: ./output\_torsional/'];
    waitbar(t/nframes,bar,text)
    name_counter = name_counter + 1;
   
    for i = 1:length(plots)
        delete(plots{i})
    end
         
end
close(h)
close(bar)
end






