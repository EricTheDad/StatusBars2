-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad
local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


local groups = addonTable.groups;
local bars = addonTable.bars;

-- Bar types
local kHealth = addonTable.barTypes.kHealth
local kPower = addonTable.barTypes.kPower
local kAura = addonTable.barTypes.kAura
local kAuraStack = addonTable.barTypes.kAuraStack
local kRune = addonTable.barTypes.kRune
local kDruidMana = addonTable.barTypes.kDruidMana
local kUnitPower = addonTable.barTypes.kUnitPower
local kAlternateMana = addonTable.barTypes.kAlternateMana;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_OnEvent
--
--  Description:    Specialty bar event handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_SpecialtyBar_OnEvent(self, event, ...)
    
    -- Do the actual event handling
    self:HandleEvent(event, ...);
    
    -- Update visibility
    if (self:BarIsVisible()) then
        StatusBars2_ShowBar(self);
    else
        StatusBars2_HideBar(self);
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_OnEnable
--
--  Description:    Specialty bar enable handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_SpecialtyBar_OnEnable(self)
    
    if (not StatusBars2.configMode) then
        -- Set the number of boxes we should be seeing
        self:SetupBoxes(self:GetMaxCharges());
        
        -- Update
        self:Update(self:GetCharges());
    
    end
    
    -- Call the base method
    self:DiscreteBar_OnEnable();

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_IsDefault
--
--  Description:    Determine if a specialty bar is at its default state
--
-------------------------------------------------------------------------------
--
local function StatusBars2_SpecialtyBar_IsDefault(self)
    
    return self:GetCharges() == self.defaultCharges;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetUnitPowerCharges
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
local function StatusBars2_GetUnitPowerCharges(self)
    
    -- undocumented 3rd parameter "true" in Unitpower delivers partial charges (e.g. for destruction warlocks)
    return UnitPower(self.unit, self.powerType, self.showPartialCharges)

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetMaxUnitPowerCharges
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
local function StatusBars2_GetMaxUnitPowerCharges(self)
    
    return UnitPowerMax(self.unit, self.powerType)

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UnitPower_HandleEvent
--
--  Description:    Unit power bar event handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_UnitPower_HandleEvent(self, event, ...)
    
    -- Number of charges changed
    if (event == self.powerEvent) then
        local unit, powerToken = ...;
        
        if (unit == self.unit and powerToken == self.powerToken) then
            self:Update(self:GetCharges());
        end
    
    -- Entering combat
    elseif (event == "PLAYER_REGEN_DISABLED") then
        self.inCombat = true;
    
    -- Leaving combat
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self.inCombat = false;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateUnitPowerBar
--
--  Description:    Create a bar that processes the unit power
--
-------------------------------------------------------------------------------
--
local function StatusBars2_CreateUnitPowerBar(group, index, removeWhenHidden, key, displayName, defaultColor, powerType, powerEvent, powerToken)
    
    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar(group, index, removeWhenHidden, key, "player", displayName, kUnitPower, 0, defaultColor);
    
    -- Set the event handlers
    bar.OnEvent = StatusBars2_SpecialtyBar_OnEvent;
    bar.OnEnable = StatusBars2_SpecialtyBar_OnEnable;
    bar.Update = StatusBars2_UpdateDiscreteBar;
    bar.HandleEvent = StatusBars2_UnitPower_HandleEvent;
    bar.SetupBoxes = StatusBars2_SetDiscreteBarBoxCount;
    bar.IsDefault = StatusBars2_SpecialtyBar_IsDefault;
    bar.defaultCharges = 0;
    
    -- Base methods for subclasses to call
    bar.SpecialtyBar_OnEnable = StatusBars2_SpecialtyBar_OnEnable;
    
    -- Save the unit power type
    bar.powerType = powerType;
    bar.powerToken = powerToken;
    
    -- Blizzard sometimes listens to "UNIT_POWER_UPDATE" and sometimes to "UNIT_POWER_FREQUENT" to update their
    -- displays.  I'll just listen to the event they tell me to listen for.
    bar.powerEvent = powerEvent;
    
    bar.GetCharges = StatusBars2_GetUnitPowerCharges;
    bar.GetMaxCharges = StatusBars2_GetMaxUnitPowerCharges;
    
    -- Events to register for on enable
    bar.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;
    bar.eventsToRegister[powerEvent] = true;
    
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateComboBar
--
--  Description:    Create a combo point bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateComboBar(group, index, removeWhenHidden)
    
    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar(group, index, removeWhenHidden, "combo", COMBO_POINTS, {r = 1, g = 0, b = 0}, Enum.PowerType.ComboPoints, "UNIT_POWER_UPDATE", "COMBO_POINTS");
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateHolyPowerBar
--
--  Description:    Create a holy power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateHolyPowerBar(group, index, removeWhenHidden)
    
    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar(group, index, removeWhenHidden, "holyPower", HOLY_POWER, PowerBarColor["HOLY_POWER"], Enum.PowerType.HolyPower, "UNIT_POWER_UPDATE", "HOLY_POWER");
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateChiBar
--
--  Description:    Create a chi bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateChiBar(group, index, removeWhenHidden)
    
    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar(group, index, removeWhenHidden, "chi", CHI_POWER, PowerBarColor["CHI"], Enum.PowerType.Chi, "UNIT_POWER_FREQUENT", "CHI");
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StaggerBar_GetColor
--
--  Description:    Get the appropriate color for the stagger bar
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StaggerBar_GetColor(self)
    
    local percent = self:GetPower() / self:GetPowerMax();
    local color = PowerBarColor[self.powerToken];
    
    if (percent >= STAGGER_RED_TRANSITION) then
        color = color[STAGGER_RED_INDEX];
    elseif (percent >= STAGGER_YELLOW_TRANSITION) then
        color = color[STAGGER_YELLOW_INDEX];
    else
        color = color[STAGGER_GREEN_INDEX];
    end
    
    return color.r, color.g, color.b
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateStaggerBar
--
--  Description:    Create a stagger bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateStaggerBar(group, index, removeWhenHidden)
    
    -- Create the bar
    local bar = StatusBars2_CreatePowerBar(group, index, removeWhenHidden, "stagger", "player");
    bar.powerToken = BREWMASTER_POWER_BAR_NAME;
    bar.GetColor = StatusBars2_StaggerBar_GetColor;
    bar.displayName = BREWMASTER_POWER_BAR_NAME
    
    bar.GetPower = function(self, returnFractionalCharges)
        return UnitStagger(self.unit)
    end
    
    bar.GetPowerMax = function(self, returnFractionalCharges)
        return UnitHealthMax(self.unit)
    end
    
    bar.IsDefault = function(self)
        return (self:GetPower() == 0)
    end
    
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateArcaneChargesBar
--
--  Description:    Create an arcane charges bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateArcaneChargesBar(group, index, removeWhenHidden)
    
    local MAGE_ARCANE_BLAST = 30451;
    
    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar(group, index, removeWhenHidden, "arcaneCharge", "Arcane Charges", PowerBarColor["ARCANE_CHARGES"], Enum.PowerType.ArcaneCharges, "UNIT_POWER_UPDATE", "ARCANE_CHARGES");
    bar.spellID = MAGE_ARCANE_BLAST;
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetEmbersBoxCount
--
--  Description:    Set up the number of embers boxes and initialize them specially for embers
--
-------------------------------------------------------------------------------
--
local function StatusBars2_SetEmbersBoxCount(self, boxCount)
    
    -- Call the base class
    StatusBars2_SetDiscreteBarBoxCount(self, boxCount);
    
    -- Modify the boxes to display ember particles
    local boxes = self.boxes;

    -- MAX_POWER_PER_EMBER defined in Blizzard constants
    for i, box in ipairs(boxes) do
        local status = box.fillBar;
        status:SetMinMaxValues(0, MAX_POWER_PER_EMBER);
    
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateEmbersBar
--
--  Description:    Custom update for the semi-discrete embers bar
--
-------------------------------------------------------------------------------
--
local function StatusBars2_UpdateEmbersBar(self, current)
    
    local current = current;
    
    -- Update the boxes
    local boxes = self.boxes;
    
    -- Initialize the boxes
    for i, box in ipairs(boxes) do
        
        local status = box.fillBar;
        local _, maxValue = status:GetMinMaxValues();
        
        if current < maxValue then
            status:SetValue(current);
            current = 0;
        else
            status:SetValue(maxValue);
            current = current - maxValue;
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ShardBar_OnEnable
--
--  Description:    Shard bar setup
--
-------------------------------------------------------------------------------
--
local function StatusBars2_ShardBar_OnEnable(self)
    
    if GetSpecialization() == SPEC_WARLOCK_DESTRUCTION then
        self.defaultCharges = 3 * MAX_POWER_PER_EMBER
        self.showPartialCharges = true
        self.SetupBoxes = StatusBars2_SetEmbersBoxCount;
        self.Update = StatusBars2_UpdateEmbersBar;
    else
        self.defaultCharges = 3
        self.showPartialCharges = false
        self.SetupBoxes = StatusBars2_SetDiscreteBarBoxCount;
        self.Update = StatusBars2_UpdateDiscreteBar;
    end
    
    StatusBars2_SpecialtyBar_OnEnable(self);

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateShardBar
--
--  Description:    Create a soul shard bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateShardBar(group, index, removeWhenHidden)
    -- TODO: use WarlockPowerBar_UnitPower
    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar(group, index, removeWhenHidden, "shard", SOUL_SHARDS, PowerBarColor["SOUL_SHARDS"], Enum.PowerType.SoulShards, "UNIT_POWER_FREQUENT", "SOUL_SHARDS");
    
    -- Override event handlers and values for this specific type of bar
    bar.OnEnable = StatusBars2_ShardBar_OnEnable;
    
    return bar;
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateEssenceBar
--
--  Description:    Create a Drakthyr Essence bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateEssenceBar(group, index, removeWhenHidden)
    
    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar(group, index, removeWhenHidden, "essence", POWER_TYPE_ESSENCE, {r = 0.78, g = 1, b = 1}, Enum.PowerType.Essence, "UNIT_POWER_UPDATE", "ESSENCE");
    bar.defaultCharges = self:GetMaxCharges();
    return bar;

end
