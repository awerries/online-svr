import service
import logging

class Receiver(service.receiver):
  def handler(self,msg):
    data = msg.strip().split('\n')
    for datum in data:
      if datum:
        datum_pieces = datum.split('|')
        msg_type = str(datum_pieces[0])
        msg_time = str(datum_pieces[1])
        msg_orig = str(datum_pieces[2])
        msg_data = str(datum_pieces[5])

        #check for relevant observations to send to the learner
        if (msg_type == 'observation'):
          # clust_info = msg_data.split(',')[1].split(']')[0]
          # print '\n' + str(clust_info.split[' '][0])
          # print '\n' + str(clust_info)
          print '\n' + msg_data.split(',')[1].split(']')[0]

        # print '\n' + datum

        # # print the phase changes
        # if (msg_orig == 'Baum_Euclid') and (not msg_type == 'full_schedule'):
        #   print '\n\n' + datum + '\n\n'
        
        # print the phase changes
        # if (msg_orig == 'Baum_Euclid') and (not msg_type == 'full_schedule'):
        #   print '\n\n' + datum + '\n\n'

        # print the scheduler information
        # elif msg_type == 'full_schedule':
        #   if msg_data.split(':')[0] == '["current_full_schedule",SchData':
        #     print 't=' + msg_time + msg_data.split(':')[1] + '\n'
          # msg_data_all = msg_data.split(',')
          # msg_label = str(msg_data_all[0])
          # if msg_label == 'current_full_schedule':
          #   print msg_data_all[1]

class Listener(service.listener):
  def __init__(self, addr):
    service.listener.__init__(self)
    self.name = "online_traffic_learner"
    self.addr = addr
    self.client = Receiver
    self.logger = logging.getLogger(self.name)

# myListener = Listener(('amh-lap.wv.cc.cmu.edu',33321))
myListener = Listener(('osprey.pc.cs.cmu.edu',33321))
myListener.start()