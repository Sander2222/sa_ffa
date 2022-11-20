local isInDimension = nil
local PlayerLoadout = {}
local ActiveClientGame = {}


-- Test Befehl: create Arena1 23 3 0 2 SG
RegisterCommand('Create', function(source, args) -- Arg: Name, passwort, Max, Privat, Modus, Map
    --if not isInDimension then
    Config.SendNotifyClient("Raum wird erstellt...")
    TriggerServerEvent('sa_ffa:CreateGame', args)
    --end
end)

RegisterCommand('Join', function(source, args) -- Arg: Name, Passwort
    --if not isInDimension then
    TriggerServerEvent("sa_ffa:JoinGame", args)
    --ESX.ShowNotification("Raum wird betreten...")
    --else
    --ESX.ShowNotification("Du bist bereits in einem Raum!")
    --end
end)

-- Test Befehl: search SG 3
RegisterCommand('Search', function(source, args) -- Arg: Map, Modus (Die braucht man nicht umbedingt)
    TriggerServerEvent("sa_ffa:SearchRandomGame", args)
    ESX.ShowNotification("Spielsuche gestartet!")
end)

RegisterCommand('game', function(source, args)
    print(ESX.DumpTable(ActiveClientGame))
end)

RegisterCommand('Leave', function(source, args)
    --if isInDimension then
    Loadout('Leave', nil)
    TriggerServerEvent('sa_ffa:LeaveGame', PlayerLoadout, ActiveClientGame.Name)
    ActiveClientGame = {}
    --else
    --ESX.ShowNotification("Du bist in keiner sa_ffa Lobby!")
    --end
end)

RegisterNetEvent("sa_ffa:FoundRandomGame")
AddEventHandler("sa_ffa:FoundRandomGame", function()
    isInDimension = true
end)

RegisterNetEvent("sa_ffa:JoinGameClient")
AddEventHandler("sa_ffa:JoinGameClient", function(ActiveGame, PlayerWeapons)
    PlayerLoadout = PlayerWeapons
    ActiveClientGame = ActiveGame
    Loadout('Join', ActiveGame.Modus)
    Teleport()
    isInDimension = true
end)

RegisterNetEvent("sa_ffa:LeaveGameClient")
AddEventHandler("sa_ffa:LeaveGameClient", function(Modus)
    Loadout('Leave', Modus)
    isInDimension = false
end)

AddEventHandler('esx:onPlayerDeath', function(data)

    -- if istInDimension then
            Citizen.Wait(1000)
            TriggerEvent('esx_ambulancejob:revive')
            Wait(1000)
            Loadout('Join', ActiveClientGame.Modus)
            Teleport()
            NetworkSetFriendlyFireOption(false)
            SetCanAttackFriendly(GetPlayerPed(-1), false, false)
            if Config.Invincible then
                SetEntityInvincible(GetPlayerPed(-1), true)
            end
            Citizen.Wait(3000)
            NetworkSetFriendlyFireOption(true)
            SetCanAttackFriendly(GetPlayerPed(-1), true, true)
        if Config.Invincible then
            SetEntityInvincible(GetPlayerPed(-1), false)
        end
    -- end
end)

function Teleport()
    for i,v in ipairs(Config.Maps) do
        if v.Name == ActiveClientGame.Map then
            DoScreenFadeOut(100)
            ESX.Game.Teleport(PlayerPedId(), v.Teleports[math.random(1, #v.Teleports)], function()end)
            DoScreenFadeIn(100)
        end
    end
end

function Loadout(Type, Modus)
    
    if Type == 'Join' then
        local ped = PlayerPedId(-1)

        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 200)
        for i,v in ipairs(Config.Modus) do
            if tonumber(v.Modus) == tonumber(ActiveClientGame.Modus) then
                for j,k in ipairs(v.Weapons) do
                    GiveWeaponToPed(ped, GetHashKey(k), 1, 0, 0)
                end
                SetPedInfiniteAmmoClip(ped, true)
            end
        end
    elseif Type == 'Leave' then
        local ped = PlayerPedId(-1)

        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 0)
        for i,v in ipairs(Config.Modus) do
            if tonumber(v.Modus) == tonumber(ActiveClientGame.Modus) then
                for j,k in ipairs(v.Weapons) do
                    RemoveWeaponFromPed(ped, GetHashKey(k))
                end
                SetPedInfiniteAmmoClip(ped, false)
            end
        end

        ESX.Game.Teleport(ped, Config.EnterCoords, function()
            
        end)
    else
        print("Error")
    end
end

-- local weaponStealeableList = {2725352035,4194021054,148160082,2578778090,1737195953,1317494643,2508868239,1141786504,2227010557,453432689,1593441988,584646201,2578377531,324215364,736523883,4024951519,3220176749,2210333304,2937143193,2634544996,2144741730,487013001,2017895192,3800352039,2640438543,911657153,100416529,205991906,856002082,2726580491,1305664598,2982836145,375527679,324506233,1752584910,1119849093,2481070269,741814745,4256991824,2694266206,615608432,101631238,883325847,4256881901,2294779575,28811031,600439132,1233104067,3204302209,1223143800,4284007675,1936677264,2339582971,2461879995,539292904,3452007600,910830060,3425972830,133987706,2741846334,341774354,3750660587,3218215474,4192643659,1627465347,3231910285,3523564046,2132975508,2460120199,137902532,2138347493,2828843422,984333226,3342088282,1672152130,2874559379,126349499,1198879012,3794977420,3494679629,171789620,3696079510,3638508604,4191993645,1834241177,3713923289,3675956304,738733437,3756226112,3249783761
-- ,4019527611,1649403952,317205821,3441901897,125959754,3173288789,3125143736,2484171525,419712736,2803906140,4222310262,2971687502,1945616459,4171469727,3473446624,3800181289,4026335563,1259576109,1186503822,2669318622,1566990507,3450622333,3530961278,1741783703,1155224728,2144528907,1097917585,1638077257,729375873,3959029566,3041872152,50118905,1850631618,1948018762,1751145014,1817941018,3550712678,1426343849,4187887056,2753668402,4080829360,3748731225,2998219358,2244651441,2995980820,4264178988,1765114797,496339155,978070226,1274757841,1295434569,792114228,2406513688,2838846925,2528383651,2459552091,1577485217,768803961,483787975,2081529176,4189041807,2305275123,996550793,779501861,4263048111,4246083230,3407073922,3332236287,663586612,1587637620,693539241,2179883038,2297080999,2267924616,155886031,738282662,3812460080,2158727964,1852930709,1263688126,3463437675,1575005502,513448440,545862290,341217064,1897726628,3732468094,3500855031,3431676165,2773149623,2803366040,2228647636,1705498857,746606563,160266735,1125567497,3094015579,3430731035,772217690,2780351145,1704231442,3889104844,483577702,1735599485,544828034,292537574,3837603782,3730366643,2012476125,3224170789,2283450536,2223210455,4065984953,2170382056,4199656437,3317114643,1393009900,2633054488,157823901,3220073531,3958938975,582047296,1983869217,4180625516,1613316560,837436873,3201593029,127042729,3782592152,1649373715,3223238264,1548844439,3175998018,3759398940,2023061218,4254904030,2329799797}

-- Citizen.CreateThread(function()
--     print("lol")

--     SetPedInfiniteAmmo(PlayerPedId(), false, tonumber(weaponStealeableList[i]))
    
-- end)