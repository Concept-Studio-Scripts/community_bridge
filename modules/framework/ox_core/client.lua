---@diagnostic disable: duplicate-set-field
if GetResourceState('ox_core') ~= 'started' then return end

Framework = Framework or {}

local Ox = require '@ox_core.lib.init'
LocalPlayer.state.isLoggedIn = true

local function getPlayerObject()
    return Ox.GetPlayer(cache.playerId)
end

local function buildGroupData(player)
    local groups = player.getGroups() or {}
    local allGroups = Ox.GetGroups() or {}

    local primaryJobName = 'unemployed'
    local primaryJobGrade = 0

    for groupName, grade in pairs(groups) do
        primaryJobName = groupName
        primaryJobGrade = grade
        break
    end

    local groupDef = allGroups[primaryJobName]

    return {
        name = primaryJobName,
        label = groupDef and groupDef.label or primaryJobName,
        grade = {
            name = tostring(primaryJobGrade),
            level = primaryJobGrade,
        },
        isboss = false,
        onduty = player.get('onDuty') or player.get('onduty') or false,
    }
end

---@description Returns the raw OxPlayer object. Internal use, avoid outside of bridge.
---@return table
Framework.GetPlayerObject = function()
    return getPlayerObject()
end

---@description This will get the name of the framework being used (if a supported framework).
---@return string
Framework.GetFrameworkName = function()
    print("This is deprecated, please use Framework.GetResourceName() instead.")
    return Framework.GetResourceName()
end

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'ox_core'
end

---@description This will return true if the player is loaded, false otherwise.
---This could be useful in scripts that rely on player loaded events and offer a debug mode to hit this function.
---@return boolean
Framework.GetIsPlayerLoaded = function()
    return LocalPlayer.state.isLoggedIn or false
end

---@description This will return a table of the player data, this will be in the framework format.
---This is mainly for internal bridge use and should be avoided.
---@return table
Framework.GetPlayerData = function()
    local player = getPlayerObject()
    return player
end

---@description This will return a table of all the jobs in the framework.
---@return table
Framework.GetFrameworkJobs = function()
    return Ox.groups()
end

---@description This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    return Framework.GetPlayerData().get('dateOfBirth')
end

---@description This will return the players metadata for the specified metadata key.
---@param metadata table | string
---@return table | string | number | boolean
Framework.GetPlayerMetaData = function(metadata)
    return Framework.GetPlayerData().get(metadata)
end

---@description This will get the hunger of a player
---@return number
Framework.GetHunger = function()
    local hunger = Framework.GetPlayerMetaData('hunger') or 0
    return math.floor((hunger) + 0.5) or 0
end

---@description This will get the thirst of a player
---@return number
Framework.GetThirst = function()
    local thirst = Framework.GetPlayerMetaData('thirst') or 0
    return math.floor((thirst) + 0.5) or 0
end

---@description This will get the players identifier (citizenid) etc.
---@return string
Framework.GetPlayerIdentifier = function()
    return tostring(Framework.GetPlayerData().userId)
end

---@description This will get the players name (first and last).
---@return string
---@return string
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    return playerData.get('firstName'), player.get('lastName')
end

---@deprecated Deprecated: This will return the players job name, job label, job grade label and job grade level
---@return string
---@return string
---@return string
---@return string
Framework.GetPlayerJob = function()
    local jobData = Framework.GetPlayerJobData()
    return jobData.jobName, jobData.jobLabel, jobData.gradeName, jobData.gradeRank
end

---@description This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
---@return table
Framework.GetPlayerJobData = function()
    local playerData = Framework.GetPlayerData()
    local jobData = buildGroupData(playerData)
    return {
        jobName = jobData.name,
        jobLabel = jobData.label,
        gradeName = jobData.grade.name,
        gradeLabel = jobData.grade.name,
        gradeRank = jobData.grade.level,
        boss = jobData.isboss,
        onDuty = jobData.onduty,
    }
end

---@description This will get a players dead status
---@return boolean
Framework.GetIsPlayerDead = function()
    local playerData = Framework.GetPlayerData()
    return playerData.get('isDead')
end

---@description Event handler for when player is loaded in ox_core framework
AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    Wait(1500)
    TriggerEvent('community_bridge:Client:OnPlayerLoaded')
end)

---@description Event handler for when player group is updated in ox_core framework
RegisterNetEvent('ox:setGroup', function(groupName, grade)
    local playerData = Framework.GetPlayerData()
    local jobData = buildGroupData(playerData)
    TriggerEvent('community_bridge:Client:OnPlayerJobUpdate', jobData.name, jobData.label, jobData.grade.name,
        jobData.grade.level)
end)

return Framework
