debug.sethook(nil)

------------------------------
--- Object Loading functions ---
------------------------------

Loaded = {}
AssignedObjects = {}
ID = {}



	function Failed(Name)
		
		local name = getPlayerName(client)
		print('JStreamer : '..Name..' Failed For - '..name)
	end

	addEvent( "Failed", true )
	addEventHandler( "Failed", resourceRoot, Failed) 
	
	
	function loadObject(Object,Name)
		if isElement(Object) then
			if ID[Name] then

				setElementModel(Object,ID[Name])
				setElementData(Object,'ID',Name)
				setElementID(Object,Name)
				
			end
			triggerClientEvent ( root, "LoadObject", root,Object,Name )
		end
	end


	function PrepID(Name,Reload)
		if not Name then return end
		if Reload then
			ID[Name] = nil
			ID[Name] = ID[Name] or getFreeID()
			
			for i,v in pairs(AssignedObjects[Name]) do
				if isElement(i) then
					JsetElementModel(i,Name)
				end
			end
		end
		
	ID[Name] = ID[Name] or getFreeID()
	UsedIDs[ID[Name]] = Name
	AssignedObjects[Name] = AssignedObjects[Name] or {}
	triggerClientEvent ( root, "LoadID", root,Name,ID[Name] ) -- Need this
		return ID[Name]
	end

	addEvent( "PrepID", true )
	addEventHandler( "PrepID", resourceRoot, PrepID) 
	
	
------------------------
--- Original functions ---
------------------------
	

	function loadOriginal(ID)
		if UsedIDs[ID] then
			if not UsedIDs[ID] == 'Yes' then
				PrepID(UsedIDs[ID],true)
				UsedIDs[ID] = 'Yes'
			end
		end
	end
	
	addEvent( "prepOriginals", true )
	addEventHandler( "prepOriginals", resourceRoot, loadOriginal)  
	 
------------------------
--- Object functions ---
------------------------

Objects = {}

	function JcreateObject(Name,x,y,z,xr,yr,zr)
			 
			if tonumber(Name) or getModelFromID(Name) then
				loadOriginal(tonumber(Name) or getModelFromID(Name))
			end

			local TheID = tonumber(Name) or getModelFromID(Name) or PrepID(Name)
			
			ID[Name] = TheID
			
			if tonumber(TheID) then
			
			
			local object = createObject(TheID,x or 0,y or 0,z or 0,xr or 0,yr or 0,zr or 0)
			
				if not object then 
					return 
				else
					loadObject(object,Name)
					AssignedObjects[Name] = AssignedObjects[Name] or {}
					AssignedObjects[Name][object] = true
					Objects[sourceResource] = Objects[sourceResource] or {} 
					Objects[sourceResource][object] = true
				return object
			end
		end
	end

	function JsetElementModel(Element,Name)
			
			if tonumber(Name) or getModelFromID(Name) then
				loadOriginal(tonumber(Name) or getModelFromID(Name))
			end
			
			local currentID = getElementID(Element) or getElementData(Element,'ID')
			
			if AssignedObjects[currentID] then
				AssignedObjects[currentID][Element] = nil
			end
			
			local TheID = tonumber(Name) or getModelFromID(Name) or PrepID(Name)
			
			ID[Name] = TheID
			
			setElementModel(Element,TheID)
			
			AssignedObjects[Name][object] = true
			
			loadObject(Element,Name)
			
		return Element
	end

-----------------------
---- Map Functions ----
-----------------------

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
	
addEventHandler ( "onResourceStop", root, 
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





