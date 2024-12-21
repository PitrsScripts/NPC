-----------------------------------------------
----------------ESX-EXTENDED---------------------
-----------------------------------------------
ESX = exports["es_extended"]:getSharedObject()
-----------------------------------------------
----------------LOAD NPC SCRIPT----------------
-----------------------------------------------
function loadNPCs()
    TriggerServerEvent('npc:server:requestNPCs')
end
RegisterNetEvent('npc:client:loadNPCs')
AddEventHandler('npc:client:loadNPCs', function(npcs)
    for _, v in pairs(npcs) do
        local x, y, z, heading = table.unpack(v.coords)
        print("Loading NPC with prop:", v.propModel) 
        local ped = addNPC(x, y, z, heading, v.useModel, v.model, v.animationDict, v.animationName, v.propModel, v.propOffset, v.propRotation)
        if v.id then
            setupTarget(ped, v)
        end
    end
end)

CreateThread(function()
    while ESX == nil do
        Wait(100)
    end
    loadNPCs() 
end)
-----------------------------------------
----------------ANIMATION----------------
-----------------------------------------
function addNPC(x, y, z, heading, useModel, model, animationDict, animationName, propModel, propOffset, propRotation)
    if useModel then
        model = GetHashKey(model)
    end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(15)
    end
    --print("Model loaded:", model)

    local ped = CreatePed(4, model, x, y, z - 1, heading, false, true)
    SetEntityHeading(ped, heading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
   -- print("NPC created:", ped)

    if animationDict and animationDict ~= "" and animationName and animationName ~= "" then
        RequestAnimDict(animationDict)
        while not HasAnimDictLoaded(animationDict) do
            Wait(15)
        end
        if HasAnimDictLoaded(animationDict) then
            local flags = 1
            TaskPlayAnim(ped, animationDict, animationName, 8.0, -8.0, -1, flags, 0, false, false, false)
            --print("Playing animation:", animationDict, animationName)
        else
           -- print("Animation dictionary not loaded:", animationDict)
        end
    else
        --print("Animation parameters are not valid:", animationDict, animationName)
    end
    if propModel and propModel ~= "" then
        print("Prop parameters are valid:", propModel, propOffset, propRotation)
        propModel = GetHashKey(propModel)
        RequestModel(propModel)
        while not HasModelLoaded(propModel) do
            Wait(15)
        end
        if HasModelLoaded(propModel) then
            local prop = CreateObject(propModel, x, y, z, true, true, true)
            if prop then
                local boneIndex = 57005 
                AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, boneIndex), propOffset.x, propOffset.y, propOffset.z, propRotation.x, propRotation.y, propRotation.z, false, false, false, true, 2, true)
               -- print("Prop attached:", propModel, "to ped:", ped)
            else
               -- print("Failed to create prop:", propModel)
            end
        else
           -- print("Prop model not loaded:", propModel)
        end
    else
       -- print("Prop parameters are not valid:", propModel)
    end

    return ped
end
-------------------------------------
------------OX TARGET----------------
-------------------------------------
function setupTarget(ped, pedData)
    ESX.TriggerServerCallback('npc:server:checkGroup', function(isAllowed)
        if isAllowed then
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'movePed',
                    label = 'Move Ped',
                    icon = 'fas fa-arrows-alt',
                    onSelect = function()
                        movePed(ped, pedData)
                    end
                }
            })
        end
    end)
end
--------------------------------------------
----------------OBJECT GIZMO----------------
--------------------------------------------
function movePed(ped, pedData)
    FreezeEntityPosition(ped, false)
    local data = exports.object_gizmo:useGizmo(ped)

    if data then
        local coords = data.position
        local rotation = data.rotation
        local heading = GetEntityHeading(ped)

        if pedData.id then
            TriggerServerEvent('npc:server:updateNPC', {
                id = pedData.id,
                x = coords.x,
                y = coords.y,
                z = coords.z,
                heading = heading
            })
        end
    end
    FreezeEntityPosition(ped, true)
end