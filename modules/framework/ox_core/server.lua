---@diagnostic disable: duplicate-set-field
if GetResourceState('ox_core') ~= 'started' then return end

Framework = Framework or {}

local Ox = require '@ox_core.lib.init'

local function buildPlayerData(player)
    local groups = player.getGroups() or {}
    local allGroups = {}

    local primaryJobName = 'unemployed'
    local primaryJobGrade = 0

    for groupName, grade in pairs(groups) do
        primaryJobName = groupName
        primaryJobGrade = grade
        break
    end

    local groupDef = allGroups[primaryJobName]

    return {
        source = player.source,
        citizenid = tostring(player.userId),
        charinfo = {
            firstname = player.get('firstName') or '',
            lastname = player.get('lastName') or '',
            birthdate = player.get('dateOfBirth') or '',
            phone = player.get('phoneNumber') or '',
        },
        job = {
            name = primaryJobName,
            label = groupDef and groupDef.label or primaryJobName,
            grade = {
                name = tostring(primaryJobGrade),
                level = primaryJobGrade,
            },
            isboss = false,
            onduty = player.get('onDuty') or player.get('onduty') or false,
            type = groupDef and groupDef.type or 'job',
        },
        gang = {
            name = 'none',
            label = 'None',
            grade = {
                name = '0',
                level = 0,
            },
        },
        money = {
            cash = player.getAccount('money') or 0,
            bank = player.getAccount('bank') or 0,
            black_money = player.getAccount('black_money') or 0,
        },
        metadata = player.get('metadata') or {},
    }
end

Framework.oxGetRawPlayer = function(src)
    return Ox.GetPlayer(src)
end

---@description Returns the name of the framework being used (if a supported framework).
---@return string
Framework.GetFrameworkName = function()
    return 'ox_core'
end

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'ox_core'
end

---@description This will return if the player is an admin in the framework.
---@param src number
---@return boolean
Framework.GetIsFrameworkAdmin = function(src)
    if not src then return false end
    return IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'group.admin')
end

---@description Returns the player date of birth.
---@param src number
---@return string|nil
Framework.GetPlayerDob = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    return player.PlayerData.charinfo.birthdate
end

---@description Returns the player data of the specified source.
---@param src number
---@return table | nil
Framework.GetPlayer = function(src)
    local player = Ox.GetPlayer(src)
    if not player then return end

    local playerData = buildPlayerData(player)

    player.PlayerData = playerData
    player.Functions = {
        AddMoney = function(_type, amount)
            if _type == 'cash' then _type = 'money' end
            return player.addAccount(_type, amount)
        end,
        RemoveMoney = function(_type, amount)
            if _type == 'cash' then _type = 'money' end
            return player.removeAccount(_type, amount)
        end,
        SetMetaData = function(key, value)
            player.set(key, value)
            playerData.metadata[key] = value
            return true
        end,
        SetJob = function(name, grade)
            return player.setGroup(name, grade)
        end,
        SetJobDuty = function(status)
            return player.set('onDuty', status)
        end,
    }

    return player
end

---@description Returns the player data of the specified identifier in the framework default format.
---@param citizenid string
---@return table | nil
Framework.GetPlayerByIdentifier = function(citizenid)
    local player = Ox.GetPlayerByUserId(tonumber(citizenid))
    if not player then return end
    return Framework.GetPlayer(player.source)
end

---@description This will return the player source of the specified citizen ID.
---@param citizenid string
---@return number | nil
Framework.GetPlayerSource = function(citizenid)
    local player = Ox.GetPlayerByUserId(tonumber(citizenid))
    if not player then return end
    return player.source
end

---@description Returns a table of the jobs in the framework.
---@return table
Framework.GetFrameworkJobs = function()
    return {}
end

---@description Returns the citizen ID of the player.
---@param src number
---@return string | nil
Framework.GetPlayerIdentifier = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    return player.PlayerData.citizenid
end

---@description This will return a table of all logged in players
---@return table
Framework.GetPlayers = function()
    return Ox.GetPlayers()
end

---@description Returns the first and last name of the player.
---@param src number
---@return string | nil
---@return string | nil
Framework.GetPlayerName = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

---@description Adds the specified metadata key and value to the player's data.
---@param src number
---@param metadata string
---@param value any
---@return boolean | nil
Framework.SetPlayerMetadata = function(src, metadata, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    return player.Functions.SetMetaData(metadata, value)
end

---@description Gets the specified metadata key to the player's data.
---@param src number
---@param metadata string
---@return any | nil
Framework.GetPlayerMetadata = function(src, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return end
    return player.get(metadata) or false
end

---@description Adds the specified value to the player's stress level and updates the client HUD.
---@param src number
---@param value number
---@return number | nil
Framework.AddStress = function(src, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local currentStress = player.get('stress') or 0
    local newStress = Math.Clamp(currentStress + value, 0, 100)
    player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newStress
end

---@description Removes the specified value from the player's stress level and updates the client HUD.
---@param src number
---@param value number
---@return number | nil
Framework.RemoveStress = function(src, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local currentStress = player.get('stress') or 0
    local newStress = Math.Clamp(currentStress - value, 0, 100)
    player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newStress
end

---@description Adds the specified value from the player's hunger level.
---@param src number
---@param value number
---@return number | nil
Framework.AddHunger = function(src, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local currentHunger = player.get('hunger') or 0
    local newHunger = Math.Clamp(currentHunger + value, 0, 100)
    player.Functions.SetMetaData('hunger', newHunger)
    return newHunger
end

---@description Adds the specified value from the player's thirst level.
---@param src number
---@param value number
---@return number | nil
Framework.AddThirst = function(src, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local currentThirst = player.get('thirst') or 0
    local newThirst = Math.Clamp(currentThirst + value, 0, 100)
    player.Functions.SetMetaData('thirst', newThirst)
    return newThirst
end

---@description This will return the players hunger level.
---@param src number
---@return number | nil
Framework.GetHunger = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return 0 end
    return math.floor((player.get('hunger') or 0) + 0.5) or 0
end

---@description This will return a boolean if the player is dead or in last stand.
---@param src number
---@return boolean|nil
Framework.GetIsPlayerDead = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    return player.getStatus('dead') or player.get('dead') or false
end

---@description This will revive a player, if the player is dead or in last stand.
---@param src number
---@return boolean
Framework.RevivePlayer = function(src)
    src = tonumber(src)
    if not src then return false end
    local player = Framework.GetPlayer(src)
    if player then
        player.setStatus('dead', false)
        player.set('dead', false)
    end
    TriggerClientEvent('hospital:client:Revive', src)
    return true
end

---@description This will return the players thirst level.
---@param src number
---@return number| nil
Framework.GetThirst = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return 0 end
    return math.floor((player.get('thirst') or 0) + 0.5) or 0
end

---@description Returns the phone number of the player.
---@param src number
---@return string | nil
Framework.GetPlayerPhone = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    return player.PlayerData.charinfo.phone
end

---@description Returns the gang name of the player.
---@param src number
---@return string | nil
Framework.GetPlayerGang = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.gang.name
end

---@description This will get a table of player sources that have the specified job name.
---@param job string
---@return table
Framework.GetPlayersByJob = function(job)
    return Framework.GetPlayerSourcesByJob(job) or {}
end

---@description Deprecated: Returns the job name, label, grade name, and grade level of the player.
---Please use GetPlayerJobData instead.
---@param src number
---@return string | string | string | number | nil
---@return string | string | string | number | nil
---@return string | string | string | number | nil
---@return string | string | string | number | nil
Framework.GetPlayerJob = function(src)
    local jobData = Framework.GetPlayerJobData(src)
    if not jobData then return end
    return jobData.name, jobData.label, jobData.gradeLabel, jobData.grade
end

---@description This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
---@param src number
---@return table | nil
Framework.GetPlayerJobData = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local jobData = playerData.job
    return {
        name = jobData.name,
        label = jobData.label,
        grade = jobData.grade.level,
        gradeLabel = jobData.grade.name,
        isBoss = jobData.isboss,
        duty = jobData.onduty,
        type = jobData.type or 'job',
    }
end

---@description Sets the player's job to the specified name and grade.
---@param src number
---@param name string
---@param grade string|number
---@return boolean | nil
Framework.SetPlayerJob = function(src, name, grade)
    local player = Framework.GetPlayer(src)
    if not player then return end
    grade = tonumber(grade) or 0
    return player.Functions.SetJob(name, grade)
end

---@description This will toggle the duty status of the player.
---@param src number
---@param status boolean
Framework.SetPlayerDuty = function(src, status)
    local player = Framework.GetPlayer(src)
    if not player then return end
    return player.Functions.SetJobDuty(status)
end

---@description Returns the players duty status.
---@param src number
---@return boolean | nil
Framework.GetPlayerDuty = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    if not player.PlayerData.job.onduty then return false end
    return true
end

---@description Adds the specified amount to the player's account balance of the specified type.
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.AddAccountBalance = function(src, _type, amount)
    local player = Framework.GetPlayer(src)
    if not player then return end
    if _type == 'money' then _type = 'cash' end
    if amount <= 0 then return false end
    return player.Functions.AddMoney(_type, amount)
end

---@description Removes the specified amount from the player's account balance of the specified type.
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.RemoveAccountBalance = function(src, _type, amount)
    local player = Framework.GetPlayer(src)
    if not player then return end
    if _type == 'money' then _type = 'cash' end
    if amount <= 0 then return false end
    return player.Functions.RemoveMoney(_type, amount)
end

---@description Returns the player's account balance of the specified type.
---@param src number
---@param _type string
---@return number | nil
Framework.GetAccountBalance = function(src, _type)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    if _type == 'money' then _type = 'cash' end
    local balance = playerData.money[_type] or 0
    if balance <= 0 then return 0 end
    return balance
end

---@description Returns a table of owned vehicles for the player. format is {vehicle = vehicle, plate = plate}
---@param src number
---@return table
Framework.GetOwnedVehicles = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return {} end
    local charId = player.charId
    local result = MySQL.Sync.fetchAll("SELECT plate, model FROM vehicles WHERE owner = '" .. charId .. "'")
    local vehicles = {}
    for i = 1, #result do
        local vehicle = result[i].model
        local plate = result[i].plate
        table.insert(vehicles, { vehicle = vehicle, plate = plate })
    end
    return vehicles
end

---@description Returns a table of owned vehicles for the player. format is {id = id, vehicle = model, plate = plate}
---@param src number
---@param plate string
---@return table|false
Framework.IsVehicleOwnedByPlayer = function(src, plate)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    local charId = player.charId
    local result = MySQL.Sync.fetchAll("SELECT id, model, plate FROM vehicles WHERE owner = '" ..
        charId .. "' AND plate = '" .. plate .. "'")
    if not result[1] then return false end

    local id = result[1].id
    local vehicle = result[1].model
    return { id = id, vehicle = vehicle, plate = plate }
end

---@description Registers a usable item with a callback function.
---@param itemName string
---@param cb function
---@return function
Framework.RegisterUsableItem = function(itemName, cb)
    local func = function(src, item, itemData)
        itemData = itemData or item
        itemData.metadata = itemData.metadata or itemData.info or {}
        itemData.slot = itemData.id or itemData.slot
        cb(src, itemData)
    end

    local serverInventory = GetResourceState('ox_inventory') == 'started'
    if serverInventory then
        exports.ox_inventory:registerUsableItem(itemName, func)
    else
        RegisterNetEvent('ox_core:useItem:' .. itemName, func)
        AddEventHandler('ox_core:useItem:' .. itemName, function(...)
            func(source, ...)
        end)
    end
end

---@description Event handler for when a player is loaded in ox_core framework
RegisterNetEvent("ox:playerLoaded", function(playerId, userId, charId)
    playerId = playerId or source
    TriggerEvent("community_bridge:Server:OnPlayerLoaded", playerId)
    local jobData = Framework.GetPlayerJobData(playerId)
    if not jobData then return end
    Framework.AddJobCount(playerId, jobData.name)
end)

---@description Event handler for when a player logs out in ox_core framework
RegisterNetEvent("ox:playerLogout", function(playerId, userId, charId)
    playerId = playerId or source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", playerId)
end)

---@description Event handler for when a player's group is updated in ox_core framework
RegisterNetEvent("ox:setGroup", function(playerId, groupName, grade)
    playerId = playerId or source
    if not groupName then return end
    TriggerEvent("community_bridge:Server:OnPlayerJobChange", playerId, groupName)
end)

---@description Event handler for when a player disconnects from the server
AddEventHandler("playerDropped", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

Framework.Commands = {}
---@description Adds a command to the ox_core framework
---@param name string
---@param help string
---@param arguments table
---@param argsrequired boolean
---@param callback function
---@param permission string
---@param ... any
Framework.Commands.Add = function(name, help, arguments, argsrequired, callback, permission, ...)
    RegisterCommand(name, function(src, args, raw)
        if permission and permission ~= '' then
            if not IsPlayerAceAllowed(src, permission) then return end
        end
        callback(src, args, raw)
    end, false)
end

return Framework
