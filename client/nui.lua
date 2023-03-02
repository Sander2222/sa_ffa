local AllGames = {}

function FFAUICreate()
    ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)
        local ActiveGamePlayer = 0
        local Number = #ActiveGames

        for i, v in ipairs(ActiveGames) do
            ActiveGamePlayer = ActiveGamePlayer + v.Players
        end

        SetNuiFocus(true, true)
        SendNUIMessage({
            state = "show",
            type = "create",
            MapsA = Config.Maps,
            -- Soon im UI
            -- ActiveGamePlayerN = ActiveGamePlayer,
            -- MaxGamesN = Number
        })
        
        --Add Mode
        for i,v in ipairs(Config.Modus) do
            SendNUIMessage({
                state = "add",
                type = "create",
                status = "modus",
                ModeNumber = v.Modus,
                ModeName = v.Name,
                Icon = v.Icon,
                Title = v.title
            })
        end

        --Add Maps
        for i,v in ipairs(Config.Maps) do
            SendNUIMessage({
                state = "add",
                type = "create",
                status = "maps",
                MapNumber = v.Map,
                ModeName = v.Name,
                MapMaxPlayer = v.MaxPlayer
            })
        end
    end)
end

if Config.Debug then
    RegisterCommand('1', function(source, args)
        FFAUICreate()
    end)
end

if Config.Debug then
    RegisterCommand('2', function(source, args)
        FFAUISearch()
    end)
end

function FFAUISearch()
    ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)

        AllGames = ActiveGames

        SetNuiFocus(true, true)
        SendNUIMessage({state = 'show', type = 'search'})

        for i, v in ipairs(ActiveGames) do
                local MapName, ModusName  = GiveDataBack(v.Modus, v.Map)

                while ModusName == nil and MapName == nil do
                    wait(1)
                end

            SendNUIMessage({
                state = 'add',
                type = 'search',
                players = v.Players,
                maxplayers = v.MaxPlayer,
                password = v.Password,
                map = MapName,
                name = v.Name,
                modus = ModusName
            })
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

RegisterNUICallback('CreateGame', function(data, cb)

    if not isInDimension then
        SetNuiFocus(false, false)
        SendNUIMessage({
            state = 'close'
        })
        TriggerServerEvent('sa_ffa:CreateGame', data)
        Config.SendNotifyClient(Config.Local['GameCreate'])
    else
        Config.SendNotifyClient(Config.Local['AlreadyInLobby'])
    end
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
    local MapName, ModusName

    for i,v in ipairs(Config.Modus) do
        if tonumber(v.Modus) == tonumber(Modus) then
            ModusName = v.Name
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