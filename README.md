# OMRON 2JCIE-BU Logger

Tested on Raspi 3B+

## install

cd /home/pi
git clone https://github.com/sowd/KAITOmronLogger.git
pip3 install pyserial schedule


```
$ crontab -e
```

add
```
@reboot /home/pi/KAITOmronLogger/runLogger.sh
```
in the editor

## Reference
https://qiita.com/karaage0703/items/ed18f318a1775b28eab4
