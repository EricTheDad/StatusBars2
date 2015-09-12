-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


local groups = addonTable.groups;
local bars = addonTable.bars;

-- Bar types
local kHealth = addonTable.barTypes.kHealth;
local kPower = addonTable.barTypes.kPower;
local kAura = addonTable.barTypes.kAura;
local kAuraStack = addonTable.barTypes.kAuraStack;
local kRune = addonTable.barTypes.kRune;
local kDruidMana = addonTable.barTypes.kDruidMana;
local kUnitPower = addonTable.barTypes.kUnitPower;
local kEclipse = addonTable.barTypes.kEclipse;
local kDemonicFury = addonTable.barTypes.kDemonicFury;

local FontInfo = addonTable.fontInfo;


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateHealthBar
--
--  Description:    Create a health bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateHealthBar( group, index, removeWhenHidden, key, unit )

    local barType = kHealth;
    local displayName = StatusBars2_ConstructDisplayName( unit, barType );

    -- Create the bar
    local bar = StatusBars2_CreateContinuousBar( group, index, removeWhenHidden, key, unit, displayName, barType, 1, 0, 0 );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_HealthBar_OnEvent;
    bar.OnEnable = StatusBars2_HealthBar_OnEnable;
    bar.IsDefault = StatusBars2_HealthBar_IsDefault;

    -- Events to register for on enable
    bar.eventsToRegister["UNIT_HEALTH"] = true;
    bar.eventsToRegister["UNIT_MAXHEALTH"] = true;
    bar.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    if( bar.unit == "target" ) then
        bar.eventsToRegister["PLAYER_TARGET_CHANGED"] = true;
    elseif( bar.unit == "focus" ) then
        bar.eventsToRegister["PLAYER_FOCUS_CHANGED"] = true;
    elseif( bar.unit == "pet" ) then
        bar.eventsToRegister["UNIT_PET"] = true;
    end

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HealthBar_OnEvent
--
--  Description:    Health bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_HealthBar_OnEvent( self, event, ... )

    -- Entering combat
    if( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Exiting combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update
   StatusBars2_UpdateHealthBar( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HealthBar_OnEnable
--
--  Description:    Health bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_HealthBar_OnEnable( self )

    if( StatusBars2.configMode ) then
        self.status:SetStatusBarColor( 0, 1, 0 );
    else
        -- Update
        StatusBars2_UpdateHealthBar( self );
    end

    -- Call the base method
    self:ContinuousBar_OnEnable( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateHealthBar
--
--  Description:    Update a health bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateHealthBar( self )

    -- Get the current and max health
    local health = UnitHealth( self.unit );
    local maxHealth = UnitHealthMax( self.unit );

    -- Update the bar
    self:ContinuousBar_Update( health, maxHealth );

    -- If the bar is still visible update its color
    if( self.visible ) then

        -- Determine the percentage of health remaining
        local percent = health / maxHealth;

        -- Set the bar color based on the percentage of remaining health
        if( percent >= 0.75 ) then
            self.status:SetStatusBarColor( 0, 1, 0 );
        elseif( percent >= 0.50 ) then
            self.status:SetStatusBarColor( 1, 1, 0 );
        elseif( percent >= 0.25 ) then
            self.status:SetStatusBarColor( 1, 0.5, 0 );
        else
            self.status:SetStatusBarColor( 1, 0, 0 );
        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HealthBar_IsDefault
--
--  Description:    Determine if a health bar is at its default level
--
-------------------------------------------------------------------------------
--
function StatusBars2_HealthBar_IsDefault( self )

    -- Get the current and max health
    local health = UnitHealth( self.unit );
    local maxHealth = UnitHealthMax( self.unit );

    return health == maxHealth;

end

