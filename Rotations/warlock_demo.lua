--[[@rotation Demonology 6.0.2 Basic
@class warlock
@spec demonology
@description
Demo Rotation.<br>
ALT Key for instant casts.<br>
Shift+Control for enter meta at any time<br>
Shift+Alt to cancel meta<br>
Control for cataclysm
]]--

function wl.hasPowerfulDemoProc()
	if jps.buff(wl.spells.darkSoulKnowledge)
	or jps.buff(26297) -- berserking, haste
	or jps.bloodlusting()
	or jps.buff(105702) --potion of jade serpent
	or jps.buff(138786)--Wushoolay's Lightning,  int
	or jps.debuff(138002) --fluidity jinrokh, dmg
	or jps.buff(112879) -- primal nutriment jikun, dmg
	or jps.buff(138963) --Perfect Aim, 1005 crit
	then
		return true
	end
	return false
end

function wl.shouldMouseoverDoom()
	if not jps.canDPS("mouseover") then return false end
	if jps.myDebuffDuration(wl.spells.doom, "mouseover") > 20 then return false end
	return true
end

local cdTable = {
	{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge)' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{ wl.spells.lifeblood, 'jps.UseCDs' },
	{ jps.useTrinket(0),	   'jps.useTrinket(0) ~= ""  and jps.UseCDs' },
	{ jps.useTrinket(1),	   'jps.useTrinket(1) ~= ""  and  jps.UseCDs' },
	{ wl.spells.impSwarm , 'jps.UseCDs and jps.buff(wl.spells.darkSoulKnowledge)'},
}

wl.DSCharges = function()
	return select(1, GetSpellCharges(wl.spells.darkSoulKnowledge))
end

--[[[
@rotation Demonology 6.0.2 Advanced
@class warlock
@spec demonology
@description
Demo Rotation.<br>
ALT Key for instant casts.<br>
Shift+Control for enter meta at any time<br>
Shift+Alt to cancel meta<br>
Control for cataclysm
]]--


local cdTable = {
	{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge) and jps.talentInfo(wl.spells.kilJaedenCunning)' },
	{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge) and not jps.talentInfo(wl.spells.kilJaedenCunning) and jps.demonicFury() > 700' },
	{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge) and not jps.talentInfo(wl.spells.kilJaedenCunning) and jps.demonicFury() > 400 and wl.DSCharges() == 2 ' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{ wl.spells.lifeblood, 'jps.UseCDs' },
	{ {"macro","/use 13"}, 'jps.useEquipSlot(13) and jps.UseCDs'},
	{ {"macro","/use 14"}, 'jps.useEquipSlot(14) and jps.UseCDs'},
	{ wl.spells.impSwarm , 'jps.UseCDs and jps.buff(wl.spells.darkSoulKnowledge)'},
}

local demoSpellTable = {
	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),

	-- Def CD's
	{wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	{wl.spells.lifeTap, 'jps.hp("player") > 0.4 and jps.mana() <= 0.3' },
	{jps.useBagItem(109218), 'jps.shouldUsePotion() and jps.demonicFury() > 650' }, -- Dreanic Intellect Potion

	-- Soulstone
	wl.soulStone("target"),

	{wl.spells.summonTerrorguard, 'jps.talentInfo(wl.spells.grimoireOfSupremacy) and not jps.talentInfo(wl.spells.demonicServitude) and jps.UseCDs and jps.targetIsRaidBoss()'},
	{wl.spells.summonDoomguard, 'not jps.talentInfo(wl.spells.grimoireOfSupremacy) and not jps.talentInfo(wl.spells.demonicServitude)  and jps.UseCDs and jps.targetIsRaidBoss()'},

	-- CD's
	{"nested", 'jps.buff(wl.spells.metamorphosis)', cdTable},
	
	{ wl.spells.grimoireFelguard,'jps.UseCDs'},

	{wl.spells.commandDemon, 'wl.hasPet() and jps.UseCDs'},

	-- rules for enter meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and IsAltKeyDown() == false', {
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 880 and jps.cooldown(wl.spells.darkSoulKnowledge) == 0'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 880 and jps.cooldown(wl.spells.darkSoulKnowledge) >=30'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 600  and jps.combatTime() < 25'},
		{wl.spells.metamorphosis, 'jps.myDebuffDuration(wl.spells.doom) < 15 and not jps.MultiTarget and jps.demonicFury() >= 450 and jps.combatTime() < 20'},
	}},

	-- instant casts while moving
	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and not jps.buff(wl.spells.metamorphosis) and not IsShiftKeyDown()', {
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
	}},

	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and jps.buff(wl.spells.metamorphosis) and not IsShiftKeyDown()', {
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.shadowBolt},
	}},

	-- single target without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.handOfGuldan) >= 1 and jps.myDebuffDuration(wl.spells.handOfGuldan) < 4'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 2'},
		{wl.spells.shadowBolt},
	}},

	-- single target with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 18'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.demonBolt, 'jps.debuffStacks(wl.spells.demonBolt,"player") < 4'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) >= 1'},
		{wl.spells.shadowBolt, 'jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 1'},
		{wl.spells.shadowBolt}, --touch of chaos
	}},

	-- aoe without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.handOfGuldan) >= 2 and jps.myDebuffDuration(wl.spells.handOfGuldan) < 4'},
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.metamorphosis, 'jps.demonicFury() > 800'},
		{wl.spells.hellfire, 'jps.hp() > 0.6'},
		{wl.spells.harvestLife},
	}},

	-- aoe with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.corruption, 'not jps.debuff(wl.spells.doom)'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.hellfire, 'not jps.buff(wl.spells.immolationAura)'},
		{wl.spells.carrionSwarm},
		{wl.spells.chaosWave, 'jps.demonicFury() > 500'},
		{wl.spells.chaosWave, 'jps.TimeToDie("target") < 13'},
	}},
}

jps.registerRotation("WARLOCK","DEMONOLOGY",function()
	wl.deactivateBurningRushIfNotMoving(1)
	
	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() and not IsControlKeyDown() == true then
		jps.Cast("Shadowfury")
	end
	
	if IsAltKeyDown() == true and jps.CastTimeLeft("player") >= 0 and IsShiftKeyDown() == false then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	if UnitChannelInfo("player") == wl.spells.hellfire and jps.hp() < 0.59 then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	if jps.IsSpellKnown(wl.spells.cataclysm) and jps.cooldown(wl.spells.cataclysm) == 0 and IsShiftKeyDown() and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() then
		jps.Cast(wl.spells.cataclysm)
	end --spells out of spelltable are currently necessary when they come from talents :(
	

	
	nextSpell,target  = parseStaticSpellTable(demoSpellTable)
	return nextSpell,target
end,"Demonology 6.0.2 Demonbolt")



-- out of combat rotation
local spellTableOOCDemo = {
	{"Dark Intent",'not jps.buff("Dark Intent")',"player"},
	{"Summon Voidwalker",'not jps.Moving and jps.talentInfo("Grimoire of Sacrifice") and not wl.hasPet() and not jps.buff("Grimoire of Sacrifice") and not jps.isRecast("Summon Voidwalker")',"player"},
	{"Grimoire of Sacrifice",'jps.talentInfo("Grimoire of Sacrifice") and wl.hasPet() and not jps.buff("Grimoire of Sacrifice")',"player"},
}


jps.registerRotation("WARLOCK","DEMONOLOGY",function()
	wl.deactivateBurningRushIfNotMoving(1)

	return parseStaticSpellTable(spellTableOOCDemo)
end,"Out of Combat",false,false,nil, true)
