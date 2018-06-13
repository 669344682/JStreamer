Data = {Assigned = {},Data.ID = {}}

------------------------------
--- Object Loading functions ---
------------------------------

-- If a player failed to load a custom object then it is printed here
function LoadingFailed(Name)
	local name = getPlayerName(client)
	print('JStreamer : '..Name..' Failed For - '..name)
end

	addEvent( "FailedInLoading", true )
	addEventHandler( "FailedInLoading", resourceRoot, LoadingFailed) 
	
	
	
-- When an element is created this is triggered,
function loadObject(Object,Name)
	if isElement(Object) then
		if Data.ID[Name] then
			setElementModel(Object,Data.ID[Name])
			setElementData(Object,'Data.ID',Name)
			setElementID(Object,Name)	
		end
		triggerClientEvent ( root, "LoadObject", root,Object,Name )
	end
end

-- Preps an ID for usage whether it be custom or original.
function PrepID(Name,Reload)
	if Name then
	
		if Reload then
			Data.ID[Name] = nil
			Data.ID[Name] = Data.ID[Name] or getFreeID()
				
			for i,v in pairs(Data.Assigned[Name]) do
				if isElement(i) then
						JsetElementModel(i,Name)
				end
			end
		end
		
		Data.ID[Name] = Data.ID[Name] or getFreeID()
		UsedIDs[Data.ID[Name]] = Name
		Data.Assigned[Name] = Data.Assigned[Name] or {}
		triggerClientEvent ( root, "LoadID", root,Name,Data.ID[Name] ) -- Need this
		return Data.ID[Name]
	end
end

addEvent( "PrepID", true )
addEventHandler( "PrepID", resourceRoot, PrepID) 
	
	
--------------------------
--- Original functions ---
--------------------------
	
-- When the streamer attempts to create a SA object it'll run it through here, this reverts any elements using said Data.ID and reassigns them allowing the original Data.ID to be used.
function loadOriginal(Data.ID)
	if UsedIDs[Data.ID] then
		if not UsedIDs[Data.ID] == 'Yes' then
			PrepID(UsedIDs[Data.ID],true)
			UsedIDs[Data.ID] = 'Yes'
		end
	end
end
	
	addEvent( "prepOriginals", true )
	addEventHandler( "prepOriginals", resourceRoot, loadOriginal)  
	 
------------------------
--- Object functions ---
------------------------

Objects = {}

function JcreateObject(Name,x,y,z,xr,yr,zr) -- Create object function
			 
	if tonumber(Name) or getModelFromID(Name) then
		loadOriginal(tonumber(Name) or getModelFromID(Name))
	end

		local TheID = tonumber(Name) or getModelFromID(Name) or PrepID(Name)
			
		Data.ID[Name] = TheID
			
	if tonumber(TheID) then
			local object = createObject(TheID,x or 0,y or 0,z or 0,xr or 0,yr or 0,zr or 0)
			
		if object then 
			loadObject(object,Name)
			Data.Assigned[Name] = Data.Assigned[Name] or {}
			Data.Assigned[Name][object] = true
			Objects[sourceResource] = Objects[sourceResource] or {} 
			Objects[sourceResource][object] = true
			return object
		end
	end
end

function JsetElementModel(Element,Name) -- Set object model (Should technically be setObjectModel but for legacy purposes Element is kept)
			
	if tonumber(Name) or getModelFromID(Name) then
		loadOriginal(tonumber(Name) or getModelFromID(Name))
	end
			
		local currentID = getElementID(Element) or getElementData(Element,'Data.ID')
			
	if Data.Assigned[currentID] then
		Data.Assigned[currentID][Element] = nil
	end
			
		Data.ID[Name] = tonumber(Name) or getModelFromID(Name) or PrepID(Name)	
		setElementModel(Element,Data.ID[Name])	
		Data.Assigned[Name][object] = true	
		loadObject(Element,Name)
	return Element
end

-----------------------
---- Map Functions ----
-----------------------

-- Unloads the original map, if interiors are enabled it attempts to keep them (Check IDs_Sh for the other Interior related stuff if you want to try to get this working properly)
-- Only work around is to use my interior resource which contains all of the DFFs COLs and TXDs from SAs interiors (Unlisted at the moment, needs work)
if unloadMap then
	local dimenision = AllowInteriors and 0 or nil
	
	for i=550,20000 do
		removeWorldModel(i,10000,0,0,0,dimenision)
		removeWorldModel(i,10000,0,0,0,13)
	end	
		setOcclusionsEnabled(false)
	setWaterLevel ( -100000,true,false )
end
	
	
	function unloadModel(Name)
	triggerClientEvent ( root, "unLoadObject", root,Name )
	end
	
addEventHandler ( "onResourceStop", root, -- If you stop the resource 'Vice City' all elements created from the resource 'Vice City' will be destoryed.
function ( resource )
	if Objects[resource] then
		for i,v in pairs(Objects[resource]) do
			if isElement(i) then
				destroyElement(i)
			end
		end
	Objects[resource] = nil
	end
end 
)


--------------------------
---- Broken Functions ----
--------------------------
-- This allows server sided resources to check if an element is broken (Not 100% accurate)

	Broken = {}
function ElementBroke(Object)
	Broken[Object] = true
end
	
addEvent( "ElementBroke", true )
addEventHandler( "ElementBroke", resourceRoot, ElementBroke) 

	
function stopSync()
	Broken[source] = nil
end

addEventHandler( "onElementStopSync", resourceRoot, stopSync ) 
	
function isElementBroken(object)
		return Broken[object]
end





