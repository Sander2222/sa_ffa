local Games = {}
local PlayerLoadouts = {}
local UsedDimension = Config.StandardDimension + 1

if Config.UseESX12 then
    ESX = exports["es_extended"]:getSharedObject()
end

-- Games in die liste hinzufügen
RegisterNetEvent('sa_ffa:CreateGame')
AddEventHandler('sa_ffa:CreateGame', function(FFAInfo)
    local _source = source
    local IsNameValid = 0
    local NewPassword = FFAInfo.Password
    local FFAPlayerIDS = {}
    local Time = nil

    if #Games > 0 then
        for i,v in ipairs(Games) do
            if v.Name ~= FFAInfo.Name then
                IsNameValid = IsNameValid + 1
            else 
                if FFAInfo.PreBuild == 1 then
                    print("^1[ERROR]^7: There are 2 or more prebuild games that have the same name please change that name:^1" ..FFAInfo.Name)
                else
                    Config.SendNotifyServer(_source, Config.Local['NameIsInvalid'])
                end
                break
            end
        end
    end

    if FFAInfo.Password == '' or FFAInfo.Password == nil then
        NewPassword = ' '
    end

    if FFAInfo.Time ~= nil then
        Time = tonumber(FFAInfo.Time) - 1
    end

    if IsNameValid == #Games then
        local NewGame = {
            Name = FFAInfo.Name,
            Password = NewPassword,
            FFAPlayerID = FFAPlayerIDS,
            MaxPlayer = tonumber(FFAInfo.MaxPlayer),
            --Players muss 0 sein weil standard 0 Spieler in einer Runde sind
            Players = 0,
            PrivateGame = FFAInfo.Private or 2,
            Modus = FFAInfo.Mode,
            Map = FFAInfo.Map,
            Dimension = UsedDimension,
            PreBuild = FFAInfo.PreBuild or 0,
            TimeMin = Time,
            TimeSec = 60
        }

        table.insert(Games, NewGame)
        if FFAInfo.PreBuild ~= 1 then
            local xPlayer = ESX.GetPlayerFromId(_source)
            JoinGame(_source, NewGame, xPlayer.getLoadout())
        end
        UsedDimension = UsedDimension + 1

        local privat
        if FFAInfo.Password == '' then
            privat = 'Privat'
        else
            privat = nil
        end
        
        if FFAInfo.PreBuild ~= 1 then
            local xPlayer = ESX.GetPlayerFromId(_source)
            SendDiscord((SvConfig.WebhookText['PlayerCreatedGame']):format( xPlayer.getName(), xPlayer.getIdentifier(), FFAInfo.Name, privat or FFAInfo.Password))
            Config.SendNotifyServer(_source, (Config.Local['CreatedRoom']):format(NewGame.Name))
        end


    end
end)

CreateThread(function()
    while true do
        for k, v in ipairs(Games) do
            if v.PreBuild ~= 1 then
                if v.TimeSec <= 0 then
                    if v.TimeMin <= 0 then
                        for f, g in pairs(v.FFAPlayerID) do
                            TriggerClientEvent('sa_ffa:KickPlayer', g)
                        end
                    else
                        v.TimeMin = v.TimeMin - 1
                        v.TimeSec = 59
                        SendPlayerTime(v.FFAPlayerID, v.TimeMin, v.TimeSec)
                    end
                else 
                    v.TimeSec = v.TimeSec - 1
                    SendPlayerTime(v.FFAPlayerID, v.TimeMin, v.TimeSec)
                end
            else 
                SendPlayerTime(v.FFAPlayerID, nil, nil)
            end
        end

    Wait(1000)
    end
end)

function SendPlayerTime(playerarray, min, sec)
    for k, v in pairs(playerarray) do
        TriggerClientEvent('sa_ffa:SetTime', v, min, sec)
    end
end

RegisterNetEvent("sa_ffa:JoinGameServer")
AddEventHandler("sa_ffa:JoinGameServer", function(Game)
    local xPlayer = ESX.GetPlayerFromId(source)

    Config.SendNotifyServer(source, (Config.Local['GameFound']):format(Game.Name))
    SendDiscord((SvConfig.WebhookText['PlayerJoinedRoom']):format( xPlayer.getName(), xPlayer.getIdentifier(), Game.Name))
    JoinGame(source, Game, xPlayer.getLoadout())
end)

function JoinGame(PlayerID, GameArray, Loadout)
    local xPlayer = ESX.GetPlayerFromId(PlayerID)

    if next(Loadout) == nil then
        PlayerLoadouts[xPlayer.getIdentifier()] = {}
    else 
        PlayerLoadouts[xPlayer.getIdentifier()] = Loadout
    end

    ChangeWeaponState(PlayerID, 'join', Loadout)
    Wait(1000)
    TriggerClientEvent('sa_ffa:JoinGameClient', PlayerID, GameArray)
    SetPlayerRoutingBucket(PlayerID, GameArray.Dimension)
    SetRoutingBucketEntityLockdownMode(GameArray.Dimension, 'strict')
    ChangePlayerCount(PlayerID, GameArray, "join")

    if not Config.DisabledNPCS then
        SetRoutingBucketPopulationEnabled(GameArray.Dimension, false)
    end
end

RegisterNetEvent('sa_ffa:LeaveGame')
AddEventHandler('sa_ffa:LeaveGame', function(GameArray, player)
    ChangeWeaponState(player or source, "leave")
    LeaveGame(player or source, GameArray)
end)

function LeaveGame(Player, GameInfo)
    SetPlayerRoutingBucket(Player, Config.StandardDimension)
    TriggerClientEvent('sa_ffa:LeaveGameClient', Player, GameInfo.Modus)
    ChangePlayerCount(Player, GameInfo, "leave")

    local xPlayer = ESX.GetPlayerFromId(Player) 

    SendDiscord((SvConfig.WebhookText['PlayerLeavedGame']):format( xPlayer.getName(), xPlayer.getIdentifier(), GameInfo.Name))
end

RegisterNetEvent("sa_ffa:PlayerKilled")
AddEventHandler("sa_ffa:PlayerKilled", function(KillData)
    local killed = source
    local killer = KillData.killerServerId

    if KillData.killerServerId ~= nil then
        TriggerClientEvent('sa_ffa:UpdatePlayerStats', killed, 'killed')
        TriggerClientEvent('sa_ffa:UpdatePlayerStats', killer, 'killer')
        if Config.NotifyForKill then
            Config.SendNotifyServer(killed, (Config.Local['YouGotKilled']):format(GetPlayerName(killer)))
            Config.SendNotifyServer(killer, (Config.Local['YouKilled']):format(GetPlayerName(killed)))
        end
    else 
        TriggerClientEvent('sa_ffa:UpdatePlayerStats', killed, 'killed')
        if Config.NotifyForKill then
            Config.SendNotifyServer(killed, Config.Local['KilledYourself'])
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
            ['kills'] = result.kills + PlayerStats.kills,
            ['deaths'] = result.deaths + PlayerStats.deaths
        })
    end
end)

ESX.RegisterServerCallback('sa_ffa:GetSource', function(src, cb)
    cb(src)
end)

function ChangeWeaponState(Player, State, Loadout)
    local xPlayer = ESX.GetPlayerFromId(Player)

    if State == 'join' then
        -- Waffen entnehmen
        for i,v in ipairs(Loadout) do
            xPlayer.removeWeapon(v.name)
        end
    elseif State == 'leave' then
        --Waffen hinzufügen
        for i, v in ipairs(PlayerLoadouts[xPlayer.getIdentifier()]) do
            xPlayer.addWeapon(v.name, v.ammo)

            for e, f in pairs(v.components) do
                xPlayer.addWeaponComponent(v.name, f)
            end
        end
        PlayerLoadouts[xPlayer.getIdentifier()] = nil
    end
end



function ChangePlayerCount(Player, ActiveGame, State)

    --Bei join ist ActiveGame ein Array mit dem Ganzen Game 
    --Bei leave ist ActiveGame nur der Name von dem Game deswegen wird durchgeloopt

    if State == "join" then
        for k ,v in ipairs(Games) do
            if v.Name == ActiveGame.Name then
                v.Players = v.Players + 1
                table.insert(v.FFAPlayerID, Player)
            end
        end
    elseif State == "leave" then
        for k, v in ipairs(Games) do
            if v.Name == ActiveGame.Name then
                v.Players = v.Players - 1

                        for k,d in pairs(v.FFAPlayerID) do
                            if d == Player then
                                table.remove( v.FFAPlayerID, k )
                            end
                        end

                if ActiveGame.PreBuild == 0 then
                    if v.Players <= 0 then
                        Config.SendNotifyServer(Player, Config.Local['LastPerson'])
                        table.remove(Games, k )
                        SendDiscord((SvConfig.WebhookText['LobbyDeleted']):format(v.Name))
                    end
                    break
                end
            end
        end
    end
end

AddEventHandler("playerConnecting", function()
    local Player = source
    local xPlayer
    while xPlayer == nil do
        xPlayer =  ESX.GetPlayerFromId(Player)
        Wait(1)
    end

    if PlayerLoadouts[xPlayer.getIdentifier()] ~= nil then
        for k, v in ipairs(PlayerLoadouts[xPlayer.getIdentifier()]) do
            xPlayer.addWeapon(v.name)
            SetPedAmmo(GetPlayerPed(Player), v.name, v.ammo)
        end
        PlayerLoadouts[xPlayer.getIdentifier()] = nil
    end
end)

--- DEBUG
--- DEBUG
--- DEBUG

if Config.Debug then
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
end

ESX.RegisterServerCallback('sa_ffa:GetAllGames', function(source, cb)
    cb(Games)
end)

-- Discord
-- Discord
-- Discord


function SendDiscord(message)
    local embed = {
          {
              ["color"] = SvConfig.WebhookColor,
              ["title"] = SvConfig.WebhookNameLogs,
              ["description"] = message,
              ["footer"] = {
                  ["text"] = SvConfig.WebhookFooter,
              },
          }
      }
    PerformHttpRequest(SvConfig.WebhookLogs, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function SendFFAScoreboard(message)
    local embed = {
          {
              ["color"] = SvConfig.WebhookColor,
              ["title"] = SvConfig.WebhookNameLogsScoreboard,
              ["description"] = message,
              ["footer"] = {
                  ["text"] = SvConfig.WebhookFooter,
              },
          }
      }
    PerformHttpRequest(SvConfig.WebhookScoreboard, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

CreateThread(function()
    local IsSend = false
    while SvConfig.SendDiscordStats do
        local t = os.date ("*t")
        local hour = tostring(t.hour)

        if tonumber(hour) <= 9 then
            hour = "0" ..tostring(t.hour)
        end
        local ActiveTime = hour .. ':' .. tostring(t.min)
        if Config.Debug then
            Wait(500)
        else
            Wait(60000)
        end

        if ActiveTime == SvConfig.SendDisordStatsTime then
            if not IsSend then
                local message = ''
                local finish = false

                if SvConfig.ScoreboardDesign == 2 then
                    message = '**' .. Config.Local['FFATop'] .. ' ' .. SvConfig.SendDiscordScoreboardLimit ..'**\n\n'
                end

                local result = MySQL.query.await('SELECT ffa.kills, ffa.deaths, users.firstname, users.lastname  FROM ffa INNER JOIN users ON ffa.identifier = users.identifier ORDER BY ffa.kills DESC LIMIT ' ..tostring(SvConfig.SendDiscordScoreboardLimit), {})
                if result and result ~= {} then
                    for i = 1, #result do
                        local row = result[i]
                        if SvConfig.ScoreboardDesign == 1 then
                            message = message .. Config.Local['Place'] ..': **' .. i .. '**\n' .. Config.Local['Name'] .. ': **' .. row.firstname .. ' ' .. row.lastname .. '**\n' .. Config.Local['Kills'] ..': **' .. row.kills .. '**\n ' .. Config.Local['Deaths'] .. ': **' .. row.deaths .. '**\n' .. '\n\n'
                        elseif SvConfig.ScoreboardDesign == 2 then
                            message = message .. '**#' .. i  .. '** '.. row.firstname .. ' ' .. row.lastname .. ' | ' .. Config.Local['Kills'] .. ': ' .. row.kills .. ' - ' .. Config.Local['Deaths'] .. ': ' .. row.deaths .. '\n'
                        end
                            if i == #result then
                            finish = true
                        end
                    end
                    while not finish do
                        Wait(1)
                    end
                    SendFFAScoreboard(message)
                    finish = false
                    message = ''
                else
                    message = 'Es gibt gerade noch keine Daten für das Scoreboard'
                    SendFFAScoreboard(message)
                    finish = false
                    message = ''
                end
                IsSend = true
            end
        end
    end
end)

CreateThread( function()
    if Config.CheckVersion then
        local resourceName = "("..GetCurrentResourceName()..")"

        function CheckVersion(err,responseText, headers)
            local curVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

            if curVersion ~= responseText and curVersion < responseText then
                print("\n^3----------------------------------------------------------------------------------^7")
                print("\n"..resourceName.." is outdated, the newest Verion is^2:\n"..responseText.."^7 your version is:^1 "..curVersion.."\n^7Please update it from: ^1https://keymaster.fivem.net/asset-grants")
                print("\n^3----------------------------------------------------------------------------------^7")
            elseif curVersion > responseText then
                print("\n^3----------------------------------------------------------------------------------^7")
                print(resourceName.." You have a version problem. The newest version is: ^2"..responseText.."^7, but you have installed version: ^1"..curVersion.."^7! Please Update/Downgrade your Version from here: ^1https://keymaster.fivem.net/asset-grants")
                print("^3----------------------------------------------------------------------------------^7")
            else
                print("\n"..resourceName.." is up to date ^2(" .. curVersion .. ")^7, have fun and if you find bugs or need help just ask.")
            end
        end
        PerformHttpRequest("https://ffa.sa-scripts.com/", CheckVersion, "GET")
    end
end)

CreateThread(function()
    for k ,v in ipairs(Config.PrebuiltGames) do
        local ModeNumber, MapNumber = GiveIDBack(v.Mode, v.Map)

        local  Data = {
            Name = v.Name,
            Map = MapNumber,
            Mode =  ModeNumber,
            PreBuild = 1,
            MaxPlayer = v.MaxPlayer
        }
        TriggerEvent('sa_ffa:CreateGame', Data)
    end
end)

function GiveIDBack(Mode, Map)
    local ModeNumber, MapNumber

    for k,v in ipairs(Config.Modus) do
        if string.lower(v.Name) == string.lower(Mode) then
            ModeNumber = k
            break
        end
    end

    for k,v in ipairs(Config.Maps) do
        if string.lower(v.Name) == string.lower(Map) then
            MapNumber = k
            break
        end
    end

    return ModeNumber, MapNumber
end