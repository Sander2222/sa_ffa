Config = {}

Config.Debug = true
Config.StandardDimension = 0
Config.Invincible = false
Config.DisabledNPCS = true
Config.NotifyForKill = true
Config.SendDiscordStats = true
Config.SendDisordStatsTime = '01:35'
Config.SendDiscordScoreboardLimit = 10
Config.UseCamAnimations = true
Config.CamWait = 2500

Config.SendNotifyClient = function (msg)
    ESX.ShowNotification(msg)
end

Config.SendNotifyServer = function (source, msg)
    
    --ESX 1.3 or higher
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification(msg)
end

Config.AfterRevive = function(source)
    ExecuteCommand('removeTimeout ' ..tostring(source)) 
end

Config.EnterCoords = {1628.2857666016,2552.1848144531,45.564849853516}

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
    }
}

Config.Local = {
    ['PressE'] = 'Drücke ~INPUT_CONTEXT~ um etwas zu kaufen',
    ['NameIsInValid'] = 'Es gibt schon einen Raum mit diesem Namen',
    ['CreatedRoom'] = 'Du hast einen Raum erstellt mit dem Namen: %s',
    ['NoGameFound'] = 'Es wurde kein Spiel gefunden mit dem Namen: %s',
    ['OutOfZone'] = 'Du bist auserhalb der Zone, deswegen wurdest du zurück teleporiert',
    ['NotInLobby'] = 'Du bist in keiner FFA Runde',
    ['AlreadyInLobby'] = 'Du bist schon in einer Lobby',
    ['GameCreate'] = 'Der Raum wird erstellt',
}