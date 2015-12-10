load('traffic_data.mat')

y1_avg = avg_arrival_rate(x1,y1);%preprocessing
epsilon = 0.1;
start = 312;
sample_time = 30;%unit: second

time = size(y1_avg,1);
data_size = floor((time-start)/sample_time);
series = zeros(1,data_size);
for i = 1:data_size
    series(i) = mean(y1_avg(start+(i-1)*sample_time:start+i*sample_time-1));
end


window_size = 5*60/sample_time;%unit: sample_time
horizon = 5*60/sample_time;%unit: sample_time
online_size = data_size - window_size + 1;%unit: sample_time

PredictedY = zeros(1,online_size);
ActualY = zeros(1,online_size);
ActualX = zeros(online_size, window_size);
Loss = zeros(1,online_size);
weights = zeros(1,window_size);

for i = 1:online_size
    OnlineSetX = series(i:i+window_size-1);
    ActualX(i,:) = OnlineSetX;
    PredictedY(i) = weights * OnlineSetX';
    
    if(i-horizon >= 1)
        OnlineSetY = mean(series(i+window_size-horizon-1:i+window_size-1));
        ActualY(i-horizon) = OnlineSetY;
        Loss(i-horizon) = pa_loss(weights,ActualX(i-horizon,:), OnlineSetY, epsilon);
        tau = Loss(i-horizon)/(sum((ActualX(i-horizon,:)).^2)+1/0.001);
        weights = weights + sign(ActualY(i-horizon) - PredictedY(i-horizon)) * ActualX(i-horizon,:) * tau ;
    end
end

fileID = fopen('new_log.txt','w');
for i = 1:online_size
    g=sprintf('%f ', ActualX(i,:));
    formatSpec = '%f, %s\n';
    fprintf(fileID,formatSpec,ActualY(i), g);
end



mean_sq_error = mean((PredictedY - ActualY).^2)
figure;
plot(1:online_size,PredictedY,'-r', 1:online_size,ActualY,'-b');
grid on;