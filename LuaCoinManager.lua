------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lua Coin Module [v0.1a]
-- Created by shloid (da man!!!)
------------------------------------------------------------------------------------------------------------------------------------------------------

-- DataStores
local DataStore = game:GetService("DataStoreService")
local MasterBank = DataStore:GetDataStore("LuaCoin_MasterBank")
local Playerbase  = DataStore:GetDataStore("LuaCoin_Playerbase")

-- Settings & Module's Return Value
local lcm = {}
local settings = {
	debug = true;
	version = "1.0a",
	encrypted = true, -- it does nothing yet. so coming soon
	encrypt_length = 16,
	github_repository = "https://github.com/shloid/lua_coin_manager",
}

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Local Functions / Methods
------------------------------------------------------------------------------------------------------------------------------------------------------

local function Print(str)
	if settings.debug == true then 
		return print(str) 
	end
end

local function encrypt()
	local var, letterTable, numberTable = "",{"a","B","c","D","e","F","g","H","i","J","k","L","m","N","o","P","q","R","s","T","u","V","w","X","y","Z","#","$","%","@"},{"0","1","2","3","4","5","6","7","8","9"}
	for i = 1, settings.encrypt_length do
		if math.random(1,2) == 1 then
			local mdr1 = math.random(1,#letterTable)
			local letter = ""..letterTable[mdr1]
			var = var..letter			
		else
			local mdr1 = math.random(1,#numberTable)
			local letter = ""..numberTable[mdr1]
			var = var..letter	
		end
	end
	Print("[LuaCoin] New encrypted code: "..var)
	return var
end

local function checkForKey(key)
	local returnValue = nil
	local succ = pcall(function()
		Playerbase:UpdateAsync(key, function(oldValue)
			returnValue = ""..oldValue
		end)
	end)
	if succ then
		Print("[LuaCoin] There is a key within the Playerbase!")
	else
		Print("[LuaCoin] The player may not have a key OR you're in offline mode.")
	end
	return returnValue
end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Module Functions / Methods
------------------------------------------------------------------------------------------------------------------------------------------------------

function lcm:LuaCoinManager(amount,key)
	if amount == nil or key == nil then return end
	local encryptedKey = checkForKey(key)
	if encryptedKey == nil then Print("[LuaCoin] It seems that the encryptedKey is nil.") return end
	
	local succ = pcall(function()
		MasterBank:GetAsync(encryptedKey)
	end)
	
	if succ then
		MasterBank:UpdateAsync(encryptedKey,function(oldValue)
			if oldValue == nil then return amount end
			Print(oldValue + amount)
			return oldValue + amount
		end)
	else
		Print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return
	end	
end

function lcm:GetCoins(key)
	if key == nil then return end
	local encryptedKey = checkForKey(key)
	if encryptedKey == nil then Print("[LuaCoin] It seems that the encryptedKey is nil.") return end
	
	Playerbase:UpdateAsync(key, function(oldValue)
		if oldValue == nil then
			local encrypt_code = ""..key.."_"..encrypt()
			encryptedKey = encrypt_code
			return encrypt_code
		end
		encryptedKey = ""..oldValue
	end)
	
	local succ = pcall(function()
		MasterBank:GetAsync(encryptedKey)
	end)

	if succ then
		return MasterBank:GetAsync(encryptedKey)
	else
		Print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return 0
	end	
end

function lcm:SetupBank(key)
	if key == nil then return end
	local encryptedKey
	local isNew = false
	
	Playerbase:UpdateAsync(key, function(oldValue)
		if oldValue == nil then
			local encrypt_code = ""..key.."_"..encrypt()
			encryptedKey = encrypt_code
			isNew = true
			return encrypt_code
		end
		encryptedKey = ""..oldValue
	end)
	
	if isNew == false then return end 
	
	local succ = pcall(function()
		MasterBank:GetAsync(encryptedKey)
	end)

	if succ then
		MasterBank:UpdateAsync(key, function(oldValue)
			Print("[LuaCoin]",encryptedKey,"has been added to the MasterBank and Playerbase.")
			return 0
		end)
	else
		Print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return
	end	
end

function lcm:GetInformation(key)
	if key == nil then return end
	local encryptedKey = checkForKey(key)
	if encryptedKey == nil then Print("[LuaCoin] It seems that the encryptedKey is nil.") return end
	
	local succ = pcall(function()
		MasterBank:GetAsync(encryptedKey)
	end)

	if succ then
		MasterBank:UpdateAsync(key, function(value)
			print("[LuaCoin]",key.."'s user information:")
			print("[LuaCoin] Encrypted Key:",encryptedKey)
			print("[LuaCoin] Bank Amount:",value)
		end)
	else
		Print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return
	end	
end

print("[Server] Shloid's LuaCoinManager v"..settings.version,"has loaded up successfully.")
print("[Server] Check out the Github repository for more detailed update logs:",settings.github_repository)
return lcm