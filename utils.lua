function split(inputstr, sep)
   if sep == nil then
      sep = '%s'
   end
   local t = {}
   for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
      table.insert(t, str)
   end
   return t
end

--[[ Because there is no wait function in lua this is as good as it will get, but 
     it's not 100% accurate, a few milliseconds here or there]]
function wait(msToWait)
   local millis = computer.millis()
   while computer.millis() - millis < msToWait do
      computer.skip()
   end
end

--[[ function round: This will round numbers for you to whatever precision level you want,
     from whole numbeers down to thousands or even more.
     to get this to a specific decimal place call it with the precison you want writen as 0.x
     example 1 : round(<some number>,0.1) will round to the nearest tenth
     example 2 : round( <some number> , 0.01) will return the number rounded to the nearest hundreth and so on
     example 3 : if precision is not specified it defaults to 1 (whole number rounding) ]]
function round(number, decimalPlace)
   if decimalPlace == nil then
      decimalPlace = 1
   end

   -- Now we divide the value by the decimalPlace ... this works because math ...
   local preRound = number / decimalPlace

   -- I stole this from google somewhere --
   local value = preRound % 1 >= 0.5 and math.ceil(preRound) or math.floor(preRound)

   local desiredPrecision = value * decimalPlace
   return desiredPrecision
end

--[[ perMinute: This will take the amount a machine uses or produces and then 
     multiply it by the result of diving 60 by the cycleTime of the factory ]]
function perMinute(amount, cycleTime)
   local perMinute = (60 / cycleTime) * amount
   return perMinute
end


worldClock = {}
function worldClock.new(card,fs)
   local self = {}
   local request = card:request("http://worldclockapi.com/api/json/utc/now","GET", "")
   local _,jsonDate = request:await()
   local self = {}
   local dateInfo = json.decode(jsonDate)
      for k,v in pairs (dateInfo) do
         if k == "currentDateTime" then 
            self.year = string.sub(v,1,4)
            self.month = string.sub(v,6,7)
            self.day = string.sub(v,9,10)
         elseif k == "dayOfTheWeek" then
            self.dayOfTheWeek = v
         end
      end
   return self
end
