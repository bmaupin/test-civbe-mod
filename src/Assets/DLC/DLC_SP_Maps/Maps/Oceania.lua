-------------------------------------------------------------------------------
--	FILE:	 Oceania.lua  (Version for BE)
--	AUTHOR:  Bob Thomas (Sirian)
--	PURPOSE: Global map script - Generates a random map with a combination
--	         of island clusters and empty ocean, but no continents.
-------------------------------------------------------------------------------
--	Copyright (c) 2013, 2014 Firaxis Games, Inc. All rights reserved.
-------------------------------------------------------------------------------

include("MapGenerator");
include("MultilayeredFractal");
include("TerrainGenerator");
include("RiverGenerator");
include("FeatureGenerator");
include("MapmakerUtilities");

-------------------------------------------------------------------------------
function GetMapScriptInfo()
	local world_age, temperature, rainfall, sea_level, resources = GetCoreMapOptions()
	return {
		Name = "TXT_KEY_MAP_OCEANIA_NAME",
		Type = "TXT_KEY_MAP_OCEANIA_TYPE",
		Description = "TXT_KEY_MAP_OCEANIA_HELP",
		IsAdvancedMap = false,
		IconIndex = 17,
		CustomOptions = {rainfall,
			{
				Name = "TXT_KEY_MAP_OPTION_RESOURCES",	-- Customizing the Resource setting to Default to Strategic Balance.
				Values = {
					"TXT_KEY_MAP_OPTION_SPARSE",
					"TXT_KEY_MAP_OPTION_STANDARD",
					"TXT_KEY_MAP_OPTION_ABUNDANT",
					"TXT_KEY_MAP_OPTION_LEGENDARY_START",
					"TXT_KEY_MAP_OPTION_STRATEGIC_BALANCE",
					"TXT_KEY_MAP_OPTION_RANDOM",
				},
				DefaultValue = 5,
				SortPriority = -95,
			},
			{
				Name = "TXT_KEY_MAP_OPTION_OCEANS",
				Values = {
					"TXT_KEY_MAP_OPTION_RANDOM",
					"TXT_KEY_MAP_OPTION_LARGE",
					"TXT_KEY_MAP_OPTION_MEDIUM",
					"TXT_KEY_MAP_OPTION_SMALL",
				},
				DefaultValue = 2,
				SortPriority = 1,
			},
		},
	}
end
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
function MultilayeredFractal:GeneratePlotsByRegion()
	-- Sirian's MultilayeredFractal controlling function.
	-- You -MUST- customize this function for each script using MultilayeredFractal.
	--
	-- This implementation is specific to Oceania.
	local iW, iH = Map.GetGridSize();
	-- Initiate plot table, fill all data slots with type PLOT_OCEAN
	table.fill(self.wholeworldPlotTypes, PlotTypes.PLOT_OCEAN, iW * iH);


	-- Generate Large Islands		
	local args = {};
	args.iWaterPercent = 86;
	args.iRegionWidth = math.ceil(iW);
	args.iRegionHeight = math.ceil(iH);
	args.iRegionWestX = math.floor(0);
	args.iRegionSouthY = math.floor(0);
	args.iRegionGrain = 3;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = self.iHorzFlags;
	args.iRegionFracXExp = 7;
	args.iRegionFracYExp = 6;
	--args.iRiftGrain = 0;
	--args.bShift
	
	self:GenerateFractalLayerWithoutHills(args)


	-- Generate Tiny Islands	
	local args = {};
	args.iWaterPercent = 61;
	args.iRegionWidth = math.ceil(iW);
	args.iRegionHeight = math.ceil(iH);
	args.iRegionWestX = math.floor(0);
	args.iRegionSouthY = math.floor(0);
	args.iRegionGrain = 4;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = self.iHorzFlags;
	args.iRegionFracXExp = 7;
	args.iRegionFracYExp = 6;
	--args.iRiftGrain = Map.Rand(3, "Rift Grain - Mediterranean LUA");
	--args.bShift
	
	self:GenerateFractalLayerWithoutHills(args)
	

	-- Generate Patches of Empty Ocean
	local userInputOceans = Map.GetCustomOption(3)
	if userInputOceans == 1 then -- Random
		userInputOceans = 2 + Map.Rand(3, "Random Oceans Grain - Lua");
	end
			
	local args = {};
	args.iWaterPercent = 60;
	args.iRegionWidth = math.ceil(iW);
	args.iRegionHeight = math.ceil(iH);
	args.iRegionWestX = math.floor(0);
	args.iRegionSouthY = math.floor(0);
	args.iRegionGrain = userInputOceans;
	args.iRegionHillsGrain = 4;
	args.iRegionPlotFlags = self.iHorzFlags;
	args.iRegionFracXExp = 7;
	args.iRegionFracYExp = 6;
	args.iRiftGrain = -1;
	--args.bShift;
	
	self:GenerateWaterLayer(args)


	-- Ensure a strip of unbroken ocean at top and bottom of map.
	for x = 0, iW - 1 do
		local i_bottom = x + 1;
		local i_top = (iH - 1) * iW + x + 1;
		self.wholeworldPlotTypes[i_bottom] = PlotTypes.PLOT_OCEAN;
		self.wholeworldPlotTypes[i_top] = PlotTypes.PLOT_OCEAN;
	end
		
	-- Land and water are set. Apply hills and mountains.
	local args = {
		extra_mountains = 4,
		adjust_plates = 1.3,
		}
	self:ApplyTectonics(args)

	-- Plot Type generation completed. Return global plot array.
	return self.wholeworldPlotTypes
	
end
------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Setting Plot Types (Lua Oceania) ...");

	local layered_world = MultilayeredFractal.Create();
	local plotsOceania = layered_world:GeneratePlotsByRegion();
	
	SetPlotTypes(plotsOceania);

	GenerateCoasts();
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function TerrainGenerator:GetLatitudeAtPlot(iX, iY)
	-- All latitudes fixed to be Temperate region
	
	return 0.35;
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain (Lua Oceania) ...");
	
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
function RiverGenerator:GetCapsForMethodC()
	-- Set up caps for number of formations and plots based on world size.
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {2, 4, 2, 0},
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {3, 6, 2, 0},
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {5, 11, 2, 1},
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {6, 16, 2, 2},
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {7, 25, 3, 2},
		--[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {9, 39, 3, 3},
		};
	local caps_list = worldsizes[Map.GetWorldSize()];
	local max_lines, max_plots, base_length, extension_range = caps_list[1], caps_list[2], caps_list[3], caps_list[4];
	return max_lines, max_plots, base_length, extension_range;
end
------------------------------------------------------------------------------
function AddRivers()
	print("Generating Rivers, Canyons, and Lakes. (Lua Oceania) ...");

	local args = {minimum_percentage_of_total_land = 2};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function FeatureGenerator:AddIceAtPlot(plot, iX, iY, lat)
	-- Do nothing. No ice to be placed.
end
------------------------------------------------------------------------------
function FeatureGenerator:AddAtolls()
	-- Adds the new feature Atolls in to the game, for oceanic maps.
	local iW, iH = Map.GetGridSize()
	
	-- World has oceans, proceed with adding Atolls.
	local iNumAtollsPlaced = 0;
	local direction_types = {
		DirectionTypes.DIRECTION_NORTHEAST,
		DirectionTypes.DIRECTION_EAST,
		DirectionTypes.DIRECTION_SOUTHEAST,
		DirectionTypes.DIRECTION_SOUTHWEST,
		DirectionTypes.DIRECTION_WEST,
		DirectionTypes.DIRECTION_NORTHWEST
	};
	local worldsizes = {
		[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = 8,
		[GameInfo.Worlds.WORLDSIZE_TINY.ID] = 15,
		[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = 20,
		[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = 25,
		[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = 30,
		--[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = 40,
	};
	local atoll_target = worldsizes[Map.GetWorldSize()];
	local atoll_number = atoll_target + Map.Rand(atoll_target, "Number of Atolls to place - LUA");
	local feature_atoll;
	for thisFeature in GameInfo.Features() do
		if thisFeature.Type == "FEATURE_ATOLL" then
			feature_atoll = thisFeature.ID;
		end
	end

	-- Generate candidate plot lists.
	local temp_one_tile_island_list, temp_alpha_list, temp_beta_list = {}, {}, {};
	local temp_gamma_list, temp_delta_list, temp_epsilon_list = {}, {}, {};
	for y = 0, iH - 1 do
		for x = 0, iW - 1 do
			local i = y * iW + x + 1; -- Lua tables/lists/arrays start at 1, not 0 like C++ or Python
			local plot = Map.GetPlot(x, y)
			local plotType = plot:GetPlotType()
			if plotType == PlotTypes.PLOT_OCEAN then
				local featureType = plot:GetFeatureType()
				if featureType ~= FeatureTypes.FEATURE_ICE then
					if not plot:IsLake() then
						local terrainType = plot:GetTerrainType()
						if terrainType == TerrainTypes.TERRAIN_COAST then
							if plot:IsAdjacentToLand() then
								-- Check all adjacent plots and identify adjacent landmasses.
								local iNumLandAdjacent, biggest_adj_area = 0, 0;
								local bPlotValid = true;
								for loop, direction in ipairs(direction_types) do
									local adjPlot = Map.PlotDirection(x, y, direction)
									if adjPlot ~= nil then
										local adjPlotType = adjPlot:GetPlotType()
										if adjPlotType ~= PlotTypes.PLOT_OCEAN then -- Found land.
											iNumLandAdjacent = iNumLandAdjacent + 1;
											-- Avoid being adjacent to tundra, snow, or feature ice!
											local adjTerrainType = adjPlot:GetTerrainType()
											if adjTerrainType == TerrainTypes.TERRAIN_TUNDRA or adjTerrainType == TerrainTypes.TERRAIN_SNOW then
												bPlotValid = false;
											end
											local adjFeatureType = adjPlot:GetFeatureType()
											if adjFeatureType == FeatureTypes.FEATURE_ICE then
												bPlotValid = false;
											end
											if adjPlotType == PlotTypes.PLOT_LAND or adjPlotType == PlotTypes.PLOT_HILLS then
												local iArea = adjPlot:GetArea()
												local adjArea = Map.GetArea(iArea)
												local iNumAreaPlots = adjArea:GetNumTiles()
												if iNumAreaPlots > biggest_adj_area then
													biggest_adj_area = iNumAreaPlots;
												end
											end
										end
									end
								end
								-- Only plots with a single land plot adjacent can be eligible.
								if iNumLandAdjacent == 1 and bPlotValid == true then
									if biggest_adj_area >= 76 then
										-- discard this site
									elseif biggest_adj_area >= 41 then
										table.insert(temp_epsilon_list, i);
									elseif biggest_adj_area >= 17 then
										table.insert(temp_delta_list, i);
									elseif biggest_adj_area >= 8 then
										table.insert(temp_gamma_list, i);
									elseif biggest_adj_area >= 3 then
										table.insert(temp_beta_list, i);
									elseif biggest_adj_area >= 1 then
										table.insert(temp_alpha_list, i);
									--else -- Unexpected result
										--print("** Area Plot Count =", biggest_adj_area);
									end
								end
							end
						end
					end
				end
			end
		end
	end
	local alpha_list = GetShuffledCopyOfTable(temp_alpha_list)
	local beta_list = GetShuffledCopyOfTable(temp_beta_list)
	local gamma_list = GetShuffledCopyOfTable(temp_gamma_list)
	local delta_list = GetShuffledCopyOfTable(temp_delta_list)
	local epsilon_list = GetShuffledCopyOfTable(temp_epsilon_list)

	-- Determine maximum number able to be placed, per candidate category.
	local max_alpha = math.ceil(table.maxn(alpha_list) / 4);
	local max_beta = math.ceil(table.maxn(beta_list) / 5);
	local max_gamma = math.ceil(table.maxn(gamma_list) / 4);
	local max_delta = math.ceil(table.maxn(delta_list) / 3);
	local max_epsilon = math.ceil(table.maxn(epsilon_list) / 4);
	
	-- Place Atolls.
	local plotIndex;
	local i_alpha, i_beta, i_gamma, i_delta, i_epsilon = 1, 1, 1, 1, 1;
	for loop = 1, atoll_number do
		local able_to_proceed = true;
		local diceroll = 1 + Map.Rand(100, "Atoll Placement Type - LUA");
		if diceroll <= 40 and max_alpha > 0 then
			plotIndex = alpha_list[i_alpha];
			i_alpha = i_alpha + 1;
			max_alpha = max_alpha - 1;
			--print("- Alpha site chosen");
		elseif diceroll <= 65 then
			if max_beta > 0 then
				plotIndex = beta_list[i_beta];
				i_beta = i_beta + 1;
				max_beta = max_beta - 1;
				--print("- Beta site chosen");
			elseif max_alpha > 0 then
				plotIndex = alpha_list[i_alpha];
				i_alpha = i_alpha + 1;
				max_alpha = max_alpha - 1;
				--print("- Alpha site chosen");
			else -- Unable to place this Atoll
				--print("-"); print("* Atoll #", loop, "was unable to be placed.");
				able_to_proceed = false;
			end
		elseif diceroll <= 80 then
			if max_gamma > 0 then
				plotIndex = gamma_list[i_gamma];
				i_gamma = i_gamma + 1;
				max_gamma = max_gamma - 1;
				--print("- Gamma site chosen");
			elseif max_beta > 0 then
				plotIndex = beta_list[i_beta];
				i_beta = i_beta + 1;
				max_beta = max_beta - 1;
				--print("- Beta site chosen");
			elseif max_alpha > 0 then
				plotIndex = alpha_list[i_alpha];
				i_alpha = i_alpha + 1;
				max_alpha = max_alpha - 1;
				--print("- Alpha site chosen");
			else -- Unable to place this Atoll
				--print("-"); print("* Atoll #", loop, "was unable to be placed.");
				able_to_proceed = false;
			end
		elseif diceroll <= 90 then
			if max_delta > 0 then
				plotIndex = delta_list[i_delta];
				i_delta = i_delta + 1;
				max_delta = max_delta - 1;
				--print("- Delta site chosen");
			elseif max_gamma > 0 then
				plotIndex = gamma_list[i_gamma];
				i_gamma = i_gamma + 1;
				max_gamma = max_gamma - 1;
				--print("- Gamma site chosen");
			elseif max_beta > 0 then
				plotIndex = beta_list[i_beta];
				i_beta = i_beta + 1;
				max_beta = max_beta - 1;
				--print("- Beta site chosen");
			elseif max_alpha > 0 then
				plotIndex = alpha_list[i_alpha];
				i_alpha = i_alpha + 1;
				max_alpha = max_alpha - 1;
				--print("- Alpha site chosen");
			else -- Unable to place this Atoll
				--print("-"); print("* Atoll #", loop, "was unable to be placed.");
				able_to_proceed = false;
			end
		else
			if max_epsilon > 0 then
				plotIndex = epsilon_list[i_epsilon];
				i_epsilon = i_epsilon + 1;
				max_epsilon = max_epsilon - 1;
				--print("- Epsilon site chosen");
			elseif max_delta > 0 then
				plotIndex = delta_list[i_delta];
				i_delta = i_delta + 1;
				max_delta = max_delta - 1;
				--print("- Delta site chosen");
			elseif max_gamma > 0 then
				plotIndex = gamma_list[i_gamma];
				i_gamma = i_gamma + 1;
				max_gamma = max_gamma - 1;
				--print("- Gamma site chosen");
			elseif max_beta > 0 then
				plotIndex = beta_list[i_beta];
				--print("- Beta site chosen");
				i_beta = i_beta + 1;
				max_beta = max_beta - 1;
			elseif max_alpha > 0 then
				plotIndex = alpha_list[i_alpha];
				i_alpha = i_alpha + 1;
				max_alpha = max_alpha - 1;
				--print("- Alpha site chosen");
			else -- Unable to place this Atoll
				--print("-"); print("* Atoll #", loop, "was unable to be placed.");
				able_to_proceed = false;
			end
		end
		if able_to_proceed and plotIndex ~= nil then
			local x = (plotIndex - 1) % iW;
			local y = (plotIndex - x - 1) / iW;
			local plot = Map.GetPlot(x, y)
			plot:SetFeatureType(feature_atoll, -1);
			iNumAtollsPlaced = iNumAtollsPlaced + 1;
		--else
			--print("** ERROR ** Atoll unable to be placed and/or chosen Plot Index was nil.");
		end
	end
	
	--[[ Debug report
	print("-"); print("- Atoll Target Number: ", atoll_number);
	print("- Number of Atolls placed: ", iNumAtollsPlaced); print("-");
	print("- Atolls placed in Alpha locations: ", i_alpha - 1);
	print("- Atolls placed in Beta locations: ", i_beta - 1);
	print("- Atolls placed in Gamma locations: ", i_gamma - 1);
	print("- Atolls placed in Delta locations: ", i_delta - 1);
	print("- Atolls placed in Epsilon locations: ", i_epsilon - 1);
	]]--
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features (Lua Oceania) ...");

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
		resources = res,
		method = 5,
		};
	start_plot_database:GenerateRegions(args)

	print("Choosing start locations for civilizations.");
	-- Forcing starts along the ocean.
	-- Lowering start position minimum eligibility thresholds.
	local args = {
	mustBeCoast = true,
	};
	start_plot_database:ChooseLocations(args)
	
	print("Normalizing start locations and assigning them to Players.");
	start_plot_database:BalanceAndAssign()

	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()
	
	-- tell the AI that we should treat this as a naval + offshore expansion map
	Map.ChangeAIMapHint(1+4);

end
------------------------------------------------------------------------------
