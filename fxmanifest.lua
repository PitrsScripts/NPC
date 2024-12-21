fx_version 'cerulean'
game 'gta5'

author 'PitrsScripts'
description 'Script for spawning NPCs at given locations with animations'
version '1.0.0'

lua54 'yes'

client_scripts {
    '@ox_lib/init.lua', 
    'config.lua',
    'client/cl.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',  
    'server/sv.lua',
}
