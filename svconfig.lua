SvConfig = {}

SvConfig.WebhookLogs = 'https://canary.discord.com/api/webhooks/1001453843227361350/sbbCM02f6Yl0lOrtVmlchPDYEd_EwIPJwVpkZeJJRHVncyX-pH2cYQUmrO81cUc_mLNW'
SvConfig.WebhookNameLogs = 'FFA'
SvConfig.WebhookColor = 134
SvConfig.WebhookFooter = 'sa_ffa'

SvConfig.WebhookScoreboard = 'https://canary.discord.com/api/webhooks/1001453843227361350/sbbCM02f6Yl0lOrtVmlchPDYEd_EwIPJwVpkZeJJRHVncyX-pH2cYQUmrO81cUc_mLNW'
SvConfig.WebhookNameLogsScoreboard = 'FFA Scoreboard'

SvConfig.WebhookText = {
    ['PlayerCreatedGame'] = 'Der Spieler **%s** (%s) hat gerade eine Lobby erstellt. Infos zu der Lobby: \n\nName: %s \nPasswort: %s',
    ['PlayerJoinedRoom'] = 'Der Spieler **%s** (%s) ist den %s gejoint',
    ['LobbyDeleted'] = 'Die Lobby **%s** wurde gelöscht da kein Spieler mehr drin ist',
}

--SendDiscord((SvConfig.WebhookText['PlayerJoinedRoom']):format( xPlayer.getName(), xPlayer.getIdentifier(), v.Name))
