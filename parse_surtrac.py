from Queue import Queue
import numpy as np
import sys
import copy


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


def doLearning(line, q_sample, q_feature, q_smooth, samples, output_file, timestamp):
	all_phases = ['0','1']
	sample_rate = 30#how many seconds constitue a sample
	window_arrival = 10#1*60 / sample_rate
	predict_horizon = 5#window should be greater than horizon
	smooth_period = 60


    
	if len(samples) == sample_rate:
		if q_sample.qsize() == window_arrival:
			feature = np.array(q_sample.queue)
			label = arrival_rate(feature[-predict_horizon:])
			if q_feature.qsize() == predict_horizon:
				previous_feature = q_feature.get()
				#print "label ", label[0]
				#print "previous_feature ", previous_feature[:,0].tolist()
				#print "current_feature ", feature[:,0].tolist()
				for pi, phase in enumerate(all_phases):
					output_file[pi].write(str(timestamp)+": "+str(feature[:,pi].tolist())[1:-1]+": "+str(label[pi])+": "+str(previous_feature[:,pi].tolist())[1:-1]+"\n")
				
			q_feature.put(feature)
			q_sample.get()

		q_sample.put(arrival_rate(samples))
		del samples[:] #= list()

	if q_smooth.qsize() == smooth_period:
		q_smooth.get()
	q_smooth.put(parse_line(line, all_phases))
	data = arrival_rate(list(q_smooth.queue))
	
	samples.append(data)
	
	
def main():
	q_sample = Queue()
	q_feature = Queue()
	q_smooth = Queue()

	log_name = "./centre_graham_cluster_log.txt"
	input_file = open(log_name,'r')
	file_0 = open('phase0_10D_test.txt','w')
	file_1 = open('phase1_10D_test.txt','w')
	output_file =[file_0, file_1]
	
	
	new_msg_rcv_time = 0
	prev_msg_rcv_time = 0
	scale = 1000
	dt = 1

	samples = list()
	'''all_phases = ['0','1']
	sample_rate = 30#how many seconds constitue a sample
	window_arrival = 10#1*60 / sample_rate
	predict_horizon = 5#window should be greater than horizon
	smooth_period = 60
'''
	for temp_line in input_file:

		line = temp_line[0:-1]

		new_msg_rcv_time = int(line.split()[0])
		time_diff = new_msg_rcv_time - prev_msg_rcv_time
		if  time_diff/scale > dt:
			fake_msg_time = prev_msg_rcv_time
			for i in range(time_diff/scale - 1):
				fake_msg_time += dt*scale
				fake_msg = str(fake_msg_time)

				#print fake_msg
				doLearning(fake_msg, q_sample, q_feature, q_smooth, samples, output_file, fake_msg_time)
				'''if len(samples) == sample_rate:
					if q_sample.qsize() == window_arrival:
						feature = np.array(q_sample.queue)
						label = arrival_rate(feature[-predict_horizon:])
						if q_feature.qsize() == predict_horizon:
							previous_feature = q_feature.get()
							for pi, phase in enumerate(all_phases):
								output_file[pi].write(str(fake_msg_time)+": "+str(feature[:,pi].tolist())[1:-1]+": "+str(label[pi])+": "+str(previous_feature[:,pi].tolist())[1:-1]+"\n")
						q_feature.put(feature)
						q_sample.get()
					q_sample.put(arrival_rate(samples))
					samples = list()
				if q_smooth.qsize() == smooth_period:
					q_smooth.get()
				q_smooth.put(parse_line(fake_msg, all_phases))
				data = arrival_rate(list(q_smooth.queue))

				samples.append(data)'''


		elif time_diff == 0:
			continue

		#print line
		doLearning(line, q_sample, q_feature, q_smooth, samples, output_file, new_msg_rcv_time)
		
		'''if len(samples) == sample_rate:
			if q_sample.qsize() == window_arrival:
				feature = np.array(q_sample.queue)
				label = arrival_rate(feature[-predict_horizon:])
				if q_feature.qsize() == predict_horizon:
					previous_feature = q_feature.get()
					for pi, phase in enumerate(all_phases):
						output_file[pi].write(str(new_msg_rcv_time)+": "+str(feature[:,pi].tolist())[1:-1]+": "+str(label[pi])+": "+str(previous_feature[:,pi].tolist())[1:-1]+"\n")
				q_feature.put(feature)
				q_sample.get()
			q_sample.put(arrival_rate(samples))
			samples = list()

		if q_smooth.qsize() == smooth_period:
			q_smooth.get()
		q_smooth.put(parse_line(line, all_phases))
		data = arrival_rate(list(q_smooth.queue))
		samples.append(data)'''
		
		prev_msg_rcv_time = new_msg_rcv_time
		
if __name__ == '__main__':
    main()
	