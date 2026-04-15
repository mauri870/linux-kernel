#!/bin/bash                                                                                                                                                                                                          
# Interbench benchmark tuned for 9950X3D                                                                                                                                                                             
# https://github.com/ckolivas/interbench
#
# Targets CCD0(x3d cores), minus cpu0 since it's BSP                                                                                                                                                                 
sudo taskset -c 1-7,17-23 interbench -L 16 -r -t 10 -m "CCD0 isolated" 
