import traceback
import socket

class game_client(object):
    def __init__(self):
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        port = 2222
        self.server.bind((socket.gethostname(), port))
        print("Hostname: %s Port: %d" % (socket.gethostname(), port))
        self.server.listen(1)
        
    def listen(self):
        while True:
            try:
                print('Listening for connection...')
                (self.clientsocket, self.address) = self.server.accept()
                print('Connection received.')
                
                break
            except KeyboardInterrupt:
                print('Keyboard Interrupt')
                pass
            except:
                print('Exception occurred while listening for client.')
                print(traceback.print_exc())
                if self.clientsocket != None:
                    self.clientsocket.send(b"close")
                    self.clientsocket.close()
            

    def receive_line(self):
        line = ""
        while not line.endswith('\n'):
            new_data = self.clientsocket.recv(1).decode('ascii')
            if len(new_data) == 0:
                raise Exception()
            line += new_data
        return line.strip()
    
    def receive(self):
        while True:
            try:
                screen = self.receive_line()
                #screen = [float(v) for v in screen.split(' ')]
                return screen
            except KeyboardInterrupt:
                print('interrupted!')
            except:
                print("Exception occurred. Closing connection.")
                print(traceback.print_exc())
                self.clientsocket.send(b"close")
                self.clientsocket.close()
                self.listen()
                
    def send_line(self, line):
        try:
            self.clientsocket.send((str(line) + '\n').encode())
        except:
            print("Exception occurred. Closing connection.")
            print(traceback.print_exc())
            self.clientsocket.send(b"close")
            self.clientsocket.close()
            self.listen()