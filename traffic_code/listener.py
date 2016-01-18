import service
import logging
import sys

# last_timestep = 0
# dt = 1000

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
          clust_info = str(msg_data.split(',')[1].split(']')[0])

          #write the cluster information
          sys.stdout.write(clust_info+'\n')
          return clust_info

  def run(self):
    data = ''
    while True:
      try:
        d = self.sock.recv(1024)
      except Exception as e:
        #self.logger.error('Could not receive data: %s'%e)
        print 'Could not receive data'
        break
      else:
        data += d
        if not d:
          break
    #self.sockclose()
    try:
      parsed_clusters = self.handler(data)
      logging.info('%s'%parsed_clusters)
    except Exception as e:
      #self.logger.error('Could not handle data: %s (%s)'%(data,e))
      print 'Could not handle data'


class Listener(service.listener):
  def __init__(self, addr):
    service.listener.__init__(self)
    self.name = "online_traffic_learner"
    self.addr = addr
    self.client = Receiver
    # self.logger = logging.getLogger(self.name)

# myListener = Listener(('amh-lap.wv.cc.cmu.edu',33321))
logging.basicConfig(filename='example.log',level=logging.INFO)
myListener = Listener(('osprey.pc.cs.cmu.edu',33321))
myListener.start()