function cylinders_3D(n,time,V,user,colourscheme,intro_anim)
% INPUT
% n = number of cylinders
% time = array time data
% V = Velocity data for n cylinders throughout time.
% user = structure containing user defined options.
% intro_anim = option specifying the animation (1=on, 0=off).

% Creates n number of 3D concentric cylinders that are plotted with a
% texture in the form of scatter plotted data points over their surface.
% The data points are advected as described by the matric 'V'. An
% introductory animation where the cylinders are enclosed within a sphere
% is optional. The azimuth and elevation of the view can be defined as well
% as panning.

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
az = user.az;
el = user.el;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

name_counter = 1;
tmpl = ['./output_torsional/',tmpl,'_%04d'];

%Define heights for texture data
heights = zeros(n,4);
for i = 1:n
    r1 = i/n - (1/n);
    rnext = (i+1)/n -(1/n);
    h1 = sqrt(1-r1^2);
    h2 = sqrt(1-rnext^2);
    if i < n
        heights(i,1) = h1 - (h1-h2)/2;
    else
        heights(i,1) = 0;
    end    
    heights(i,2) = h1;
end

%Define Texture points in polar co-ords.
x = [1:n];
f = sum(x.^1)/n_tex;
x = ceil(x.^1/f);
count = 1;
data = zeros(n_tex,4);
for i = 1:length(x)
    for j = 1:x(i)
    data(count,1) = 2*pi*(j/x(i));
    data(count,2) = i/n - 0.5/n;
    data(count,3) = heights(i,1);
    data(count,4) = heights(i,2);
    count = count+1;
    end 
end

%set the index for the colourscale.
half = floor(size(colourscheme,1)/2);
fraction = round(half.*V./max(abs(V(:))));

%Set up figure
h=figure('Visible','off');
colormap(colourscheme)
cb=colorbar;
set(cb,'position',[0.9, 0.4, 0.03, 0.3])
caxis(cbar_range)
title(cb,ct)
grid on
view(az-(20*intro_anim),el-(20*intro_anim))

%Make the tangent cylinder
tc=make_cylinder(1221/3480,1221/3480,2*1.3,[0.7,0.7,0.7,],0);
set(tc{1},'FaceLighting','phong','AmbientStrength',0.2,'FaceAlpha',0.4)
hold on

% Set up labels etc of graph
set(gca,'xticklabel',[],'XTick',ticks)
set(gca,'ZTick',[-1,1],'ZTickLabel',[3480,3480],'FontSize',fs)
zlabel(x_axis,'FontSize',fs)
set(gca,'YTick',ticks,'YTickLabel',lables,'FontSize',fs)
ylabel(y_axis,'FontSize',fs)
axis([-1.3 1.3 -1.3 1.3 -1.3 1.3])
axis square
camlight;
grid on

% Draw cylinders with external
% function make_cylinder.m
colour = [1,1,1];
half = ceil(size(colourscheme,1)/2);
for i = 1:n
    rout = i/n;
    rin = i/n - (1/n);
    height = 2*heights(i,2);
    c{i}=make_cylinder(rout,rin,height,colour,1);    
    hold on
    colour = colourscheme(half+fraction(i,1),:);
    for j = 1:3
        temp = c{i};
        temp = temp{j};
        set(temp,'FaceLighting','none','Facecolor',colour)
    end
end


bar = waitbar(0,'');
tt = linspace(time(1),max(time),nframes);
step = (max(time)-time(1))/nframes;

%Start looping through time.
for t = 1:nframes
    
    % Advect the texture and set colour of cylinders
    for i = 1:size(data,1)

         for j = 1:n
            flag = 0;
            colour = colourscheme(half+fraction(j,t),:);
            
            for k = 1:3
                temp = c{j};
                temp = temp{k};
                set(temp,'facecolor',colour)
            end
            
            rad = j/n - 0.5/n;
            if data(i,2) == rad
               data(i,1) = data(i,1) + V(j,t)*step;
               flag = 1;
            end
            if flag == 1
                break
            end
         end                
     end


    %Plot the texture data
    [X1,Y1,Z1] = pol2cart(data(:,1),data(:,2)+0.55/n,data(:,3));
    sc1 = scatter3(X1,Y1,Z1,4,'k','filled');
    hold on
    [X2,Y2,Z2] = pol2cart(data(:,1),data(:,2),data(:,4));
    sc2 = scatter3(X2,Y2,Z2,4,'k','filled');
    hold on
    [X3,Y3,Z3] = pol2cart(data(:,1),data(:,2),-data(:,4));
    sc3 = scatter3(X3,Y3,Z3,4,'k','filled');


    %Create intro animation
    if intro_anim ==1
        
        % Set up data points for sphere intro animation.
        [Xs,Ys,Zs] = sphere(105);
        Xs = Xs*1.12;
        Ys = Ys*1.12;
        Zs = Zs*1.05;
        
        if t==1
            %Plot sphere
            p2=surf(Xs,Ys,Zs);
            set(p2,'FaceLighting','phong','SpecularStrength',0.2)
            set(p2,'FaceColor',[0.9 0.9 0.9],'FaceAlpha',1,'LineStyle','none');
            set(tc{1},'FaceAlpha',0);
            %Create 24 static images at beginning
            for i = 1:24
                fnam=sprintf(tmpl,name_counter);
                text=['Saving frame ', num2str(name_counter),' to: ./output\_torsional/'];
                waitbar(i/(nframes+(intro_anim*124)),bar,text)
                print(fnam,'-dpng')
                name_counter = name_counter + 1;
            end
            % Fade sphere away and pan up towards preffered elevation
            el_t = el-20;
            az_t = az-20;
            for i = 1:100
                delete(p2)
                Xs=Xs(:,1:105-i);
                Ys=Ys(:,1:105-i);
                Zs=Zs(:,1:105-i);
                p2=surf(Xs,Ys,Zs);
                set(p2,'FaceLighting','phong','SpecularStrength',0.2)
                view(az_t,el_t)
                set(p2,'FaceColor',[0.9 0.9 0.9],'FaceAlpha',1,'LineStyle','none');
                set(p2,'FaceAlpha',(1-i/100));
                set(tc{1},'FaceAlpha',(0.4/95)*i);
                text=['Saving frame ', num2str(name_counter),' to: ./output\_torsional/'];
                waitbar((24+i)/(nframes+(intro_anim*124)),bar,text)
                fnam=sprintf(tmpl,name_counter);
                print(fnam,'-dpng')
                name_counter = name_counter + 1;

                % Panning.
                el_t=el_t + 20/100;
                az_t = az_t + (20/100);
            end
         end
             delete(p2)
        else
    end


    % Once intro is over, continue as normal

     text = [num2str(tt(t)),titletext];
     title(text,'FontSize',tfs)

     text=['Saving frame ', num2str(name_counter),' to: ./output\_torsional/'];
     waitbar((t+(intro_anim*124))/(nframes+(intro_anim*124)),bar,text)

     
     fnam=sprintf(tmpl,name_counter);
     print(fnam,'-dpng')
     name_counter = name_counter + 1;
     delete(sc1)
     delete(sc2)
     delete(sc3)
end
close(bar)
close(h)
end




