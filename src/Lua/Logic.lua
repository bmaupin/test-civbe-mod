-- Get teams containing only players that have ever been alive, are not aliens, and are not minor civs.
local function GetActiveNonAlienTeams()
    local list = {};
    local seen = {};

    -- I'm not completely sure IsAlien() actually works, but by limiting to max major civs
    -- we should be safe and this is what the game code does
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local player = Players[i];
        if player and player:IsEverAlive() and not player:IsAlien() and not player:IsMinorCiv() then
            local teamID = player:GetTeam();
            if teamID ~= -1 and not seen[teamID] then
                local team = Teams[teamID];
                list[teamID] = team;
                seen[teamID] = true;
            end
        end
    end

    return list;
end
local activeTeams = GetActiveNonAlienTeams();

-- Prevent early war declarations until a team has at least one affinity-specific unit tech
local WAR_UNLOCKED = false;
local function IsWarUnlocked()
    if WAR_UNLOCKED then
        return true;
    end

	local AFFINITY_UNIT_TECHS = {
		GameInfo.Technologies["TECH_ALIEN_ADAPTATION"].ID,
		GameInfo.Technologies["TECH_ALIEN_DOMESTICATION"].ID,
		GameInfo.Technologies["TECH_ALIEN_EVOLUTION"].ID,
		GameInfo.Technologies["TECH_AUTOGYROS"].ID,
		GameInfo.Technologies["TECH_DESIGNER_LIFEFORMS"].ID,
		GameInfo.Technologies["TECH_MOBILE_LEV"].ID,
		GameInfo.Technologies["TECH_NEURAL_UPLOADING"].ID,
		GameInfo.Technologies["TECH_SERVOMACHINERY"].ID,
		GameInfo.Technologies["TECH_SURROGACY"].ID,
		GameInfo.Technologies["TECH_SYNTHETIC_THOUGHT"].ID,
		GameInfo.Technologies["TECH_TACTICAL_LEV"].ID,
		GameInfo.Technologies["TECH_TACTICAL_ROBOTICS"].ID,
	};

    local function TeamHasAffinityUnlock(teamID)
        local team = activeTeams[teamID];

        for _, techID in ipairs(AFFINITY_UNIT_TECHS) do
            if team:IsHasTech(techID) then
                return true;
            end
        end

        return false;
    end

	-- Verify the unlock status for all teams
    for teamID, _team in pairs(activeTeams) do
        if not TeamHasAffinityUnlock(teamID) then
            -- At least one team is still missing an unlock
            return false;
        end
    end

    -- All teams have at least one affinity unlock — unlock war
    print("(Robots) WAR DECLARATIONS ENABLED: All teams have an affinity unit tech.");
	WAR_UNLOCKED = true;

	return true;
end

local function CheckWarUnlock(playerID)
    -- Only run the check once per turn
    if playerID ~= 0 then
        return;
    end

    if IsWarUnlocked() then
        print("(Robots) Removing global permanent peace lock.");
        for teamID, team in pairs(activeTeams) do
            for otherTeamID, _otherTeam in pairs(activeTeams) do
                if teamID ~= otherTeamID then
                    team:SetPermanentWarPeace(otherTeamID, false);
                end
            end
        end
    end
end
GameEvents.PlayerDoTurn.Add(CheckWarUnlock);

local function PossiblyForcePeace(teamA, teamB)
    if not IsWarUnlocked() then
        print("(Robots) Cancelling war between", teamA, "and", teamB);
        Teams[teamA]:MakePeace(teamB);
    end
end
GameEvents.TeamsDeclaredWar.Add(PossiblyForcePeace);

local function InitialisePermanentPeace()
    for teamID, team in pairs(activeTeams) do
        for otherTeamID, _otherTeam in pairs(activeTeams) do
            if teamID ~= otherTeamID then
                team:SetPermanentWarPeace(otherTeamID, true);
            end
        end
    end

    print("(Robots) Global permanent peace lock applied.");
end
-- Run this once at the start of the game
Events.SequenceGameInitComplete.Add(InitialisePermanentPeace);

-- Uncomment for autoplay until war is unlocked
-- local function AutoPlay()
--     print("(Robots) AutoPlay()");
--     -- First parameter is number of turns to autoplay, second is player to return control to (or -1 for none)
--     Game.SetAIAutoPlay(400, 0);
-- end
-- -- Run this once at the start of the game
-- Events.SequenceGameInitComplete.Add(AutoPlay);

-- -- -- The game may stop autoplay in certain situations (e.g. a unit was disbanded), so reenable if needed
-- -- local function CheckAutoPlay(playerID)
-- --     -- Only run the check once per turn by restricting to player 0 (or any single player)
-- --     if playerID ~= 0 then
-- --         return;
-- --     end

-- --     if Game.GetAIAutoPlay() == 0 then
-- --         print("(Robots) Re-enabling AutoPlay()");
-- --         Game.SetAIAutoPlay(400 - Game.GetGameTurn(), 0);
-- --     end
-- -- end
-- -- GameEvents.PlayerDoTurn.Add(CheckAutoPlay);


-- local function CheckAutoPlay(playerID)
--     -- Only run the check once per turn by restricting to player 0 (or any single player)
--     if playerID ~= 0 then
--         return;
--     end

--     if IsWarUnlocked() then
--         if Game.GetAIAutoPlay() > 0 then
--             print("(Robots) WAR DECLARATIONS ENABLED: All teams have an affinity unit tech.");
--             print("(Robots) Stopping autoplay on turn " .. Game.GetGameTurn() .. "!");
--             Game.SetAIAutoPlay(1, 0);
--         end
--         return;
--     end

--     -- -- TODO: debugging
--     -- for teamID, team in pairs(activeTeams) do
--     --     for otherTeamID, otherTeam in pairs(activeTeams) do
--     --         if teamID ~= otherTeamID then
--     --             local isPermanentWarPeace = team:IsPermanentWarPeace(otherTeamID);
--     --             print(string.format("(Robots) - Team %d vs Team %d: PermanentWarPeace = %s", teamID, otherTeamID, tostring(isPermanentWarPeace)));
--     --         end
--     --     end
--     -- end

--     local function GetAnyPlayerNameFromTeam(teamID)
--         for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
--             local player = Players[i];
--             if player and player:IsEverAlive() and not player:IsAlien() and not player:IsMinorCiv() then
--                 if player:GetTeam() == teamID then
--                     return player:GetName();
--                 end
--             end
--         end
--         return "Unknown";
--     end

--     -- For some reason the game will still
--     local function CheckIfWar()
--         for teamID, team in pairs(activeTeams) do
--             for otherTeamID, otherTeam in pairs(activeTeams) do
--                 if teamID ~= otherTeamID then
--                     if team:IsAtWar(otherTeamID) then
--                         if Game.GetAIAutoPlay() > 0 then
--                             local nameA = GetAnyPlayerNameFromTeam(teamID);
--                             local nameB = GetAnyPlayerNameFromTeam(otherTeamID);
--                             -- print("(Robots) War declared between team " .. teamID .. " and team " .. otherTeamID .. "! Stopping autoplay on turn " .. Game.GetGameTurn());
--                             print("(Robots) War declared between " .. nameA .. " and " .. nameB .. "! Stopping autoplay on turn " .. Game.GetGameTurn());
--                             Game.SetAIAutoPlay(1, 0);
--                         end
--                         return;
--                         -- print("(Robots) Forcing peace between team " .. teamID .. " and team " .. otherTeamID .. " due to missing affinity unlock.");
--                         -- team:MakePeace(otherTeamID);
--                     end
--                 end
--             end
--         end
--     end

--     CheckIfWar();
-- end
-- GameEvents.PlayerDoTurn.Add(CheckAutoPlay);
