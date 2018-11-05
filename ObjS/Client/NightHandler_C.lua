off = {}
nightElements = {}


function isNightElement(object)
	local id = (getElementID(object) or getElementData(object,'ID'))
	
	if type(cache.defintions[id]) == 'table' then
		if tonumber(cache.defintions[id].on) then
			nightElements[id] = nightElements[id] or {}
			nightElements[id][(#nightElements[id])+1] = object
			if getLowLODElement(object) then
				nightElements[id][(#nightElements[id])+1] = getLowLODElement(object)
			end
		end
	end
end

function NightReload()
	nightElements = {}
	off = {}
	for i,v in pairs(getElementsByType('object',resourceRoot)) do
		isNightElement(v)
	end
	NightTimeElementCheck()
end

function reloadElements()
	if isTimer(timer) then
		killTimer(timer)
		timer = setTimer ( reloadStuff, 2000, 1 )
	end
end

function reloadStuff()
	timer = nil
	NightReload()
	VegReload()
end




function isInTimeRange(start,stop)
	hour = getTime()

	if start > stop then
		return (hour < start and hour > stop)
	else
		return (not (hour < stop and hour > start))
	end
end


function NightTimeElementCheck()
	for i,v in pairs(nightElements) do
		if not tonumber(cache.defintions[i].on) then
			NightReload()
		else
			if isInTimeRange(tonumber(cache.defintions[i].on),tonumber(cache.defintions[i].off)) then
				if not (off[i] == 1) then
					off[i] = 1
					for ia,va in pairs(v) do
						if isElement(va) then
							setObjectScale(va,0)
						end
					end
				end
			else
				if not (off[i] == 2) then
					off[i] = 2
					for ia,va in pairs(v) do
						if isElement(va) then
							setObjectScale(va,1)
						end
					end
				end
			end
		end
	end
end

setTimer(NightTimeElementCheck,1000,0)



