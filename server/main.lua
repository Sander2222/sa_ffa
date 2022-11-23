local UsedDimension = Config.StandardDimension + 1
local Games = {

}

RegisterNetEvent('sa_ffa:CreateGame')
AddEventHandler('sa_ffa:CreateGame', function(UserCreateInfo) -- Arg: Name 1, Password 2, Max 3, Privat 4, Modus 5, Maps 6
    local xPlayer = ESX.GetPlayerFromId(source)
    local PlayerLoadout = xPlayer.getLoadout()
    local IsNameValid = 0
    
    if #Games > 0 then
        for i,v in ipairs(Games) do
            if v.Name ~= UserCreateInfo[1] then
                IsNameValid = IsNameValid + 1
            else 
                Config.SendNotifyServer(source, 'Diesen Raum gibt es schon erstelle einen neuen!')
                break
            end
        end
    end

    if IsNameValid == #Games then
        local NewGame = {
            Name = UserCreateInfo[1],
            Password = UserCreateInfo[2],
            MaxPlayer = UserCreateInfo[3],
            --Players muss 0 sein weil standard 0 Spieler in einer Runde sind
            Players = 0,
            PrivateGame = UserCreateInfo[4],
            Modus = UserCreateInfo[5],
            Map = UserCreateInfo[6],
            Dimension = UsedDimension
        }
    
        table.insert(Games, NewGame)
        
        JoinGame(source, NewGame, PlayerLoadout)
        UsedDimension = UsedDimension + 1
        SendDiscord((SvConfig.WebhookText['PlayerCreatedGame']):format( xPlayer.getName(), xPlayer.getIdentifier(), UserCreateInfo[1], UserCreateInfo[2]))
        Config.SendNotifyServer(source, 'ein Raum wurde erstellt mit dem Namen: ' ..NewGame.Name)
    end
end)

RegisterNetEvent('sa_ffa:JoinGame')
AddEventHandler('sa_ffa:JoinGame', function(args) -- Arg: Name, Passwort
    local xPlayer = ESX.GetPlayerFromId(source)
    local NameValid = false
    local PasswordValid = false
    local GameIsFull = true

    for i,v in ipairs(Games) do
        if v.Name == args[1] then
            NameValid = true
            if v.Password == args[2] then
                PasswordValid = true
                if tonumber(v.Players) > tonumber(v.MaxPlayer) then
                    GameIsFull = false
                    Config.SendNotifyServer(source, "Room wurde gefunden! Room: " .. v.Name)
                    SendDiscord((SvConfig.WebhookText['PlayerJoinedRoom']):format( xPlayer.getName(), xPlayer.getIdentifier(), v.Name))
                    JoinGame(source, v, xPlayer.getLoadout())
                    break
                end
            end
        end
    end

    if not NameValid and not PasswordValid then
        Config.SendNotifyServer(source, "Es wurde kein Spiel mit passendem Namen gefunden")
    elseif not PasswordValid then
        Config.SendNotifyServer(source, "Das Game wurde gefunden aber das Passwort ist falsch")
    elseif GameIsFull then
        Config.SendNotifyServer(source, "Passwort und Name war richtig aber das Game ist voll")
    end
end)

RegisterNetEvent('sa_ffa:LeaveGame')
AddEventHandler('sa_ffa:LeaveGame', function(PlayerWeapons, ActiveClientGame)
    ChangeWeaponState(source, "leave", PlayerWeapons)
    LeaveGame(source, ActiveClientGame)
end)

RegisterNetEvent("sa_ffa:SearchRandomGame")
AddEventHandler("sa_ffa:SearchRandomGame", function(args)
    GetRandomGame(source, Games, args)
end)

RegisterNetEvent("sa_ffa:PlayerKilled")
AddEventHandler("sa_ffa:PlayerKilled", function(KillData)
    local killed = source
    local killer = KillData.killerServerId

    if KillData.killerServerId ~= nil then
        TriggerClientEvent('sa_ffa:UpdatePlayerStats', killed, 'killed')
        TriggerClientEvent('sa_ffa:UpdatePlayerStats', killer, 'killer')
        if Config.NotifyForKill then
            Config.SendNotifyServer(killed, ('Du wurdest von %s getötet'):format(GetPlayerName(killer)))
            Config.SendNotifyServer(killer, ('Du hast %s getötet'):format(GetPlayerName(killer)))
        end
    else 
        TriggerClientEvent('sa_ffa:UpdatePlayerStats', killed, 'killed')
        if Config.NotifyForKill then
            Config.SendNotifyServer(killed, 'Du hast dich selber getötet')
        end
    end
end)


RegisterNetEvent("sa_ffa:SaveStats")
AddEventHandler("sa_ffa:SaveStats", function(PlayerStats)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = MySQL.prepare.await('SELECT * FROM ffa WHERE identifier = ?',{identifier})

    if result == nil then
        MySQL.Async.execute('INSERT INTO ffa (identifier, kills, deaths) VALUES (@identifier, @kills, @deaths)', {
            ['identifier'] = identifier,
            ['kills'] = PlayerStats.kills,
            ['deaths'] = PlayerStats.deaths
        })
    else 
        MySQL.Async.execute('UPDATE ffa SET kills = @kills, deaths = @deaths WHERE identifier = @identifier', {
            ['identifier'] = identifier,
            ['kills'] = PlayerStats.kills,
            ['deaths'] = PlayerStats.deaths
        })
    end
end)


--[[ Functions ]]
function ChangeWeaponState(Player, State, Loadout)
    local xPlayer = ESX.GetPlayerFromId(Player)
    if State == 'join' then
        -- Waffen entnehmen
        for i,v in ipairs(Loadout) do
            xPlayer.removeWeapon(v.name)
        end
    elseif State == 'leave' then
        --Waffen hinzufügen
        for i,v in ipairs(Loadout) do
            xPlayer.addWeapon(v.name)
            SetPedAmmo(GetPlayerPed(Player), v.name, v.ammo)
        end
    end
end

function JoinGame(Player, GameInfo, Loadout)
    ChangeWeaponState(source, 'join', Loadout)
    SetPlayerRoutingBucket(Player, GameInfo.Dimension)
    TriggerClientEvent('sa_ffa:JoinGameClient', Player, GameInfo, Loadout)
    ChangePlayerCount(Player, GameInfo, "join")

    if not Config.DisabledNPCS then
        SetRoutingBucketPopulationEnabled(GameInfo.Dimension, false)
    end
end

function LeaveGame(Player, GameInfo)
    SetPlayerRoutingBucket(Player, Config.StandardDimension)
    TriggerClientEvent('sa_ffa:LeaveGameClient', Player, GameInfo.Modus)
    ChangePlayerCount(Player, GameInfo, "leave")
end

function ChangePlayerCount(Player, ActiveGame, State)

    --Bei join ist ActiveGame ein Array mit dem Ganzen Game 
    --Bei leave ist ActiveGame nur der Name von dem Game deswegen wird durchgeloopt

    if State == "join" then
        ActiveGame.Players = ActiveGame.Players + 1
    elseif State == "leave" then
        for k, v in ipairs(Games) do
            if v.Name == ActiveGame then
                v.Players = v.Players - 1
                if v.Players <= 0 then
                    Config.SendNotifyServer(Player, "Da du die letzte Person in dem Game warst wurde die Lobby gelöscht")
                    table.remove(Games, k )
                    SendDiscord((SvConfig.WebhookText['LobbyDeleted']):format(v.Name))
                end
                break
            end
        end
    end
end


function GetRandomGame(Player, lobbys, args) --Arg: Map (args[1]), Modus (args[2])
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


--- DEBUG
--- DEBUG
--- DEBUG

RegisterCommand("check", function(source, args, rawCommand)
    print(GetPlayerRoutingBucket(source))
end, false)

RegisterCommand("put", function(source, args, rawCommand)
    SetPlayerRoutingBucket(source, tonumber(args[1]))
    SetRoutingBucketEntityLockdownMode(tonumber(args[1]), 'inactive')
end, false)

RegisterCommand("checkffa", function(source, args, rawCommand)
    print(ESX.DumpTable(Games))
end, false)

ESX.RegisterServerCallback('sa_ffa:GetAllGames', function(source, cb)
    cb(Games)
end)

--Discord
function SendDiscord(message)
    local embed = {
          {
              ["color"] = SvConfig.WebhookColor,
              ["title"] = SvConfig.WebhookName,
              ["description"] = message,
              ["footer"] = {
                  ["text"] = SvConfig.WebhookFooter,
              },
          }
      }
    PerformHttpRequest(SvConfig.Webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end