load('traffic_data.mat')

y1_avg = avg_arrival_rate(x1,y1);%preprocessing
epsilon = 0.01;
start = 312;
sample_time = 10;%unit: second

time = size(y1_avg,1);
data_size = floor((time-start)/sample_time);
series = zeros(1,data_size);
for i = 1:data_size
    series(i) = mean(y1_avg(start+(i-1)*sample_time:start+i*sample_time-1));
end


window_size = 10*60/sample_time;%unit: sample_time
horizon = 20*60/sample_time;%unit: sample_time
online_size = data_size - horizon - window_size + 1;%unit: sample_time

PredictedY = zeros(1,online_size);
ActualY = zeros(1,online_size);
ActualX = zeros(online_size, window_size);
Loss = zeros(1,online_size);
weights = zeros(1,window_size);

for i = 1:online_size
    OnlineSetX = series(i:i+window_size-1);%y1_avg(start+(i-1)*sample_time+1:sample_time:start+(i-1+window_size)*sample_time)';
    ActualX(i,:) = OnlineSetX;
    PredictedY(i) = weights * OnlineSetX';
    OnlineSetY = mean(series(i+window_size:i+window_size+horizon-1));%mean(y1_avg(start+(i-1+window_size)*sample_time+1:start+(i-1+window_size)*sample_time+horizon)); %y1_avg(start+start_size+i+window_size+1);
    ActualY(i) = OnlineSetY;
    Loss(i) = pa_loss(weights,OnlineSetX, OnlineSetY, epsilon);
    weights = weights + sign(ActualY(i) - PredictedY(i)) * Loss(i) * OnlineSetX /sum((OnlineSetX).^2) ;  
end

fileID = fopen('test.txt','w');
for i = 1:online_size
    g=sprintf('%f ', ActualX(i,:));
    formatSpec = '%f, %s\n';
    fprintf(fileID,formatSpec,ActualY(i), g);
end



mean_sq_error = mean((PredictedY - ActualY).^2)
figure;
plot(1:online_size,PredictedY,'-r', 1:online_size,ActualY,'-b');
grid on;