function loss = pa_loss(w,x,y, epsilon)

if(abs(w*x' - y) < epsilon)
    loss = 0;
else
    loss = abs(w*x' - y) - epsilon;
end

