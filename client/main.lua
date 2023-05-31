IsInDimension = false
ActiveClientGame = {}
local cam = nil
ActiveMapInfo = {
    ActiveMapCenter = nil,
    ActiveMapRadius = nil
}
PlayerStats = {
    kills = 0,
    deaths = 0
}

-- 
-- Export machen LeaveFFA()
-- 

function IsPlayerInFFA()
    return IsInDimension
end

if Config.UseESX12 then
    ESX = exports["es_extended"]:getSharedObject()
end 

function LeaveFFA()
    if IsInDimension then
        LeaveFFA()
        return true
    else
        return false
    end
end

RegisterCommand(Config.LeaveCommand, function(source, args)
    if IsInDimension or Config.Debug then
        LeaveFFA()
    else
        Config.SendNotifyClient(Config.Local['NotInLobby'])
    end
end)

function LeaveFFA()
    TriggerServerEvent('sa_ffa:LeaveGame', ActiveClientGame)
    TriggerServerEvent('sa_ffa:SaveStats', PlayerStats)
    IsInDimension = false
    PlayerStats.kills = 0
    PlayerStats.deaths = 0
end

RegisterNetEvent("sa_ffa:SetTime")
AddEventHandler("sa_ffa:SetTime", function(TimeMin, TimeSec)
    UpdateTimerUI(TimeMin, TimeSec)
end)

RegisterNetEvent("sa_ffa:KickPlayer")
AddEventHandler("sa_ffa:KickPlayer", function()
    LeaveFFA()
end)

RegisterNetEvent("sa_ffa:JoinGameClient")
AddEventHandler("sa_ffa:JoinGameClient", function(ActiveGame)
    ActiveClientGame = ActiveGame
    Loadout('Join')
    ChangeBlipState('hide')
    if Config.UseOXInventory then
        exports.ox_inventory:weaponWheel(true)
    end

    DisplayRadar(false)
    if Config.UseCamAnimations then
    --Cams
        FreezeEntityPosition(GetPlayerPed(), true)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] + 250.0, 300.00, 0.00 ,0.00, 70.00, false, 0)
        PointCamAtCoord(cam, Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] + 2.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, Config.CamWait, true, true)
        Wait(Config.CamWait)
        ChangeClientscoreboard('show')
        if Config.ShowleaveCommandNotify then 
            Config.SendNotifyClient((Config.Local['ShowLeaveCommand']):format('/'.. Config.LeaveCommand))
        end
        IsInDimension = true
        Teleport('first')
    else 
        ChangeClientscoreboard('show')
        if Config.ShowleaveCommandNotify then 
            Config.SendNotifyClient((Config.Local['ShowLeaveCommand']):format('/'.. Config.LeaveCommand))
        end
        IsInDimension = true
        Teleport('first')
    end
end)

RegisterNetEvent("sa_ffa:LeaveGameClient")
AddEventHandler("sa_ffa:LeaveGameClient", function(Modus)
    Loadout('Leave', Modus)
    ChangeBlipState('show')
    if Config.UseOXInventory then
        exports.ox_inventory:weaponWheel(false)
    end
    ChangeClientscoreboard('close')

    ConfigFun.PlayerLeaveGame()
end)

RegisterNetEvent("sa_ffa:UpdatePlayerStats")
AddEventHandler("sa_ffa:UpdatePlayerStats", function(Type)

    if Type == 'killed' then
        PlayerStats.deaths = PlayerStats.deaths + 1
    elseif Type == 'killer' then
        SetEntityHealth(PlayerPedId(), 200)
        SetPedArmour(PlayerPedId(), 200)
        PlayerStats.kills = PlayerStats.kills + 1
    end
end)

function Teleport(Type)
    if Type == 'first' then 
        local Map = Config.Maps[ActiveClientGame.Map]
        local RandomPoint = Map.Teleports[math.random(1, #Map.Teleports)]

        RenderScriptCams(false, true, Config.CamWait, true, true)
        DoScreenFadeOut(100)
        ESX.Game.Teleport(PlayerPedId(), RandomPoint, function()end)
        DoScreenFadeIn(100)
        FreezeEntityPosition(GetPlayerPed(), false)
        ActiveMapInfo.ActiveMapCenter = Config.Maps[ActiveClientGame.Map].MapCenter
        ActiveMapInfo.ActiveMapRadius = Config.Maps[ActiveClientGame.Map].MaxRadius

        SetCamActive(cam, false)
        DestroyCam(cam, true)
        cam = nil

        Wait(Config.CamWait)
        DisplayRadar(true)
    else 
        local Map = Config.Maps[ActiveClientGame.Map]
        DoScreenFadeOut(100)
        ESX.Game.Teleport(PlayerPedId(), Map.Teleports[math.random(1, #Map.Teleports)], function()end)
        DoScreenFadeIn(100)
        DisplayRadar(true)
    end
end

--zum dist checkn
CreateThread(function()

    while true do
        if IsInDimension then
            local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), ActiveMapInfo.ActiveMapCenter)

            if dist >= ActiveMapInfo.ActiveMapRadius then
                Teleport()
                Config.SendNotifyClient(Config.Local['OutOfZone'])
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
        local ped = PlayerPedId()

        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 200)
            if ActiveClientGame.Modus ~= nil or ActiveClientGame.Modus ~= 0 then
                for j,k in ipairs(Config.Modus[ActiveClientGame.Modus].Weapons) do
                    GiveWeaponToPed(ped, GetHashKey(k), 1, 0, 0)
                end
            end
        
    elseif Type == 'Leave' then
        local ped = PlayerPedId()

        DisplayRadar(false)

        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 0)

        if ActiveClientGame.Modus ~= nil or ActiveClientGame.Modus ~= 0 then
            for j,k in ipairs(Config.Modus[ActiveClientGame.Modus].Weapons) do
                RemoveWeaponFromPed(ped, GetHashKey(k))
            end
        end

        ActiveClientGame = {}
        -- Cams zum Back TP hin
        FreezeEntityPosition(GetPlayerPed(), true)
        if Config.UseCamAnimations then
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] + 250.0, 300.00, 0.00 ,0.00, 70.00, false, 0)
            PointCamAtCoord(cam, Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] + 2.0)
            SetCamActive(cam, true)
            RenderScriptCams(true, true, Config.CamWait, true, true)
            Wait(Config.CamWait)
            RenderScriptCams(false, true, Config.CamWait, true, true)
            SetCamActive(cam, false)
            DestroyCam(cam, true)
            cam = nil
            Wait(Config.CamWait)
        end

        ESX.Game.Teleport(ped, vector3(Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3]), function()end)
        FreezeEntityPosition(GetPlayerPed(), false)
        DisplayRadar(true)
    end
end

CreateThread(function()
    while true do
        if IsInDimension then
                for k,v in pairs(Config.Modus[ActiveClientGame.Modus].Weapons) do
                    AddAmmoToPed(PlayerPedId(), GetHashKey(v), 500)
                end
            Wait(50)
        else
            Wait(2000)
        end
        Wait(0)
    end
end)