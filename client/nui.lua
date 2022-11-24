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
        type = 'create',
        ModusA = Config.Modus,
        MapsA = Config.Maps,
        ActiveGamePlayerN = ActiveGamePlayer,
        MaxGamesN= #ActiveGames
    })
end)

--Search
ESX.TriggerServerCallback('sa_ffa:GetAllGames', function(ActiveGames)

    SendNuiMessage({
        type = 'search',
        ActiveGames = ActiveGames
    })
end)

--Join
SendNuiMessage({
    type = 'join',
})

--leave
SendNuiMessage({
    type = 'leave',
    ClientGame = ActiveClientGame
})