local QBCore = exports['qb-core']:GetCoreObject()

local started = false

CreateThread(function()
    RequestModel(`a_m_m_soucent_03`)
    while not HasModelLoaded(`a_m_m_soucent_03`) do
        Wait(1)
    end

    gokart = CreatePed(2, `a_m_m_soucent_03`, Config.StartPedLoc.x, Config.StartPedLoc.y, Config.StartPedLoc.z-1, Config.StartPedLoc.w, false, false)
    SetPedFleeAttributes(gokart, 0, 0)
    SetPedDiesWhenInjured(gokart, false)
    TaskStartScenarioInPlace(gokart, Config.StartPedAnimation, 0, true)
    SetPedKeepTask(gokart, true)
    SetBlockingOfNonTemporaryEvents(gokart, true)
    SetEntityInvincible(gokart, true)
    FreezeEntityPosition(gokart, true)

    Wait(100)

    exports.ox_target:addLocalEntity(gokart, {
        {
            name = 'gokartped',
            event = 'mad-gokarting:client:attemptbuy',
            icon = 'fas fa-car',
            label = 'Rent Kart',
            distance = 2.0,
            canInteract = function(entity, distance, data)
                return not started
            end
        }
    })
end)

RegisterNetEvent('mad-gokarting:client:attemptbuy')
AddEventHandler('mad-gokarting:client:attemptbuy', function()
    TriggerServerEvent("mad-gokarting:server:attemptbuy")
end)

RegisterNetEvent("mad-gokarting:client:spawnkart")
AddEventHandler("mad-gokarting:client:spawnkart", function()
    local SpawnPoint = getVehicleSpawnPoint()
    local spawns = Config.locations

    if SpawnPoint then
        local coords = vector3(spawns[SpawnPoint].x, spawns[SpawnPoint].y, spawns[SpawnPoint].z)
        local CanSpawn = IsSpawnPointClear(coords, 2.0)
        if CanSpawn then
            local ModelHash = `veto2`
            if not IsModelInCdimage(ModelHash) then return end
            RequestModel(ModelHash)
            while not HasModelLoaded(ModelHash) do
                Wait(0)
            end
            Vehicle = CreateVehicle(ModelHash, coords, spawns[SpawnPoint].w, true, true)
            SetModelAsNoLongerNeeded(ModelHash)
            exports[Config.Fuel]:SetFuel(Vehicle, 100.0)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(Vehicle))
            TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)
            SetVehicleEngineOn(Vehicle, true, true)
            TriggerServerEvent("mad-gokarting:server:purchase")
            started = true
            timer = Config.Timer * 60 * 1000

            timerFdd()
        else
            QBCore.Functions.Notify("All spots are occupied", "error")
        end
    else
        QBCore.Functions.Notify("All spots are occupied", 'error')
        return
    end
end)

function timerFdd()
    while started do
        if timer <= 0 then
            started = false
            DoScreenFadeOut(1000)
            Wait(250)
            SetEntityCoords(PlayerPedId(), Config.ReturnPos.x, Config.ReturnPos.y, Config.ReturnPos.z)
            DeleteEntity(Vehicle)
            Wait(250)
            DoScreenFadeIn(1500)
            return
        end
        exports['qb-core']:DrawText("Time left: " .. tonumber(string.format("%.2f", (timer / 1000) / 60)), 'left')
        Wait(3000)
        exports['qb-core']:HideText()
        Wait(15000)
        timer = timer - 18000
    end
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end
    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))
        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end
    return nearbyEntities
end

function GetVehiclesInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetGamePool('CVehicle'), false, coords, maxDistance)
end

function IsSpawnPointClear(coords, maxDistance)
    return #GetVehiclesInArea(coords, maxDistance) == 0
end

function getVehicleSpawnPoint()
    local spawns = Config.locations

    local near = nil
    local distance = 10000
    for k, v in pairs(spawns) do
        if IsSpawnPointClear(vector3(v.x, v.y, v.z), 2.5) then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local cur_distance = #(pos - vector3(v.x, v.y, v.z))
            if cur_distance < distance then
                distance = cur_distance
                near = k
            end
        end
    end

    return near
end
