local isInDimension = nil
local PlayerLoadout = {}
local ActiveClientGame = {}
local ActiveMapInfo = {
    ActiveMapCenter = nil,
    ActiveMapRadius = nil
}
local PlayerStats = {
    kills = 0,
    deaths = 0
}

-- Test Befehl: create Arena1 23 3 0 2 SG
RegisterCommand('Create', function(source, args) -- Arg: Name, passwort, Max, Privat, Modus, Map
    if not isInDimension then
        Config.SendNotifyClient("Raum wird erstellt bitte warte...")
        TriggerServerEvent('sa_ffa:CreateGame', args)
    end
end)

RegisterCommand('Join', function(source, args) -- Arg: Name, Passwort
    if not isInDimension then
        TriggerServerEvent("sa_ffa:JoinGame", args)
        Config.SendNotifyClient("Raum wird betreten...")
    else
        Config.SendNotifyClient("Du bist bereits in einem Raum!")
    end
end)

-- Test Befehl: search SG 3
RegisterCommand('Search', function(source, args) -- Arg: Map, Modus (Die braucht man nicht umbedingt)
    TriggerServerEvent("sa_ffa:SearchRandomGame", args)
    Config.SendNotifyClient("Spielsuche gestartet!")
end)

RegisterCommand('game', function(source, args)
    print(ESX.DumpTable(ActiveClientGame))
end)

RegisterCommand('Leave', function(source, args)
    if isInDimension or Config.Debug then
        Loadout('Leave', nil)
        TriggerServerEvent('sa_ffa:LeaveGame', PlayerLoadout, ActiveClientGame.Name)
        ActiveClientGame = {}
        TriggerServerEvent('sa_ffa:SaveStats', PlayerStats)
    else
        Config.SendNotifyClient("Du bist in keiner sa_ffa Lobby!")
    end
end)

RegisterNetEvent("sa_ffa:JoinGameClient")
AddEventHandler("sa_ffa:JoinGameClient", function(ActiveGame, PlayerWeapons)
    PlayerLoadout = PlayerWeapons
    ActiveClientGame = ActiveGame
    Loadout('Join', ActiveGame.Modus)
    Teleport()
    isInDimension = true
end)

RegisterNetEvent("sa_ffa:LeaveGameClient")
AddEventHandler("sa_ffa:LeaveGameClient", function(Modus)
    Loadout('Leave', Modus)
    isInDimension = false
end)

RegisterNetEvent("sa_ffa:UpdatePlayerStats")
AddEventHandler("sa_ffa:UpdatePlayerStats", function(Type)

    if Type == 'killed' then
        PlayerStats.deaths = PlayerStats.deaths + 1
    elseif Type == 'killer' then
        PlayerStats.kills = PlayerStats.kills + 1 
    end

end)

AddEventHandler('esx:onPlayerDeath', function(data)

    if isInDimension then
    Citizen.Wait(1000)
    TriggerServerEvent('sa_ffa:PlayerKilled', data)
    TriggerEvent('esx_ambulancejob:revive')
    Wait(1000)
    Loadout('Join', ActiveClientGame.Modus)
    Teleport()
    NetworkSetFriendlyFireOption(false)
    SetCanAttackFriendly(GetPlayerPed(-1), false, false)
    if Config.Invincible then
        SetEntityInvincible(GetPlayerPed(-1), true)
    end
    Citizen.Wait(3000)
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(GetPlayerPed(-1), true, true)
    if Config.Invincible then
        SetEntityInvincible(GetPlayerPed(-1), false)
    end
    end
end)

function Teleport()
    for i,v in ipairs(Config.Maps) do
        if tonumber(v.Map) == tonumber(ActiveClientGame.Map) then
            DoScreenFadeOut(100)
            ESX.Game.Teleport(PlayerPedId(), v.Teleports[math.random(1, #v.Teleports)], function()end)
            DoScreenFadeIn(100)
            ActiveMapInfo.ActiveMapCenter = v.MapCenter
            ActiveMapInfo.ActiveMapRadius = v.MaxRadius
        end
    end
end

Citizen.CreateThread(function()

    while true do
        if isInDimension then
            local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), ActiveMapInfo.ActiveMapCenter)

            if dist >= ActiveMapInfo.ActiveMapRadius then
                Teleport()
                Config.SendNotifyClient("Du warst außerhalb der Zone und wurdest wieder zurück telepotier")
            end
            Wait(1000)
        else 
            Wait(5000)
        end

        Wait(1)
    end
end)

function Loadout(Type, Modus)
    
    if Type == 'Join' then
        local ped = PlayerPedId(-1)

        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 200)
        for i,v in ipairs(Config.Modus) do
            if tonumber(v.Modus) == tonumber(ActiveClientGame.Modus) then
                for j,k in ipairs(v.Weapons) do
                    if Config.UnlimitedAmmo then
                        GiveWeaponToPed(ped, GetHashKey(k), 1, 0, 0)
                        SetPedInfiniteAmmoClip(ped, true)
                    else
                        GiveWeaponToPed(ped, GetHashKey(k), Config.WeaponAmmo, 0, 0)
                    end
                end

            end
        end
    elseif Type == 'Leave' then
        local ped = PlayerPedId(-1)

        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 0)
        for i,v in ipairs(Config.Modus) do
            if tonumber(v.Modus) == tonumber(ActiveClientGame.Modus) then
                for j,k in ipairs(v.Weapons) do
                    RemoveWeaponFromPed(ped, GetHashKey(k))
                end
                SetPedInfiniteAmmoClip(ped, false)
            end
        end
        ESX.Game.Teleport(ped, Config.EnterCoords, function()end)
    end
end