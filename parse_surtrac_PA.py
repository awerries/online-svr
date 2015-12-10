from Queue import Queue
import numpy as np
import sys


def parse_line(line, all_phases):
	field_size = 6
	elements = line.split()
	size =  (len(elements) - 1)/field_size
	car_num = np.zeros(len(all_phases))

	for i in range(size):
		for pi, phase in enumerate(all_phases):
			if elements[1+field_size*i+1] == phase:
				car_num[pi] = car_num[pi] + float(elements[1+field_size*i+3])
	return car_num


def arrival_rate(samples):
	return np.mean(samples,0)

def PA_loss(weights, answ, prev_feature):
	epsilon = 0.1
	loss = abs(np.inner(weights, prev_feature) -  answ)
	if loss < epsilon:
		loss = 0
	else:
		loss = loss - epsilon
	return loss

def sign(x):
    """ Returns sign. Numpys sign function returns 0 instead of 1 for zero values. :( """
    if x >= 0:
        return 1
    else:
        return -1


def main():
	q_sample = Queue()
	q_feature = Queue()
	q_smooth = Queue()

	log_name = "../input_log.txt"
	input_file = open(log_name,'r')
	all_phases = ['0','1']

	sample_rate = 1#how many seconds constitue a sample
	samples = list()
	window_arrival = 4#1*60 / sample_rate
	predict_horizon = 2#window should be greater than horizon
	smooth_period = 10

	weights = np.zeros((window_arrival,len(all_phases)))
	prediction = np.zeros(len(all_phases))

	for line in input_file:
	#while True:
	#	line = sys.stdin.readline()
		if len(samples) == sample_rate:
			if q_sample.qsize() == window_arrival:
				feature = np.array(q_sample.queue)
				answ = arrival_rate(feature[-predict_horizon:])
				if q_feature.qsize() == predict_horizon:
					prev_prediction, prev_feature = q_feature.get()
					
					#print "answ ", answ[0], answ[1]
					#print "prev_feature ", prev_feature[:,0].tolist(),prev_feature[:,1].tolist()
					#print "current_feature ", feature[:,0].tolist(), feature[:,1].tolist()

					for pi, phase in enumerate(all_phases):
						prediction[pi] = np.inner(weights[:,pi], feature[:,pi])
						if prediction[pi] < 0:
							prediction[pi]
						if np.linalg.norm(prev_feature[:,pi]) == 0.0:
							continue
						loss = PA_loss(weights[:,pi], answ[pi], prev_feature[:,pi])
						tau = loss/(np.linalg.norm(prev_feature[:,pi]))**2
						weights[:,pi]  = weights[:,pi] + sign(answ[pi] - prev_prediction[pi]) * prev_feature[:,pi] * tau
					print prev_prediction, answ

				
				q_feature.put([prediction, feature])
				q_sample.get()

			q_sample.put(arrival_rate(samples))
			samples = list()

		if q_smooth.qsize() == smooth_period:
			q_smooth.get()
		q_smooth.put(parse_line(line, all_phases))
		data = arrival_rate(list(q_smooth.queue))

		samples.append(data)

		


if __name__ == '__main__':
    main()
	