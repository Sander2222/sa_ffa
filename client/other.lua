CreateThread(function()
    if Config.NPC.active then
        RequestModel(GetHashKey(Config.NPC.model))
        while not HasModelLoaded(GetHashKey(Config.NPC.model)) do
            Wait(15)
        end

        local ped = CreatePed(4, GetHashKey(Config.NPC.model), Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3] - 1, 3374176, false, true)
        SetEntityHeading(ped, Config.NPC.heading)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
    end

    if Config.Blip.active then
        local blip = AddBlipForCoord(Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3])
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

        local dist = #(GetEntityCoords(PlayerPedId()) - vector3(Config.EnterCoords[1], Config.EnterCoords[2], Config.EnterCoords[3]))

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

CreateThread(function()
    while Config.Sphere.Active do
        Wait(1)

        if IsInDimension then
            DrawSphere(ActiveMapInfo.ActiveMapCenter.x, ActiveMapInfo.ActiveMapCenter.y, ActiveMapInfo.ActiveMapCenter.z, ActiveMapInfo.ActiveMapRadius + .0, Config.Sphere.r, Config.Sphere.g, Config.Sphere.b, Config.Sphere.opacity)
        else
            Wait(1000)
        end
    end
end)

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

    if Config.Debug then
        RegisterCommand('2', function(source, args)
            FFAUISearch()
        end)
    end
end


function ChangeBlipState(State)
    if Config.DisableBlip then
        local blips = {}
        for k = 0, 826, 1 do -- build 2372
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

--Aktualisiert KDA UI etc.
CreateThread(function()
    while true do
        if IsInDimension then
            UpdateKDA(PlayerStats.deaths, PlayerStats.kills)
            Wait(100)
        else 
            Wait(2000)
        end
        Wait(1)
    end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    if IsInDimension then
        Wait(1000)
        TriggerServerEvent('sa_ffa:PlayerKilled', data)
        TriggerEvent('esx_ambulancejob:revive')
        Wait(1000)
        Loadout('Join')
        Teleport()
        NetworkSetFriendlyFireOption(false)
        SetCanAttackFriendly(GetPlayerPed(-1), false, false)
        if Config.Invincible then
            SetEntityInvincible(GetPlayerPed(-1), true)
        end
        
        ESX.TriggerServerCallback('sa_ffa:GetSource', function(src)
            Config.AfterRevive(src)
        end)

        Wait(3000)
        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(GetPlayerPed(-1), true, true)
        if Config.Invincible then
            SetEntityInvincible(GetPlayerPed(-1), false)
        end
        TriggerServerEvent('sa_ffa:TriggerCustomFunction')
    end
end)