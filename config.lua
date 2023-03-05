Config = {}

Config.CheckVersion = true
Config.Debug = true -- only put this on true if you know what you are doing
Config.StandardDimension = 0 -- Put there you standard dimension
Config.Invincible = false -- Put this on true if the player got killed have a spawnprotect
Config.DisabledNPCS = true -- use your brain ;)
Config.NotifyForKill = true -- If you want that the players get a notify if they die or get a kill
Config.SendDiscordStats = true -- If you want to send a Discord message with the Stats from the Database
Config.SendDisordStatsTime = '01:35' -- Set the time where the message get sended from the stats
Config.SendDiscordScoreboardLimit = 10 -- Set how much player should be listed in the Message
Config.UseCamAnimations = false -- Use cam Animations for join and leave ffa
Config.CamWait = 2500 -- Dont edit it if you dont know what are you doing
Config.UseUINotify = false
Config.LeaveCommand = 'leave'
Config.ShowleaveCommandNotify = true

Config.SendNotifyClient = function(msg) -- add your client notify 
    ESX.ShowNotification(msg)
end

Config.SendNotifyServer = function(source, msg) -- add your server notify 
    
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification(msg)
end

-- This Code is CLIENTSIDE, but you have source and you can create the ped if you want (PlayePedId()) the source is for execute commands like removedeathtimeout
Config.AfterRevive = function(source)
    -- ExecuteCommand('removeTimeout ' ..tostring(source)) 
end

-- If you want a NPC to spawn at the Coords in Config.EnterCoords then add your data here
Config.NPC = {
    active = true,
    heading = 100,
    hash = 0xB353629E,
    model = 's_m_m_paramedic_01'
}

-- Change the coord where the ffa enter coords should be
Config.EnterCoords = {1628.2857666016,2552.1848144531,45.564849853516}

-- If you want to cerate https://fontawesome.com/icons/
Config.Modus = {
    {
        Modus = 1,
        title = 'gambo1',
        Name = 'Gambo 1',
        Icon = 'fa-solid fa-user-ninja',
        Weapons = {
            "weapon_pistol",
            "weapon_appistol",
            "weapon_pumpshotgun"
        }
    },
    {
        Modus = 2,
        title = 'gambo2',
        Name = 'Gambo 2',
        Icon = 'fa-solid fa-person-praying',
        Weapons = {
            "WEAPON_PISTOL",
            "WEAPON_APPISTOL",
            "weapon_assaultrifle"
        }
    },
    {
        Modus = 3,
        title = 'gambo3',
        Name = 'Gambo 3',
        Icon = 'fa-solid fa-gun',
        Weapons = {
            "WEAPON_PISTOL",
            "WEAPON_APPISTOL",
            "weapon_smg"
        }
    },
    {
        Modus = 4,
        title = 'gambo4',
        Name = 'ficken sie sich',
        Icon = 'fa-solid fa-cross',
        Weapons = {
            "WEAPON_PISTOL",
            "WEAPON_APPISTOL",
            "weapon_mg"
        }
    },
}

Config.Maps = {
    {
        Map = 1,
        Name = 'SG',
        MaxPlayer = 187,
        MapCenter = vector3(1644.9177246094,2513.39453125,45.564910888672),
        MaxRadius = 200,
        Teleports = {
            vector3(1629.33, 2496.81, 44.56),
            vector3(1622.69, 2561.02, 44.56),
            vector3(1762.322, 2542.14, 44.56),
            vector3(1723.89, 2494.1, 45.56),
            vector3(1692.69, 2471.34, 45.57),
            vector3(1619.16, 2570.29, 45.56),
            vector3(1758.79, 2518.91, 45.56),
            vector3(1616.79, 2524.93, 44.56),
        }
    },
    {
        Map = 2,
        Name = 'WP',
        MaxPlayer = 187,
        MapCenter = vector3(198.85273742676,-931.42071533203,30.689985275269),
        MaxRadius = 200,
        Teleports = {
            vector3(257.35, -873.52, 28.21),
            vector3(186.51, -847.52, 30.21),
            vector3(127.44, -988.43, 28.21),
            vector3(215.41, -1007.14, 28.21),
            vector3(215.27, -940.14, 23.21),
            vector3(221.91, -861.14, 29.21),
            vector3(221.91, -952.14, 29.21),
            vector3(162.91, -913.14, 29.21),
        }
    },
}

-- Locals
Config.Local = {
    ['PressE'] = 'Drücke ~INPUT_CONTEXT~ um etwas zu kaufen',
    ['NameIsInValid'] = 'Es gibt schon einen Raum mit diesem Namen',
    ['CreatedRoom'] = 'Du hast einen Raum erstellt mit dem Namen: %s',
    ['NoGameFound'] = 'Es wurde kein Spiel gefunden mit dem Namen: %s',
    ['OutOfZone'] = 'Du bist auserhalb der Zone, deswegen wurdest du zurück teleporiert',
    ['NotInLobby'] = 'Du bist in keiner FFA Runde',
    ['JoinGame'] = 'Raum wird betreten...',
    ['AlreadyInLobby'] = 'Du bist schon in einer Lobby',
    ['GameCreate'] = 'Der Raum wird erstellt',
    ['RoomFound'] = 'Room wurde gefunden! Room: %s',
    ['RommFoundWrongPassword'] = 'Das Game wurde gefunden aber das Passwort ist falsch',
    ['RoomFoundButFull'] = 'Passwort und Name war richtig aber das Game ist voll',
    ['YouGotKilled'] = 'Du wurdest von %s getötet',
    ['YouKilled'] = 'Du hast %s getötet',
    ['KilledYourself'] = 'Du hast dich selber getötet',
    ['LastPerson'] = 'Da du die letzte Person in dem Game warst wurde die Lobby gelöscht',
    ['ShowLeaveCommand'] = 'Mit diesem Befehl kannst du das FFA jederzeit verlassen %s',
}

-- There are more locals in the config.js