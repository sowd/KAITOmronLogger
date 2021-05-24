#!/bin/bash

modprobe ftdi_sio
chmod 777 /sys/bus/usb-serial/drivers/ftdi_sio/new_id
echo 0590 00d4 > /sys/bus/usb-serial/drivers/ftdi_sio/new_id
python3 /home/pi/2jciebu-usb-raspberrypi/sample_2jciebu.py

