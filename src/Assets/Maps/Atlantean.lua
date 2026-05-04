------------------------------------------------------------------------------
--	FILE:	 Atlantean.lua
--	AUTHOR:  Bob Thomas
--	PURPOSE: Global map script - Produces numerous small continents.
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

include("MapGenerator");
include("FractalWorld");
include("FeatureGenerator");
include("TerrainGenerator");
include("RiverGenerator");
include("IslandMaker");

------------------------------------------------------------------------------
function GetMapScriptInfo()
	local world_age, temperature, rainfall, sea_level, resources = GetCoreMapOptions()
	return {
		Name = "TXT_KEY_MAP_ATLANTEAN",
		Type = "TXT_KEY_MAP_ATLANTEAN",
		Description = "TXT_KEY_MAP_ATLANTEAN_HELP",
		IsAdvancedMap = 0,
		IconIndex = 17,
		SortIndex = 1,
		CustomOptions = {world_age, temperature, rainfall, sea_level, resources},
	};
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Generating Plot Types (Lua Atlantean) ...");

	local sea_level = Map.GetCustomOption(4)
	if sea_level == 4 then
		sea_level = 1 + Map.Rand(3, "Random Sea Level - Lua");
	end
	local world_age = Map.GetCustomOption(1)
	if world_age == 4 then
		world_age = 1 + Map.Rand(3, "Random World Age - Lua");
	end

	local fractal_world = FractalWorld.Create();
	fractal_world:InitFractal{
		continent_grain = 3};

	local args = {
		sea_level = sea_level,
		world_age = world_age,
		sea_level_low = 65,
		sea_level_normal = 70,   -- Sea levels in BE have been lowered by 4% to 5% overall vs Civ5, to make room for Canyons and Wild Areas.
		sea_level_high = 75,
		extra_mountains = 3,
		adjust_plates = 1.3,
		tectonic_islands = true,
		}
	local plotTypes = fractal_world:GeneratePlotTypes(args);
	
	SetPlotTypes(plotTypes);
	CreateSmallIslands(100)
	GenerateCoasts();
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain (Lua Atlantean) ...");
	
	-- Get Temperature setting input by user.
	local temp = Map.GetCustomOption(2)
	if temp == 4 then
		temp = 1 + Map.Rand(3, "Random Temperature - Lua");
	end

	local args = {temperature = temp};
	local terraingen = TerrainGenerator.Create(args);

	terrainTypes = terraingen:GenerateTerrain();
	
	SetTerrainTypes(terrainTypes);
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function RiverGenerator:GetCapsForMethodC()
	-- Set up caps for number of formations and plots based on world size.
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {2, 4, 2, 0},
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {3, 7, 2, 1},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {5, 12, 2, 2},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {6, 18, 2, 3},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {7, 28, 3, 3},
		--[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {9, 42, 4, 4},
		};
	local caps_list = worldsizes[Map.GetWorldSize()];
	local max_lines, max_plots, base_length, extension_range = caps_list[1], caps_list[2], caps_list[3], caps_list[4];
	return max_lines, max_plots, base_length, extension_range;
end
------------------------------------------------------------------------------
function AddRivers()
	print("Generating Rivers, Canyons, and Lakes. (Lua Atlantean) ...");

	local args = {minimum_percentage_of_total_land = 6};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features (Lua Atlantean) ...");

	-- Get Rainfall setting input by user.
	local rain = Map.GetCustomOption(3)
	if rain == 4 then
		rain = 1 + Map.Rand(3, "Random Rainfall - Lua");
	end
	
	local args = {rainfall = rain}
	local featuregen = FeatureGenerator.Create(args);

	-- False parameter removes mountains from coastlines.
	featuregen:AddFeatures(false);
end
------------------------------------------------------------------------------
function StartPlotSystem()
	-- Get Resources setting input by user.
	local res = Map.GetCustomOption(5)
	if res == 6 then
		res = 1 + Map.Rand(3, "Random Resources Option - Lua");
	end

	print("Creating start plot database.");
	local start_plot_database = AssignStartingPlots.Create()
	
	print("Dividing the map in to Regions.");
	-- Regional Division Method 5: All Start
	local args = {
		method = 5,
		resources = res,
		};
	start_plot_database:GenerateRegions(args)

	print("Choosing start locations for civilizations.");
	-- Forcing starts along the ocean.
	local args = {mustBeCoast = true};
	start_plot_database:ChooseLocations(args)
	
	print("Normalizing start locations and assigning them to Players.");
	start_plot_database:BalanceAndAssign()

	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()
	
	-- tell the AI that we should treat this as a offshore expansion map
	Map.ChangeAIMapHint(4);

end
------------------------------------------------------------------------------
