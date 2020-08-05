fx_version 'bodacious'
game 'gta5'


-- Client Scripts
client_scripts {
	'@es_extended/locale.lua',
	"client/td_client.lua",
	'locales/tr.lua',
	'locales/en.lua',
	"config.lua",
	"export.lua"
}

export {
	"KoseTut"
}

-- server Scripts
server_scripts {
    '@es_extended/locale.lua',
	"config.lua",
	"export.lua",
	'locales/tr.lua',
	'locales/en.lua',
	"server/td_server.lua"
}