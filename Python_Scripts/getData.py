from py_gameClient import game_client
import time
from matplotlib import pyplot as plt
import os
import statistics
import numpy as np
import sys
import math


ButtonNames = ["A", "B", "Up", "Down", "Left", "Right"]


client = game_client()

testControls = np.array([0, 1, 0, 0, 0, 1]) # format for inputs, must be integers

SeqLength = 45


def sendButtons(controls):
    out = str(controls)[1:][:-1]
    out = out.replace(' ', '')
    out = out.replace(',', '')
    client.send_line(out)




## CONNECTING TO BIZHAWK ###
client.listen()

try:
    while True:
        #last_time = time.time()
        ##Send
        sendButtons(testControls)
        
        ##Receive
        screen = np.array(client.receive().split(' ')).astype(float)
        
        
        

        #print(1/(time.time() - last_time))
except KeyboardInterrupt:
    print('interrupted!')
    sys.exit(0)
