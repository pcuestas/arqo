"""
num_channels.py
Find number of channels in your image.
Author: liuhh02 https://machinelearningtutorials.weebly.com/
"""

from PIL import Image
import numpy as np

# name of your image file
filename = 'p4/material/img/im5.jpg'
file2='p4/material/img/im6.jpeg'

# open image using PIL
img = Image.open(filename)
img2 = Image.open(filename)

# convert to numpy array
img = np.array(img)
img2 = np.array(img2)

# find number of channels
if img.ndim == 2:
    channels = 1
    print("image has 1 channel")
else:
    channels = image.shape[-1]
    print("image has", channels, "channels")


# find number of channels
if img2.ndim == 2:
    channels = 1
    print("image has 2 channel")
else:
    channels = image.shape[-1]
    print("image2 has", channels, "channels")