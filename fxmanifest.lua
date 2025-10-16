fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'MrNewb'
description 'A simple, easy to use city hall script with ids, jobs, applications.'
version '0.0.1'

shared_scripts {
	'core/init.lua',
	'configs/cityhall.lua',
	'configs/applications.lua',
}

client_scripts {
	'modules/**/client.lua',
}

server_scripts {
	'configs/webhooks.lua',
	'modules/**/server.lua',
}

files {
	'locales/*.json'
}

dependencies {
	'/server:6116',
	'/onesync',
	'community_bridge'
}