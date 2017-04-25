function Arcker:Load()
	if SERVER then
		BroadcastLua( [[ Arcker:Load() ]] )
	end
	hook.Run( 'ArckerPreload', Arcker )
	
	function Arcker:GetSpawn()
		return {
			Max = Vector( 1024, 1024,-11840) * Vector( 1.1, 1.1, 1 ),
			Min = Vector(-1024,-1024,-12364) * Vector( 1.1, 1.1, 1 ),
		}
	end
	
	if SERVER then
		Arcker:LoadCommandSystem()
		Arcker:LoadBaseCommands()
		Arcker:LoadPlugins()
		Arcker:RunEvent( 'OnEndBaseLoad' )
	end
end