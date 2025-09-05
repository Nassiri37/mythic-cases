fx_version 'cerulean'
game 'gta5'

lua54 'yes'

Author 'JoeSzymkowiczFiveM / Edited and Converted to Mythic FW By nass_.'

shared_scripts {
    'shared/config.lua',
}

client_script "client/main.lua"

server_script "server/main.lua"

ui_page "html/index.html"

files {
    'html/index.html',
    'html/index.js',
    'html/index.css',
    'html/reset.css',
    'html/imgs/**/*.png',
}