import sys
import time
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation

import online_svr

def input_data(filename):
    setX = list()
    setY = list()
    f = open(filename, 'r')
    for line in f:
        Y,X = line.split(',')
        Y = float(Y)
        setY.append(Y)
        X = [float(val) for val in X.strip().split(' ')]
        setX.append(X)
    setX = np.array(setX)
    setY = np.array(setY)
    print(setX)
    print(setY)
    setY.shape = (setY.size,1)
    return setX,setY
        
def init():
    line1.set_data([],[])
    line2.set_data([],[])
    return line1,line2,

def animate(i):
    global ydata,runnum,iteration_times
    print('%%%%%%%%%%%%%%%%%%%%%%%% Run #{0}, {1}/{2} %%%%%%%%%%%%%%%%%%%%%%%%'.format(runnum,i,testSetX.shape[0]))
    iter_start_time = time.time()
    timesteps = np.array(range(i+1))
    ax.set_xlim(0,i)
    ydata.append(OSVR.predict(testSetX[i,:]).item(0))
    line1.set_data(timesteps, np.array(ydata))
    line2.set_data(timesteps, testSetY[0:i+1])
    OSVR.learn(testSetX[i,:], testSetY[i])
    if i == testSetX.shape[0]-1:
        runnum += 1
    elapsed = time.time() - iter_start_time
    print('Iteration prediction error was {0:.4f}'.format(np.abs(testSetY[i]-ydata[i]).item()))
    print('@@@@@@ Iteration elapsed time: {0:.3f} seconds @@@@@@'.format(elapsed))
    iteration_times.append(elapsed)
    return line1,line2,

# Initialization
runnum = 1
program_start_time = time.time()
iteration_times = list()
ydata = list()
C = float(sys.argv[1])
eps = float(sys.argv[2])
kernelParam = float(sys.argv[3])
filename = 'data_preparation/new_log.txt'

# Load data
testSetX, testSetY = input_data(filename)

# Set up animated figure
fig = plt.figure()
ax = plt.axes(xlim=(0,1),ylim=(0,8))
line1, = ax.plot([],[],'dr',lw=2,label='Predicted')
line2, = ax.plot([],[],'ob',lw=2,label='Truth')
plt.title('C={0},eps={1},kernelParam={2}\n{3}'.format(C,eps,kernelParam,filename))
plt.legend(loc='upper left')

# Set up learner
OSVR = online_svr.OnlineSVR(numFeatures = testSetX.shape[1], C = C, eps = eps, 
                            kernelParam = kernelParam, bias = 2, debug = False)
# Run learner with animate() function
anim = animation.FuncAnimation(fig,animate,init_func=init,interval=1,
                               frames=range(testSetX.shape[0]),repeat=False)
plt.show()

print('\n\nC={0},eps={1},kernelParam={2}'.format(C,eps,kernelParam))
print('Elapsed time: {0:.3f}'.format(time.time() - program_start_time))
print('RMSE: {0}'.format(np.linalg.norm(testSetY-np.array(ydata)) / np.sqrt(testSetY.size)))

fig = plt.figure()
plt.plot(iteration_times)
plt.xlabel('Iteration')
plt.ylabel('Elapsed time')
plt.show()
