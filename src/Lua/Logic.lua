-- Prevent early war declarations until a team has at least one affinity-specific unit tech
-- ⚠️ NOTE: This needs to be efficient as it can be called dozens of times per turn per player!
local function CanDeclareWar(myTeam, theirTeam)
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
    }

    local function TeamHasAffinityUnlock(teamID)
        local team = Teams[teamID];

        for _, techID in ipairs(AFFINITY_UNIT_TECHS) do
            if team:IsHasTech(techID) then
                return true;
            end
        end

        return false;
    end

    -- If both teams have at least one relevant tech, war is allowed.
    if TeamHasAffinityUnlock(myTeam) and TeamHasAffinityUnlock(theirTeam) then
        return true;
    end

    -- print("(Triptych) Blocking war declaration for team " .. myTeam .. " against team " .. theirTeam);
    return false;
end
GameEvents.CanDeclareWar.Add(CanDeclareWar);
