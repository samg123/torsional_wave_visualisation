function h = make_cylinder(r1,r2,h,colour,option)

% Generates the outside face and top/bottom annulus' for a 3D cylinder of a
% certain thickness and height.
%
% RadiusOut = Radius of outer edge
% RadiusIN = Radius of inner edge
% Height = Height of cylinder
% Colour = Colour of cylinder
% Option = option defines wether the top/bottom annulus' should also be
%               generated (if set to 1) or if just the side face is (set to 0).


theta=linspace(0,2*pi);
n_sides = 100;


for i=1:n_sides
    vertex_data(i,:) = [r1*cos(2*pi/n_sides*i),r1*sin(2*pi/n_sides*i),0];
    vertex_data(n_sides+i,:) = [r1*cos(2*pi/n_sides*i),r1*sin(2*pi/n_sides*i),h];
end


% Side Patches
for i=1:n_sides-1
    index_patch(i,:) = [i,i+1,i+1+n_sides,i+n_sides];
end
index_patch(n_sides,:) = [n_sides,1,1+n_sides,2*n_sides];

for i=1:n_sides
    
    % Side patches data
    patch_data_x(:,i) = vertex_data(index_patch(i,:),1);
    patch_data_y(:,i) = vertex_data(index_patch(i,:),2);
    patch_data_z(:,i) = vertex_data(index_patch(i,:),3) - h/2;
end

% Draw side patches

h{1}=patch(patch_data_x,patch_data_y,patch_data_z,colour,'LineStyle','none');
hold on

if option == 1
    % Draw Top/Bottom Patches
    upper = zeros(1,2*length(theta));
    upper(:) = h/2;
    lower = zeros(1,2*length(theta));
    lower(:) = -h/2;


    h{2}=patch([r1*cos(theta),r2*cos(theta)],[r1*sin(theta),r2*sin(theta)],upper,colour);
    hold on
    h{3}=patch([r1*cos(theta),r2*cos(theta)],[r1*sin(theta),r2*sin(theta)],lower,colour);
    hold on
else
end

end