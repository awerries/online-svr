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

	for line in input_file:
	#while True:
	#	line = sys.stdin.readline()

		if len(samples) == sample_rate:
			if q_sample.qsize() == window_arrival:
				feature = np.array(q_sample.queue)
				label = arrival_rate(feature[-predict_horizon:])
				if q_feature.qsize() == predict_horizon:
					previous_feature = q_feature.get()
					print "label ", label[0]
					print "previous_feature ", previous_feature[:,0].tolist()
					print "current_feature ", feature[:,0].tolist()
					'''for pi, phase in enumerate(all_phases):
						Adam_function(label[pi],previous_feature[:,pi].tolist(), feature[:,pi].tolist())'''
				q_feature.put(feature)
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
	