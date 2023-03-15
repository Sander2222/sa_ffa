IsInDimension = false
local cam = nil
local PlayerModus = 0
local PlayerLoadout, ActiveClientGame, GameWeapons = {}, {}, {}  
local ActiveMapInfo = {
    ActiveMapCenter = nil,
    ActiveMapRadius = nil
}
local PlayerStats = {
    kills = 0,
    deaths = 0
}

function IsPlayerInFFA()
    return IsInDimension
end

if Config.UseESX12 then
    ESX = exports["es_extended"]:getSharedObject()
end

function LeaveFFA()
    if IsInDimension then
        TriggerServerEvent('sa_ffa:LeaveGame', PlayerLoadout, ActiveClientGame.Name)
        TriggerServerEvent('sa_ffa:SaveStats', PlayerStats)
        return true
    else
        print("Player is not in ffa")
        return false
    end
end

RegisterCommand(Config.LeaveCommand, function(source, args)
    if IsInDimension or Config.Debug then
        TriggerServerEvent('sa_ffa:LeaveGame', PlayerLoadout, ActiveClientGame.Name)
        TriggerServerEvent('sa_ffa:SaveStats', PlayerStats)
    else
        Config.SendNotifyClient(Config.Local['NotInLobby'])
    end
end)

CreateThread(function()
    if Config.NPC.active then
        RequestModel(GetHashKey(Config.NPC.model))
        while not HasModelLoaded(GetHashKey(Config.NPC.model)) do
            Wait(15)
        end

        ped = CreatePed(4, GetHashKey(Config.NPC.model), Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] - 1, 3374176, false, true)
        SetEntityHeading(ped, Config.NPC.heading)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
    end

    if Config.Blip.active then
        blip = AddBlipForCoord(Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3])
        SetBlipSprite(blip, Config.Blip.id)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipColour(blip, Config.Blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.text)
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    while true do
        Wait(1)

        local dist = #(GetEntityCoords(ped) - vector3(Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3]))

        if dist <= Config.Dist then
            Config.ShowHelpNotify(Config.Local['PressE'])
            if IsControlJustReleased(0, 38) then
                FFAUISearch()
            end 
        else 
            Wait(1000)
        end

    end
end)

RegisterNetEvent("sa_ffa:JoinGameClient")
AddEventHandler("sa_ffa:JoinGameClient", function(ActiveGame, PlayerWeapons)
    PlayerLoadout = PlayerWeapons
    ActiveClientGame = ActiveGame
    Loadout('Join', ActiveGame.Modus)
    ChangeBlipState('hide')

    DisplayRadar(false)
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
    if Config.ShowleaveCommandNotify then 
        Config.SendNotifyClient((Config.Local['ShowLeaveCommand']):format('/'.. Config.LeaveCommand))
    end
    IsInDimension = true
end)

RegisterNetEvent("sa_ffa:LeaveGameClient")
AddEventHandler("sa_ffa:LeaveGameClient", function(Modus)
    Loadout('Leave', Modus)
    ChangeBlipState('show')
    ChangeClientscoreboard('close')
    IsInDimension = false
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

    if IsInDimension then
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

                Wait(Config.CamWait)
                DisplayRadar(true)
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
        DisplayRadar(true)
    end
end

--zum dist checkn
Citizen.CreateThread(function()

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

--Aktualisiert KDA UI etc.
Citizen.CreateThread(function()
    while true do
        if IsInDimension then
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

        DisplayRadar(false)

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
        if not IsInDimension then
            TriggerServerEvent("sa_ffa:JoinGame", args)
            Config.SendNotifyClient(Config.Local['JoinGame'])
        else
            Config.SendNotifyClient(Config.Local['AlreadyInLobby'])
        end
    end)
end


function ChangeBlipState(State)
    if Config.DisableBlip then
        local blips = {}
        for k = 0, 802, 1 do -- build 2372
            local blip = GetFirstBlipInfoId(k)
            if DoesBlipExist(blip) then
                table.insert(blips, blip)
                while true do
                    local blip = GetNextBlipInfoId(k)
                    if DoesBlipExist(blip) then
                        table.insert(blips, blip)
                    else
                        break
                    end
                end
            end
        end
        
        if State == 'hide' then
            for k, v in pairs(blips) do 
                SetBlipDisplay(v, 0)
            end
        elseif State == 'show' then
            for k, v in pairs(blips) do 
                SetBlipDisplay(v, 2)
            end
        end
    end
end