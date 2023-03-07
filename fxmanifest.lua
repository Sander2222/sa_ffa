fx_version 'adamant'
game 'gta5'

lua54 'yes'
version '1.0'

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

exports {
	'FFAUISearch',
	'LeaveFFA',
	'IsPlayerInFFA'
}

escrow_ignore {
	'config.lua',
	'svconfig.lua',
	'fxmanifest.lua',
	'config.js'
}

dependencies {
	'oxmysql',
	'es_extended'
}

--Export to open FFA Search UI client side
--exports['sa_ffa']:FFAUISearch()

--exports['sa_ffa']:IsPlayerInFFA()

--exports['sa_ffa']:LeaveFFA()

ui_page ('html/index.html')

files {
	'config.js',
	'html/images/skull.png',
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/css/*.css',
	'html/images/*.png',
	'html/images/*.jpg',
	'html/images/*.gif',
	'html/images/*.webp'
}