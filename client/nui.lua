function display(bool) SetNuiFocus(bool, bool) end

RegisterNUICallback("close", function() end)

-- --Join
-- RegisterCommand('ui', function(source, args)
--     ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)
--         local ActiveGamePlayer = 0
--         local Number = #ActiveGames

--         for i,v in ipairs(ActiveGames) do
--             ActiveGamePlayer = ActiveGamePlayer + ActiveGames.Players
--         end

--         print("lul")
--         SetNuiFocus(true, true)
--         SendNUIMessage({
--             type = "create",
--             ModusA = Config.Modus,
--             MapsA = Config.Maps,
--             ActiveGamePlayerN = ActiveGamePlayer,
--             MaxGamesN = Number
--         })
--     end)

-- --Search
-- ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)

--     SendNuiMessage({
--         type = 'search',
--         ActiveGames = ActiveGames
--     })
-- end)

-- --Join
-- SendNuiMessage({
--     type = 'join',
-- })

-- --leave
-- SendNuiMessage({
--     type = 'leave',
--     ClientGame = ActiveClientGame
-- })

local AllGames = {}

RegisterCommand('ui', function(source, args)
    -- Search
    ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)

        AllGames = ActiveGames

        SetNuiFocus(true, true)
        SendNUIMessage({state = 'show', type = 'search'})

        for i, v in ipairs(ActiveGames) do
            print("1")
            if tonumber(v.PrivateGame) == 0 and tonumber(v.MaxPlayer) >
                tonumber(v.Players) then
                SendNUIMessage({
                    state = 'add',
                    type = 'search',
                    players = v.Players,
                    maxplayers = v.MaxPlayer,
                    map = v.Map,
                    name = v.Name,
                    modus = v.Modus
                })
            end
        end
    end)
end)

--search
RegisterNUICallback('JoinSearchedMatch', function(data, cb)
    print(data.Game)

    for i, v in ipairs(AllGames) do
        if data.Game == v.Name then
            print("Game gefunden")
            TriggerServerEvent("sa_ffa:SearchRandomGame", v)
            print(ESX.DumpTable(v))
            AllGames = {}
        end
    end
end)

RegisterNUICallback('exit', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'close'
    })
end)
