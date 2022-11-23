fx_version 'adamant'

game 'gta5'


lua54 'yes'
version '1.8.5'

shared_scripts { 
	'@es_extended/imports.lua',
	'config.lua'
}


server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
	'svconfig.lua'
}

client_scripts {
	'client/main.lua',
	'client/nui.lua'
}