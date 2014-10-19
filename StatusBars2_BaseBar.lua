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
    elseif( barType == kDemonicFury ) then
        return DEMONIC_FURY;
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
--  Name:           Bar_ShowBackdrop
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function Bar_ShowBackdrop( self )

    -- Set an edge so we can see the aura self
    local backdropInfo = { 
        bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
        edgeSize = 16,
        insets = {
            left = 5,
            right = 5,
            top = 5,
            bottom = 5 
        }
    };

    self:SetBackdrop( backdropInfo );
    self:SetBackdropColor( 0, 0, 0, 0.85 );

    -- Create a font string if we don't have one
    if( self.text == nil ) then
        self.text = self:CreateFontString( );
        self.text:SetPoint("CENTER",0,0);
    end

end

-------------------------------------------------------------------------------
--
--  Name:           Bar_HideBackdrop
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Bar_HideBackdrop( self )

    -- Get rid of the edge if it was added in config mode
    self:SetBackdrop( nil );
    
    -- Hide the text if it was displayed from config mode
    if ( self.text ) then
        self.text:Hide( );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateBar
--
--  Description:    Create a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateBar( key, template, unit, displayName, barType, defaultColor )

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

    -- Base methods for subclasses to call
    bar.Bar_OnEnable = StatusBars2_StatusBar_OnEnable;
    bar.Bar_ShowBackdrop = Bar_ShowBackdrop;
    bar.Bar_HideBackdrop = Bar_HideBackdrop;

    -- Set the default options template
    bar.optionsTemplate = "StatusBars2_BarOptionsTemplate";

    -- Set the default configuration template
    bar.optionsPanelKey = "barOptionsTabPage";

    -- Set the default methods
    bar.OnEnable = StatusBars2_StatusBar_OnEnable;
    bar.BarIsVisible = StatusBars2_StatusBar_IsVisible;
    bar.IsDefault = StatusBars2_StatusBar_IsDefault;
    bar.SetBarScale = StatusBars2_StatusBar_SetScale;
    bar.SetBarPosition = StatusBars2_Movable_SetPosition;
    bar.GetBarHeight = StatusBars2_StatusBar_GetHeight;

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

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnEnter
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2_StatusBar_OnEnter( self )

    if( StatusBars2.showHelp ) then
        GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_BOTTOMRIGHT", 0, -20);
        GameTooltip:SetText('Hold down "Alt" to move an individual bar\nHold down "Ctrl" to move a whole group\nHold down "Ctrl" + "Alt" to move all the bars at once');
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
--  Name:           StatusBars2_StatusBar_OnEnable
--
--  Description:    Called when a status bar is enabled
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_OnEnable( self )

    if( StatusBars2.configMode ) then

        -- Set the text
        if ( self.text ) then
            self.text:SetFontObject(FontInfo[StatusBars2.font].filename);
            self.text:SetText( self.displayName );
            self.text:SetTextColor( 1, 1, 1 );
            self.text:Show( );
        end

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
--  Name:           StatusBars2_StatusBar_OnHide
--
--  Description:    Called when the frame is hidden
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_OnHide( self )

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
function StatusBars2_StatusBar_IsDefault( self )

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
function StatusBars2_StatusBar_SetScale( self, scale )

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
function StatusBars2_StatusBar_GetHeight( self )

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
function StatusBars2_StatusBar_IsVisible( self )

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

