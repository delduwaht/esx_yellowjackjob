Config = {}
Config.Locale = 'fr'

Config.DrawDistance = 25.0

Config.EnableVaultManagement	= true
Config.EnableMoneyWash			= false

Config.AlcoholMoneySelling 		= 300 -- $ par unité
Config.QuantityMaximumInVehicle	= 5 -- Maximum de barrels dans un véhicule

Config.JobVehicleName = 'BOBCATXL' -- Nom du véhicule utilisable pour les runs
Config.barrelEntityName = 'prop_cs_cardbox_01' -- Nom du prop à porter

Config.AuthorizedVehicles = {
	{ name = 'BOBCATXL',		label = 'Bobcat XL' }
}

Config.Blips = {

	Blip = {
		Pos		= { x = 1991.28, y = 3051.062, z = 53.537 },
		Sprite	= 570,
		Display	= 4,
		Scale	= 1.0,
		Color	= 44
	}

}

Config.JobBlips = {

	Recolte = {
		Pos		= { x = 1239.163, y = -3002.836, z = 8.329 },
		Sprite	= 684,
		Display = 4,
		Scale	= 1.1,
		Color	= 44,
		Name	= _U('society_harvest')
	},
	Vente = {
		Pos		= { x = 1719.426, y = 4759.067, z = 41.019 },
		Sprite	= 684,
		Display = 4,
		Scale	= 1.1,
		Color	= 44,
		Name	= _U('society_sell')
	}

}

Config.Zones = {

	Vaults = {
		Pos	 	= { x = 1980.105, y = 3049.344, z = 49.442 },
		Size	= { x = 1.3, y = 1.3, z = 1.0 },
		Color 	= { r = 255, g = 153, b = 51 },
		Type	= 23
	},

	Fridge = {
		Pos	 	= { x = 1985.242, y = 3048.727, z = 46.225 },
		Size	= { x = 1.2, y = 1.2, z = 1.0 },
		Color 	= { r = 248, g = 248, b = 255 },
		Type	= 23,
	},

	Vehicles = {
		Pos			= { x = 1979.854, y = 3045.707, z = 46.075 },
		SpawnPoint	= { x = 1986.189, y = 3041.102, z = 46.067 },
		Size		= { x = 1.8, y = 1.8, z = 1.0 },
		Color		= { r = 255, g = 153, b = 51 },
		Type		= 27,
		Heading		= 58.0
	},

	VehicleDeleters = {
		Pos	 	= { x = 1990.131, y = 3025.161, z = 46.050 },
		Size	= { x = 3.5, y = 3.5, z = 0.3 },
		Color 	= { r = 255, g = 0, b = 0 },
		Type	= 1
	},

	BossActions = {
		Pos	 	= { x = 1984.210, y = 3054.731, z = 46.215 },
		Size	= { x = 1.5, y = 1.5, z = 1.0 },
		Color 	= { r = 220, g = 110, b = 0 },
		Type	= 27
	},

	Recolte = {
		Pos	 	= { x = 1239.163, y = -3002.836, z = 8.329 },
		Size	= { x = 3.0, y = 3.0, z = 0.8 },
		Color 	= { r = 255, g = 153, b = 51 },
		Type	= 1,
	},

	Transformation = {
		Pos	 	= { x = 1996.782, y = 3038.595, z = 46.030 },
		Size	= { x = 2.3, y = 2.3, z = 0.5 },
		Color 	= { r = 255, g = 153, b = 51 },
		Type	= 1,
	},

	Vente = {
		Pos	 	= { x = 1719.426, y = 4759.067, z = 40.940 },
		Size	= { x = 2.4, y = 2.4, z = 0.5 },
		Color 	= { r = 255, g = 153, b = 51 },
		Type	= 1,
	}

}
