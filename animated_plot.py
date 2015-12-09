import sys
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation

import online_svr

# Set up animated figure
fig = plt.figure()
ax = plt.axes(xlim=(0,1),ylim=(-1,1))
line1, = ax.plot([],[],'or',lw=2,label='Predicted')
line2, = ax.plot([],[],'ob',lw=2,label='Truth')
plt.legend()

def init():
    line1.set_data([],[])
    line2.set_data([],[])
    return line1,line2,

def animate(i):
    OSVR.learn(testSetX[i,:], testSetY[i,:])
    PredictedY = OSVR.predict(testSetX[0:i,:])
    line1.set_data(testSetX[0:i,:], PredictedY)
    line2.set_data(testSetX[0:i,:], testSetY[0:i,:])
    return line1,line2,

OSVR = online_svr.OnlineSVR(C = 10, eps = 0.1, kernelParam = 30, bias = 0, debug = False)
#testSetX = np.array([[0.1],[0.2],[0.3],[0.4],[0.5]])
testSetX = np.random.rand(1000,1)
testSetY = np.sin(2*np.pi*testSetX)
anim = animation.FuncAnimation(fig,animate,init_func=init,interval=1,frames=range(testSetX.shape[0]),repeat=False)
plt.show()
