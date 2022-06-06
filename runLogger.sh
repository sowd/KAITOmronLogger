#!/usr/bin/python3
# -*- coding:utf-8 -*-

LOG_INTERVAL=60

# Slack notification
# ToDo: Replace the following SLACK_URL to your incoming webhooks API url
SLACK_URL = 'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX'
DISCONFORT_THRESHOLD = 90.0
RANDOM_NOTIFY_INTERVAL_AVG_SEC = 3*60*60 # 3 hours

import sys,os,time,glob
import argparse,json,serial
from datetime import datetime
import subprocess

def PostToSlack(msg):
  if len(SLACK_URL)==0 :
    print(msg)
    return

  try:
    args = [
      'curl','-X','POST','-H','Content-Type: application/json','-d'
      ,'{"text":"'+msg+'"}',SLACK_URL
    ]
    res = subprocess.check_call(args)
  except:
    print("Error in posting to slack.");

import socket

def pr(msg):
  PostToSlack(socket.gethostname()+':'+msg)


MYPATH=os.path.dirname(os.path.abspath(__file__))

FILENAME = "%s/log/%d.csv"%(MYPATH,time.time())
pr('Output file: '+FILENAME)

# LED display rule. Normal Off.
DISPLAY_RULE_NORMALLY_OFF = 0
# LED display rule. Normal On.
DISPLAY_RULE_NORMALLY_ON = 1

os.system(MYPATH+"/setup.sh")

while True:
  devCandidates=glob.glob('/dev/serial/by-id/usb-OMRON_2JCIE-*')
  if len(devCandidates)==0 :
    pr('Please connect OMRON 2JCIE sensor to an USB port')
    time.sleep(3)
    continue
  break
OMRON_SERIAL_ID=devCandidates[0]
#OMRON_SERIAL_ID="/dev/ttyUSB0"
#OMRON_SERIAL_ID="/dev/serial/by-id/usb-OMRON_2JCIE-BU01_MY3AIXN7-if00-port0"
pr('Connecting to '+OMRON_SERIAL_ID)

print('============')


def calc_crc(buf, length):
    """
    CRC-16 calculation.
    """
    crc = 0xFFFF
    for i in range(length):
        crc = crc ^ buf[i]
        for i in range(8):
            carrayFlag = crc & 1
            crc = crc >> 1
            if (carrayFlag == 1):
                crc = crc ^ 0xA001
    crcH = crc >> 8
    crcL = crc & 0x00FF
    return (bytearray([crcL, crcH]))


def now_utc_str():
    return datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")


serSensor = None

def startSensor():
    global serSensor
    serSensor = serial.Serial(OMRON_SERIAL_ID, 115200, serial.EIGHTBITS, serial.PARITY_NONE)

    try:
        # LED On. Color of Green.
        command = bytearray([0x52, 0x42, 0x0a, 0x00, 0x02, 0x11, 0x51, DISPLAY_RULE_NORMALLY_ON, 0x00, 0, 255, 0])
        command = command + calc_crc(command, len(command))
        serSensor.write(command)
        time.sleep(0.1)
        ret = serSensor.read(serSensor.inWaiting())

    except KeyboardInterrupt:
        # LED Off.
        command = bytearray([0x52, 0x42, 0x0a, 0x00, 0x02, 0x11, 0x51, DISPLAY_RULE_NORMALLY_OFF, 0x00, 0, 0, 0])
        command = command + calc_crc(command, len(command))
        serSensor.write(command)
        time.sleep(1)
        # script finish.
        serSensor.exit

isPrevDisconfort = False
def getSensorData(data):
    global isPrevDisconfort
    """
    print measured latest value.
    """
    time_measured = datetime.now().strftime("%Y/%m/%d %H:%M:%S")
    temperature = str(int(hex(data[9]) + '{:02x}'.format(data[8], 'x'), 16) / 100)
    relative_humidity = str(int(hex(data[11]) + '{:02x}'.format(data[10], 'x'), 16) / 100)
    ambient_light = str(int(hex(data[13]) + '{:02x}'.format(data[12], 'x'), 16))
    barometric_pressure = str(int(hex(data[17]) + '{:02x}'.format(data[16], 'x')
                                  + '{:02x}'.format(data[15], 'x') + '{:02x}'.format(data[14], 'x'), 16)
 / 1000)
    sound_noise = str(int(hex(data[19]) + '{:02x}'.format(data[18], 'x'), 16) / 100)
    eTVOC = str(int(hex(data[21]) + '{:02x}'.format(data[20], 'x'), 16))
    eCO2 = str(int(hex(data[23]) + '{:02x}'.format(data[22], 'x'), 16))
    discomfort_index = str(int(hex(data[25]) + '{:02x}'.format(data[24], 'x'), 16) / 100)
    heat_stroke = str(int(hex(data[27]) + '{:02x}'.format(data[26], 'x'), 16) / 100)
    vibration_information = str(int(hex(data[28]), 16))
    si_value = str(int(hex(data[30]) + '{:02x}'.format(data[29], 'x'), 16) / 10)
    pga = str(int(hex(data[32]) + '{:02x}'.format(data[31], 'x'), 16) / 10)
    seismic_intensity = str(int(hex(data[34]) + '{:02x}'.format(data[33], 'x'), 16) / 1000)
    temperature_flag = str(int(hex(data[36]) + '{:02x}'.format(data[35], 'x'), 16))
    relative_humidity_flag = str(int(hex(data[38]) + '{:02x}'.format(data[37], 'x'), 16))
    ambient_light_flag = str(int(hex(data[40]) + '{:02x}'.format(data[39], 'x'), 16))
    barometric_pressure_flag = str(int(hex(data[42]) + '{:02x}'.format(data[41], 'x'), 16))
    sound_noise_flag = str(int(hex(data[44]) + '{:02x}'.format(data[43], 'x'), 16))
    etvoc_flag = str(int(hex(data[46]) + '{:02x}'.format(data[45], 'x'), 16))
    eco2_flag = str(int(hex(data[48]) + '{:02x}'.format(data[47], 'x'), 16))
    discomfort_index_flag = str(int(hex(data[50]) + '{:02x}'.format(data[49], 'x'), 16))
    heat_stroke_flag = str(int(hex(data[52]) + '{:02x}'.format(data[51], 'x'), 16))
    si_value_flag = str(int(hex(data[53]), 16))
    pga_flag = str(int(hex(data[54]), 16))
    seismic_intensity_flag = str(int(hex(data[55]), 16))

    if isPrevDisconfort==False and float(discomfort_index) > DISCONFORT_THRESHOLD :
      pr("Disconfort index: "+discomfort_index)
    isPrevDisconfort = (float(discomfort_index) > DISCONFORT_THRESHOLD)

    return "%d,%s,%s,%s,%s,%s, %s,%s,%s,%s,%s, %s,%s,%s,%s,%s, %s,%s,%s,%s,%s, %s,%s,%s,%s,%s,%s" % (
       time.time()
       ,time_measured,temperature,relative_humidity,ambient_light,barometric_pressure
       ,sound_noise,eTVOC,eCO2,discomfort_index,heat_stroke,vibration_information
       ,si_value,pga,seismic_intensity,temperature_flag,relative_humidity_flag
       ,ambient_light_flag,barometric_pressure_flag,sound_noise_flag,etvoc_flag
       ,eco2_flag,discomfort_index_flag,heat_stroke_flag,si_value_flag
       ,pga_flag,seismic_intensity_flag)

#    return {
#	 "time_measured":time_measured
#	,"temperature":temperature
#	,"relative_humidity":relative_humidity
#	,"ambient_light":ambient_light
#	,"barometric_pressure":barometric_pressure
#	,"sound_noise":sound_noise
#	,"eTVOC":eTVOC
#	,"eCO2":eCO2
#	,"discomfort_index":discomfort_index
#	,"heat_stroke":heat_stroke
#	,"vibration_information":vibration_information
#	,"si_value":si_value
#	,"pga":pga
#	,"seismic_intensity":seismic_intensity
#	,"temperature_flag":temperature_flag
#	,"relative_humidity_flag":relative_humidity_flag
#	,"ambient_light_flag":ambient_light_flag
#	,"barometric_pressure_flag":barometric_pressure_flag
#	,"sound_noise_flag":sound_noise_flag
#	,"etvoc_flag":etvoc_flag
#	,"eco2_flag":eco2_flag
#	,"discomfort_index_flag":discomfort_index_flag
#	,"heat_stroke_flag":heat_stroke_flag
#	,"si_value_flag":si_value_flag
#	,"pga_flag":pga_flag
#	,"seismic_intensity_flag":seismic_intensity_flag
#    }



def addFile(str):
  print('Output: '+str)
  os.system('echo "'+str+'" >> '+FILENAME)

addFile("unixtime,time_measured,temperature,relative_humidity,ambient_light,barometric_pressure" \
     ",sound_noise,eTVOC,eCO2,discomfort_index,heat_stroke,vibration_information" \
     ",si_value,pga,seismic_intensity,temperature_flag,relative_humidity_flag" \
     ",ambient_light_flag,barometric_pressure_flag,sound_noise_flag,etvoc_flag" \
     ",eco2_flag,discomfort_index_flag,heat_stroke_flag,si_value_flag" \
     ",pga_flag,seismic_intensity_flag")

import schedule

def job():
  #print(time.time())

  if OMRON_SERIAL_ID != '':
    # Get Latest data Long.
    command = bytearray([0x52, 0x42, 0x05, 0x00, 0x01, 0x21, 0x50])
    command = command + calc_crc(command, len(command))
    tmp = serSensor.write(command)
    time.sleep(0.1)
    data = serSensor.read(serSensor.inWaiting())
    sensorData = getSensorData(data)

    addFile(sensorData)

#schedule.every(5).seconds.do(job)

startSensor()

import random
rndNotifyCountdown = int( 0.5 * RANDOM_NOTIFY_INTERVAL_AVG_SEC + random.random() * RANDOM_NOTIFY_INTERVAL_AVG_SEC )

linenum = 0
#with open( "%s/catLines.txt"%(MYPATH) ) as f:
with open( "%s/yodakaLines.txt"%(MYPATH) ) as f:
  msgs = f.readlines()

  while True:
    #schedule.run_pending()
    time.sleep(LOG_INTERVAL)
    job()

    rndNotifyCountdown = rndNotifyCountdown - LOG_INTERVAL
    if rndNotifyCountdown < 0 :
      #pr('Random nofication')
      pr(msgs[linenum])
      linenum = linenum+1
      rndNotifyCountdown = int( 0.5 * RANDOM_NOTIFY_INTERVAL_AVG_SEC + random.random() * RANDOM_NOTIFY_INTERVAL_AVG_SEC )
