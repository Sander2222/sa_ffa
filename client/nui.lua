local AllGames = {}

function FFAUISearch()
    ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)

        AllGames = ActiveGames

        SetNuiFocus(true, true)
        SendNUIMessage({
            state = 'show', 
            type = 'search',
            notify = Config.UseUINotify
        })

        local CreatedGames = 0
        for i,v in ipairs(ActiveGames) do
            if v.PreBuild == 1 then
                local MapName, ModusName  = GiveNamesBack(v.Modus, v.Map)

                SendNUIMessage({
                    state = 'add',
                    type = 'searchprebuild',
                    players = v.Players,
                    maxplayers = v.MaxPlayer,
                    map = MapName,
                    name = v.Name,
                    modus = ModusName
                })
                CreatedGames = CreatedGames + 1
            end
        end

        if CreatedGames == #ActiveGames then
            SendNUIMessage({
                state = 'add',
                type = 'nogamessearch'
            })
        end

        if #ActiveGames > 0 then
        -- Add Games to Gamelist
        for i, v in ipairs(ActiveGames) do
            if v.PreBuild == 0 then
                local MapName, ModusName  = GiveNamesBack(v.Modus, v.Map)

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
        end
        else
            SendNUIMessage({
                state = 'add',
                type = 'nogamessearch'
            })
        end

        --Add Mode
        for i, v in ipairs(Config.Modus) do
            local title = string.gsub(v.Name, "%s", "")
            SendNUIMessage({
                state = "add",
                type = "create",
                status = "modus",
                ModeNumber = i,
                ModeName = v.Name,
                Icon = v.Icon,
                Title = title
            })
        end

        --Add Maps
        for i, v in ipairs(Config.Maps) do
            SendNUIMessage({
                state = "add",
                type = "create",
                status = "maps",
                MapNumber = i,
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

RegisterNUICallback('JoinPreBuild', function(data, cb)
    print(ESX.DumpTable(data))
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
function GiveNamesBack(Modus, Map)
    local MapName, ModusName

    for i,v in ipairs(Config.Modus) do
        if v.Name == Config.Modus[Modus].Name then
            ModusName = v.Name
        end
    end

    for i,v in ipairs(Config.Maps) do
        if v.Name == Config.Maps[Map].Name then
            MapName = v.Name
        end
    end

    while MapName == nil and ModusName == nil do
        Wait(0)
    end

    return MapName, ModusName
end
