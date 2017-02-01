%Example pulse
clear all

x = linspace(0,10,100);
std_dev = 1;
vel = zeros(100,100);

for i = 1:100
    f = (1/(2*pi*i))*exp(-((x-i/10).^2)/(2*std_dev^2));
    vel(:,i) = f;
end

