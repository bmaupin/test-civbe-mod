include("GameplayUtilities");
include("MathHelpers");

------------------------------------------------------------------------------
--	Copyright (c) 2009-2010 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

-- GLOBALS

local Stages = 
{
	VeryLow= 0,
	Low = 1,
	Normal = 2,
	High = 3,
	VeryHigh = 4
}

local DEFAULT_ACTIVITY_DENSITY_TURN_RANGE : number = 50;
local UNIVERSAL_ADVISOR_MIN_TURNS : number = 5;
local ADVISOR_SAME_POLICY_MIN_TURNS : number = 40;

local NextUniversalAgreementAdvisorTurn : number = 0;
local NextAgreementAdvisorTurn : table = {
	[AdvisorTypes.ADVISOR_MILITARY] = 0,
	[AdvisorTypes.ADVISOR_ECONOMIC] = 0,
	[AdvisorTypes.ADVISOR_SCIENCE] = 0,
	[AdvisorTypes.ADVISOR_FOREIGN] = 0,
};
local PastAgreementSuggestions : table = {};

------------------------------------------------------------------------------
function GetTrendReactionChance(playerAType : number, playerBType : number)
	local respect : number = Players[playerAType]:GetRespect(playerBType);

	local chance : number = Game.GetGaussian(0, 0.5, respect / 100) * 100;

	chance = chance + GameDefines.TREND_REACTION_FLAT_MODIFIER;

	if (chance > 100) then
		chance = 100;
	end

	return chance;
end

------------------------------------------------------------------------------
function GetRankThresholds()
	local numPlayers : number = Game.CountMajorCivsAlive();
	if (numPlayers <= 4) then
		return 0, numPlayers - 1;
	elseif (numPlayers <= 6) then
		return 1, numPlayers - 2;
	elseif (numPlayers <= 8) then
		return 2, numPlayers - 3;
	else
		return 3, numPlayers - 4;
	end
end

------------------------------------------------------------------------------

function MapValueToStage(value : number)
	-- Let's map fear/respect to a higher level scale. Allows us to be flexible as the meanings of those values change.
	-- We can also maninpulate these values based on difficulty.
	local stage = Stages.Normal;

	-- These values are very roughly based on standard deviations of a normal distribution
	if value < 5 then
		stage = Stages.VeryLow;
	elseif value < 15 then
		stage = Stages.Low;
	elseif value < 85 then
		stage = Stages.Normal;
	elseif value < 95 then
		stage = Stages.High;
	else 
		stage = Stages.VeryHigh;
	end

	return stage;
end

function CalculateOpinion(playerType : number, otherPlayerType : number)
	-- Opinion is a product of the native diplomacy AI system. This method allows script to replace the internally calculated value.
	-- NOTE: returning "NO_MAJOR_CIV_OPINION_TYPE" allows the native side to ignore this script value and use the value it calculated internally.

	-- Give personality script first crack at it.
	local personalityScript : object = GetPersonalityScript(playerType);
	if personalityScript ~= nil and personalityScript.CalculateOpinion ~= nil then
		return personalityScript.CalculateOpinion(otherPlayerType);
	end

	local player : object = Players[playerType];
	if player == nil then
		return MajorCivOpinionTypes.NO_MAJOR_CIV_OPINION_TYPE;
	end

	local otherPlayer : object = Players[otherPlayerType];
	if otherPlayer == nil then
		return MajorCivOpinionTypes.NO_MAJOR_CIV_OPINION_TYPE;
	end

	local newOpinion = MajorCivOpinionTypes.NO_MAJOR_CIV_OPINION_TYPE;

	local fear : number = player:GetFear(otherPlayerType);
	local respect : number = player:GetRespect(otherPlayerType);
	local fearWeight : number = 1;
	local respectWeight : number = 2;

	-- Lets do a linear combination of fear and respect
	local combo : number = fearWeight * fear;

	-- Use inverse of respect
	combo = combo + respectWeight * (100 - respect);

	-- Map to a range from 0-100
	if (fearWeight + respectWeight == 0) then
		error("Invalid weights");
	end
	combo = combo / (fearWeight + respectWeight);

	-- Simple mapping
	if combo > 95 or respect < 5 then
		newOpinion = MajorCivOpinionTypes.MAJOR_CIV_OPINION_UNFORGIVABLE;
	elseif combo > 90 or respect < 20 then
		newOpinion = MajorCivOpinionTypes.MAJOR_CIV_OPINION_ENEMY;
	elseif combo > 70 or fear > 70 then
		newOpinion = MajorCivOpinionTypes.MAJOR_CIV_OPINION_COMPETITOR;
	elseif respect > 90 and fear < 50 then
		newOpinion = MajorCivOpinionTypes.MAJOR_CIV_OPINION_FRIEND;
	elseif combo > 40 then
		newOpinion = MajorCivOpinionTypes.MAJOR_CIV_OPINION_NEUTRAL;
	elseif combo > 20 and respect > 60 then
		newOpinion = MajorCivOpinionTypes.MAJOR_CIV_OPINION_FAVORABLE;
	else
		newOpinion = MajorCivOpinionTypes.MAJOR_CIV_OPINION_NEUTRAL;
	end

	-- Team check
	if player:GetTeam() == otherPlayer:GetTeam() then
		newOpinion = MajorCivOpinionTypes.MAJOR_CIV_OPINION_ALLY;
	end

	return newOpinion;
end

function CalculateApproach(playerType : number, otherPlayerType : number)
	-- Approach is a product of the native diplomacy AI system. This method allows script to replace the internally calculated value.
	-- NOTE: returning "NO_MAJOR_CIV_APPROACH" allows the native side to ignore this script value and use the value it calculated internally.

	-- Give personality script first crack at it.
	local personalityScript : object = GetPersonalityScript(playerType);
	if personalityScript ~= nil and personalityScript.CalculateApproach ~= nil then
		return personalityScript.CalculateApproach(otherPlayerType);
	end

	local player : object = Players[playerType];
	if player == nil then
		return MajorCivApproachTypes.NO_MAJOR_CIV_APPROACH;
	end

	local otherPlayer : object = Players[otherPlayerType];
	if otherPlayer == nil then
		return MajorCivApproachTypes.NO_MAJOR_CIV_APPROACH;
	end

	local approach = MajorCivApproachTypes.NO_MAJOR_CIV_APPROACH;

	local fear : number = player:GetFear(otherPlayerType);
	local respect : number = player:GetRespect(otherPlayerType);
	local fearStage = MapValueToStage(fear);
	local respectStage = MapValueToStage(respect);

	-- Let's map these values into the Approaches space
	if (respectStage <= Stages.VeryLow and fearStage <= Stages.VeryLow) then
		approach = MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR;
	elseif (respectStage <= Stages.VeryLow) then
		approach = MajorCivApproachTypes.MAJOR_CIV_APPROACH_DECEPTIVE;
	elseif (respectStage <= Stages.Low and fearStage <= Stages.Low) then
		approach = MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE;
	elseif (fearStage >= Stages.VeryHigh) then
		approach = MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID;
	elseif (fearStage >= Stages.High or respectStage <= Stages.Low) then
		approach = MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED;
	elseif (respectStage >= Stages.VeryHigh or (respectStage >= Stages.High and fearStage <= Stages.Normal)) then
		approach = MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY;
	else
		approach = MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL;
	end

	-- Team check
	if player:GetTeam() == otherPlayer:GetTeam() then
		approach = MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY;
	end

	return approach;
end

-- Recalculate the fear value between two players
-- FEAR range is 0 (Utterly Unafraid) to 100 (Abject Terror)
function RecalculateFear(playerType : number, otherPlayerType : number)
		
	local finalFear : number = 40;

	-- Scalars, used to multiply individual factors to balance the amount they will adjust
	local Scalars : table = {
		Military = 0.2,
		Covert = 6,
		Cities = 5,
		Territory = 0.6,
		Population = 4,
		EnergyReserves = 0.01,
		Energy = 1,
		Production = 1.1,
		Food = 1,
		Science = 1.1,
		Culture = 0.8,
		Technologies = 4,
		Virtues = 3,
		Affinity = 5
	}
	
	-- Weight values, governing how much each factor influences the final fear value
	local Weights : table = {
		TopLevel = 1,
		MidLevel = 0.6,
		LowLevel = 0.4,
	};

	local thisPlayer : object = Players[playerType];
	local otherPlayer : object = Players[otherPlayerType];
	if (thisPlayer == nil or otherPlayer == nil) then
		error("RecalculateFear: Invalid player object");
		return 0;
	end

	if (thisPlayer:IsMajorCiv() == false) then
		error("RecalculateFear: thisPlayer is not major civ");
		return 0;
	end

	-- Calculating fear towards another non-major or nonliving Civ should produce a 0 result
	-- since it is technically possible but has no gameplay impact
	if (otherPlayer:IsMajorCiv() == false or otherPlayer:IsAlive() == false) then		
		return 0;
	end

	local thisTeam : object = Teams[thisPlayer:GetTeam()];
	local otherTeam : object = Teams[otherPlayer:GetTeam()];
	if (thisTeam == nil or otherTeam == nil) then
		error("RecalculateFear: Invalid team object");
		return 0;
	end

	-- TOP LEVEL
	-- Compare relative army size and strength, and covert ops strength

	-- MILITARY
	local myMilitaryMight : number = thisPlayer:GetMilitaryMight();
	local theirMilitaryMight : number = otherPlayer:GetMilitaryMight();

	local myCovertAgents : table = thisPlayer:GetCovertAgents();
	local theirCovertAgents : table = otherPlayer:GetCovertAgents();

	local myNumAgents : number = #myCovertAgents;
	local theirNumAgents : number = #theirCovertAgents;
	local myAgentsOnThem : number = 0;
	local theirAgentsOnMe : number = 0;
	local myAvgAgentRank : number = 0;
	local theirAvgAgentRank : number = 0;
	
	local totalAgentRank : number = 0;
	local agentCity : object = nil;

	if (myNumAgents > 0) then
		for i : number, agent : object in ipairs(myCovertAgents) do
			totalAgentRank = totalAgentRank + agent:GetRank();

			agentCity = agent:GetCity();
			if (agentCity ~= nil and agentCity:GetOwner() == otherPlayerType) then
				myAgentsOnThem = myAgentsOnThem + 1;
			end
		end
		myAvgAgentRank = totalAgentRank / myNumAgents;
	end

	if (theirNumAgents > 0) then
		totalAgentRank = 0;
		for i : number, agent : object in ipairs(theirCovertAgents) do
			totalAgentRank = totalAgentRank + agent:GetRank();

			agentCity = agent:GetCity();
			if (agentCity ~= nil and agentCity:GetOwner() == playerType) then
				theirAgentsOnMe = theirAgentsOnMe + 1;
			end
		end
		theirAvgAgentRank = totalAgentRank / theirNumAgents;
	end

	local agentsFactor : number = (theirNumAgents - myNumAgents);
	local agentRankFactor : number = (theirAvgAgentRank - myAvgAgentRank);
	local agentActivityFactor : number = (theirAgentsOnMe - myAgentsOnThem);

	-- Military and Covert adjustments
	local militaryAdjustment : number = (theirMilitaryMight - myMilitaryMight) * Scalars.Military;
	local covertAdjustment : number = (agentsFactor + agentRankFactor + agentActivityFactor) * Scalars.Covert;

	-- MID LEVEL
	-- Compare short-term competition:
	-- Cities and Population
	-- Territory size
	-- Energy Yield
	-- Production Yield

	local myNumCities : number = thisPlayer:GetNumCities();
	local theirNumCities : number = otherPlayer:GetNumCities();
	local myNumPlots : number = thisPlayer:GetNumPlots();
	local theirNumPlots : number = otherPlayer:GetNumPlots();
	local myEnergyReserve : number = thisPlayer:GetEnergy();
	local theirEnergyReserve : number = otherPlayer:GetEnergy();
	local myEnergyYield : number = thisPlayer:CalculateTotalYield(YieldTypes.YIELD_ENERGY);
	local theirEnergyYield : number = otherPlayer:CalculateTotalYield(YieldTypes.YIELD_ENERGY);
	local myProductionYield : number = thisPlayer:CalculateTotalYield(YieldTypes.YIELD_PRODUCTION);
	local theirProductionYield : number = otherPlayer:CalculateTotalYield(YieldTypes.YIELD_PRODUCTION);

	local myAvgPop : number = GetAveragePopulation(thisPlayer);
	local theirAvgPop : number = GetAveragePopulation(otherPlayer);

	-- Mid Level adjustments
	local cityAdjustment : number = (theirNumCities - myNumCities) * Scalars.Cities;
	local territoryAdjustment : number = (theirNumPlots - myNumPlots) * Scalars.Territory;
	local popAdjustment : number = (theirAvgPop - myAvgPop) * Scalars.Population;
	local energyReserveAdjustment : number = (theirEnergyReserve - myEnergyReserve) * Scalars.EnergyReserves;
	local energyAdjustment : number = (theirEnergyYield - myEnergyYield) * Scalars.Energy;
	local productionAdjustment : number = (theirProductionYield - myProductionYield) * Scalars.Production;


	-- LOW LEVEL
	-- Compare long-term competition
	-- Techs
	-- Virtues
	-- Science Yield
	-- Culture Yield
	-- Food Yield
	-- Affinity Level
	
	local myNumTechs : number = thisTeam:GetTeamTechs():GetNumTechsKnown();
	local theirNumTechs : number = otherTeam:GetTeamTechs():GetNumTechsKnown();
	local myNumVirtues : number = thisPlayer:GetNumPolicies();
	local theirNumVirtues : number = otherPlayer:GetNumPolicies();
	local myFoodYield : number = thisPlayer:CalculateTotalYield(YieldTypes.YIELD_FOOD);
	local theirFoodYield : number = otherPlayer:CalculateTotalYield(YieldTypes.YIELD_FOOD);
	local myScienceYield : number = thisPlayer:CalculateTotalYield(YieldTypes.YIELD_SCIENCE);
	local theirScienceYield : number = otherPlayer:CalculateTotalYield(YieldTypes.YIELD_SCIENCE);
	local myCultureYield : number = thisPlayer:CalculateTotalYield(YieldTypes.YIELD_CULTURE);
	local theirCultureYield : number = otherPlayer:CalculateTotalYield(YieldTypes.YIELD_CULTURE);

	local myAffinityLevel : number = 0;
	local theirAffinityLevel : number = 0;

	local dominantAffinity : number = thisPlayer:GetDominantAffinityType();
	if (dominantAffinity ~= -1) then
		myAffinityLevel = thisPlayer:GetAffinityLevel(dominantAffinity);
	end

	dominantAffinity = otherPlayer:GetDominantAffinityType();
	if (dominantAffinity ~= -1) then
		theirAffinityLevel = otherPlayer:GetAffinityLevel(dominantAffinity);
	end

	-- Low Level adjustments
	local techAdjustment : number = (theirNumTechs - myNumTechs) * Scalars.Technologies;
	local virtueAdjustment : number = (theirNumVirtues - myNumVirtues) * Scalars.Virtues;
	local foodAdjustment : number = (theirFoodYield - myFoodYield) * Scalars.Food;
	local scienceAdjustment : number = (theirScienceYield - myScienceYield) * Scalars.Science;
	local cultureAdjustment : number = (theirCultureYield - myCultureYield) * Scalars.Culture;
	local affinityAdjustment : number = (theirAffinityLevel - myAffinityLevel) * Scalars.Affinity;

	-- COMBINE and APPLY
	local topLevelAdjustment = militaryAdjustment + covertAdjustment;

	local midLevelAdjustment : number = 
		cityAdjustment +  
		territoryAdjustment +
		popAdjustment +
		energyReserveAdjustment +
		energyAdjustment +
		productionAdjustment;

	local lowLevelAdjustment : number = 
		techAdjustment + 
		virtueAdjustment + 
		foodAdjustment + 
		scienceAdjustment + 
		cultureAdjustment + 
		affinityAdjustment;

	topLevelAdjustment = topLevelAdjustment * Weights.TopLevel;
	midLevelAdjustment = midLevelAdjustment * Weights.MidLevel;
	lowLevelAdjustment = lowLevelAdjustment * Weights.LowLevel;
	local finalAdjustment : number = topLevelAdjustment + midLevelAdjustment + lowLevelAdjustment;

	-- Soften adjustment based on our time on planet
	local turnsOnPlanet : number = thisPlayer:GetTurnsSincePlanetfall();
	local turnScalar = turnsOnPlanet * 3.5;
	if (turnScalar < 100) then
		finalAdjustment = (finalAdjustment * turnScalar) / 100;
	end

	finalFear = finalFear + finalAdjustment;

	return Clamp(finalFear, 0, 100);
end

----------------------------------------------------
-- Personality Trait Reaction helpers
---------------------------------------------------- 

-- Checks global and data-driven throttling conditions to determine if a given reaction can be sent this turn
function CanSendReactionThisTurn(reactionInfo : table, sendingPlayerType: number, receivingPlayerType : number)
	local receivingPlayer : object = Players[receivingPlayerType];
	if (receivingPlayer == nil) then
		return false;
	end

	local sendingPlayer : object = Players[sendingPlayerType];
	if (sendingPlayer == nil) then
		return false;
	end

	-- Ignore reactions involving non-Civ players
	if (not sendingPlayer:IsMajorCiv() or not receivingPlayer:IsMajorCiv()) then
		return false;
	end

	local turnInterval : number = reactionInfo.ThrottleTurns or GameDefines.DIPLO_TRAIT_DEFAULT_REACTION_INTERVAL;
	-- Adjust turn interval for game speed
	local gameSpeedType = Game.GetGameSpeedType();
	local gameSpeedInfo = GameInfo.GameSpeeds[gameSpeedType];	
	if (gameSpeedInfo ~= nil and gameSpeedInfo.DiploReactionIntervalPercent ~= nil) then
		turnInterval = (turnInterval * gameSpeedInfo.DiploReactionIntervalPercent) / 100;
	end
	
	-- Look for instances of either reaction that occurred within the given interval
	local latestReactionTurn : number = receivingPlayer:GetLatestLoggedReactionTurn(sendingPlayerType, reactionInfo.ID);
	if (latestReactionTurn >= 0 and Game.GetGameTurn() - latestReactionTurn <= turnInterval) then
		return false;
	end

	-- All conditions passed
	return true;
end

----------------------------------------------------
-- Diplomacy Advisors
---------------------------------------------------- 

-- Scan possible agreements for a player and present a recommendation communique for a good one
function DoAgreementsAdvisor(playerType : number)
	-- Scan available foreign policies and advise an agreement for one that makes sense

	-- Store and shuffle the advisor table first.  The ActivePlayer check below
	-- will exit out early when it's not the active player in multiplayer.
	local advisorTable : table = {
		AdvisorTypes.ADVISOR_MILITARY,
		AdvisorTypes.ADVISOR_ECONOMIC,
		AdvisorTypes.ADVISOR_SCIENCE,
		AdvisorTypes.ADVISOR_FOREIGN
	};
	Shuffle(advisorTable);

	-- Store the cooldown roll.  The ActivePlayer check below will exit out early
	-- when it's not the active player in multiplayer.
	local cooldownRoll = (Game.Rand(8, "Agreement Advisor Turn Cooldown Roll") + 2);

	-- This function triggers agreement advisor communiques that are UI only.  
	-- This script is only designed for the active player. 
	local player : object = Players[playerType];
	if (player:GetID() ~= Game.GetActivePlayer()) then
		return;
	end
	local team : object = Teams[player:GetTeam()];
	local gameTurn : number = Game.GetGameTurn();

	if (gameTurn < NextUniversalAgreementAdvisorTurn) then
		return;
	end

	-- Early out if we can't make any more agreements
	if (not Game.CanProposeAnyAgreement(playerType)) then
		return;
	end

	local capitalStockpile : number = player:GetDiplomaticCapital();
	local capitalPerTurn : number = player:GetNetDiplomaticCapitalPerTurn();
	local agreementOptions : table = {};

	for otherPlayerType : number = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
		if (otherPlayerType ~= playerType) then
			local otherPlayer : object = Players[otherPlayerType];
			local otherTeam : number = otherPlayer:GetTeam();

			if (otherPlayer:IsAlive() and otherPlayer:IsMajorCiv() and team:IsHasMet(otherTeam)) then
				if (Game.CanMakeAgreements(playerType, otherPlayerType)) then				

					-- Can we afford one of this leader's policies right now?
					local foreignPolicies : table = otherPlayer:GetForeignPolicies();
					for i : number, policyType : number in ipairs(foreignPolicies) do					
						if (not Game.HasMadeAgreementWithPolicy(playerType, otherPlayerType, policyType)) then
							local validOption : boolean = false;
							if (capitalStockpile >= player:GetForeignPolicyPurchaseCapitalCost(policyType)) then
								-- Do we have enough capital income to maintain this agreement?
								local costPerTurn : number = player:GetForeignPolicyPerTurnCapitalCost(policyType);
								if (capitalPerTurn >= costPerTurn) then
									validOption = true;
								-- If not, do we have enough stockpiled to pay for it anyway for at least 10 turns?
								elseif (capitalStockpile >= (costPerTurn * 10)) then					
									validOption = true;
								end
							end

							if (validOption) then
								table.insert(agreementOptions, {
									PlayerType = otherPlayerType,
									ForeignPolicyType = policyType
								});
							end
						end
					end
				end
			end
		end
	end

	if (#agreementOptions > 0) then
		for _,advisorType in ipairs(advisorTable) do
			local nextTurnThisAdvisor : number = NextAgreementAdvisorTurn[advisorType] or 0;

			if (gameTurn >= nextTurnThisAdvisor) then
				local bestPolicyPick : table = nil;
				local withPlayer : number = -1;
				local bestPolicyValue : number = 0;

				for _,potentialAgreement in ipairs(agreementOptions) do
					-- Don't suggest the same foreign policy twice
					local foreignPolicyInfo : table = GameInfo.ForeignPolicies[potentialAgreement.ForeignPolicyType];
					if (PastAgreementSuggestions[foreignPolicyInfo.ID] == nil or 
						gameTurn - PastAgreementSuggestions[foreignPolicyInfo.ID] >= ADVISOR_SAME_POLICY_MIN_TURNS) 
					then
						local relationshipInfo : table = GameInfo.RelationshipLevels[Game.GetRelationship(playerType, potentialAgreement.PlayerType)];
					
						local perkInfo : table = nil;

						for foreignPolicies_Perk : table in GameInfo.ForeignPolicies_Perks{ForeignPolicyType = foreignPolicyInfo.Type, RelationshipLevelType = relationshipInfo.Type} do
							perkInfo = GameInfo.PlayerPerks[foreignPolicies_Perk.PlayerPerkType];
							break;
						end

						if (perkInfo ~= nil) then
							local bestAdvisor : number = -1;
							local bestAdvisorValue : number = 0;

							local flavorWeight : number = GetPerkScoreForAdvisorType(perkInfo.Type, advisorType);
							if (flavorWeight > bestPolicyValue) then
								bestPolicyPick = foreignPolicyInfo;
								bestPolicyValue = flavorWeight;
								withPlayer = potentialAgreement.PlayerType;
							end
						end
					end
				end

				if (bestPolicyPick ~= nil) then
					-- Send advisor communique
					Events.AddAdvisorCommunique(advisorType, withPlayer, bestPolicyPick.ID);			
					-- Update tracking for this advisor and this agreement
					NextAgreementAdvisorTurn[advisorType] = gameTurn + cooldownRoll;
					NextUniversalAgreementAdvisorTurn = NextUniversalAgreementAdvisorTurn + UNIVERSAL_ADVISOR_MIN_TURNS;
					PastAgreementSuggestions[bestPolicyPick.ID] = gameTurn;
					return;
				end
			end
		end
	end
end

function GetPerkScoreForAdvisorType(perkType : string, advisorType : number)
	local totalScore : number = 0;
	for row in GameInfo.PlayerPerks_Flavors{PlayerPerkType = perkType} do
		totalScore = totalScore + Game.GetAdvisorInterestInFlavor(advisorType, GameInfo.Flavors[row.FlavorType].ID);
	end

	return totalScore;
end

----------------------------------------------------
-- Diplomacy Data helpers
--
-- Functions to provide more complex insight into a player's
-- power, holdings, status, etc.
---------------------------------------------------- 

-- Average Yield per City
function GetAverageYieldPerCity(player : object, yieldType : number)
	
	if (player == nil) then
		return 0;
	end
	if (yieldType == nil or yieldType < 0 or yieldType > YieldTypes.NUM_YIELD_TYPES) then
		return 0;
	end
	
	local totalYield : number = player:CalculateTotalYield(yieldType);
	local numCities : number = player:GetNumCities();

	return ZeroSafeRatio(totalYield, numCities);
end

-- Average Population
function GetAveragePopulation(player : object)
	
	if (player == nil) then
		return 0;
	end

	local numCities : number = player:GetNumCities();	
	local totalPop : number = 0;

	for city : object in player:Cities() do
		totalPop = totalPop + city:GetPopulation();
	end

	return ZeroSafeRatio(totalPop, numCities);
end

-- Improvement Density
function GetImprovementDensity(player : object)
	if (player == nil) then
		return 0;
	end

	local numImproved : number = 0;
	for plot in player:Plots() do
		if (plot:HasImprovement()) then
			numImproved = numImproved + 1;
		end
	end

	local numPlots : number = player:GetNumPlots();
	return ZeroSafeRatio(numImproved, numPlots);
end

-- Best Military Unit Strength (rough measure of overall military advancement)
function GetBestMilitaryUnitStrength(player : object)
	if (player == nil) then
		return 0;
	end

	local bestCombatStrength : number = 0;
	for unit : object in player:Units() do
		local unitStrength : number = math.max(unit:GetCombatStrength(), unit:GetRangedCombatStrength());
		bestCombatStrength = math.max(bestCombatStrength, unitStrength);
	end

	return bestCombatStrength;
end

-- Average Military Unit Strength (rough measure of overall military advancement)
function GetAverageMilitaryUnitStrength(player : object)
	if (player == nil) then
		return 0;
	end

	local totalMilitaryStrength : number = 0;
	for unit : object in player:Units() do
		local unitStrength : number = math.max(unit:GetCombatStrength(), unit:GetRangedCombatStrength());
		totalMilitaryStrength = totalMilitaryStrength + unitStrength;
	end

	local totalNumUnits : number = player:GetNumMilitaryUnits();

	return ZeroSafeRatio(totalMilitaryStrength, totalNumUnits);
end

-- Average Military Unit Experience (aka Veterancy, rough measure of current military might)
function GetAverageMilitaryUnitExperience(player : object)
	if (player == nil) then
		return 0;
	end

	local totalExperience : number = 0;
	for unit : object in player:Units() do
		totalExperience = totalExperience + unit:GetExperience();
	end

	local totalNumUnits : number = player:GetNumMilitaryUnits();

	return ZeroSafeRatio(totalExperience, totalNumUnits);
end

-- Offensive Military Activity Density (in turns)
function GetOffensiveMilitaryActivityDensity(player : object, turnRange : number)
	if (player == nil) then
		return 0;
	end

	factManager = Game.GetAIFactManager();
	if (factManager == nil) then
		return 0;
	end

	if (turnRange == nil) then
		turnRange = DEFAULT_ACTIVITY_DENSITY_TURN_RANGE;
	end

	local turnCutoff : number = Game.GetGameTurn() - turnRange;	

	-- TODO: Find more performant way of using a complex predicate in a Lua call to the native fact db?

	local activityScore : number = 0;
	local resultFacts : table = factManager:FindFactsByType(GameInfo.AIFacts["AIFACT_UNIT_ATTACKED_UNIT"].ID);
	if (resultFacts ~= nil) then
		for _,fact : object in pairs(resultFacts) do
			if (fact:GetPlayerSource() == player:GetID() and fact:GetTurnCreated() >= turnCutoff) then
				activityScore = activityScore + 1;
			end
		end
	end

	return activityScore;
end

-- Average City Intrigue
function GetAverageCityIntrigue(player : object)
	if (player == nil) then
		return 0;
	end

	local totalIntrigue : number = 0;
	for city : object in player:Cities() do
		totalIntrigue = totalIntrigue + city:GetIntrigue();
	end

	local totalNumCities : number = player:GetNumCities();

	return ZeroSafeRatio(totalIntrigue, totalNumCities);
end

-- Covert Ops Activity Density (in turns)
function GetCovertOpsActivityDensity(player : object, turnRange : number)
	if (player == nil) then
		return 0;
	end

	factManager = Game.GetAIFactManager();
	if (factManager == nil) then
		return 0;
	end

	if (turnRange == nil) then
		turnRange = DEFAULT_ACTIVITY_DENSITY_TURN_RANGE;
	end

	local turnCutoff : number = Game.GetGameTurn() - turnRange;	

	-- TODO: Performance, see line 542
	local activityScore : number = 0;

	-- Weights for various kinds of covert activities
	local covertOpCompleteWeight : number = 1;
	local covertAgentRecruitedWeight : number = 2;

	-- Covert Ops Completed 
	local resultFacts : table = factManager:FindFactsByType(GameInfo.AIFacts["AIFACT_COVERT_OPERATION_COMPLETED"].ID);
	if (resultFacts ~= nil) then
		for _,fact : object in pairs(resultFacts) do
			if (fact:GetPlayerSource() == player:GetID() and fact:GetTurnCreated() >= turnCutoff) then
				activityScore = activityScore + covertOpCompleteWeight;
			end
		end
	end

	-- Covert Agents Recruited
	resultFacts = factManager:FindFactsByType(GameInfo.AIFacts["AIFACT_COVERT_AGENT_RECRUITED"].ID);
	if (resultFacts ~= nil) then
		for _,fact : object in pairs(resultFacts) do
			if (fact:GetPlayerSource() == player:GetID() and fact:GetTurnCreated() >= turnCutoff) then
				activityScore = activityScore + covertAgentRecruitedWeight;
			end
		end
	end

	return activityScore;
end

-- Trade Route Plundering Activity Density (in turns)
function GetTradeRoutePlunderActivityDensity(player : object, turnRange : number)
	if (player == nil) then
		return 0;
	end

	factManager = Game.GetAIFactManager();
	if (factManager == nil) then
		return 0;
	end

	if (turnRange == nil) then
		turnRange = DEFAULT_ACTIVITY_DENSITY_TURN_RANGE;
	end

	local turnCutoff : number = Game.GetGameTurn() - turnRange;

	-- TODO: Performance, see line 542

	local activityScore : number = 0;
	local resultFacts : table = factManager:FindFactsByType(GameInfo.AIFacts["AIFACT_TRADE_ROUTE_PLUNDERED"].ID);
	if (resultFacts ~= nil) then
		for _,fact : object in pairs(resultFacts) do
			if (fact:GetPlayerSource() == player:GetID() and fact:GetTurnCreated() >= turnCutoff) then
				activityScore = activityScore + 1;
			end
		end
	end

	return activityScore;
end

-- Best Orbital Unit Level (rough measure of overall orbital advancement)
function GetBestOrbitalUnitLevel(player : object)
	if (player == nil) then
		return 0;
	end

	local bestScore : number = 0;
	for unit : object in player:Units() do
		if (unit:IsOrbitalUnit()) then
			local unitInfo : table = GameInfo.Units[unit:GetUnitType()];
			-- Base score is unit's build cost
			local unitScore : number = unitInfo.Cost;
			-- Unit Combat (half weight)
			unitScore = unitScore + (unitInfo.RangedCombat / 2);

			bestScore = math.max(bestScore, unitScore);
		end
	end

	return bestScore;
end