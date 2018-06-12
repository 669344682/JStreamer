debug.sethook(nil)
------------------------------
--- File Loading functions ---
------------------------------

TextureCache = {}
CollisionCache = {}
ModelCache = {}
UsingTXD = {}

	function requestCOL(path)
		if not path then return end
		
		CollisionCache[path] = CollisionCache[path] or engineLoadCOL(path)
		
		if not CollisionCache[path] then
			triggerServerEvent ( "Failed", resourceRoot, path )
		end
		
		return CollisionCache[path]
	end
	
	function requestTXD(path,Name)
		if not path then return end
		
		TextureCache[path] = TextureCache[path] or engineLoadTXD(path)
		
		UsingTXD[path] = UsingTXD[path] or {}
		if Name then
		UsingTXD[path][Name] = true
		end
		
		if not TextureCache[path] then
			triggerServerEvent ( "Failed", resourceRoot, path )
		end
		
		return TextureCache[path]
	end

	function requestDFF(path)
		if not path then return end
		ModelCache[path] = ModelCache[path] or engineLoadDFF(path)
		
		if not ModelCache[path] then
			triggerServerEvent ( "Failed", resourceRoot, path )
		end
		
		return ModelCache[path]
	end
	
-------------------------
--- Loading functions ---
-------------------------
	
ModelInfo = {}

function LoadModel(Name,Model)
		
		ModelInfo[Name] = ModelInfo[Name] or {}
		
		if not ObjectDefintions[Name] then return end
		
		if not (ModelInfo[Name]['ID'] == Model) then

		if tonumber(ModelInfo[Name]['ID']) then
			engineRestoreCOL (ModelInfo[Name]['ID'])
			engineRestoreModel (ModelInfo[Name]['ID'])
		end
		
		
		ModelInfo[Name]['ID'] = Model        
	
		local DefintionTable = ObjectDefintions[Name]
	
		engineSetModelLODDistance (Model,math.max(tonumber(DefintionTable.LodDistance),150)) 

		
		
		engineImportTXD (requestTXD(DefintionTable.Txd,Name),Model)
		engineReplaceModel (requestDFF(DefintionTable.Dff),Model,DefintionTable.Alpha)
		engineReplaceCOL (requestCOL(DefintionTable.Col),Model)
		
		
	end
end

addEvent( "LoadID", true )
addEventHandler( "LoadID", root, LoadModel )

ObjectDefintions = {}

ObjectList = {}

for i,v in pairs(getElementsByType('object',resourceRoot)) do
	local id = getElementID(v) or getElementData(v,'ID')
		ObjectList[id] = ObjectList[id] or {}
		ObjectList[id][v] = true
end



function JCreateObjectDefinition(Name,DFFLocation,TextureLocation,CollisionLocation,Streaming,Alpha,Cull,Lod,OnA,OffA)
	if Name then
	
	ObjectDefintions[Name] = {}
	ObjectDefintions[Name].LodDistance = Streaming
	ObjectDefintions[Name].Col = CollisionLocation
	ObjectDefintions[Name].Txd = TextureLocation
	ObjectDefintions[Name].Dff = DFFLocation
	ObjectDefintions[Name].Alpha = Alpha
	ObjectDefintions[Name].Cull = Cull
	ObjectDefintions[Name].LOD = Lod
	
	if tonumber(OnA) then
	ObjectDefintions[Name].On = OnA
	ObjectDefintions[Name].Off = OffA
	end
	
	
	requestCOL(CollisionLocation)
	requestTXD(TextureLocation)
	requestDFF(DFFLocation)
	
		for i,v in pairs(ObjectList[Name] or {}) do
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
	

	if not ObjectDefintions[Name] then
			ObjectList[Name] = ObjectList[Name] or {}
				ObjectList[Name][Object] = true
		return
	end
	
	if isElement(Object) and ObjectDefintions[Name] then
				
			ObjectList[Name] = ObjectList[Name] or {}
				ObjectList[Name][Object] = true
			
			LoadModel(Name,getElementModel(Object)) -- This is just incase the model did not load previously
			
			local DefintionTable = ObjectDefintions[Name] 
			
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
						
	--VegReload()
	isVegElement(Object)
	isNightElement(Object)
	
		return true
		
	end
	--VegReload()
	isVegElement(Object)
	isNightElement(Object)
end
	addEvent( "LoadObject", true )
	addEventHandler( "LoadObject", root, changeObject )

Objects = {}

function JcreateObject(Name,x,y,z,xr,yr,zr)

		if tonumber(Name) or Model[Name] then
			triggerServerEvent ( "prepOriginals", resourceRoot,tonumber(Name) or Model[Name])
			return createObject(tonumber(Name) or Model[Name],x,y,z,xr,yr,zr) 
		end
	
		if not ModelInfo[Name] then
		triggerServerEvent ( "PrepID", resourceRoot,Name) -- Attempt to load ID
		end
		
		if ModelInfo[Name] then 
			local object = createObject(1899,x,y,z,xr,yr,zr)
			setElementModel(object,ModelInfo[Name]['ID'])
			
					Objects[sourceResource] = Objects[sourceResource] or {} 
					Objects[sourceResource][object] = true
				--changeObject(object,Name)
					
			return object
	end
end


function JsetElementModel(Element,Name) --- SET MODEL

		
		local id = getElementID(Element)
		
		if ObjectList[id] then
			ObjectList[id][Element] = nil
		end
		
		if tonumber(Name) or Model[Name] then
			triggerServerEvent ( "prepOriginals", resourceRoot,tonumber(Name) or Model[Name] )
			return setElementModel(Element,tonumber(Name) or Model[Name])
		end
		
		
		if not ModelInfo[Name] then
		triggerServerEvent ( "PrepID", resourceRoot,Name) -- Attempt to load ID
		end
		
		if ModelInfo[Name] then
			if ModelInfo[Name]['ID'] then
			setElementModel(Element,ModelInfo[Name]['ID'])
			changeObject(Element,Name)
		end
	end
end

---------------------------
--- UnLoading functions ---
---------------------------

function checkTXD(TXD)
if UsingTXD[TXD] then
		for i,v in pairs(UsingTXD[TXD]) do
			if i then 
				return
			end
		end
		destroyElement(TextureCache[TXD])
		TextureCache[TXD] = nil
	end
end


function unloadModel(Name)
	
	if ObjectDefintions[Name] then
		if ModelInfo[Name] then
		
		if ObjectDefintions[Name].Col then
			if CollisionCache[ObjectDefintions[Name].Col] and ModelCache[ObjectDefintions[Name].Dff] then
			
				destroyElement(CollisionCache[ObjectDefintions[Name].Col])
				CollisionCache[ObjectDefintions[Name].Col] = nil
				
				destroyElement(ModelCache[ObjectDefintions[Name].Dff])
				ModelCache[ObjectDefintions[Name].Dff] = nil
				
				UsingTXD[ObjectDefintions[Name].Txd][Name] = nil
				
				checkTXD(ObjectDefintions[Name].Txd)
			
			end
		end
		
			for i,v in pairs(LODs[Name] or {}) do
				if isElement(i) then
					destroyElement(i)
				end
			end
			
			if ModelInfo[Name]['ID'] then
				engineRestoreCOL (ModelInfo[Name]['ID'])
				engineRestoreModel (ModelInfo[Name]['ID'])
			end
			
			LODs[Name] = nil
			ModelInfo[Name] = nil
			ObjectDefintions[Name] = nil
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
