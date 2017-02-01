function h = make_cylinder(RadiusOut,RadiusIn,Height,Colour,option)

% Generates the outside face and top/bottom annulus' for a 3D cylinder of a
% certain thickness and height.
%
% RadiusOut = Radius of outer edge
% RadiusIN = Radius of inner edge
% Height = Height of cylinder
% Colour = Colour of cylinder
% Option = option defines wether the top/bottom annulus' should also be
%               generated (if set to 1) or if just the side face is (set to 0).



r1 = RadiusOut;
r2 = RadiusIn;
theta=linspace(0,2*pi);
n_sides = 100;


for i=1:n_sides
    VertexData(i,:) = [r1*cos(2*pi/n_sides*i),r1*sin(2*pi/n_sides*i),0];
    VertexData(n_sides+i,:) = [r1*cos(2*pi/n_sides*i),r1*sin(2*pi/n_sides*i),Height];
end


% Side Patches
for i=1:n_sides-1
    Index_Patch1(i,:) = [i,i+1,i+1+n_sides,i+n_sides];
end
Index_Patch1(n_sides,:) = [n_sides,1,1+n_sides,2*n_sides];

for i=1:n_sides
    
    % Side patches data
    PatchData1_X(:,i) = VertexData(Index_Patch1(i,:),1);
    PatchData1_Y(:,i) = VertexData(Index_Patch1(i,:),2);
    PatchData1_Z(:,i) = VertexData(Index_Patch1(i,:),3) - Height/2;
end

% Draw side patches

h{1}=patch(PatchData1_X,PatchData1_Y,PatchData1_Z,Colour,'LineStyle','none');
hold on

if option == 1
    % Draw Top/Bottom Patches
    upper = zeros(1,2*length(theta));
    upper(:) = Height/2;
    lower = zeros(1,2*length(theta));
    lower(:) = -Height/2;


    h{2}=patch([r1*cos(theta),r2*cos(theta)],[r1*sin(theta),r2*sin(theta)],upper,Colour);
    hold on
    h{3}=patch([r1*cos(theta),r2*cos(theta)],[r1*sin(theta),r2*sin(theta)],lower,Colour);
    hold on
else
end

end