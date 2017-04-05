local manager = require(game.ReplicatedStorage:WaitForChild("LuaCoinManager"))

game.Players.PlayerAdded:connect(function(plr)
	local key = plr.Name.."_"..plr.userId
	manager:SetupPlayer("MasterBank",key)
	manager:GetInformation("MasterBank",key)
end)