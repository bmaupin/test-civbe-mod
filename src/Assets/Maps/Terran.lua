------------------------------------------------------------------------------
--	FILE:	 Terran.lua
--	AUTHOR:  Bob Thomas
--	PURPOSE: Global map script - Produces widely varied continents.
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
		Name = "TXT_KEY_MAP_TERRAN",
		Type = "TXT_KEY_MAP_TERRAN",
		Description = "TXT_KEY_MAP_TERRAN_HELP",
		IsAdvancedMap = 0,
		IconIndex = 11,
		SortIndex = 1,
		CustomOptions = {world_age, temperature, rainfall, sea_level, resources},
	};
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
------------------------------------------------------------------------------
ContinentsFractalWorld = {};
------------------------------------------------------------------------------
function ContinentsFractalWorld.Create(fracXExp, fracYExp)
	local gridWidth, gridHeight = Map.GetGridSize();
	
	local data = {
		InitFractal = FractalWorld.InitFractal,
		ShiftPlotTypes = FractalWorld.ShiftPlotTypes,
		ShiftPlotTypesBy = FractalWorld.ShiftPlotTypesBy,
		DetermineXShift = FractalWorld.DetermineXShift,
		DetermineYShift = FractalWorld.DetermineYShift,
		GenerateCenterRift = FractalWorld.GenerateCenterRift,
		GeneratePlotTypes = ContinentsFractalWorld.GeneratePlotTypes,	-- Custom method

		-- Four methods have been crafted to add canyons to the maps. Method D occurs with plot generation. Methods A, B and C come with rivers.
		-- Method A: Fault lines where plates are pulling apart. Opposite of mountain range creation. These large canyons may be segmented.
		-- Method B: Weak spots in the planet's crust. Crust collapses in a pocket area due to high magma activity in the mantle. Creates isolated canyons.
		-- Method C: Plate collision creates mountains, then (geologically) rapid plate separation also creates a parallel canyon.
		-- Method D: Plate separation creates a canyon at fault line, then later plate collision closes most of the canyon and also creates new mountains.
		PlotCanBeCanyon = ContinentsFractalWorld.PlotCanBeCanyon,
		HexAdjustment = FractalWorld.HexAdjustment,
		GenerateCanyonPlotCandidateList = ContinentsFractalWorld.GenerateCanyonPlotCandidateList,
		MethodD = ContinentsFractalWorld.MethodD,
		
		iFlags = Map.GetFractalFlags(),
		
		fracXExp = fracXExp,
		fracYExp = fracYExp,
		
		iNumPlotsX = gridWidth,
		iNumPlotsY = gridHeight,
		plotTypes = table.fill(PlotTypes.PLOT_OCEAN, gridWidth * gridHeight),

		-- Canyon variables
		canyon_plot_candidate_list = table.fill(false, gridWidth * gridHeight),
		mountain_count = 0,
		extra_mountains = 0,
		adjustment = 0,
		};
		
	return data;
end	
------------------------------------------------------------------------------
function ContinentsFractalWorld:PlotCanBeCanyon(plot)
	if plot:IsWater() or plot:IsMountain() or plot:IsCanyon() then
		return false
	else
		return true
	end
end
------------------------------------------------------------------------------
function ContinentsFractalWorld:GenerateCanyonPlotCandidateList()
	for x = 0, self.iNumPlotsX - 1 do
		for y = 1, self.iNumPlotsY - 2 do -- Never putting a canyon in top or bottom row of map.
			local plot = Map.GetPlot(x, y);
			local i = y * self.iNumPlotsX + x + 1;
			if plot:IsWater() then
				self.canyon_plot_candidate_list[i] = false;
			elseif plot:IsMountain() then
				self.mountain_count = self.mountain_count + 1;
				self.canyon_plot_candidate_list[i] = false;
			else
				self.canyon_plot_candidate_list[i] = true;
			end
		end
	end
end
------------------------------------------------------------------------------
function ContinentsFractalWorld:MethodD()
	-- This method seeks to simulate areas where plates pulled apart first, then slammed back 
	-- together, first creating fault line canyons, then smashing most of them and making mountains.
	--
	-- The actual method is to identify hills plots of a specific fractal elevation, in
	-- relationship to mountain generation, and turn some of these and one or two adjacent 
	-- plots into canyons, always two or three plots in size. The net effect should be some
	-- cases of two or three plot canyons in the shadow of mountain ranges.
	print("Mountain count = ", self.mountain_count);
	local max_type_d_canyon_plots = math.ceil(self.mountain_count / 3);
	print("Max 'Type D' canyon plots = ", max_type_d_canyon_plots)
	local canyon_seed = 92 - self.extra_mountains - self.adjustment;
	local HeightTypeD = self.mountainsFrac:GetHeight(canyon_seed);
	local type_d_seed_list = {};
	local num_seed_plots = 0;
	local canyons_placed = 0;
	local firstRingYIsEven = {{0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}};
	local firstRingYIsOdd = {{1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, 0}, {0, 1}};
	
	-- Generate seed list.
	for x = 0, self.iNumPlotsX - 1 do
		for y = 0, self.iNumPlotsY - 1 do
			local plot = Map.GetPlot(x, y);
			if self:PlotCanBeCanyon(plot) then
				local canyonVal = self.mountainsFrac:GetHeight(x, y);
				if canyonVal == HeightTypeD then
					table.insert(type_d_seed_list, {x, y});
					num_seed_plots = num_seed_plots + 1;
				end
			end
		end
	end
	local shuffled_seed_list;
	
	-- Apply Method D.
	if num_seed_plots > 0 then
		shuffled_seed_list = GetShuffledCopyOfTable(type_d_seed_list);
		for loop = 1, num_seed_plots do
			local x, y = shuffled_seed_list[loop][1], shuffled_seed_list[loop][2];
			local plot = Map.GetPlot(x, y)
			plot:SetPlotType(PlotTypes.PLOT_CANYON, false, false);
			canyons_placed = canyons_placed + 1;
			local i = y * self.iNumPlotsX + x + 1;
			self.canyon_plot_candidate_list[i] = false;
			print("Placing Canyon center via Method D at plot: ", x, y);
			
			-- Try to add adjacent canyon plots.
			local rand = Map.Rand(5, "Extra canyon plots - Lua FractalWorld");
			local num_extra = 1;
			if rand > 1 then
				num_extra = 2;
			end
			print("Attempting to add ", num_extra, " wing plots to this canyon.")
			local wing_plot_candidate_list = {};
			local randomized_first_ring_adjustments = nil;
			local isEvenY = true;
			if y / 2 > math.floor(y / 2) then
				isEvenY = false;
			end
			if isEvenY then
				randomized_first_ring_adjustments = GetShuffledCopyOfTable(firstRingYIsEven);
			else
				randomized_first_ring_adjustments = GetShuffledCopyOfTable(firstRingYIsOdd);
			end
			for attempt = 1, 6 do
				local plot_adjustments = randomized_first_ring_adjustments[attempt];
				local searchX, searchY = self:HexAdjustment(x, y, plot_adjustments)
				local search_i = searchY * self.iNumPlotsX + searchX + 1;
				-- Make sure the search plot is not off the grid.
				if search_i > 0 and search_i < self.iNumPlotsX * self.iNumPlotsY then -- OK, it's in play.
					if self.canyon_plot_candidate_list[search_i] == true then
						table.insert(wing_plot_candidate_list, {searchX, searchY});
					end
				end
			end
			local iNumWingCandidates = table.maxn(wing_plot_candidate_list);
			if iNumWingCandidates >= 1 then
				local iNumWings = math.min(num_extra, iNumWingCandidates)
				-- Create Canyon "wing" plots.
				for wing_loop = 1, iNumWings do
					local wing_x, wing_y = wing_plot_candidate_list[wing_loop][1], wing_plot_candidate_list[wing_loop][2];
					local wing_plot = Map.GetPlot(wing_x, wing_y)
					wing_plot:SetPlotType(PlotTypes.PLOT_CANYON, false, false);
					canyons_placed = canyons_placed + 1;
					local wing_i = wing_y * self.iNumPlotsX + wing_x + 1;
					self.canyon_plot_candidate_list[wing_i] = false;
					print("Placing Canyon wing via Method D at plot: ", wing_x, wing_y);
				end
			else
				print("No wings available for canyon at ", x, y);
			end

			if canyons_placed >= max_type_d_canyon_plots then
				print(canyons_placed, "canyon plots placed using Method D.");
				break
			elseif loop == num_seed_plots then
				print(canyons_placed, "canyon plots placed using Method D. Less than target: ran out of candidates.");
			end
		end
	else
		print("No eligible plots for Method D of Canyon generation.")
	end
end
------------------------------------------------------------------------------
function ContinentsFractalWorld:GeneratePlotTypes(args)
	if(args == nil) then args = {}; end
	
	local sea_level_low = 63;
	local sea_level_normal = 67;   -- Sea levels in BE have been lowered by 4% to 5% overall vs Civ5, to make room for Canyons and Wild Areas.
	local sea_level_high = 71;
	local world_age_old = 2;
	local world_age_normal = 3;
	local world_age_new = 5;
	--
	local extra_mountains = 0;
	local grain_amount = 3;
	local adjust_plates = 1.0;
	local shift_plot_types = true;
	local tectonic_islands = false;
	local hills_ridge_flags = self.iFlags;
	local peaks_ridge_flags = self.iFlags;
	local has_center_rift = true;
	
	local sea_level = Map.GetCustomOption(4)
	if sea_level == 4 then
		sea_level = 1 + Map.Rand(3, "Random Sea Level - Lua");
	end
	local world_age = Map.GetCustomOption(1)
	if world_age == 4 then
		world_age = 1 + Map.Rand(3, "Random World Age - Lua");
	end

	-- Set Sea Level according to user selection.
	local water_percent = sea_level_normal;
	if sea_level == 1 then -- Low Sea Level
		water_percent = sea_level_low
	elseif sea_level == 3 then -- High Sea Level
		water_percent = sea_level_high
	else -- Normal Sea Level
	end

	-- Set values for hills and mountains according to World Age chosen by user.
	local adjustment = world_age_normal;
	if world_age == 3 then -- 5 Billion Years
		adjustment = world_age_old;
		adjust_plates = adjust_plates * 0.75;
	elseif world_age == 1 then -- 3 Billion Years
		adjustment = world_age_new;
		adjust_plates = adjust_plates * 1.5;
	else -- 4 Billion Years
	end
	-- Apply adjustment to hills and peaks settings.
	local hillsBottom1 = 28 - adjustment;
	local hillsTop1 = 28 + adjustment;
	local hillsBottom2 = 72 - adjustment;
	local hillsTop2 = 72 + adjustment;
	local hillsClumps = 1 + adjustment;
	local hillsNearMountains = 91 - (adjustment * 2) - extra_mountains;
	local mountains = 97 - adjustment - extra_mountains;

	-- Store data for canyon generation - Bob Thomas, Feb 2014
	self.adjustment = adjustment;
	self.extra_mountains = extra_mountains;

	-- Hills and Mountains handled differently according to map size
	local WorldSizeTypes = {};
	for row in GameInfo.Worlds() do
		WorldSizeTypes[row.Type] = row.ID;
	end
	local sizekey = Map.GetWorldSize();
	-- Fractal Grains
	local sizevalues = {
		[WorldSizeTypes.WORLDSIZE_DUEL]     = 3,
		[WorldSizeTypes.WORLDSIZE_TINY]     = 3,
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 4,
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 4,
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 5,
		--[WorldSizeTypes.WORLDSIZE_HUGE]		= 5
	};
	local grain = sizevalues[sizekey] or 3;
	-- Tectonics Plate Counts
	local platevalues = {
		[WorldSizeTypes.WORLDSIZE_DUEL]		= 6,
		[WorldSizeTypes.WORLDSIZE_TINY]     = 9,
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 12,
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 18,
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 24,
		--[WorldSizeTypes.WORLDSIZE_HUGE]     = 30
	};
	local numPlates = platevalues[sizekey] or 5;
	-- Add in any plate count modifications passed in from the map script.
	numPlates = numPlates * adjust_plates;

	-- Generate continental fractal layer and examine the largest landmass. Reject
	-- the result until the largest landmass occupies 58% or less of the total land.
	local done = false;
	local iAttempts = 0;
	local iWaterThreshold, biggest_area, iNumTotalLandTiles, iNumBiggestAreaTiles, iBiggestID;
	while done == false do
		local grain_dice = Map.Rand(7, "Continental Grain roll - LUA Continents");
		if grain_dice < 4 then
			grain_dice = 2;
		else
			grain_dice = 1;
		end
		local rift_dice = Map.Rand(3, "Rift Grain roll - LUA Continents");
		if rift_dice < 1 then
			rift_dice = -1;
		end
		
		self.continentsFrac = nil;
		self:InitFractal{continent_grain = grain_dice, rift_grain = rift_dice};
		iWaterThreshold = self.continentsFrac:GetHeight(water_percent);
		
		iNumTotalLandTiles = 0;
		for x = 0, self.iNumPlotsX - 1 do
			for y = 0, self.iNumPlotsY - 1 do
				local i = y * self.iNumPlotsX + x;
				local val = self.continentsFrac:GetHeight(x, y);
				if(val <= iWaterThreshold) then
					self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
				else
					self.plotTypes[i] = PlotTypes.PLOT_LAND;
					iNumTotalLandTiles = iNumTotalLandTiles + 1;
				end
			end
		end

		self:ShiftPlotTypes();
		self:GenerateCenterRift()

		SetPlotTypes(self.plotTypes);
		Map.RecalculateAreas();
		
		biggest_area = Map.FindBiggestArea(false);
		iNumBiggestAreaTiles = biggest_area:GetNumTiles();
		-- Now test the biggest landmass to see if it is large enough.
		if iNumBiggestAreaTiles <= iNumTotalLandTiles * 0.58 then
			done = true;
			iBiggestID = biggest_area:GetID();
		end
		iAttempts = iAttempts + 1;
		
		--[[ Printout for debug use only
		print("-"); print("--- Continents landmass generation, Attempt#", iAttempts, "---");
		print("- This attempt successful: ", done);
		print("- Total Land Plots in world:", iNumTotalLandTiles);
		print("- Land Plots belonging to biggest landmass:", iNumBiggestAreaTiles);
		print("- Percentage of land belonging to biggest: ", 100 * iNumBiggestAreaTiles / iNumTotalLandTiles);
		print("- Continent Grain for this attempt: ", grain_dice);
		print("- Rift Grain for this attempt: ", rift_dice);
		print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
		print(".");
		]]--
	end
	
	-- Generate fractals to govern hills and mountains
	self.hillsFrac = Fractal.Create(self.iNumPlotsX, self.iNumPlotsY, grain, self.iFlags, self.fracXExp, self.fracYExp);
	self.mountainsFrac = Fractal.Create(self.iNumPlotsX, self.iNumPlotsY, grain, self.iFlags, self.fracXExp, self.fracYExp);
	self.hillsFrac:BuildRidges(numPlates, hills_ridge_flags, 1, 2);
	self.mountainsFrac:BuildRidges((numPlates * 2) / 3, peaks_ridge_flags, 6, 1);
	-- Get height values
	local iHillsBottom1 = self.hillsFrac:GetHeight(hillsBottom1);
	local iHillsTop1 = self.hillsFrac:GetHeight(hillsTop1);
	local iHillsBottom2 = self.hillsFrac:GetHeight(hillsBottom2);
	local iHillsTop2 = self.hillsFrac:GetHeight(hillsTop2);
	local iHillsClumps = self.mountainsFrac:GetHeight(hillsClumps);
	local iHillsNearMountains = self.mountainsFrac:GetHeight(hillsNearMountains);
	local iMountainThreshold = self.mountainsFrac:GetHeight(mountains);
	local iPassThreshold = self.hillsFrac:GetHeight(hillsNearMountains);
	
	-- Set Hills and Mountains
	for x = 0, self.iNumPlotsX - 1 do
		for y = 0, self.iNumPlotsY - 1 do
			local plot = Map.GetPlot(x, y);
			local mountainVal = self.mountainsFrac:GetHeight(x, y);
			local hillVal = self.hillsFrac:GetHeight(x, y);
	
			if plot:GetPlotType() ~= PlotTypes.PLOT_OCEAN then
				if (mountainVal >= iMountainThreshold) then
					if (hillVal >= iPassThreshold) then -- Mountain Pass though the ridgeline
						plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
					else -- Mountain
						plot:SetPlotType(PlotTypes.PLOT_MOUNTAIN, false, false);
					end
				elseif (mountainVal >= iHillsNearMountains) then
					plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
				elseif ((hillVal >= iHillsBottom1 and hillVal <= iHillsTop1) or (hillVal >= iHillsBottom2 and hillVal <= iHillsTop2)) then
					plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false);
				end
			end
		end
	end
	
	-- Canyon generation handled independent from other plot generation, for easier customization.
	-- Individual components of canyon generation can be overridden without having to override the entire plot generator.
	-- Method D is called here. Methods A, B and C are called in the RiverGenerator.
	self:GenerateCanyonPlotCandidateList()
	self:MethodD()
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function GeneratePlotTypes()
	-- Customized plot generation to ensure avoiding "near Pangaea" conditions.
	print("Generating Plot Types (Lua Continents) ...");
	
	local fractal_world = ContinentsFractalWorld.Create();
	fractal_world:GeneratePlotTypes();
	CreateSmallIslands(100);
	GenerateCoasts();
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain (Lua Continents) ...");
	
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
function AddRivers()
	print("Generating Rivers, Canyons, and Lakes. (Lua Continents) ...");

	local args = {};
	local rivergen = RiverGenerator.Create(args);
	
	rivergen:Generate();
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features (Lua Continents) ...");

	-- Get Rainfall setting input by user.
	local rain = Map.GetCustomOption(3)
	if rain == 4 then
		rain = 1 + Map.Rand(3, "Random Rainfall - Lua");
	end
	
	local args = {rainfall = rain};
	local featuregen = FeatureGenerator.Create(args);

	-- False parameter removes mountains from coastlines.
	featuregen:AddFeatures(false);
end
------------------------------------------------------------------------------

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
	start_plot_database:ChooseLocations()
	
	print("Normalizing start locations and assigning them to Players.");
	start_plot_database:BalanceAndAssign()

	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()
end
------------------------------------------------------------------------------
