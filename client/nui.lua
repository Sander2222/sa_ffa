local AllGames = {}

if Config.Debug then
    RegisterCommand('2', function(source, args)
        FFAUISearch()
    end)
end

function FFAUISearch()
    ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)

        AllGames = ActiveGames

        SetNuiFocus(true, true)
        SendNUIMessage({
            state = 'show', 
            type = 'search',
            notify = Config.UseUINotify
        })

        for i, v in ipairs(ActiveGames) do
                local MapName, ModusName  = GiveDataBack(v.Modus, v.Map)

                while ModusName == nil and MapName == nil do
                    Wait(1)
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

        --Add Mode
        for i,v in ipairs(Config.Modus) do
            local title = string.gsub(v.Name, "%s", "")
            SendNUIMessage({
                state = "add",
                type = "create",
                status = "modus",
                ModeNumber = v.Modus,
                ModeName = v.Name,
                Icon = v.Icon,
                Title = title
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

RegisterNUICallback('notify', function(data, cb)
    Config.SendNotifyClient(data.Message)
end)

RegisterNUICallback('CreateGame', function(data, cb)

    if not IsInDimension then
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
