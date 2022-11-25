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