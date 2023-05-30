Config = {}

Config.CheckVersion = false -- if you want to check the active version (suggested!!)
Config.Debug = true -- only put this on true if you know what you are doing
Config.StandardDimension = 0 -- Put there you standard dimension
Config.Invincible = false -- Put this on true if the player got killed have a spawnprotect
Config.DisabledNPCS = true -- use your brain ;)
Config.NotifyForKill = true -- If you want that the players get a notify if they die or get a kill
Config.UseCamAnimations = false -- Use cam Animations for join and leave ffa
Config.CamWait = 2500 -- Dont edit it if you dont know what are you doing
Config.UseUINotify = false -- This is for the UI there is a Notifysystem in the ui if you dont use it then put this on false
Config.LeaveCommand = 'leave' -- This command ist for leave the ffa
Config.ShowleaveCommandNotify = true -- This is if the player get a notify how the leave command ist Config.LeaveCommand
Config.Dist = 3.0 -- the distance to check at the point
Config.DisableBlip = true -- put this on true if you want do disable all blips if the player is in a ffa game (beta version)
Config.UseESX12 = false -- not recommended and not tested!!! (if you use 1.2 or lower please update your ESX Version)
Config.UseOXInventory = false -- if you use ox_inventory put this on true
Config.OneSecondWait = 995 -- With this you can experiment, this is the time that waits for the time basic ffa to update the time, is the TimeSync is slow or to fast change this. But dont change it when you dont know what your doing

Config.SendNotifyClient = function(msg) -- add your client notify
    ESX.ShowNotification(msg)
end

Config.Sphere = {
    Active = true,
    r = 255, -- 0 to 255 (rgb)
    g = 0, -- 0 to 255 (rgb)
    b = 0, -- 0 to 255 (rgb)
    opacity = 0.3 -- 0.1 to 1.0
}

Config.SendNotifyServer = function(source, msg) -- add your server notify
    
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification(msg)
end

-- This Code is CLIENTSIDE, but you have source and you can create the ped if you want (PlayePedId()) the source is for execute commands like removedeathtimeout
Config.AfterRevive = function(source)
    -- ExecuteCommand('removeTimeout ' ..tostring(source)) 
end

Config.ShowHelpNotify = function(Text) -- add your ShowHelpNotification
    ESX.ShowHelpNotification(Text)
end

-- Change the coord where the ffa enter coords should be
Config.EnterCoords = {1628.2857666016,2552.1848144531,45.564849853516}

-- If you want a NPC to spawn at the Coords in Config.EnterCoords then add your data here
Config.NPC = {
    active = true, -- put this true if you want a NPC
    heading = 100, -- set the heading where the NPC should look at
    model = 'ig_ballasog' -- look here what you want for a NPC https://docs.fivem.net/docs/game-references/ped-models/
}

Config.Blip = {
    active = true, -- Put this true if you want a blip
    id = 84, -- look here what you want for a blip https://docs.fivem.net/docs/game-references/blips/
    scale = 1.0, -- how big the blip is 1.0 is basic. THIS MUST BE A FLOAT/DOUBLE
    color = 3, -- look here what you want for a blip color https://docs.fivem.net/docs/game-references/blips/
    text = 'FFA' -- what the blip is called
}

-- If you want to add more prebuild games read the readme.md
Config.PrebuiltGames = {
    {
        Name = 'FFA 1',
        Mode = 'only Sniper',
        Map = 'WP',
        MaxPlayer = 123
    }
}

-- If you want to add more modus read the readme.md
Config.Modus = {
    {
        Name = 'Only Pistol',
        Icon = 'fa-solid fa-user-ninja',
        Weapons = {
            "weapon_pistol",
            "weapon_appistol"
        }
    },
    {
        Name = 'Only Sniper',
        Icon = 'fa-solid fa-person-praying',
        Weapons = {
            'weapon_sniperrifle',
            "weapon_heavysniper",
            "weapon_marksmanrifle"
        }
    },
    {
        Name = 'Only Pumpgun',
        Icon = 'fa-solid fa-gun',
        Weapons = {
            "weapon_pumpshotgun",
            "weapon_sawnoffshotgun",
            "weapon_assaultshotgun"
        }
    },
    {
        Name = 'Only Assault',
        Icon = 'fa-solid fa-cross',
        Weapons = {
            "weapon_assaultrifle",
            "weapon_carbinerifle",
            "weapon_advancedrifle"
        }
    },
}

-- If you want to add more modus read the readme.md
Config.Maps = {
    {
        Name = 'SG',
        MaxPlayer = 15,
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
        Name = 'WP',
        MaxPlayer = 10,
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
    ['PressE'] = 'Drücke ~INPUT_CONTEXT~ um das FFA zu öffnen',
    ['NameIsInvalid'] = 'Es gibt schon einen Raum mit diesem Namen',
    ['CreatedRoom'] = 'Du hast einen Raum erstellt mit dem Namen: %s', -- param 1 = FFA Name
    ['NoGameFound'] = 'Es wurde kein Spiel gefunden mit dem Namen: %s', -- param 1 = User Enter FFA Name
    ['GameFound'] = 'Es wurde ein Spiel gefunden: %s', -- param 1 = FFA Name
    ['OutOfZone'] = 'Du bist auserhalb der Zone, deswegen wurdest du zurück teleporiert',
    ['NotInLobby'] = 'Du bist in keiner FFA Runde',
    ['JoinGame'] = 'Raum wird betreten...',
    ['AlreadyInLobby'] = 'Du bist schon in einer Lobby',
    ['RoomFound'] = 'Room wurde gefunden! Room: %s', -- param 1 = FFA name
    ['RommFoundWrongPassword'] = 'Das Game wurde gefunden aber das Passwort ist falsch',
    ['RoomFoundButFull'] = 'Passwort und Name war richtig aber das Game ist voll',
    ['YouGotKilled'] = 'Du wurdest von %s getötet', -- param 1 = the killer from this player (steam)
    ['YouKilled'] = 'Du hast %s getötet', -- -- param 1 = the person you killed (steam)
    ['KilledYourself'] = 'Du hast dich selber getötet',
    ['LastPerson'] = 'Da du die letzte Person in dem Game warst wurde die Lobby gelöscht',
    ['ShowLeaveCommand'] = 'Mit diesem Befehl kannst du das FFA jederzeit verlassen %s', -- -- param 1 = leave command
    
    ['Place'] = 'Place',
    ['Name'] = 'Name',
    ['Kills'] = 'Kills',
    ['Deaths'] = 'Deaths',
    ['FFATop'] = 'FFA Top × ',
}

-- There are more locals in the config.js