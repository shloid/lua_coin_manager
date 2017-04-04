local manager = require(game.ReplicatedStorage:WaitForChild("LuaCoinManager"))

game.Players.PlayerAdded:connect(function(plr)
	local key = plr.Name.."_"..plr.userId
	manager:SetupBank(key)
	manager:GetInformation(key)
end)