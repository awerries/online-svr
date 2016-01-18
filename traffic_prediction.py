import sys
import time
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation

import online_svr

def input_data(filename):
    times = list()
    setX = list()
    setY = list()
    setXp = list()
    f = open(filename, 'r')
    for line in f:
        t,X,Y,Xp = line.split(':')
        t = int(t)
        times.append(t)
        Y = float(Y)
        setY.append(Y)
        X = [float(val) for val in X.strip().split(',')]
        setX.append(X)
        Xp = [float(val) for val in Xp.strip().split(',')]
        setXp.append(Xp)
    times = np.array(times)
    setX = np.array(setX)
    setY = np.array(setY)
    setXp = np.array(setXp)
    setY.shape = (setY.size,1)
    return times,setX,setY,setXp
        
def init():
    line1.set_data([],[])
    line2.set_data([],[])
    return line1,line2,

def animate(i):
    global ydata,iteration_times
    print('%%%%%%%%%%%%%%%%%%%%%%%% {0}/{1} %%%%%%%%%%%%%%%%%%%%%%%%'.format(i+1,testSetX.shape[0]))
    iter_start_time = time.time()
    timesteps = np.array(range(i+1))
    ax.set_xlim(0,i)
    ydata.append(OSVR.predict(testSetX[i,:]).item(0))
    line1.set_data(timesteps, np.array(ydata))
    if i < testSetX.shape[0]-1:
        line2.set_data(timesteps, testSetY[1:i+2])
    else:
        line2.set_data(timesteps[:-1], testSetY[1:i+1])
    OSVR.learn(testSetXp[i,:], testSetY[i])
    elapsed = time.time() - iter_start_time
    if i < testSetX.shape[0]-1:
        print('Iteration prediction error was {0:.4f}'.format(np.abs(testSetY[i+1]-ydata[i]).item()))
    print('@@@@@@ Iteration elapsed time: {0:.3f} seconds @@@@@@'.format(elapsed))
    iteration_times.append(elapsed)
    return line1,line2,

# Initialization
program_start_time = time.time()
iteration_times = list()
ydata = list()
C = float(sys.argv[1])
eps = float(sys.argv[2])
kernelParam = float(sys.argv[3])
filename = str(sys.argv[4])

# Load data
times, testSetX, testSetY, testSetXp = input_data(filename + '.txt')

# Set up animated figure
fig = plt.figure(0)
ax = plt.axes(xlim=(0,1),ylim=(0,5))
line1, = ax.plot([],[],'dr',lw=2,label='Predicted')
line2, = ax.plot([],[],'ob',lw=2,label='Truth')
plt.title('C={0},eps={1},kernelParam={2}\n{3}'.format(C,eps,kernelParam,filename))
plt.legend(loc='upper left')

# Set up learner
OSVR = online_svr.OnlineSVR(numFeatures = testSetX.shape[1], C = C, eps = eps, 
                            kernelParam = kernelParam, bias = 0.5, debug = False)
# Run learner with animate() function
anim = animation.FuncAnimation(fig,animate,init_func=init,interval=1,
                               frames=range(testSetX.shape[0]),repeat=False)
plt.show()
# Display performance (time and RMS error)
print('\n\nC={0},eps={1},kernelParam={2}'.format(C,eps,kernelParam))
iteration_times = np.array(iteration_times)
print('Elapsed time: {0:.3f}'.format(np.sum(iteration_times)))
print('Mean iteration time: {0:.3f}'.format(np.mean(iteration_times)))
rmse = np.sqrt(np.mean((testSetY-np.array(ydata))**2))
print('RMSE: {0}'.format(rmse))

fig = plt.figure(1)
plt.plot(iteration_times,'o')
plt.xlabel('Iteration')
plt.ylabel('Elapsed time')
plt.title('C={0},eps={1},kernelParam={2}\n{3}'.format(C,eps,kernelParam,filename))
plt.show()

with open('{0}_prediction_log.txt'.format(filename),'w') as f:
    for i,t in enumerate(times):
        y = ydata[i]
        f.write('{0}: {1}\n'.format(t,y))
