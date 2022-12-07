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

exports {
	'FFAUISearch',
	'FFAUICreate'
}

--Export to open FFA Search UI client side
exports['sa_ffa']:FFAUISearch()
--Export to open FFA Create UI client side
exports['sa_ffa']:FFAUICreate()

ui_page ('html/index.html')

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/css/*.css',
	'html/images/*.png',
	'html/images/*.jpg',
	'html/images/*.gif',
	'html/images/*.webp',
	'html/lines.svg',
	'html/panel_lines.svg'
}