function [D,avg_vel] = displacements(vel,n,time,nframes)


s = size(vel,1)-1;
avg_vel = zeros(n,size(vel,2));
f = (s/n)-1;

for j = 1:size(vel,2)

    lower = 1;
    
    for i = 1:n
        upper = round(lower+f);
        avg_vel(i,j) = mean(vel(lower:upper,j));
        if upper == lower
            lower = lower+1;
        else
            lower = upper;
        end
    end
end

D = zeros(n,nframes);
f = ((length(time)-1)/nframes)-1;

for i = 1:n
    
    lower = 1;   
    
    for j = 1:nframes
        upper = round(lower+f);
        D(i,j)=  mean(avg_vel(i,lower:upper));
        if upper == lower
            lower = lower+1;
        else
            lower = upper;
        end
    end
end
end