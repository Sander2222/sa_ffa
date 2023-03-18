SvConfig = {}

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
    ['PlayerCreatedGame'] = 'Der Spieler **%s** (%s) hat gerade eine Lobby erstellt. Infos zu der Lobby: \n\nName: %s \nPasswort: %s', -- param 1 = ESX Player Name || param 2 = Player Indentifer || param = 3 Room name || param 4 || Room Password
    ['PlayerJoinedRoom'] = 'Der Spieler **%s** (%s) ist den %s gejoint', -- param 1 = ESX Player name || param 2 = Player Identifier || param 3 Room name
    ['LobbyDeleted'] = 'Die Lobby **%s** wurde gelöscht da kein Spieler mehr drin ist', -- param 1 = Room name
}