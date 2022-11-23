function display(bool)
    SetNuiFocus(bool, bool)
end

RegisterNUICallback("close", function()
    
end)

--Join
ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)
    local ActiveGamePlayer = 0

    for i,v in ipairs(ActiveGames) do
        ActiveGamePlayer = ActiveGamePlayer + ActiveGames.Players
    end

    SendNuiMessage({
        typeS = 'create',
        ModusA = Config.Modus,
        MapsA = Config.Maps,
        ActiveGamePlayerN = ActiveGamePlayer,
        MaxGamesN= #ActiveGames
    })
end)

--Search
ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)

    SendNuiMessage({
        typeS = 'search',
        ActiveGames = ActiveGames
    })
end)

--Join
SendNuiMessage({
    typeS = 'join',
})

--leave
SendNuiMessage({
    typeS = 'leave',
    ClientGame = ActiveClientGame
})