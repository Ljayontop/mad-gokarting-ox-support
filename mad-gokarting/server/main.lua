local QBCore = exports['qb-core']:GetCoreObject()

-- Event to handle the attempt to buy a kart
RegisterServerEvent('mad-gokarting:server:attemptbuy')
AddEventHandler('mad-gokarting:server:attemptbuy', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local cash = Player.PlayerData.money.cash

    if cash >= Config.price then
        TriggerClientEvent('mad-gokarting:client:spawnkart', source)
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough money", "error")
    end
end)

-- Event to handle the purchase of the kart
RegisterServerEvent('mad-gokarting:server:purchase')
AddEventHandler('mad-gokarting:server:purchase', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney("cash", Config.price)
end)







