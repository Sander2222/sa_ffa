function GetRandomGame(Player, lobbys) --Arg: Map (args[1]), Modus (args[2])
    local xPlayer = ESX.GetPlayerFromId(Player)
    local LobbyFound = false
    local ClientMap = args[1]
    local ClientModus = args[2]

    for i, v in ipairs(Games) do
        --Sander bitte erkläre das keinem und mach das mal richtig
        if tonumber(v.PrivateGame) ~= 1 and tonumber(v.Players) < tonumber(v.MaxPlayer) then
            if ClientModus == (nil or '') then
                --Hier kommst du rein wenn kein Modus ist
                if ClientMap == (nil or '') then
                    --Hier kommst du rein wenn keine map ist und keinen Modus
                    Config.SendNotifyServer(source, "Es wurde eine Lobby gefunden mit dem Namen: " ..v.Name)
                    JoinGame(Player, v, xPlayer.getLoadout())
                    LobbyFound = true
                    break
                else
                    --Hier kommst du rein wenn du keinem Modus hast aber eine Map
                    if v.Map == ClientMap then
                        Config.SendNotifyServer(source, "Es wurde eine Lobby gefunden mit dem Namen: " ..v.Name)
                        JoinGame(Player, v, xPlayer.getLoadout())
                        LobbyFound = true
                        break
                    end
                end
            else
                if ClientModus == v.Modus then
                    if ClientMap == (nil or '') then
                        Config.SendNotifyServer(source, "Es wurde eine Lobby gefunden mit dem Namen: " ..v.Name)
                        JoinGame(Player, v, xPlayer.getLoadout())
                        LobbyFound = true
                        break
                    else
                        if v.Map == ClientMap then
                            Config.SendNotifyServer(source, "Es wurde eine Lobby gefunden mit dem Namen: " ..v.Name)
                            JoinGame(Player, v, xPlayer.getLoadout())
                            LobbyFound = true
                            break
                        end
                    end
                end
            end
        end
    end

    if not LobbyFound then
        Config.SendNotifyServer(source, 'Es wurde kein Lobby gefunden bitte versuche es gleich nochmal')
    end
end









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

function FFAUICreate()
    ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)
        local ActiveGamePlayer = 0
        local Number = #ActiveGames

        for i,v in ipairs(ActiveGames) do
            ActiveGamePlayer = ActiveGamePlayer + ActiveGames.Players
        end

        print("lul")
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "create",
            ModusA = Config.Modus,
            MapsA = Config.Maps,
            ActiveGamePlayerN = ActiveGamePlayer,
            MaxGamesN = Number
        })
    end)
end

function FFAUISearch()
    ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)

        AllGames = ActiveGames

        SetNuiFocus(true, true)
        SendNUIMessage({state = 'show', type = 'search'})


        for i, v in ipairs(ActiveGames) do
            if tonumber(v.PrivateGame) == 0 and tonumber(v.MaxPlayer) >
                tonumber(v.Players) then
                    local MapName, ModusName  = GiveDataBack(v.Modus, v.Map)

                    while ModusName == nil and MapName == nil do
                        wait(1)
                    end

                SendNUIMessage({
                    state = 'add',
                    type = 'search',
                    players = v.Players,
                    maxplayers = v.MaxPlayer,
                    map = MapName,
                    name = v.Name,
                    modus = ModusName
                })
            end
        end
    end)
end

--search Callback
RegisterNUICallback('JoinSearchedMatch', function(data, cb)
    
    for i, v in ipairs(AllGames) do
        if data.Game == v.Name then
            TriggerServerEvent("sa_ffa:SearchRandomGame", v)
            AllGames = {}
        end
    end
end)

--Exit
RegisterNUICallback('exit', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'close'
    })
end)


function UpdateKDA(Death, Kill)
        SendNUIMessage({
        state = 'add',
        type = 'score',
        death = Death,
        kill = Kill
    })
end

function ChangeClientscoreboard(State)
    SendNUIMessage({
        state = State,
        type = 'score'
    })
end

--Please dont ask
function GiveDataBack(Modus, Map)
    local MapName
    local ModusName

    for i,v in ipairs(Config.Modus) do
        if tonumber(v.Modus) == tonumber(Modus) then
            ModusName = v.Name
            print("modus")
        end
    end

    for i,v in ipairs(Config.Maps) do
        if tonumber(v.Map) == tonumber(Map) then
            MapName = v.Name
        end
    end

    while MapName == nil and ModusName == nil do
        Wait(0)
    end

    return MapName, ModusName
end