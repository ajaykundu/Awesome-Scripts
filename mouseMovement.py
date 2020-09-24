# -*- coding: utf-8 -*-
"""
Created on Thu Sep 24 10:32:51 2020

@author: ajkundu
"""

import pyautogui 
import time

while 1:
    pyautogui.moveTo(100, 100, duration = 1) 
    pyautogui.moveTo(1000, 1000, duration = 1)
    time.sleep(120)
    