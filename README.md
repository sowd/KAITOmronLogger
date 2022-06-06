# OMRON 2JCIE-BU Logger/Slack bot or JSONP API server

Tested on Raspi 3B+

## clone

```
cd /home/pi
git clone https://github.com/sowd/KAITOmronLogger.git
pip3 install pyserial schedule
```


### Install (autostart) Logger/Slack

If you want to automatically run Logger/Slack bot, modify Slack API address at the beginning of runLogger.sh and:

```
$ crontab -e
```

then add the following line.

```
@reboot /home/pi/KAITOmronLogger/runLogger.sh
```

in the editor

### Install (autostart) JSONP API server

```
$ crontab -e
```

then add the following line.

```
@reboot /home/pi/KAITOmronLogger/runServer.sh
```

Default port is 8081. If you want to modify, supply -P option.

If you want JSONP access, add ?callback= parameter to GET call.


## Reference
https://qiita.com/karaage0703/items/ed18f318a1775b28eab4
