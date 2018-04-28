# -*- coding: utf-8 -*-
"""
Created on Fri Apr 20 16:17:19 2018

@author: Dell
"""

import numpy as np
import cv2
import time
import os


starttime = time.time()
cap = cv2.VideoCapture(0) # video capture source camera (Here webcam of laptop) 

# i is an integer to give numbering to captured image.
i=0;
location = os.getcwd()
directory = 'images'
if not os.path.exists(directory):
	os.makedirs(directory)

while(cap.isOpened()):
    # Read frame to capture an image.
    ret, frame = cap.read() 
    
    # To show an image in window.
    cv2.imshow('frame',frame)
   
    # location where you want to store your images.
    
    # write frame on specified location.
    cv2.imwrite(location+'/images/photo'+str(i)+'.png',frame)
    
    # var going to store after what time your while loop should stop.
    var = time.time() - starttime  
    if ((var) > 20):
        break
    
    # if you want to quit press q.
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break 
    #you can change the sleeping time if you want. 0.005 sec which is currently set.
    time.sleep(0.005)
    i = i+1  

    cv2.putText(frame, var, (10,20),cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
    
# Release everything if job is finished
cap.release()
cv2.destroyAllWindows()