Config = {}
Config.Locale = 'fr'

Config.DrawDistance = 25.0

Config.EnableVaultManagement	= true
Config.EnableMoneyWash			= false

Config.AlcoholMoneySelling 		= 300 -- $ par unité
Config.QuantityMaximumInVehicle	= 5 -- Maximum de barrels dans un véhicule

Config.JobVehicleName = 'BOBCATXL' -- Nom du véhicule utilisable pour les runs

Config.AuthorizedVehicles = {
	{ name = 'BOBCATXL',		label = 'Bobcat XL' }
}

Config.Blips = {

	Blip = {
		Pos		= { x = 1983.412, y = 3053.862, z = 46.215 },
		Sprite	= 570,
		Display	= 4,
		Scale	= 1.0,
		Color	= 64
	}

}

Config.JobBlips = {

	Recolte = {
		Pos		= { x = 1241.949, y = -2952.928, z = 8.319 },
		Sprite	= 684,
		Display = 4,
		Scale	= 1.1,
		Color	= 64,
		Name	= _U('society_harvest')
	},
	Vente = {
		Pos		= { x = 1692.438, y = 4785.551, z = 40.921 },
		Sprite	= 684,
		Display = 4,
		Scale	= 1.1,
		Color	= 64,
		Name	= _U('society_sell')
	}

}

Config.Zones = {

	Vaults = {
		Pos	 	= { x = 489.151, y = -2182.274, z = 4.938 },
		Size	= { x = 1.3, y = 1.3, z = 1.0 },
		Color 	= { r = 220, g = 110, b = 0 },
		Type	= 23
	},

	Fridge = {
		Pos	 	= { x = 135.478, y = -1288.615, z = 28.289 },
		Size	= { x = 1.6, y = 1.6, z = 1.0 },
		Color 	= { r = 248, g = 248, b = 255 },
		Type	= 23,
	},

	Vehicles = {
		Pos			= { x = 1977.583, y = 3032.69, z = 47.0 },
		SpawnPoint	= { x = 1981.598, y = 3039.748, z = 47.0 },
		Size		= { x = 1.8, y = 1.8, z = 1.0 },
		Color		= { r = 220, g = 110, b = 0 },
		Type		= 27,
		Heading		= 244.0
	},

	VehicleDeleters = {
		Pos	 	= { x = 501.193, y = -2143.193, z = 4.918 },
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
		Pos	 	= { x = 1241.949, y = -2952.928, z = 8.319 },
		Size	= { x = 3.0, y = 3.0, z = 0.8 },
		Color 	= { r = 220, g = 110, b = 0 },
		Type	= 1,
	},

	Transformation = {
		Pos	 	= { x = 1996.414, y = 3038.002, z = 47.0 },
		Size	= { x = 3.0, y = 3.0, z = 0.8 },
		Color 	= { r = 220, g = 110, b = 0 },
		Type	= 1,
	},

	Vente = {
		Pos	 	= { x = 1692.438, y = 4785.551, z = 40.921 },
		Size	= { x = 3.0, y = 3.0, z = 0.8 },
		Color 	= { r = 220, g = 110, b = 0 },
		Type	= 1,
	}

}