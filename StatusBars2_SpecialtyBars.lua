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
local kEclipse = addonTable.barTypes.kEclipse
local kDemonicFury = addonTable.barTypes.kDemonicFury

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_OnEvent
--
--  Description:    Specialty bar event handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_SpecialtyBar_OnEvent( self, event, ... )

    -- Do the actual event handling
    self:HandleEvent( event, ... );

    -- Update visibility
    if( self:BarIsVisible( ) ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
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
local function StatusBars2_SpecialtyBar_OnEnable( self )

    if( not StatusBars2.configMode ) then

        -- Set the number of boxes we should be seeing
        self:SetupBoxes( self:GetMaxCharges( ) );

        -- Update
        self:Update( self:GetCharges( ) );

    end

    -- Call the base method
    self:DiscreteBar_OnEnable( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_ZeroIsDefault
--
--  Description:    Determine if a specialty bar is at its default state when zero power is default
--
-------------------------------------------------------------------------------
--
local function StatusBars2_SpecialtyBar_ZeroIsDefault( self )

    return self:GetCharges( ) == 0;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_MaxIsDefault
--
--  Description:    Determine if a specialty bar is at its default state when max power is default
--
-------------------------------------------------------------------------------
--
local function StatusBars2_SpecialtyBar_MaxIsDefault( self )

    return self:GetCharges( ) == self:GetMaxCharges( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetUnitPowerCharges
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
local function StatusBars2_GetUnitPowerCharges( self )

    -- undocumented 3rd parameter "true" in Unitpower delivers the Emberparticles
    return UnitPower( self.unit, self.powerType, self.powerType == SPELL_POWER_BURNING_EMBERS )

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetMaxUnitPowerCharges
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
local function StatusBars2_GetMaxUnitPowerCharges( self )

    return UnitPowerMax( self.unit, self.powerType )

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UnitPower_HandleEvent
--
--  Description:    Unit power bar event handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_UnitPower_HandleEvent( self, event, ... )

    -- Number of charges changed
    if( event == self.powerEvent ) then
        local unit, powerToken = ...;

        if( unit == self.unit and powerToken == self.powerToken ) then
            self:Update( self:GetCharges( ) );
        end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
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
local function StatusBars2_CreateUnitPowerBar( group, index, removeWhenHidden, key, displayName, defaultColor, powerType, powerEvent, powerToken )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( group, index, removeWhenHidden, key, "player", displayName, kUnitPower, 0, defaultColor );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_SpecialtyBar_OnEvent;
    bar.OnEnable = StatusBars2_SpecialtyBar_OnEnable;
    bar.Update = StatusBars2_UpdateDiscreteBar;
    bar.HandleEvent = StatusBars2_UnitPower_HandleEvent;
    bar.SetupBoxes = StatusBars2_SetDiscreteBarBoxCount;
    bar.IsDefault = StatusBars2_SpecialtyBar_ZeroIsDefault;

    -- Base methods for subclasses to call
    bar.SpecialtyBar_OnEnable = StatusBars2_SpecialtyBar_OnEnable;

    -- Save the unit power type 
    bar.powerType = powerType;
    bar.powerToken = powerToken;
    
    -- Blizzard sometimes listens to "UNIT_POWER" and sometimes to "UNIT_POWER_FREQUENT" to update their
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
function StatusBars2_CreateComboBar( group, index, removeWhenHidden )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( group, index, removeWhenHidden, "combo", COMBO_POINTS, { r = 1, g = 0, b = 0 }, SPELL_POWER_COMBO_POINTS, "UNIT_COMBO_POINTS" );
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateShardBar
--
--  Description:    Create a soul shard bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateShardBar( group, index, removeWhenHidden )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( group, index, removeWhenHidden, "shard", SOUL_SHARDS, PowerBarColor["SOUL_SHARDS"], SPELL_POWER_SOUL_SHARDS, "UNIT_POWER_FREQUENT", "SOUL_SHARDS" );

    -- Override event handler for this specific type of bar
    bar.IsDefault = StatusBars2_SpecialtyBar_MaxIsDefault;
    
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
function StatusBars2_CreateHolyPowerBar( group, index, removeWhenHidden )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( group, index, removeWhenHidden, "holyPower", HOLY_POWER, PowerBarColor["HOLY_POWER"], SPELL_POWER_HOLY_POWER, "UNIT_POWER", "HOLY_POWER" );
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
function StatusBars2_CreateChiBar( group, index, removeWhenHidden )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( group, index, removeWhenHidden, "chi", CHI_POWER, PowerBarColor["CHI"], SPELL_POWER_CHI, "UNIT_POWER_FREQUENT", "CHI" );
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateOrbsBar
--
--  Description:    Create a orbs bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateOrbsBar( group, index, removeWhenHidden )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( group, index, removeWhenHidden, "orbs", SHADOW_ORBS, { r = 162/255, g = 51/255, b = 209/255 }, SPELL_POWER_SHADOW_ORBS, "UNIT_POWER_FREQUENT", "SHADOW_ORBS" );
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
local function StatusBars2_SetEmbersBoxCount( self, boxCount )

    -- Call the base class
    StatusBars2_SetDiscreteBarBoxCount( self, boxCount );
    
    -- Modify the boxes to display ember particles
    boxes = { self:GetChildren( ) };
    
    -- MAX_POWER_PER_EMBER defined in Blizzard constants
    for i, box in ipairs(boxes) do
    
       local status = box:GetChildren( );
       status:SetMinMaxValues( 0, MAX_POWER_PER_EMBER );

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
local function StatusBars2_UpdateEmbersBar( self, current )

    local current = current;
    
    -- Update the boxes
    boxes = { self:GetChildren( ) };
    
    -- Initialize the boxes
    for i, box in ipairs(boxes) do
    
       local status = box:GetChildren( );
       local _, maxValue = status:GetMinMaxValues( );
       
        if current < maxValue then
            status:SetValue( current );
            current = 0;
        else
            status:SetValue( maxValue );
            current = current - maxValue;
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EmbersBar_IsDefault
--
--  Description:    Determine if a Embers bar is at its default state
--
-------------------------------------------------------------------------------
--
local function StatusBars2_EmbersBar_IsDefault( self )

    -- Default is exactly one full ember
    return self:GetCharges( ) == MAX_POWER_PER_EMBER;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateEmbersBar
--
--  Description:    Create a Embers bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateEmbersBar( group, index, removeWhenHidden )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( group, index, removeWhenHidden, "embers", BURNING_EMBERS, { r = 1, g = 0.33, b = 0 }, SPELL_POWER_BURNING_EMBERS, "UNIT_POWER_FREQUENT", "BURNING_EMBERS" );

    -- Set the event handlers
    bar.IsDefault = StatusBars2_EmbersBar_IsDefault;
    bar.SetupBoxes = StatusBars2_SetEmbersBoxCount;
    bar.Update = StatusBars2_UpdateEmbersBar;

    return bar;

end
