------------------------------------------------------------------------------
--	FILE:	 Equatorial.lua
--	AUTHOR:  Bob Thomas
--	PURPOSE: Global map script - One or more large continents in the equatorial
--	         region, with ever-smaller islands closer to the poles.
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

include("MapGenerator");
include("MultilayeredFractal");
include("FeatureGenerator");
include("TerrainGenerator");
include("RiverGenerator");
include("MapmakerUtilities");

------------------------------------------------------------------------------
function GetMapScriptInfo()
	local world_age, temperature, rainfall, sea_level, resources = GetCoreMapOptions()
	return {
		Name = "TXT_KEY_MAP_EQUATORIAL",
		Type = "TXT_KEY_MAP_EQUATORIAL",
		Description = "TXT_KEY_MAP_EQUATORIAL_HELP",
		IconIndex = 8,
		SortIndex = 1,
		CustomOptions = {world_age, temperature, rainfall, resources},
	};
end
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
function MultilayeredFractal:GeneratePlotsByRegion()
	-- Sirian's MultilayeredFractal controlling function.
	-- You -MUST- customize this function for each script using MultilayeredFractal.
	--
	-- This implementation is specific to Equatorial.
	local large_NorthLat = 0.65;
	local large_SouthLat = 0.35;
	local medium_NorthLat = 0.8;
	local medium_SouthLat = 0.2;
	local small_NorthLat = 0.95;
	local small_SouthLat = 0.05;
	local iFlags = {FRAC_POLAR = true};

	print("Generating Region One (Equatorial) ...");
	local regiononeWestX = 0;
	local regiononeEastX = self.iW - 1;
	local regiononeNorthY = math.floor(self.iH * large_NorthLat);
	local regiononeSouthY = math.floor(self.iH * large_SouthLat);
	local regiononeWidth = self.iW;
	local regiononeHeight = regiononeNorthY - regiononeSouthY + 1;

	-- With all of your parameters figured out, it is time to define your argument list.
	-- This is where the rubber meets the road.
	local args = {};
	--
	args.iWaterPercent = 0;
	args.iRegionWidth = regiononeWidth;
	args.iRegionHeight = regiononeHeight;
	args.iRegionWestX = regiononeWestX;
	args.iRegionSouthY = regiononeSouthY;
	args.iRegionGrain = 2;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = iFlags;
	--args.iRegionFracXExp -- left at default
	--args.iRegionFracYExp -- left at default
	--args.iRiftGrain -- left at default
	--args.bShift -- left at default
	
	self:GenerateFractalLayer(args)


	print("Generating Region Two (Equatorial) ...");
	local regiontwoWestX = 0;
	local regiontwoEastX = self.iW - 1;
	local regiontwoNorthY = math.floor(self.iH * medium_NorthLat);
	local regiontwoSouthY = math.floor(self.iH * medium_SouthLat);
	local regiontwoWidth = self.iW;
	local regiontwoHeight = regiontwoNorthY - regiontwoSouthY + 1;

	-- With all of your parameters figured out, it is time to define your argument list.
	-- This is where the rubber meets the road.
	local args = {};
	--
	args.iWaterPercent = 0;
	args.iRegionWidth = regiontwoWidth;
	args.iRegionHeight = regiontwoHeight;
	args.iRegionWestX = regiontwoWestX;
	args.iRegionSouthY = regiontwoSouthY;
	args.iRegionGrain = 4;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = iFlags;
	--args.iRegionFracXExp -- left at default
	--args.iRegionFracYExp -- left at default
	--args.iRiftGrain -- left at default
	--args.bShift -- left at default
	
	self:GenerateFractalLayer(args)


	print("Generating Region Three (Equatorial) ...");
	local regionthreeWestX = 0;
	local regionthreeEastX = self.iW - 1;
	local regionthreeNorthY = math.floor(self.iH * small_NorthLat);
	local regionthreeSouthY = math.floor(self.iH * small_SouthLat);
	local regionthreeWidth = self.iW;
	local regionthreeHeight = regionthreeNorthY - regionthreeSouthY + 1;

	-- With all of your parameters figured out, it is time to define your argument list.
	-- This is where the rubber meets the road.
	local args = {};
	--
	args.iWaterPercent = 0;
	args.iRegionWidth = regionthreeWidth;
	args.iRegionHeight = regionthreeHeight;
	args.iRegionWestX = regionthreeWestX;
	args.iRegionSouthY = regionthreeSouthY;
	args.iRegionGrain = 5;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = iFlags;
	--args.iRegionFracXExp -- left at default
	--args.iRegionFracYExp -- left at default
	--args.iRiftGrain -- left at default
	--args.bShift -- left at default
	
	self:GenerateFractalLayer(args)


	-- Land and water are set. Now apply hills and mountains.
	local world_age = Map.GetCustomOption(1)
	if world_age == 4 then
		world_age = 1 + Map.Rand(3, "Random World Age - Lua");
	end
	local args = {world_age = world_age};
	self:ApplyTectonics(args)

	-- Plot Type generation completed. Return global plot array.
	return self.wholeworldPlotTypes
end
------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Setting Plot Types (Lua Equatorial) ...");

	local layered_world = MultilayeredFractal.Create();
	local plotsIS = layered_world:GeneratePlotsByRegion();
	
	SetPlotTypes(plotsIS);

	GenerateCoasts();
end
----------------------------------------------------------------------------------

------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain (Lua Equatorial) ...");
	
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
	print("Generating Rivers, Canyons, and Lakes. (Lua Equatorial) ...");

	local args = {minimum_percentage_of_total_land = 5};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features (Lua Equatorial) ...");

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
	local res = Map.GetCustomOption(4)
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
