------------------------------
--- File Loading functions ---
------------------------------

Cache = {txd = {},coll = {},dff = {},usingTXD = {},list = {},info = {},defintions = {}}

function requestCOL(path)
	if path then
		Cache.coll[path] = Cache.coll[path] or engineLoadCOL(path)
			if not Cache.coll[path] then
				triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
			end
		return Cache.coll[path]
	end
end
	
function requestTXD(path,Name)
	if path then
	Cache.txd[path] = Cache.txd[path] or engineLoadTXD(path)

		Cache.usingTXD[path] = Cache.usingTXD[path] or {}
			if Name then
				Cache.usingTXD[path][Name] = true
			end
			
			if not Cache.txd[path] then
				triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
			end
		return Cache.txd[path]
	end
end

function requestDFF(path)
	if path then
		Cache.dff[path] = Cache.dff[path] or engineLoadDFF(path)
			if not Cache.dff[path] then
				triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
			end
		return Cache.dff[path]
	end
end
	
-------------------------
--- Loading functions ---
-------------------------

function LoadModel(Name,Model)
		
		Cache.info[Name] = Cache.info[Name] or {}
		
		if not Cache.defintions[Name] then return end
		
		if not (Cache.info[Name]['ID'] == Model) then

		if tonumber(Cache.info[Name]['ID']) then
			engineRestoreCOL (Cache.info[Name]['ID'])
			engineRestoreModel (Cache.info[Name]['ID'])
		end
		
		Cache.info[Name]['ID'] = Model        
	
		local DefintionTable = Cache.defintions[Name]
	
		engineSetModelLODDistance (Model,math.max(tonumber(DefintionTable.LodDistance),150)) 

		engineImportTXD (requestTXD(DefintionTable.Txd,Name),Model)
		engineReplaceModel (requestDFF(DefintionTable.Dff),Model,DefintionTable.Alpha)
		engineReplaceCOL (requestCOL(DefintionTable.Col),Model)
	end
end

addEvent( "LoadID", true )
addEventHandler( "LoadID", root, LoadModel )



for i,v in pairs(getElementsByType('object',resourceRoot)) do
	local id = getElementID(v) or getElementData(v,'ID')
		Cache.list[id] = Cache.list[id] or {}
	Cache.list[id][v] = true
end



function JCreateObjectDefinition(Name,DFFLocation,TextureLocation,CollisionLocation,Streaming,Alpha,Cull,Lod,OnA,OffA)
	if Name then
	
	Cache.defintions[Name] = {LodDistance = Streaming,Col = CollisionLocation,Txd = TextureLocation,Dff = DFFLocation,Alpha = Alpha,Cull = Cull,LOD = Lod,On = OnA,Off = Offa}
	
		--requestCOL(CollisionLocation)
		requestTXD(TextureLocation)
		--requestDFF(DFFLocation)
	
		for i,v in pairs(Cache.list[Name] or {}) do
			if isElement(i) then
				changeObject(i,Name)
			end
		end
	end
	triggerServerEvent ( "PrepID", resourceRoot,Name)
end



------------------------
--- Object functions ---
------------------------

LODs = {}

function changeObject(Object,Name)
	

	if not Cache.defintions[Name] then
			Cache.list[Name] = Cache.list[Name] or {}
			Cache.list[Name][Object] = true
		return
	end
	
	if isElement(Object) and Cache.defintions[Name] then
				
			Cache.list[Name] = Cache.list[Name] or {}
			Cache.list[Name][Object] = true
			
			LoadModel(Name,getElementModel(Object)) -- This is just incase the model did not load previously
			
			local DefintionTable = Cache.defintions[Name] 
			
			setElementDoubleSided(Object,DefintionTable.Cull)
			
		if getLowLODElement(Object) then
				destroyElement(getLowLODElement(Object)) -- Remove any previous LOD elements
		end
			
		setElementData(Object,'ID',Name)
		setElementID(Object,Name)				
			
		if DefintionTable.LOD then 							
			local LOD = createObject(getElementModel(Object),0,0,0,0,0,0,true)
			LODs[Name] = LODs[Name] or {}
			setElementID(LOD,Name)
			setElementData(LOD,'ID',Name)
			setLowLODElement(Object,LOD)
			setElementDoubleSided(LOD,DefintionTable.Cull)
			setElementDimension(LOD,getElementDimension(Object))
			setElementCollisionsEnabled(LOD,false)
			local x,y,z = getElementPosition(Object)
			local xr,yr,zr = getElementRotation(Object)
			setElementPosition(LOD,x,y,z)
			setElementRotation(LOD,xr,yr,zr)
		end
						
	isVegElement(Object)
	isNightElement(Object)
	
		return true
	end

	isVegElement(Object)
	isNightElement(Object)
end
	addEvent( "LoadObject", true )
	addEventHandler( "LoadObject", root, changeObject )

Objects = {}

function JcreateObject(Name,x,y,z,xr,yr,zr)

	if tonumber(Name) or getModelFromID(Name) then
		triggerServerEvent ( "prepOriginals", resourceRoot,tonumber(Name) or getModelFromID(Name))
		return createObject(tonumber(Name) or getModelFromID(Name),x,y,z,xr,yr,zr) 
	end
	
	if not Cache.info[Name] then
		triggerServerEvent ( "PrepID", resourceRoot,Name) -- Attempt to load ID
	end
		
	if Cache.info[Name] then 
		local object = createObject(1899,x,y,z,xr,yr,zr)
		setElementModel(object,Cache.info[Name]['ID'])
			
		Objects[sourceResource] = Objects[sourceResource] or {} 
		Objects[sourceResource][object] = true
			--changeObject(object,Name)
		return object
	end
end


function JsetElementModel(Element,Name) --- SET MODEL

		
	local id = getElementID(Element)
		
	if Cache.list[id] then
		Cache.list[id][Element] = nil
	end
		
	if tonumber(Name) or getModelFromID(Name) then
		triggerServerEvent ( "prepOriginals", resourceRoot,tonumber(Name) or getModelFromID(Name) )
		return setElementModel(Element,tonumber(Name) or getModelFromID(Name))
	end
		
		
	if not Cache.info[Name] then
	triggerServerEvent ( "PrepID", resourceRoot,Name) -- Attempt to load ID
	end
		
	if Cache.info[Name] then
		if Cache.info[Name]['ID'] then
			setElementModel(Element,Cache.info[Name]['ID'])
			changeObject(Element,Name)
		end
	end
end

---------------------------
--- UnLoading functions ---
---------------------------

function checkTXD(TXD)
	if Cache.usingTXD[TXD] then
		for i,v in pairs(Cache.usingTXD[TXD]) do
			if i then 
				return
			end
		end
		destroyElement(Cache.txd[TXD])
	Cache.txd[TXD] = nil
	end
end


function unloadModel(Name)
	if Cache.defintions[Name] then
		if Cache.info[Name] then
		
			if Cache.defintions[Name].Col then
				if Cache.coll[Cache.defintions[Name].Col] and Cache.dff[Cache.defintions[Name].Dff] then
				
					destroyElement(Cache.coll[Cache.defintions[Name].Col])
					Cache.coll[Cache.defintions[Name].Col] = nil
					
					destroyElement(Cache.dff[Cache.defintions[Name].Dff])
					Cache.dff[Cache.defintions[Name].Dff] = nil
					
					Cache.usingTXD[Cache.defintions[Name].Txd][Name] = nil
					
					checkTXD(Cache.defintions[Name].Txd)
				end
			end
		
				for i,v in pairs(LODs[Name] or {}) do
					if isElement(i) then
						destroyElement(i)
					end
				end
			
			if Cache.info[Name]['ID'] then
				engineRestoreCOL (Cache.info[Name]['ID'])
				engineRestoreModel (Cache.info[Name]['ID'])
			end
			
			LODs[Name] = nil
			Cache.info[Name] = nil
			Cache.defintions[Name] = nil
		end
	end
	VegReload()
	NightReload()
end
	addEvent( "unLoadObject", true )
	addEventHandler( "unLoadObject", root, unloadModel )
	
	

addEventHandler("onClientObjectBreak", resourceRoot,
    function()
		triggerServerEvent ( "ElementBroke", resourceRoot,source)
    end
)


addEventHandler("onClientElementDestroy", resourceRoot, function ()
	if getElementType(source) == "object" then
		if getLowLODElement(source) then
			destroyElement(getLowLODElement(source))
		end
	end
end)


addEventHandler ( "onClientResourceStop", root, 
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
