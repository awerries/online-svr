from Queue import Queue
import numpy as np
import sys


sample_rate = 30#how many seconds constitue a sample
window_arrival = 5#1*60 / sample_rate
predict_horizon = 4#window should be greater than horizon
smooth_period = 60
all_phases = ['0','1']
epsilon = 1


q_sample = Queue()
q_feature = Queue()
q_smooth = Queue()
samples = list()
weights = np.zeros((window_arrival,len(all_phases)))
prediction = np.zeros(len(all_phases))


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


def PA_learning(line, output_file, timestamp, weights):


	if len(samples) == sample_rate:
		if q_sample.qsize() == window_arrival:
			feature = np.array(q_sample.queue)
			answ = arrival_rate(feature[-predict_horizon:])
			if q_feature.qsize() == predict_horizon:
				prev_prediction, prev_feature = q_feature.get()
			
				for pi, phase in enumerate(all_phases):
					prediction[pi] = np.inner(weights[:,pi], feature[:,pi])
					output_file[pi].write(str(timestamp)+": "+str(prediction[pi])+"\n")
					if prediction[pi] < 0.0:
						prediction[pi]  = 0.0
					if np.linalg.norm(prev_feature[:,pi]) == 0.0:
						continue
					loss = PA_loss(weights[:,pi], answ[pi], prev_feature[:,pi])
					tau = loss/((np.linalg.norm(prev_feature[:,pi]))**2+1/0.2)
					weights[:,pi]  = weights[:,pi] + sign(answ[pi] - prev_prediction[pi]) * prev_feature[:,pi] * tau
					#output_file[pi].write(str(prev_prediction[pi])+" "+str(answ[pi])+'\n')

			
			q_feature.put([prediction, feature])
			q_sample.get()

		q_sample.put(arrival_rate(samples))
		del samples[:]

	if q_smooth.qsize() == smooth_period:
		q_smooth.get()
	q_smooth.put(parse_line(line, all_phases))
	data = arrival_rate(list(q_smooth.queue))

	samples.append(data)



def main():
	log_name = "./centre_graham_cluster_log.txt"
	input_file = open(log_name,'r')
	file_0 = open('phase0_5D_PA.txt','w')
	file_1 = open('phase1_5D_PA.txt','w')
	output_file =[file_0, file_1]


	new_msg_rcv_time = 0
	prev_msg_rcv_time = 0
	scale = 1000
	dt = 1

	for temp_line in input_file:

		line = temp_line[0:-1]

		new_msg_rcv_time = int(line.split()[0])
		time_diff = new_msg_rcv_time - prev_msg_rcv_time
		if  time_diff/scale > dt:
			fake_msg_time = prev_msg_rcv_time
			for i in range(time_diff/scale - 1):
				fake_msg_time += dt*scale
				fake_msg = str(fake_msg_time)
				PA_learning(fake_msg, output_file, fake_msg_time, weights)
		elif time_diff == 0:
			continue
		
		PA_learning(line, output_file, new_msg_rcv_time, weights)	
		prev_msg_rcv_time = new_msg_rcv_time
		


		


if __name__ == '__main__':
    main()
	