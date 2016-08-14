print("I: version 0.993")
relaycount = 4
relaypin = {8, 4, 3, 2}
relaystat = {"OFF", "OFF", "OFF", "OFF"}
relayname = {"REL1", "REL2", "REL3", "REL4"}
relaycfg = {0, 0, 0, 0}
relaynames = {"SR1", "SR2", "SR3", "SR4"}

if file.open("index.cfg", "r") then
 for i = 1, relaycount do
  local tmp = file.readline()
  if (tmp ~= nil) then
   tmp = string.gsub(tmp, "\r", "")
   tmp = string.gsub(tmp, "\n", "")
   relaystat[i] = tmp
  end
 end
 file.close()
else
 print("I: file index.cfg doesn't exist")
end

if file.open("relays.cfg", "r") then
 for i = 1, relaycount do
  local tmp = file.readline()
  if (tmp ~= nil) then
   tmp = string.gsub(tmp, "\r", "")
   tmp = string.gsub(tmp, "\n", "")
   relaycfg[i] = tmp
  end
 end
 file.close()
else
 print("I: file relays.cfg doesn't exist")
end

gpio.mode(0, gpio.OUTPUT)
gpio.write(0, gpio.LOW)
for i = 1, relaycount do
 gpio.mode(relaypin[i], gpio.OUTPUT)
 if (relaycfg[i] == "0") then  
  gpio.write(relaypin[i], gpio.HIGH)
  relaystat[i] = "OFF"
 end
 if (relaycfg[i] == "1") then  
  if (relaystat[i] == "OFF") then
   gpio.write(relaypin[i], gpio.HIGH)
  else
   gpio.write(relaypin[i], gpio.LOW)
  end
 end
 if (relaycfg[i] == "2") then  
  gpio.write(relaypin[i], gpio.LOW)
  relaystat[i] = "ON"
 end
end

wifi.setmode(wifi.SOFTAP)
cfgapwifi = {ssid = "relayboard", pwd = "relayboard"}
wifi.ap.config(cfgapwifi)
cfgapip = {ip="192.168.55.1", netmask="255.255.255.0", gateway="192.168.55.1"}
wifi.ap.setip(cfgapip)
tmr.register(0, 120000, tmr.ALARM_SINGLE, function()
 wifi.setmode(wifi.STATION)
 print("I: disabling default AP")
end)
tmr.start(0)

cfgaccessip = cfgapip.ip

function connectSTA()
 if file.open("sta.cfg", "r") then
  cfgstassid = file.readline();
  cfgstapwd = file.readline();
  file.close()
  if (cfgstapwd == nil) then
   cfgstapwd = "";
  end
  if (cfgstassid ~= nil) then
   cfgstassid = string.gsub(cfgstassid, "\r", "")
   cfgstassid = string.gsub(cfgstassid, "\n", "")
   cfgstapwd = string.gsub(cfgstapwd, "\r", "")
   cfgstapwd = string.gsub(cfgstapwd, "\n", "")
   print("I: STA attempting to configure ssid = \""..cfgstassid.."\" and pwd = \""..cfgstapwd.."\"")
   wifi.setmode(wifi.STATIONAP)
   wifi.sta.config(cfgstassid, cfgstapwd)
   counter = 0
   tmr.alarm(1, 1000, 1, function() 
    if (wifi.sta.getip() == nil) then
     if (counter == 0) then
      uart.write(0, "I: STA waiting for connect ")
     else
      uart.write(0, ".")
     end
     counter = counter + 1
     if (counter > 10) then
      print("\r\nE: STA connection timeout")
      tmr.stop(1)
     end
    else
     gpio.write(0, gpio.HIGH)
     print("\r\nI: STA IP address is "..wifi.sta.getip())
     cfgaccessip = wifi.sta.getip()
     tmr.stop(1)
    end
   end)
  end
 else
  print("I: file sta.cfg doesn't exist")
 end
end

function urlencode(str)
 str = string.gsub (str, "([^%w ])", function (c)
  return string.format ("%%%02X", string.byte(c))
 end)
 return str
end

function urldecode(str)
 str = string.gsub(str, "%%(%x%x)", function(h)
  return string.char(tonumber(h, 16))
 end)
 return str
end

function Header(code, content)
 return "HTTP/1.1 "..code.."\r\nConnection: close\r\nServer: ESP8266\r\nContent-Type: "..content.."\r\n\r\n"
end

function sendFile(filename, c)
 if file.open(filename, "r") then
  buf = Header("200 OK", "text/html")
  repeat
   local chunk = file.read(256)
   if chunk then
   buf = buf..chunk
  end
 until not chunk
 c:send(buf)
 file.close()
 end
end

connectSTA()

srv = net.createServer(net.TCP, 1)
srv:listen(80, function(c)
 c:on("receive", function(c, request)
  local buf = Header("200 OK", "text/html")
  local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP/1.1")
  if (method == nil) then
   _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
  end
  local _GET = {}
  if (method == "GET") and (vars ~= nil) and (path == "/cfg.html") then
--   print(vars)
   for n, v in string.gmatch(vars, "(%w+)=([%w,%%,-]+)&*") do
    _GET[n] = v
   end

   local changedstat = 0
   local changedcfg = 0
   local stattosave = 0

   for i = 1, relaycount do
    if (_GET[relayname[i]] ~= nil) then
     changedstat = 1

     if (relaycfg[i] == "1") then
      stattosave = 1
     end

     if (_GET[relayname[i]] == "ON") then
      relaystat[i] = "ON"
      gpio.write(relaypin[i], gpio.LOW)
     else
      relaystat[i] = "OFF"
      gpio.write(relaypin[i], gpio.HIGH)
     end
    end

    if (_GET[relaynames[i]] ~= nil) then
     changedcfg = 1
     relaycfg[i] = _GET[relaynames[i]]
     if (relaycfg[i] == "1") then
      stattosave = 1
     end
    end 
   end

   local function writeFile(filename, array)
    file.open(filename, "w+")
    for i = 1, relaycount do
     file.writeline(array[i])
    end
    print("I: closing file "..filename)
    file.close()
   end


   if (changedstat == 1) and (stattosave == 1) then
    writeFile("index.cfg", relaystat)
   end

   if (changedcfg == 1) then
    writeFile("relays.cfg", relaycfg)
    if (stattosave == 1) then
     writeFile("index.cfg", relaystat)
    end
   end

   if (_GET.cfgstassid ~= nil) then
    file.open("sta.cfg", "w+")
    file.writeline(urldecode(_GET.cfgstassid))
    if (_GET.cfgstapwd ~= nil) then
     file.writeline(urldecode(_GET.cfgstapwd))
    else
     file.writeline("")
    end
    print("I: closing file sta.cfg")
    file.close()
    connectSTA()
   end

   if (_GET.REL == "STATUS") then
    for i = 1, relaycount do
     buf = buf..relayname[i].."=\""..relaystat[i].."\";\r\n"
    end
   end
   
   if (_GET.STA == "STATUS") then
     buf = buf.."cfgstassid=\""..urlencode(cfgstassid).."\";\r\n"
     buf = buf.."cfgstapwd=\""..urlencode(cfgstapwd).."\";\r\n"
   end

   if (_GET.AIP == "STATUS") then
     buf = buf.."cfgaccessip='<a href=\"http://"..cfgaccessip.."\">"..cfgaccessip.."</a>';\r\n"
   end

   if (_GET.RLS == "STATUS") then
    for i = 1, relaycount do
     buf = buf..relaynames[i].."=\""..relaycfg[i].."\";\r\n"
    end

   end
   c:send(buf)
   buf = nil
  else
--   print(path)
   if (path == "/index.js") then
    sendFile("index.js", c)
   elseif (path == "/sta.html") then
    sendFile("sta.html", c)
   elseif (path == "/sta.js") then
    sendFile("sta.js", c)
   elseif (path == "/relays.html") then
    sendFile("relays.html", c)
   elseif (path == "/relays.js") then
    sendFile("relays.js", c)
   elseif (path == "/timers.html") then
    sendFile("timers.html", c)
   elseif (path == "/timers.js") then
    sendFile("timers.js", c)
   elseif (path == "/favicon.ico") then
    sendFile("favicon.ico", c)
   else
    sendFile("index.html", c)
   end
  end
  c:close()
  collectgarbage()
 end)
end)
