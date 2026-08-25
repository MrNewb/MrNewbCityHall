fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'MrNewbCityHall'
description 'City hall jobs, ID cards, and job applications'
author 'MrNewb'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    '@Newb_Bridge/import.lua',
    'configs/cityhall.lua',
    'configs/applications.lua',
    'resource/shared/locale.lua',
    'resource/shared/applications.lua',
}

client_scripts {
    'resource/client/menus.lua',
    'resource/client/registry.lua',
}

server_scripts {
    'configs/webhooks.lua',
    'resource/server/discord.lua',
    'resource/server/cityhall.lua',
}

files {
    'locales/*.json',
}

dependencies {
    '/server:6116',
    '/onesync',
    'ox_lib',
    'Newb_Bridge',
}

escrow_ignore {
    'configs/*.lua',
    'locales/*.json',
    'resource/**/*.lua',
}
