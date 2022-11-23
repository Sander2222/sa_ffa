SvConfig = {}

SvConfig.Webhook = 'https://canary.discord.com/api/webhooks/1001453843227361350/sbbCM02f6Yl0lOrtVmlchPDYEd_EwIPJwVpkZeJJRHVncyX-pH2cYQUmrO81cUc_mLNW'
SvConfig.WebhookName = 'FFA'
SvConfig.WebhookColor = 134
SvConfig.WebhookFooter = 'sa_ffa'

SvConfig.WebhookText = {
    ['PlayerCreatedGame'] = 'Der Spieler **%s** (%s) hat gerade eine Lobby erstellt: **%s** und Passwort **%s**',
    ['PlayerJoinedRoom'] = 'Der Spieler **%s** (%s) ist den %s gejoint',
    ['LobbyDeleted'] = 'Die Lobby **%s** wurde gelöscht da kein Spieler mehr drin ist',
}

--SendDiscord((SvConfig.WebhookText['PlayerJoinedRoom']):format( xPlayer.getName(), xPlayer.getIdentifier(), v.Name))
