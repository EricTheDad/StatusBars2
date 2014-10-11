-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


local groups = addonTable.groups;
local bars = addonTable.bars;

-- Bar types
local kHealth = addonTable.barTypes.kHealth;
local kPower = addonTable.barTypes.kPower;
local kAura = addonTable.barTypes.kAura;
local kAuraStack = addonTable.barTypes.kAuraStack;
local kCombo = addonTable.barTypes.kCombo;
local kRune = addonTable.barTypes.kRune;
local kDruidMana = addonTable.barTypes.kDruidMana;
local kUnitPower = addonTable.barTypes.kUnitPower;
local kEclipse = addonTable.barTypes.kEclipse;
local kDemonicFury = addonTable.barTypes.kDemonicFury;

local FontInfo = addonTable.fontInfo;


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateSpecialtyBar
--
--  Description:    Create a generic specialty bar that displays a class/spec specific resource (combo points/holy power/burning embers etc.)
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateSpecialtyBar( key, unit, displayName, barType )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( key, unit, displayName, barType, 0 );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_SpecialtyBar_OnEvent;
    bar.OnEnable = StatusBars2_SpecialtyBar_OnEnable;
    bar.Update = StatusBars2_UpdateDiscreteBar;
    bar.HandleEvent = StatusBars2_SpecialtyBars_HandleEvent;
    bar.SetupBoxes = StatusBars2_SetDiscreteBarBoxCount;
    bar.IsDefault = StatusBars2_SpecialtyBar_ZeroIsDefault;

    -- Base methods for subclasses to call
    bar.SpecialtyBar_OnEnable = StatusBars2_SpecialtyBar_OnEnable;

    -- Events to register for on enable
    bar.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_OnEvent
--
--  Description:    Specialty bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_SpecialtyBar_OnEvent( self, event, ... )

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
--  Name:           StatusBars2_SpecialtyBar_HandleEvent
--
--  Description:    Specialty bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_SpecialtyBar_HandleEvent( self, event, ... )
    
    -- Entering combat
    if( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
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
function StatusBars2_SpecialtyBar_OnEnable( self )

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
function StatusBars2_SpecialtyBar_ZeroIsDefault( self )

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
function StatusBars2_SpecialtyBar_MaxIsDefault( self )

    return self:GetCharges( ) == self:GetMaxCharges( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetComboPoints
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetComboPoints( )

    -- Check if the target is dead
    if UnitIsDeadOrGhost( 'target' ) then
        return 0;
    else
        return GetComboPoints( "player", "target" );
    end;

end
-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateComboBar
--
--  Description:    Create a combo point bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateComboBar( )

    -- Create the bar
    local bar = StatusBars2_CreateSpecialtyBar( "combo", "player", COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT, kCombo );

    bar.HandleEvent = StatusBars2_ComboBar_HandleEvent;
    bar.GetCharges = StatusBars2_GetComboPoints;
    bar.GetMaxCharges = StatusBars2_GetMaxComboPoints;
    
    -- Events to register for on enable
    bar.eventsToRegister["UNIT_COMBO_POINTS"] = true;
    bar.eventsToRegister["PLAYER_TARGET_CHANGED"] = true;

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ComboBar_HandleEvent
--
--  Description:    Combo bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ComboBar_HandleEvent( self, event, ... )

    -- Target changed
    if( event == "PLAYER_TARGET_CHANGED" ) then
        StatusBars2_UpdateDiscreteBar( self, self:GetCharges( ) );

    -- Combo points changed
    elseif( event == "UNIT_COMBO_POINTS" ) then
        local unit = ...;
        if( unit == self.unit ) then
            StatusBars2_UpdateDiscreteBar( self, self:GetCharges( ) );
        end
    else
        StatusBars2_SpecialtyBar_HandleEvent( self, event, ... );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetMaxComboPoints
--
--  Description:    Get the max number of combo points/shards/holy power etc.
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetMaxComboPoints( )

    return MAX_COMBO_POINTS;
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateUnitPowerBar
--
--  Description:    Create a bar that processes the unit power (this is how most specialty charges operate)
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateUnitPowerBar( key, displayName )
    
    -- Create the bar
    local bar = StatusBars2_CreateSpecialtyBar( key, "player", displayName, kUnitPower );

    local powerType, powerToken, powerEvent = StatusBars2_GetSpecialtyUnitPowerType( key );

    -- Save the unit power type 
    bar.powerType = powerType;
    bar.powerToken = powerToken;
    
    -- Blizzard sometimes listens to "UNIT_POWER" and sometimes to "UNIT_POWER_FREQUENT" to update their
    -- displays.  I'll just listen to the event they tell me to listen for.
    bar.powerEvent = powerEvent;
    
    -- Set the event handlers
    bar.HandleEvent = StatusBars2_UnitPower_HandleEvent;
    
    bar.GetCharges = StatusBars2_GetUnitPowerCharges;
    bar.GetMaxCharges = StatusBars2_GetMaxUnitPowerCharges;

    -- Events to register for on enable
    bar.eventsToRegister[powerEvent] = true;

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UnitPower_HandleEvent
--
--  Description:    Unit power bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_UnitPower_HandleEvent( self, event, ... )
    
    -- Number of charges changed
    if( event == self.powerEvent ) then
        local unit, powerToken = ...;

        if( unit == self.unit and powerToken == self.powerToken ) then
            self:Update( self:GetCharges( ) );
        end
    else
        StatusBars2_SpecialtyBar_HandleEvent( self, event, ... );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetSpecialtyUnitPowerType
--
--  Description:    Get the power type and power token based on the bar type
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetSpecialtyUnitPowerType( key )

    if( key == "shard" ) then
        return SPELL_POWER_SOUL_SHARDS, "SOUL_SHARDS", "UNIT_POWER_FREQUENT";
    elseif( key == "holyPower" ) then
        return SPELL_POWER_HOLY_POWER, "HOLY_POWER", "UNIT_POWER";
    elseif( key == "chi" ) then
        -- Contrary to the documentation, the power token for CHI appears to be "CHI"
        return SPELL_POWER_CHI, "CHI", "UNIT_POWER_FREQUENT";
    elseif( key == "orbs" ) then
        return SPELL_POWER_SHADOW_ORBS, "SHADOW_ORBS", "UNIT_POWER_FREQUENT";
    elseif( key == "embers" ) then
        return SPELL_POWER_BURNING_EMBERS, "BURNING_EMBERS", "UNIT_POWER_FREQUENT";
    else
        assert(false, "unknown bar type");
    end
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetUnitPowerCharges
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetUnitPowerCharges( self )

    -- undocumented parameter "true" in Unitpower delivers the Emberparticles
    return UnitPower( self.unit, self.powerType, self.powerType == SPELL_POWER_BURNING_EMBERS );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetMaxUnitPowerCharges
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetMaxUnitPowerCharges( self )

    return UnitPowerMax( self.unit, self.powerType );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateShardBar
--
--  Description:    Create a soul shard bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateShardBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "shard", SOUL_SHARDS );

    -- Override event handlers for this specific type of bar
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
function StatusBars2_CreateHolyPowerBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "holyPower", HOLY_POWER );
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
function StatusBars2_CreateChiBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "chi", CHI_POWER );
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
function StatusBars2_CreateOrbsBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "orbs", SHADOW_ORBS );
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateEmbersBar
--
--  Description:    Create a Embers bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateEmbersBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "embers", BURNING_EMBERS );

    -- Set the event handlers
    bar.IsDefault = StatusBars2_EmbersBar_IsDefault;
    bar.SetupBoxes = StatusBars2_SetEmbersBoxCount;
    bar.Update = StatusBars2_UpdateEmbersBar;

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
function StatusBars2_SetEmbersBoxCount( self, boxCount )

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
function StatusBars2_UpdateEmbersBar( self, current )

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
function StatusBars2_EmbersBar_IsDefault( self )

    -- Default is exactly one full ember
    return self:GetCharges( ) == MAX_POWER_PER_EMBER;

end
