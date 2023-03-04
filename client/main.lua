isInDimension = false
local cam = nil
local IsClose = false
local IsAt = false
local PlayerModus = 0
local PlayerLoadout = {}
local ActiveClientGame = {}
local GameWeapons = {}
local ActiveMapInfo = {
    ActiveMapCenter = nil,
    ActiveMapRadius = nil
}
local PlayerStats = {
    kills = 0,
    deaths = 0
}

function IsPlayerInFFA()
    return isInDimension
end

if Config.NPC.active then
    Citizen.CreateThread(function()
        RequestModel(GetHashKey(Config.NPC.model))
        while not HasModelLoaded(GetHashKey(Config.NPC.model)) do
            Wait(15)
        end

        ped = CreatePed(4, Config.NPC.hash, Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] - 1, 3374176, false, true)
        SetEntityHeading(Config.NPC.ped, Config.NPC.heading)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
    end)
end

Citizen.CreateThread(function()
    local ped = PlayerPedId()
    while true do
        Wait(950)

        IsClose = false
		IsAt = false

        local dist = #(GetEntityCoords(ped) - vector3(Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3]))

        if dist <= 2.0 then
            IsClose = true
            IsAt = true
        elseif dist <= 4.0 then
            IsClose = true
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1)
		if  not IsClose then
			Wait(950) 
        end
		if IsAt then
            ESX.ShowHelpNotification(Config.Local['PressE'])
            if IsControlJustReleased(0, 38) then
                FFAUICreate()
            end
		end
    end
end)

RegisterNetEvent("sa_ffa:JoinGameClient")
AddEventHandler("sa_ffa:JoinGameClient", function(ActiveGame, PlayerWeapons)
    PlayerLoadout = PlayerWeapons
    ActiveClientGame = ActiveGame
    Loadout('Join', ActiveGame.Modus)

    if Config.UseCamAnimations then
    --Cams
        FreezeEntityPosition(GetPlayerPed(), true)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] + 250.0, 300.00, 0.00 ,0.00, 70.00, false, 0)
        PointCamAtCoord(cam, Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] + 2.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, Config.CamWait, true, true)
        Citizen.Wait(Config.CamWait)
        Teleport('first')
    else 
        Teleport()
    end

    ChangeClientscoreboard('show')
    isInDimension = true
end)

RegisterNetEvent("sa_ffa:LeaveGameClient")
AddEventHandler("sa_ffa:LeaveGameClient", function(Modus)
    Loadout('Leave', Modus)
    ChangeClientscoreboard('close')
    isInDimension = false
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
        
        ESX.TriggerServerCallback('sa_ffa:GetSource', function(src)
            Config.AfterRevive(src)
        end)

        Citizen.Wait(3000)
        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(GetPlayerPed(-1), true, true)
        if Config.Invincible then
            SetEntityInvincible(GetPlayerPed(-1), false)
        end
        TriggerServerEvent('sa_ffa:TriggerCustomFunction')
    end
end)

function Teleport(Type)
    if Type == 'first' then 
        for i,v in ipairs(Config.Maps) do
            if tonumber(v.Map) == tonumber(ActiveClientGame.Map) then
                local RandomPoint = v.Teleports[math.random(1, #v.Teleports)]

                RenderScriptCams(false, true, Config.CamWait, true, true)
                DoScreenFadeOut(100)
                ESX.Game.Teleport(PlayerPedId(), RandomPoint, function()end)
                DoScreenFadeIn(100)
                FreezeEntityPosition(GetPlayerPed(), false)
                ActiveMapInfo.ActiveMapCenter = v.MapCenter
                ActiveMapInfo.ActiveMapRadius = v.MaxRadius

                SetCamActive(cam, false)
                DestroyCam(cam, true)
                cam = nil
            end
        end
    else 
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
end

--zum dist checkn
Citizen.CreateThread(function()

    while true do
        if isInDimension then
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

--Aktualisiert KDA UI etc.
Citizen.CreateThread(function()
    while true do
        if isInDimension then
            UpdateKDA(PlayerStats.deaths, PlayerStats.kills, ActiveClientGame.Name)
            Wait(100)
        else 
            Wait(2000)
        end
        Wait(1)
    end
end)

function Loadout(Type, Modus)
    
    if Type == 'Join' then
        local ped = PlayerPedId()
        PlayerModus = Modus

        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 200)
        for i,v in ipairs(Config.Modus) do
            if tonumber(v.Modus) == tonumber(ActiveClientGame.Modus) then
                for j,k in ipairs(v.Weapons) do
                    GiveWeaponToPed(ped, GetHashKey(k), 1, 0, 0)
                end
                GameWeapons = v.Weapons
            end
        end
    elseif Type == 'Leave' then
        local ped = PlayerPedId()

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

        PlayerModus = 0
        GameWeapons = {}

        ActiveClientGame = {}
        -- Cams zum Back TP hin
        FreezeEntityPosition(GetPlayerPed(), true)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] + 250.0, 300.00, 0.00 ,0.00, 70.00, false, 0)
        PointCamAtCoord(cam, Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] + 2.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, Config.CamWait, true, true)
        Citizen.Wait(Config.CamWait)

        RenderScriptCams(false, true, Config.CamWait, true, true)
        ESX.Game.Teleport(ped, vector3(Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3]), function()end)
        FreezeEntityPosition(GetPlayerPed(), false)

        SetCamActive(cam, false)
        DestroyCam(cam, true)
        cam = nil

    end
end

--
--DEBUG
--DEBUG
--DEBUG
--

if Config.Debug then

    RegisterCommand('kills', function(source, args) -- Arg: Map, Modus (Die braucht man nicht umbedingt)
        PlayerStats.kills = args[1]
    end)

    RegisterCommand('deaths', function(source, args) -- Arg: Map, Modus (Die braucht man nicht umbedingt)
        PlayerStats.deaths = args[1]
    end)

    RegisterCommand('game', function(source, args)
        print(ESX.DumpTable(ActiveClientGame))
    end)

    function er(msg)
        print(msg)
    end

    RegisterCommand('Join', function(source, args) -- Arg: Name, Passwort
        if not isInDimension then
            TriggerServerEvent("sa_ffa:JoinGame", args)
            Config.SendNotifyClient("Raum wird betreten...")
        else
            Config.SendNotifyClient(Config.Local['AlreadyInLobby'])
        end
    end)
    
    RegisterCommand('Leave', function(source, args)
        if isInDimension or Config.Debug then
            TriggerServerEvent('sa_ffa:LeaveGame', PlayerLoadout, ActiveClientGame.Name)
            TriggerServerEvent('sa_ffa:SaveStats', PlayerStats)
        else
            Config.SendNotifyClient(Config.Local['NotInLobby'])
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        ped = PlayerPedId()
        if PlayerModus ~= 0 then
            while true do
                for k,v in pairs(GameWeapons) do
                    AddAmmoToPed(ped, GetHashKey(v), 500)
                end
                Wait(0)
            end
        else
            Wait(2000)
        end
        Wait(0)
    end
end)