import sys
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation

import online_svr

def input_data(filename = 'OnlineSVR Matlab 2006b Code/test2.txt'):
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
    return setX,setY
        
def init():
    line1.set_data([],[])
    line2.set_data([],[])
    return line1,line2,

def animate(i):
    timesteps = np.array(range(i))
    ax.set_xlim(0,i)
    PredictedY = OSVR.predict(testSetX[0:i,:])
    line1.set_data(timesteps, PredictedY)
    line2.set_data(timesteps, testSetY[0:i])
    OSVR.learn(testSetX[i,:], testSetY[i])
    return line1,line2,

testSetX, testSetY = input_data()
print(testSetY.max())
# Set up animated figure
fig = plt.figure()
ax = plt.axes(xlim=(0,1),ylim=(0,5.5))
line1, = ax.plot([],[],'dr',lw=2,label='Predicted')
line2, = ax.plot([],[],'ob',lw=2,label='Truth')
plt.legend()

OSVR = online_svr.OnlineSVR(numFeatures = testSetX.shape[1], C = 10, eps = 0.1, 
                            kernelParam = 30, bias = 0, debug = False)
anim = animation.FuncAnimation(fig,animate,init_func=init,interval=1,
                               frames=range(testSetX.shape[0]),repeat=False)
plt.show()
