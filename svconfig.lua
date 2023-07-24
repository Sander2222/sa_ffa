SvConfig = {}

SvConfig.SendDisordStatsTime = '22:06' -- Set the time where the message get sended from the stats
SvConfig.SendDiscordStats = true -- If you want to send a Discord message with the Stats from the Database
SvConfig.SendDiscordScoreboardLimit = 10 -- Set how much player should be listed in the Message

-- This Webhook is where the logs get send
SvConfig.WebhookLogs = 'https://canary.discord.com/api/webhooks/1001453843227361350/sbbCM02f6Yl0lOrtVmlchPDYEd_EwIPJwVpkZeJJRHVncyX-pH2cYQUmrO81cUc_mLNW' -- URL
SvConfig.WebhookNameLogs = 'FFA' -- Header
SvConfig.WebhookColor = 134 -- https://birdie0.github.io/discord-webhooks-guide/structure/embed/color.html
SvConfig.WebhookFooter = 'sa_ffa' -- the footer

-- This Webhook is where the Scorenboard get send
SvConfig.WebhookScoreboard = 'https://canary.discord.com/api/webhooks/1001453843227361350/sbbCM02f6Yl0lOrtVmlchPDYEd_EwIPJwVpkZeJJRHVncyX-pH2cYQUmrO81cUc_mLNW' --URL
SvConfig.WebhookNameLogsScoreboard = 'FFA Scoreboard'  -- Header

-- Webhook locals
SvConfig.WebhookText = {
    ['PlayerCreatedGame'] = 'Player **%s** (%s) has created an lobby. Information about the lobby: \n\nName: %s \nPasswort: %s', -- param 1 = ESX Player Name || param 2 = Player Indentifer || param = 3 Room name || param 4 || Room Password
    ['PlayerJoinedRoom'] = 'Player **%s** (%s) has joined the game: %s', -- param 1 = ESX Player name || param 2 = Player Identifier || param 3 Room name
    ['LobbyDeleted'] = 'The lobby **%s** was deleted because no one was in the lobby', -- param 1 = Room name
    ['PlayerLeavedGame'] = 'Player **%s** (%s) leaved a game: %s' -- param 1 PlayerName || param 2 Player Identifier || param 3 Romm Name
}

SvConfig.ScoreboardDesign = 1

--[[ 
    
Here are the designs

Design 1
Link: https://media.discordapp.net/attachments/1001453825330249798/1098668913870524446/image.png?width=157&height=629

Design 2
Link: https://media.discordapp.net/attachments/892386561323331642/1116362809169678356/image.png

]]--