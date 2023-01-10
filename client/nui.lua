local AllGames = {}

function FFAUICreate()
    ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)
        local ActiveGamePlayer = 0
        local Number = #ActiveGames

        for i, v in ipairs(ActiveGames) do
            print(v.Players)
            print(type(v.Players))
            ActiveGamePlayer = ActiveGamePlayer + v.Players
        end

        print("lul")
        SetNuiFocus(true, true)
        SendNUIMessage({
            state = "show",
            type = "create",
            ModusA = Config.Modus,
            MapsA = Config.Maps,
            ActiveGamePlayerN = ActiveGamePlayer,
            MaxGamesN = Number
        })
        
        for i,v in ipairs(Config.Modus) do
            SendNUIMessage({
                state = "add",
                type = "create",
                ModeNumber = v.Modus,
                ModeName = v.Name
            })
        end

    end)
end

RegisterCommand('nui', function(source, args) -- Arg: Map, Modus (Die braucht man nicht umbedingt)
    FFAUICreate()
    --[[ UI WIRD GEÖFFNET ]]
end)

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
    print(data.Game)

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

RegisterNUICallback('CreateGame', function(data, cb)
    print(ESX.DumpTable(data))
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'close'
    })
    TriggerServerEvent('sa_ffa:CreateGame', data)
end)

function UpdateKDA(Death, Kill, Name)
        SendNUIMessage({
        state = 'add',
        type = 'score',
        death = Death,
        kill = Kill,
        Name = Name
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