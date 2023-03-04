from gameClient import game_client
import time
import os
import statistics

client = game_client()
client.listen()

count = 0
avfps = []
try:
    while True:
        lastTime = time.time()
        screen = client.receive()
        fps = 1/(time.time() - lastTime)
        avfps.append(fps)
        count+=1
        if count>120:
            print(statistics.mean(avfps))
            avfps = []
            count = 0
except KeyboardInterrupt:
    print('interrupted!')