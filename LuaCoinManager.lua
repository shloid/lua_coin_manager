------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lua Coin Module [v0.2a]
-- Created by shloid (da man!!!)
------------------------------------------------------------------------------------------------------------------------------------------------------

-- DataStores
local DataStore = game:GetService("DataStoreService")
local BankDatabase = DataStore:GetDataStore("LuaCoin_Bankbase")
local MasterBank = DataStore:GetDataStore("LuaCoin_MasterBank")
local Playerbase  = DataStore:GetDataStore("LuaCoin_Playerbase")

-- Settings & Module's Return Value
local lcm = {}
local banks = {}
local settings = {
	debug = true;
	version = "0.2a",
	prefix = "LuaCoin",
	encrypted = true, -- it does nothing yet. so coming soon
	encrypt_length = 16,
	github_repository = "https://github.com/shloid/lua_coin_manager",
	type_prefixes = {
		Add = "Add",
		Subtract = "Subtract",
		Multiply = "Multiply",
		Divide = "Divide", -- or hwndu for short ;)
	}
}

banks.MasterBank = {
	Name = "LuaCoin_Master";
	Database = MasterBank;
}

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Local Functions / Methods
------------------------------------------------------------------------------------------------------------------------------------------------------

local function Print(str)
	if settings.debug == true then 
		return print(str) 
	end
end

local function findBank(bank)
	local dbName = settings.prefix.."_"..bank
	for i = 1, #banks do
		if banks[i].BankName == dbName then
			return banks[i].Database
		end
	end
	return nil
end

local function encrypt()
	local var, letterTable, numberTable = "",{"a","B","c","D","e","F","g","H","i","J","k","L","m","N","o","P","q","R","s","T","u","V","w","X","y","Z","#","$","%","@"},{"0","1","2","3","4","5","6","7","8","9"}
	for i = 1, settings.encrypt_length do
		if math.random(1,2) == 1 then
			local letter = letterTable[math.random(1,#letterTable)]
			var = var..letter			
		else
			local letter = numberTable[math.random(1,#numberTable)]
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

function lcm:LuaCoinManager(amount,type,key,bank)
	if amount == nil or type == nil or key == nil or bank == nil then return end
	local encryptedKey = checkForKey(key)
	local theBank = findBank(bank)
	if encryptedKey == nil or theBank == nil then Print("[LuaCoin] It seems that the encryptedKey or theBank is nil.") return end
	
	local succ = pcall(function()
		theBank:GetAsync(encryptedKey)
	end)
	
	if succ then
		if type == settings.type_prefixes.Add then
			theBank:UpdateAsync(encryptedKey,function(oldValue)
				if oldValue == nil then return amount end
				Print(oldValue + amount)
				return oldValue + amount
			end)
		elseif type == settings.type_prefixes.Subtract  then
			theBank:UpdateAsync(encryptedKey,function(oldValue)
				if oldValue == nil then return end
				Print(oldValue - amount)
				return oldValue - amount
			end)
		elseif type == settings.type_prefixes.Multiply then
			theBank:UpdateAsync(encryptedKey,function(oldValue)
				if oldValue == nil then return end
				Print(oldValue * amount)
				return oldValue * amount
			end)
		elseif type == settings.type_prefixes.Divide then
			theBank:UpdateAsync(encryptedKey,function(oldValue)
				if oldValue == nil then return end
				Print(oldValue / amount)
				return oldValue / amount
			end)
		else
			print("[LuaCoin] error: Type is invalid. Returning...")
			return
		end
	else
		print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return
	end	
end

function lcm:TransferData(amount,key1,key2,bank)
	if amount == nil or key1 == nil or key2 == nil or bank == nil then return end
	local encryptedKey1 = checkForKey(key1)
	local encryptedKey2 = checkForKey(key2)
	local theBank = findBank(bank)
	if encryptedKey1 == nil or encryptedKey2 == nil or theBank == nil then Print("[LuaCoin] It seems that the encryptedKey or theBank is nil.") return end
	
	local isEKey2Nil = false
	local succ = pcall(function()
		theBank:GetAsync(encryptedKey1)
		theBank:GetAsync(encryptedKey2)
	end)
	
	if succ then
		theBank:UpdateAsync(encryptedKey1,function(oldValue)
			if oldValue == nil then isEKey2Nil = true return end
			Print(oldValue - amount)
			return oldValue - amount
		end)
		
		if isEKey2Nil == true then return end
		
		theBank:UpdateAsync(encryptedKey2,function(oldValue)
			if oldValue == nil then return amount end
			Print(oldValue + amount)
			return oldValue + amount
		end)
	end
end

function lcm:GenerateNewBank(bank)
	if bank == nil and findBank(bank) ~= nil then return end
	local dbName = settings.prefix.."_"..bank
	local newDatabase = DataStore:GetDataStore(dbName)
	local bankTable = {
		Name = dbName,
		Database = newDatabase
	}
	table.insert(banks,bankTable)
	
	local succ = pcall(function()
		BankDatabase:GetAsync(dbName)
	end)
	
	if succ then
		Print("[LuaCoin] New Bank has been created!")
		BankDatabase:SetAsync(dbName,function(v)
			v = banks
		end)
	end
end

function lcm:GetCoins(bank,key)
	if key == nil or bank == nil then return end
	local encryptedKey = checkForKey(key)
	local theBank = findBank(bank)
	if encryptedKey == nil or theBank == nil then Print("[LuaCoin] It seems that the encryptedKey or theBank is nil.") return end
	
	local succ = pcall(function()
		theBank:GetAsync(encryptedKey)
	end)

	if succ then
		return theBank:GetAsync(encryptedKey)
	else
		Print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return "null"
	end	
end

function lcm:SetupBank(bank,key)
	if key == nil or bank == nil then return end
	local encryptedKey = checkForKey(key)
	local theBank = findBank(bank)
	if encryptedKey == nil or theBank == nil then Print("[LuaCoin] It seems that the encryptedKey or theBank is nil.") return end
	
	local succ = pcall(function()
		theBank:GetAsync(encryptedKey)
	end)

	if succ then
		theBank:UpdateAsync(encryptedKey,function(v)
			if v == nil then return 0 end
		end)
	else
		Print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return "null"
	end	
end

function lcm:SetupPlayer(key)
	if key == nil then return end
	local encryptedKey
	local isNew = false
	local succ = pcall(function()
		Playerbase:UpdateAsync(key, function(oldValue)
			if oldValue == nil then
				local encrypt_code = key.."_"..encrypt()
				encryptedKey = encrypt_code
				isNew = true
				return encrypt_code
			end
			encryptedKey = oldValue
		end)
	end)
	
	if isNew == false then return end 

	if succ then
		Print("[LuaCoin]",encryptedKey,"has been added to the MasterBank and Playerbase.")
	else
		Print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return
	end	
end

function lcm:GetInformation(bank,key)
	if key == nil or bank == nil then return end
	local encryptedKey = checkForKey(key)
	local theBank = findBank(bank)
	if encryptedKey == nil or theBank == nil then Print("[LuaCoin] It seems that the encryptedKey or theBank is nil.") return end
	
	local succ = pcall(function()
		theBank:GetAsync(encryptedKey)
	end)

	if succ then
		theBank:UpdateAsync(key, function(value)
			print("[LuaCoin]",key.."'s user information:")
			print("[LuaCoin] Encrypted Key:",encryptedKey)
			print("[LuaCoin]",bank,"Amount:",value)
		end)
	else
		Print("[LuaCoin] error: MasterBank cannot find the correct key.")
		return
	end	
end

print("[Server] Shloid's LuaCoinManager v"..settings.version,"has loaded up successfully.")
print("[Server] Check out the Github repository for more info!",settings.github_repository)
return lcm