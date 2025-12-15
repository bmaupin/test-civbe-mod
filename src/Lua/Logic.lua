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

local function CheckWarUnlock(playerID)
    -- Only run the check once per turn
    if playerID ~= 0 then
        return;
    end

    if WAR_UNLOCKED then
        return;
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

    local function TeamHasAffinityUnlock(team)
        for _, techID in ipairs(AFFINITY_UNIT_TECHS) do
            if team:IsHasTech(techID) then
                return true;
            end
        end

        return false;
    end

    -- Verify the unlock status for all teams
    for _teamID, team in pairs(activeTeams) do
        if not TeamHasAffinityUnlock(team) then
            -- At least one team is still missing an unlock
            return;
        end
    end

    -- All teams have at least one affinity unlock — unlock war
    WAR_UNLOCKED = true;

    for teamID, team in pairs(activeTeams) do
        for otherTeamID, _otherTeam in pairs(activeTeams) do
            if teamID ~= otherTeamID then
                team:SetPermanentWarPeace(otherTeamID, false);
            end
        end
    end
end
GameEvents.PlayerDoTurn.Add(CheckWarUnlock);

local function InitialisePermanentPeace()
    print("(Robots) Initialising global permanent peace lock...")

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
