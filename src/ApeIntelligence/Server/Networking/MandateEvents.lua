--!strict
local RemoteEventSpyStatic = {}

export type RemoteSpyObject = {
	Event: RBXScriptConnection; 
	PlayerRequestTable: {};
	Callback: (any) -> ();
	Disconnect: () -> ();
}

function RemoteEventSpyStatic:SpyRemote(Event: RBXScriptSignal, Leeway: number, Callback: (any) -> ()): RemoteSpyObject
	local Object = {}
	Object.PlayerRequestTable = {}
	Object.Callback = Callback

	Object.Event = Event:Connect(function(...)
		local Args = {...}
		local _, Player = next(Args)
		local LastRequest = Object.PlayerRequestTable[Player.UserId]

		if LastRequest and tick() - LastRequest > Leeway or not LastRequest then
			Object.PlayerRequestTable[Player.UserId] = tick()
			Object.Callback(...)
		else
			-- drop request
			return
		end
	end)

	Object.Disconnect = function()
		Object.Event:Disconnect()
	end

	return Object
end

return RemoteEventSpyStatic