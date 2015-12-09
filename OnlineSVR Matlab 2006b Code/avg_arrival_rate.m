function output = avg_arrival_rate(x,y)

windowSize = 300;% averaged over 5 minutes
b = (1/windowSize)*ones(1,windowSize);
a = 1;
output = filter(b,a,y);

figure;
plot(x,output);
grid on;

