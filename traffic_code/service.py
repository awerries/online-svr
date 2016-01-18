import socket
import threading
import logging
import time

#### Persistent threads ####

class persistent(threading.Thread):
  def __init__(self):
    threading.Thread.__init__(self)
    self.stayAlive = True
    self.logger = ''#logging
    self.daemon = True
  def stop(self):
    self.stayAlive = False
  def quit(self):
    if self.isAlive():
      self.stop()
      self.join()
  def restart(self):
    self.quit()
    self.__init__()
    self.start()
  def pre(self):
    pass
  def main(self):
    pass
  def post(self):
    pass
  def run(self):
    #self.logger.info('Starting %s'%self.name)
    self.pre()
    while self.stayAlive:
      self.main()
    self.post()
    #self.logger.info('Stopping %s'%self.name)

class listener(persistent):
  def __init__(self):
    persistent.__init__(self)
    self.addr = ''
    self.client = ''
    self.sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  def pre(self):
    if self.addr and self.client:
      try:
        self.sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind(self.addr)
        #self.sock.settimeout(1)
        self.sock.setblocking(1)
        self.sock.listen(100)
      except Exception as e:
        #self.logger.critical('Cannot listen on address (%s,%d): %s'%(self.addr[0],self.addr[1],e))
        print "Cannot listen on address"
        self.stop()
    else:
      self.stop()
  def main(self):
    try:
      sock,addr = self.sock.accept()
    except socket.timeout:
      pass
    except Exception as e:
      #self.logger.error('Caught an unexpected exception while listening, restarting socket: %s'%e)
      self.post()
      self.pre()
    else:
      try:
        self.client(sock,self.logger).start()
      except Exception as e:
        #self.logger.critical('Failed to start client thread (%n threads active): %s'%(threading.active_count(),e))
        try:
          sock.shutdown(socket.SHUT_RDWR)
          sock.close()
        except Exception as e:
          #self.logger.error('Could not close client socket for listener: %s'%e)
          print 'Could not close client socket for listener'
  def post(self):
    try:
      self.sock.shutdown(socket.SHUT_RDWR)
      self.sock.close()
    except Exception as e:
      #self.logger.warning('Caught an exception while trying to shutdown a listener socket, might already be closed: %s'%e)
      print 'Caught an exception while trying to shutdown a listener socket, might already be closed'

class persist_recv(persistent):
  def __init__(self,sock,logger):
    persistent.__init__(self)
    self.sock = sock
    self.file = sock.makefile("rb")
    self.logger = logger
  def restart(self):
    sock = self.sock
    logger = self.logger
    self.quit()
    try:
      self.__init__(sock,logger)
    except Exception as e:
      #self.logger.error('Could not restart persistent_recv')
      print 'Could not restart persistent_recv'
    else:
      self.start()
  def handler(self,data):
    pass
  def pre(self):
    self.sock.settimeout(1)
  def main(self):
    try:
      data = self.file.readline().strip()
    except socket.timeout:
      pass
    else:
      if data:
        self.handler(data)
      else:
        #self.logger.debug('Persistent socket was closed')
        print 'Persistent socket was closed'
        self.stop()
  def post(self):
    try:
      self.sock.shutdown(socket.SHUT_RDWR)
      self.sock.close()
    except Exception as e:
      #self.logger.warning('Caught an exception while trying to shutdown a persistent_recv socket, might already be closed: %s'%e)
      print 'Caught an exception while trying to shutdown a persistent_recv socket'

class collector(persistent):
  def __init__(self,addr,timeout=1.0,begin='',end=''):
    persistent.__init__(self)
    self.addr = addr
    self.name = '_'.join([str(x) for x in self.addr])
    self.logger ='' #logging.getLogger(self.name)
    self.begin = begin
    self.end = end
    self.timeout = timeout
  def connect(self,period=6):
    connected = False
    tries = 0
    while not connected:
      connected = self._connect(verbose=(tries % period == 0))
      tries += 1
  def _connect(self,verbose=False,wait=10):
    self.sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    self.sock.settimeout(self.timeout)
    try:
      self.sock.connect(self.addr)
    except Exception as e:
      #self.logger.warning('Cannot connect to %s (%s)'%(str(self.addr),e))
      time.sleep(wait)
      return False
    else:
      self.sock.settimeout(1)
      #self.file = self.sock.makefile("rb")
      #self.logger.debug('Connected to %s'%str(self.addr))
      if self.begin:
        self.sock.send(self.begin)
      return True
  def restart(self):
    addr = self.addr
    timeout = self.timeout
    begin = self.begin
    end = self.end
    self.quit()
    try:
      self.__init__(addr,timeout,begin,end)
    except Exception as e:
      #self.logger.error('Could not restart collector')
      print 'Could not restart collector'
    else:
      self.start()
  def handler(self,data):
    pass
  def pre(self):
    self.connect()
  def main(self):
    try:
      #data = self.file.readline().strip()
      data = self.readline()
    except socket.timeout:
      pass
    else:
      if data:
        self.handler(data)
      else:
        #self.logger.debug('Persistent socket was closed')
        self.connect()
        #self.stop()
  def readline(self,delim='\n'):
    line = ''
    c = self.sock.recv(1)
    if not c:
      raise socket.timeout
    else:
      while c != delim:
        line += c
        c = self.sock.recv(1)
      return line
  def post(self):
    try:
      if self.end:
        self.sock.send(self.end)
      self.sock.shutdown(socket.SHUT_RDWR)
      self.sock.close()
    except Exception as e:
      #self.logger.info('Caught an exception while trying to shutdown a collector socket, probably was closed from the other side: %s'%e)
      print 'Caught an exception while trying to shutdown a collector socket '


#### Client threads ####

class helper(threading.Thread):
  def __init__(self,data,logger):
    threading.Thread.__init__(self)
    self.data = data
    self.logger = '' #logger

class client(threading.Thread):
  def __init__(self,sock,logger):
    threading.Thread.__init__(self)
    self.sock = sock
    self.logger = logger
  def sockclose(self):
    try:
      self.sock.shutdown(socket.SHUT_RDWR)
    except Exception as e:
      #self.logger.warning('Socket has already been shutdown: %s'%e)
      print 'Socket has already been shutdown'
    try:
      self.sock.close()
    except Exception as e:
      #self.logger.warning('Socket has already been closed: %s'%e)
      print 'Socket has already been closed'

class receiverOld(client):
  def handler(self,data):
    pass
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
    self.sockclose()
    try:
      self.handler(data)
    except Exception as e:
      #self.logger.error('Could not handle data: %s (%s)'%(data,e))
      print 'Could not handle data'

class receiver(client):
  def handler(self,data):
    pass
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
      self.handler(data)
    except Exception as e:
      #self.logger.error('Could not handle data: %s (%s)'%(data,e))
      print 'Could not handle data'


class sender(client):
  def handler(self):
    pass
  def run(self):
    try:
      data = self.handler()
    except Exception as e:
      #self.logger.error('Could not get data from handler, not sent (%s)'%e)
      print 'Could not get data from handler'
    else:
      try:
        self.sock.send(data)
      except Exception as e:
        #self.logger.error('Could not send data: %s (%s)'%(data,e))
        print 'Could not send data'
    self.sockclose()

class query(client):
  def handler(self,data):
    pass
  def run(self):
    try:
      data = self.sock.recv(1024)
    except Exception as e:
      #self.logger.error('Could not receive query: %s'%e)
      print 'Could not receive query'
    else:
      try:
        response = self.handler(data)
      except Exception as e:
        #self.logger.error('Could not handle query data: %s (%s)'%(data,e))
        print 'Could not handle query data'
      else:
        try:
          self.sock.send(response)
        except Exception as e:
          #self.logger.error('Could not send query response: %s (%s)'%(response,e))
          print 'Could not send query response'
    self.sockclose()
