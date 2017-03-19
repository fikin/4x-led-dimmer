-- initialize a dimmer of 4 leds

local areLedsOff=false
local pinButton=0
local port=43333
local hotspotName="-PUT-HERE-SSID-"
local hotspotPswd="-PUT-HERE-SSID-PASSWORD-"

local function initButton()
  gpio.mode(pinButton, gpio.INPUT, gpio.PULLUP)
  gpio.write(pinButton, gpio.HIGH)
end

local function doSetLed(led,value)
  print( "Setting " .. led .. "=" .. value )
  pwm.setup(led,1000,value)
  if value == 0 then
    areLedsOff = true
  else
    areLedsOff = false
  end
end

local function initLeds()
  for pin=1,4 do
    doSetLed(pin, 0)
    pwm.start(pin)
  end
end

local function assertAndSetLed(led, value)
  if led == "all" then
    for i=1,4 do assertAndSetLed(i, value) end
    return true
  else
    local ledN = tonumber(led)
    local valueN = tonumber(value)
    if not ledN or ledN <= 0 or ledN > 4 then
      print( "[WARN] : ignoring invalid led identification " .. led .. "=" .. value )
      return false
    elseif not valueN or valueN < 0 or valueN > 1023 then
      print( "[WARN] : ignoring invalid brightness " .. led .. "=" .. value )
      return false
    else
      doSetLed(ledN,valueN)
      return true
    end
  end
end

local function onNetRequest(sck, data)
    print("New data :" .. data)
    local processReq = false
  for line in string.gmatch(data,"[^\r\n]+") do
    for led,value in string.gmatch( line, "([^=]+)=([0-9]+)" ) do
      if assertAndSetLed(led, value) then
        processReq = true
      end
    end
  end
  if processReq then
    sck:send("Roger")
  else
    sck:send("Ignored")
  end
end

local function closeNetConnection(sck)
  sck:close()
end

local function onNetConnection(sck)
  print("New net connection arrived.")
  sck:on("receive", onNetRequest) 
  sck:on("sent", closeNetConnection) 
end

local function listenOnNetPort()
  print("Starting server on port " .. port .. " ...")
  srv = net.createServer(net.TCP)
  srv:listen(port, onNetConnection)
end

local function onWifiConnect()
  print( wifi.sta.getip() )
  listenOnNetPort()
end

local function doConnectToHomeWifi()
  print( "Connecting to " .. hotspotName .. " ..." )
  wifi.setmode(wifi.STATION)
  wifi.sta.config(hotspotName,hotspotPswd)
  wifi.sta.eventMonReg(wifi.STA_GOTIP, onWifiConnect)
  wifi.sta.eventMonStart()
end

local function connectToHomeWifi()
    local myTmr = tmr.create()
  myTmr:register(10, tmr.ALARM_SINGLE, doConnectToHomeWifi )
  if not myTmr:start() then
    print( "[ERR] : failed to initiate WiFi connectivity via delayed timer ".. timerId)
  end
end

local function startButtonListener(myTmr)
  if not myTmr:start() then
    print("[ERR] : failed to restart button timer!!!")
  end
end

local function toggleLedOnOff()
  if areLedsOff then
    assertAndSetLed("all", 1023)
  else
    assertAndSetLed("all", 0)
  end
end

local function onButtonDown(myTmr)
  print("Button pressed")
  toggleLedOnOff()
end

local function onButtonListen(myTmr)
  if gpio.read(pinButton) == gpio.LOW then
    onButtonDown(myTmr)
  end
  startButtonListener(myTmr)
end

local function startButtonServer()
  local myTmr = tmr.create()
  myTmr:register( 1000, tmr.ALARM_SEMI, onButtonListen )
  startButtonListener(myTmr)
end

local function main()
  print("Initialize the dimmer ...")
  initLeds()
  initButton()
  connectToHomeWifi()
  startButtonServer()
end

main()
