--[[  isWagonEmpty: Checks to see if there any empty wagons. Please note that 
      this not checking to see if a wagon has remaining space. It only returns 
      wagons if they are completely empty. 
]]
function isWagonEmpty(vehicles)
   for _, vehicle in ipairs(vehicles) do
      print(vehicle.internalName)
      if string.match(vehicle.internalName, 'Wagon') then
         slots = vehicle:getInventories()
         print(slots[1].itemCount)
         if slots[1].itemCount == 0 then
            return true
         end
      end
      return false
   end
end

--[[ This is used for finding a station that can fulfill an order. ]]
function findStation(stationServiceName, homeStation)
   for _, stationSearch in ipairs(allStations) do
      if stationSearch.nick ~= nil then
         if string.match(stationSearch.nick, stationServiceName) then
            return stationSearch
         end
      end
   end
   return 'not found'
end

--[[  getStations: Returns all stations attached to the same track. This is 
      useful for when you want to use a system to create and automatically fulfill 
      order / requests from a station.
]]
function getStations(trainStation)
   local allStations = trainStation:getTrackGraph():getStations()
   return allStations
end

--[[  getStationByName: Finds and retrieves the station trace. This is necessary
      as it is not enough to just pass the name of a station in other functions
      but you need a reference to the actual in game object
]]
function getStationByName(stationName)
   local stations = component.proxy(component.findComponent(stationName))
   return stations
end

--[[  Pass the name of the train as defined in the train table. Ideally you would make
      the train name fairly unique, but we iterate through just in case it returns more
      than one result. With the getTrains command it will fetch all the trains attached
      to the track the station is attached to.
]]
function getTrain(stationName, searchTrainName)
   trainStations = component.proxy(component.findComponent(stationName))
   for _, trainStation in pairs(trainStations) do
      local trackGraph = trainStation:getTrackGraph()
      local trains = trackGraph:getTrains()
      for _, train in pairs(trains) do
         local trainName = train:getName()
         if string.find(trainName, searchTrainName) then
            return train
         end
      end
   end
end

function stationStorage(stationName)
   local freightPlatforms = component.proxy(component.findComponent(stationName))
   local size = 1 -- I don't recall why I had to set this, it may be that the station itself is returned as the first platform?
   local totalPercent = 0
   local totalAmount = 0
   local allPercent = 0
   for _, platform in pairs(freightPlatforms) do
      if size <= #freightPlatforms then
         inv = platform:getInventories()[1]
         total = (inv.itemCount / 4800) * 100
         --[[ I cheated a bit here. Stations have 48 slots, and if you are
             storing an item that is 100 stack size you'd use 4800, so 
             this needs to be adjusted depending on cargo.
             In addition to get percent we take the amount in the cargo,
             divide it by the max and then multiply by 100 to get the % being used
             in each platform
         ]]
         totalAmount = totalAmount + total -- Add up each % for each platform.
         size = size + 1
      end
   end
   if totalAmount ~= 0 then
      allPercent = (totalAmount / 5) -- Five may need to be adjusted to use the number of platforms ...
   end
   return allPercent
end

function addStop(station, train)
   local timeTable = getTrainTimeTable(train)
   timeTable:addStop(1, station, 1)
end

function removeStation(station, trainTimeTable)
   local stationStops = trainTimeTable:getStops()
   for i, stationStop in ipairs(stationStops) do
      if station.nick == stationStop.station.nick then
         if i > 1 then
            trainTimeTable:removeStop(i - 1)
         end
      end
   end
end

function isScheduled(stationFind, trainTimeTable)
  local stationStops = trainTimeTable:getStops()
  if #stationStops < 0 then
     return false
  end
  for _, stationStop in ipairs(stationStops) do
     if stationStop.station.nick == stationFind.nick then
        return true
     end
  end
  return false
end

function getTrainTimeTable(train)
  local trainTimeTable = train:getTimeTable()
  print("time",type(trainTimeTable))
  if trainTimeTable == nil then 
    print("UNABLE TO LOCATE TIME TABLE!!") 
  end
  return trainTimeTable
end
