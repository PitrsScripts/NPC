----------------------------------------
--------------ESX-EXTENDED--------------
----------------------------------------
ESX = exports["es_extended"]:getSharedObject()
--------------------------------------
----------------CONFIG----------------
--------------------------------------
Config = {}
local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
if configFile then
    local func, err = load(configFile)
    if func then
        func()
    else
       -- print("Error loading config.lua: " .. err)
    end
else
   -- print("config.lua file not found")
end
----------------------------------------
----------------DATABASE----------------
----------------------------------------
MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT * FROM npc_table', {}, function(npcs)
        for _, npc in ipairs(npcs) do
            local configNpc = nil
            for _, cfgNpc in ipairs(Config.Peds) do
                if cfgNpc.id == npc.id then
                    configNpc = cfgNpc
                    break
                end
            end

            if configNpc then
                configNpc.coords = {npc.x, npc.y, npc.z, npc.heading}
            end
        end
    end)
end)
RegisterNetEvent('npc:server:requestNPCs')
AddEventHandler('npc:server:requestNPCs', function()
    local src = source
    MySQL.Async.fetchAll('SELECT * FROM npc_table', {}, function(npcs)
        local npcData = {}
        for _, npc in ipairs(npcs) do
            local configNpc = nil
            for _, cfgNpc in ipairs(Config.Peds) do
                if cfgNpc.id == npc.id then
                    configNpc = cfgNpc
                    break
                end
            end

            if configNpc then
                table.insert(npcData, {
                    id = npc.id,
                    coords = {npc.x, npc.y, npc.z, npc.heading},
                    useModel = configNpc.useModel,
                    model = configNpc.model,
                    animationDict = configNpc.animationDict,
                    animationName = configNpc.animationName,
                    propModel = configNpc.propModel,     
                    propOffset = configNpc.propOffset,    
                    propRotation = configNpc.propRotation 
                })
            end
        end
        TriggerClientEvent('npc:client:loadNPCs', src, npcData)
    end)
end)
RegisterNetEvent('npc:server:updateNPC')
AddEventHandler('npc:server:updateNPC', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        if data.id then
            MySQL.Async.fetchAll('SELECT * FROM npc_table WHERE id = @id', {['@id'] = data.id}, function(result)
                if #result > 0 then
                    MySQL.Async.execute('UPDATE npc_table SET x = @x, y = @y, z = @z, heading = @heading WHERE id = @id', {
                        ['@x'] = data.x,
                        ['@y'] = data.y,
                        ['@z'] = data.z,
                        ['@heading'] = data.heading,
                        ['@id'] = data.id
                    })
                else
                    MySQL.Async.execute('INSERT INTO npc_table (id, x, y, z, heading) VALUES (@id, @x, @y, @z, @heading)', {
                        ['@id'] = data.id,
                        ['@x'] = data.x,
                        ['@y'] = data.y,
                        ['@z'] = data.z,
                        ['@heading'] = data.heading
                    })
                end
            end)
        end
    end
end)

ESX.RegisterServerCallback('npc:server:checkGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        for _, group in ipairs(Config.AllowedGroups) do
            if playerGroup == group then
                cb(true)
                return
            end
        end
        cb(false)
    else
        cb(false)
    end
end)