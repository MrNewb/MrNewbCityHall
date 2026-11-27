fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'MrNewbCityHall'
description 'City hall jobs, ID cards, and job applications'
author 'MrNewb'
version '1.0.5'

ox_libs {
    'locale',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@Newb_Bridge/import.lua',
    'resource/open/shared/cityhall.lua',
    'resource/open/shared/applications.lua',
    'resource/modules/applications/shared/applications.lua',
}

client_scripts {
    'resource/modules/cityhall/client/menus.lua',
    'resource/modules/cityhall/client/registry.lua',
}

server_scripts {
    'resource/open/server/webhooks.lua',
    'resource/modules/applications/server/discord.lua',
    'resource/modules/cityhall/server/cityhall.lua',
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
    '**/*',
}
