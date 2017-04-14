# 4x-led-dimmer
nodemcu based led dimmer.

This is a dimmer I made for use in my garden tent. It features wireless and wired control of 4 paper lanters.
TODO : put picture here.

It is capable of dimming each individual lantern and all together from zero to full.
it is controlled remotely via http requests, sent to dimmer's own ip address.
And it is controlled locally via simple push button switch.

The dimmer is based on esp12, nodemcu and mosfet transistors.
Its schematics is based on work done by [quinled](http://blog.quindorian.org/2016/07/esp8266-lighting-revisit-and-history-of-quinled.html/).
Its software is my own take on the subject but it is [standing on the shoulders of giants](https://en.wikipedia.org/wiki/Standing_on_the_shoulders_of_giants). 

Lanterns are something I found in Ikea sometime back. They used to have single solar charged led. 
TODO : picture here.

Replacing it with a led strip was straight forward. Led stripts are 12v white in color, one can shop virtually from everywhere.
TODO : picture here.

## How it works?
Led strips inside lanterns are wired to the dimmer.
The dimmer is wired to 12v/2A DC power supply.
Once powered, the dimmer will connect to specific wifi network (your home network). 
Once connected, it will offer an http address to receive requests how to control each lantern. Setup is based on ESP pwm module, using 1kHz modulation and 0-1023 duty cycle.
When operational, one can switch on/off the lanterns using a push button, wired to the dimmer.
Or it can use a control web page, hosted on separate http server, which can control the lanterns more complexly.

## Reqired Parts
In order to build dimmer like that, one would need following parts :
+ 4x 12v led strip(s). I've used 0.5m per lantern.
+ 4x paper lantern or something else to house the leds and give impression of a lamp.
+ 4x n-type MOSFET. I've used FDS8896.
If you choose another, make sure it opens fully with 3.3v input in gate. 
And it can support the current from leds. Mine were 30leds/m equaling 9w/m. Since I used half meter per lantern, each mosfet was loaded fully with 4.5w.
+ 1x [ESP8266 Dev Board](http://www.electrodragon.com/w/ESP8266_NodeMCU_Dev_Board)
I've used NodeMCU v0.9 because I had few lying around.
Basically I prefer NodeMCU boards rather than plain ESP12 chips because of USB-ready setup.
+ 1x DC2DC converter. I've used XM1584.
Input has to be 12v and output 3.3v capable. Current consumption is very small as NodeMCU and MOSFET gates are only powered.

## Dimmer wiring
Schematics of the dimmer is defined in [EasyEDA](https://easyeda.com/nikolai.fiikov/4x_led_dimmer-1c6357d0d04b4df8aa10d23598643d1c).
There is also PCB design defined, one can download or directly order.

## Software
There are 3 distincs aspects to be addressed :
- NodeMCU firmware
- Dimmer application inside NodeMCU
- Primary control server/web page

### NodeMCU firmware
The firmware is generic and provides with Lua-capable execution environment.
Typically NodeMCU dev boards come with pre-installed firmware.
But if you want to flash your own, the default build options from [nodemcu-custom-builds](https://nodemcu-build.com/) are enough. One can flash the "integer" version of the build.

### Dimmer software inside NodeMCU
The software is responsible of :
- initializing ESP chip
- connecting to home wifi network
- starting up the internal net server controlling the leds
- announce the server to mDNS
- support directly wired push button switch

How to install it? 
- Clone this repo
- Modify the wifi connectivity details at beggining in nodemcu/src/init.lua file
- Upload to NodeMCU nodemcu/src/init.lua to NodeMCU. 
Most simple way to upload lua code to NodeMCU is to use [ESPlorer](https://esp8266.ru/esplorer/).

### Web server
