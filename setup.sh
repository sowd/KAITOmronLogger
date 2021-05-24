#!/bin/bash

#pip3 install pyserial schedule

sudo modprobe ftdi_sio
sudo chmod 777 /sys/bus/usb-serial/drivers/ftdi_sio/new_id
sudo echo 0590 00d4 > /sys/bus/usb-serial/drivers/ftdi_sio/new_id

#python3 sample_2jciebu.py
