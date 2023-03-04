from gameClient import game_client
import time
from matplotlib import pyplot as plt
import os
import statistics
import numpy as np
import sys
import math


client = game_client()




## CONNECTING TO BIZHAWK ###
client.listen()

try:
    while True:
        #last_time = time.time()
        
        screen = np.array(client.receive().split(' ')).astype(float)
        
        #print(1/(time.time() - last_time))

except KeyboardInterrupt:
    print('interrupted!')
    sys.exit(0)