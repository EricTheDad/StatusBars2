-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


local groups = addonTable.groups;
local bars = addonTable.bars;

-- String table (localization)
local L = addonTable.strings;

-- Bar types
local kHealth = addonTable.barTypes.kHealth;
local kPower = addonTable.barTypes.kPower;
local kAura = addonTable.barTypes.kAura;
local kAuraStack = addonTable.barTypes.kAuraStack;
local kRune = addonTable.barTypes.kRune;
local kDruidMana = addonTable.barTypes.kDruidMana;
local kUnitPower = addonTable.barTypes.kUnitPower;

local FontInfo = addonTable.fontInfo;


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ConstructDisplayName
--
--  Description:    Construct the appropriate display name for a bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_ConstructDisplayName( unit, barType )

    local barTypeText;
    
    if( barType == kDruidMana ) then
        local localizedClass = UnitClass( unit );
        return localizedClass.." "..MANA;
    elseif( barType == kHealth ) then
        barTypeText = HEALTH;
    elseif( barType == kPower ) then
        -- A little odd, but as far as Blizzard defined strings go, the text for PET_BATTLE_STAT_POWER 
        -- probably best embodies a generic power bar for all languages
        barTypeText = PET_BATTLE_STAT_POWER;
    elseif( barType == kAura ) then
        barTypeText = AURAS;
    else
        assert( false, "unknown bar type");
    end
    
    local unitText;
    
    if( unit == "player" ) then
        unitText = STATUS_TEXT_PLAYER;
    elseif( unit == "target" ) then
        unitText = STATUS_TEXT_TARGET;
    elseif( unit == "focus" ) then
        unitText = FOCUS;
    elseif( unit == "pet" ) then
        unitText = STATUS_TEXT_PET;
    else
        assert( false, "Unknown unit type" );
    end

    return unitText.." "..barTypeText;
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnHide
--
--  Description:    Called when the frame is hidden
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_OnHide( self )

    StatusBars2_Movable_StopMoving( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_IsDefault
--
--  Description:    Determine if a status bar is in the default state
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_IsDefault( self )

    return true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_SetScale
--
--  Description:    Set the bar scale
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_SetScale( self, scale )

    self:SetScale( scale );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_GetHeight
--
--  Description:    Get the bar height
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_GetHeight( self )

    return self:GetHeight( ) * self.scale;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_IsVisible
--
--  Description:    Determine if a status bar should be visible
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_IsVisible( self )

    -- Get the enable type
    local enabled = self.enabled;

    local visible = false;

    -- Auto
    if( enabled == "Auto" ) then
        visible = self.inCombat or not self:IsDefault( );

    -- Combat
    elseif( enabled == "Combat" ) then
        visible = self.inCombat;

    -- Always
    elseif( enabled == "Always" ) then
        visible = true;
    end

    return visible;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnEnter
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_OnEnter( self )

    if( not StatusBars2.hideHelp ) then
        GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_BOTTOMRIGHT", 0, -20);
        GameTooltip:SetText( L[ "STRING_ID_MOVE_BAR_HELP_TEXT" ] );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnLeave
--
--  Description:    
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_OnLeave( self )

    if( GameTooltip:IsOwned(self) ) then
        GameTooltip:Hide( );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatuBars2_StatusBar_OnUpdateLayout
--
--  Description:    Called when a status bar's layout is updated
--
-------------------------------------------------------------------------------
--
local function StatuBars2_StatusBar_OnUpdateLayout( self )

    if( StatusBars2.configMode ) then

        -- Set the text, update the font etc.
        if ( self.text ) then
            self.text:SetFontObject(FontInfo[StatusBars2.font].filename);
            self.text:SetText( self.displayName );
            self.text:SetTextColor( 1, 1, 1 );
            self.text:Show( );
        end

    end

    -- Set the scale
    self:SetBarScale( self.scale );

    -- Set maximum opacity
    self.alpha = self.alpha or 1.0;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnEnable
--
--  Description:    Called when a status bar is enabled
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_OnEnable( self )

    if( StatusBars2.configMode ) then

        self:SetScript( "OnEnter", StatusBars2_StatusBar_OnEnter );
        self:SetScript( "OnLeave", StatusBars2_StatusBar_OnLeave );

        StatusBars2_ShowBar( self );

    else

        -- Check if the bar type is enabled
        -- Signing up for events if the bar isn't enable wastes performance needlessly
        if( self.enabled ~= "Never" ) then

            -- Initialize the inCombat flag
            self.inCombat = UnitAffectingCombat( "player" );

            -- Enable the event and update handlers
            self:SetScript( "OnEvent", self.OnEvent );
            self:SetScript( "OnUpdate", self.OnUpdate );

            if( StatusBars2.hideHelp ) then
                self:SetScript( "OnEnter", nil );
                self:SetScript( "OnLeave", nil );
            else
                self:SetScript( "OnEnter", StatusBars2_StatusBar_OnEnter );
                self:SetScript( "OnLeave", StatusBars2_StatusBar_OnLeave );
            end

            -- Register for events
            for event, v in pairs ( self.eventsToRegister ) do
                self:RegisterEvent( event );
            end

            if( self:BarIsVisible( ) ) then
                StatusBars2_ShowBar( self );
            end
        end
    end

    StatusBars2_Movable_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetBarColor
--
--  Description:    Get the color for a bar
--
-------------------------------------------------------------------------------
--
local function StatusBars2_GetBarColor( bar, powerToken )

    local color

    if( bar.color ) then
        color = bar.color
    elseif( bar.defaultColor ) then
        color = bar.defaultColor
    elseif ( powerToken ) then
        -- PowerBarColor defined by Blizzard unit frame
        color = PowerBarColor[powerToken]
    end

    -- if we didn't find anything suitable, use the default color
    if( not color ) then 
        color = addonTable.kDefaultPowerBarColor
    end

    return color.r, color.g, color.b

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateBar
--
--  Description:    Create a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateBar( group, index, removeWhenHidden, key, template, unit, displayName, barType, defaultColor )

    -- Create the bar
    local bar = CreateFrame( "Frame", "StatusBars2_"..key.."Bar", StatusBars2, template );
    bar:Hide( );

    -- Add mouse click handlers
    StatusBars2_MakeMovable( bar, "bar");

    -- Store bar settings
    bar.unit = unit;
    bar.key = key;
    bar.displayName = displayName;
    bar.type = barType;
    bar.inCombat = false;

    -- Store layout settings
    bar.index = index;
    bar.group = group;
    bar.removeWhenHidden = removeWhenHidden;
    bar.layoutType = "AutoLayout";

    -- Base methods for subclasses to call
    bar.BaseBar_OnUpdateLayout = StatuBars2_StatusBar_OnUpdateLayout;
    bar.BaseBar_OnEnable = StatusBars2_StatusBar_OnEnable;
    bar.BaseBar_BarIsVisible = StatusBars2_StatusBar_IsVisible;

    -- Set the default configuration template
    bar.optionsPanelKey = "barConfigTabPage";

    -- Set the default methods
    bar.OnUpdateLayout = bar.BaseBar_OnUpdateLayout;
    bar.OnEnable = bar.BaseBar_OnEnable;
    bar.BarIsVisible = bar.BaseBar_BarIsVisible;
    bar.IsDefault = StatusBars2_StatusBar_IsDefault;
    bar.SetBarScale = StatusBars2_StatusBar_SetScale;
    bar.SetBarPosition = StatusBars2_Movable_SetPosition;
    bar.GetBarHeight = StatusBars2_StatusBar_GetHeight;
    bar.GetColor = StatusBars2_GetBarColor;

    -- Set the mouse event handlers
    bar:SetScript( "OnHide", StatusBars2_StatusBar_OnHide );

    -- Default the bar to Auto enabled
    bar.defaultEnabled = "Auto";

    -- Store default color if it was passed in
    bar.defaultColor = defaultColor;

    -- Initialize flashing variables
    bar.flashing = false;

    -- Events to register for on enable
    bar.eventsToRegister = {};

    -- Save it in the bar collection
    table.insert( bars, bar );

    return bar;

end

