for i = 1:1002
PP = spline(radius, vel(i,:));
for j = 1:nframes
test = integral(@(xx)ppval(PP,xx),xx(j),xx(j+1),'Waypoints',radius);
end
disp(i)
end




for i = 1:7301
PP = spline(time, vel(:,i));
for j = 1:length(tt)-1
test = integral(@(tt)ppval(PP,tt),tt(j),tt(j+1),'Waypoints',radius);
end
disp(i)
end

