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

local kDefaultPowerBarColor = addonTable.kDefaultPowerBarColor;

local FontInfo = addonTable.fontInfo;


-- Max flash alpha
local kFlashAlpha = 0.8;

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
local function Bar_ShowBackdrop( self )

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
--  Name:           Bar_ShowBackdrop
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
--  Name:           Config_Bar_OnEnable
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Config_Bar_OnEnable( self )

    -- Set the text
    if ( self.text ) then
        self.text:SetFontObject(FontInfo[StatusBars2_Settings.font].filename);
        self.text:SetText( self.displayName );
        self.text:SetTextColor( 1, 1, 1 );
        self.text:Show( );
    end

    -- In config mode, the mouse is always enabled
    self:EnableMouse( true );
    StatusBars2_ShowBar( self );

end

-------------------------------------------------------------------------------
--
--  Name:           Config_Bar_OnMouseDown
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Config_Bar_OnMouseDown( self, button )

    -- Move on left button down
    if( button == 'LeftButton' ) then

        -- print("StatusBars2_StatusBar_OnMouseDown "..self:GetName().." x "..self:GetLeft().." y "..self:GetTop().." parent "..self:GetParent():GetName());
        -- point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        -- print("Anchor "..relativePoint.." of "..relativeTo:GetName().." to "..point.." xoff "..xOfs.." yoff "..yOfs);

        -- If grouped move the main frame
        if( StatusBars2_Settings.grouped == true ) then
            self:GetParent( ):OnMouseDown( button );
            -- StatusBars2_OnMouseDown( StatusBars2, button );

        -- Otherwise move this bar
        else
            self:StartMoving( );
            self.isMoving = true;
        end

    end

end

-------------------------------------------------------------------------------
--
--  Name:           Config_Bar_OnMouseUp
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Config_Bar_OnMouseUp( self, button )

    -- Move with left button
    if( button == 'LeftButton' ) then

        local parentFrame = self:GetParent( );

        -- If grouped move the main frame
        if( StatusBars2_Settings.grouped == true ) then
            parentFrame:OnMouseUp( button );
            -- StatusBars2_OnMouseUp( StatusBars2, button );

        -- Otherwise move this bar
        elseif( self.isMoving ) then

            -- End moving
            self:StopMovingOrSizing( );
            self.isMoving = false;

            -- Moving the bar de-anchored it from its group frame and anchored it to the screen.
            -- We don't want that, so re-anchor the bar to its group frame
            self:ClearAllPoints( );
            self:SetPoint( "TOPLEFT", groups[ self.group ], "TOPLEFT", xOffset * ( 1 / self:GetScale( ) ), yOffset * ( 1 / self:GetScale( ) ) );

        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           Bar_SetNormalHandlers
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Bar_SetNormalHandlers( bar )

    -- Base methods for subclasses to call
    bar.Bar_OnEnable = StatusBars2_StatusBar_OnEnable;
    bar.Bar_OnMouseDown = StatusBars2_StatusBar_OnMouseDown;
    bar.Bar_OnMouseUp = StatusBars2_StatusBar_OnMouseUp;

    -- Set the mouse event handlers
    bar:SetScript( "OnMouseDown", StatusBars2_StatusBar_OnMouseDown );
    bar:SetScript( "OnMouseUp", StatusBars2_StatusBar_OnMouseUp );

end

-------------------------------------------------------------------------------
--
--  Name:           Bar_SetConfigHandlers
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Bar_SetConfigHandlers( bar )

    -- Base methods for subclasses to call
    bar.Bar_OnEnable = Config_Bar_OnEnable;
    bar.Bar_OnMouseDown = Config_Bar_OnMouseDown;
    bar.Bar_OnMouseUp = Config_Bar_OnMouseUp;

    -- Set the mouse event handlers
    bar:SetScript( "OnMouseDown", Config_Bar_OnMouseDown );
    bar:SetScript( "OnMouseUp", Config_Bar_OnMouseUp );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateBar
--
--  Description:    Create a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateBar( key, template, unit, displayName, barType )

    -- Create the bar
    local bar = CreateFrame( "Frame", "StatusBars2_"..key.."Bar", StatusBars2, template );
    bar:Hide( );

    -- Store bar settings
    bar.unit = unit;
    bar.key = key;
    bar.displayName = displayName;
    bar.type = barType;
    bar.inCombat = false;
    bar.settings = StatusBars2_Settings.bars[ key ];

    -- Set the default options template
    bar.optionsTemplate = "StatusBars2_BarOptionsTemplate";

    -- Set the functions to switch between normal and config modes
    bar.Bar_SetNormalHandlers = Bar_SetNormalHandlers;
    bar.Bar_SetConfigHandlers = Bar_SetConfigHandlers;

    -- Set the bar to normal mode
    bar:Bar_SetNormalHandlers( );

    -- Set the default methods
    bar.OnEnable = StatusBars2_StatusBar_OnEnable;
    bar.BarIsVisible = StatusBars2_StatusBar_IsVisible;
    bar.IsDefault = StatusBars2_StatusBar_IsDefault;
    bar.SetBarScale = StatusBars2_StatusBar_SetScale;
    bar.SetBarPosition = StatusBars2_StatusBar_SetPosition;
    bar.GetBarHeight = StatusBars2_StatusBar_GetHeight;
    bar.Bar_ShowBackdrop = Bar_ShowBackdrop;
    bar.Bar_HideBackdrop = Bar_HideBackdrop;

    -- Set the mouse event handlers
    bar:SetScript( "OnHide", StatusBars2_StatusBar_OnHide );

    -- Default the bar to Auto enabled
    bar.defaultEnabled = "Auto";

    -- Initialize flashing variables
    bar.flashing = false;

    -- Save it in the bar collection
    table.insert( bars, bar );

    return bar;

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

    -- Check if the bar type is enabled
    -- Signing up for events if the bar isn't enable wastes performance needlessly
    if( self.settings.enabled ~= "Never" ) then

        -- Initialize the inCombat flag
        self.inCombat = UnitAffectingCombat( "player" );

        -- Enable the event and update handlers
        self:SetScript( "OnEvent", self.OnEvent );
        self:SetScript( "OnUpdate", self.OnUpdate );

        -- If not locked enable the mouse for moving
        -- Don't enable mouse on aura bars, we only want the mouse to be able to grab active icons
        self:EnableMouse( not StatusBars2_Settings.locked and self.type ~= kAura );

        if( self:BarIsVisible( ) ) then
            StatusBars2_ShowBar( self );
        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_OnMouseDown( self, button )

    -- Move on left button down
    if( button == 'LeftButton' ) then

        -- print("StatusBars2_StatusBar_OnMouseDown "..self:GetName().." x "..self:GetLeft().." y "..self:GetTop().." parent "..self:GetParent():GetName());
        -- point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        -- print("Anchor "..relativePoint.." of "..relativeTo:GetName().." to "..point.." xoff "..xOfs.." yoff "..yOfs);

        -- If grouped move the main frame
        if( StatusBars2_Settings.grouped ) then
            self:GetParent( ):OnMouseDown( button );
            -- StatusBars2_OnMouseDown( StatusBars2, button );

        -- Otherwise move this bar
        else
            self:StartMoving( );
            self.isMoving = true;
        end

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnMouseUp
--
--  Description:    Called when the mouse button goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_OnMouseUp( self, button )

    -- Move with left button
    if( button == 'LeftButton' ) then

        local parentFrame = self:GetParent( );

        -- If grouped move the main frame
        if( StatusBars2_Settings.grouped ) then
            parentFrame:OnMouseUp( button );
            -- StatusBars2_OnMouseUp( StatusBars2, button );

        -- Otherwise move this bar
        elseif( self.isMoving ) then

            -- End moving
            self:StopMovingOrSizing( );
            self.isMoving = false;
            
            -- Get the scaled position
            local left = self:GetLeft( ) * self:GetScale( );
            local top = self:GetTop( ) * self:GetScale( );

            -- Get the offsets relative to the main frame
            local xOffset = left - parentFrame:GetLeft( );
            local yOffset = top - parentFrame:GetTop( );

            -- Save the position in the settings
            self.settings.position = {};
            self.settings.position.x = xOffset;
            self.settings.position.y = yOffset;

            -- Moving the bar de-anchored it from its group frame and anchored it to the screen.
            -- We don't want that, so re-anchor the bar to its group frame
            self:ClearAllPoints( );
            self:SetPoint( "TOPLEFT", groups[ self.group ], "TOPLEFT", xOffset * ( 1 / self:GetScale( ) ), yOffset * ( 1 / self:GetScale( ) ) );

        end
    end
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

    StatusBars2_StatusBar_OnMouseUp( self, "LeftButton" );

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
--  Name:           StatusBars2_StatusBar_SetPosition
--
--  Description:    Set the bar position
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_SetPosition( self, x, y )

    local xOffset;
    local yOffset;

    -- If the bar has a saved position use it
    if( self.settings.position ~= nil ) then
        xOffset = self.settings.position.x * ( 1 / self:GetScale( ) );
        yOffset = self.settings.position.y * ( 1 / self:GetScale( ) );

    -- If using default positioning need to adjust for the scale
    else
        xOffset = ( 85 * ( 1 / self.settings.scale ) ) + ( -self:GetWidth( ) / 2 );
        yOffset = y * ( 1 / self.settings.scale );
    end

    -- Set the bar position
    self:ClearAllPoints( );
    self:SetPoint( "TOPLEFT", groups[ self.group ], "TOPLEFT", xOffset, yOffset );

    -- if( self:IsVisible() ~= nil) then
    --     print("StatusBars2_StatusBar_SetPosition "..self:GetName().." x "..x.." y "..y.." xOffset "..xOffset.." yOffset "..yOffset.." vis "..self:IsVisible());
    -- else
    --     print("StatusBars2_StatusBar_SetPosition "..self:GetName().." x "..x.." y "..y.." xOffset "..xOffset.." yOffset "..yOffset.." vis unknown");
    -- end

    -- print("StatusBars2 pos "..StatusBars2:GetLeft().." "..StatusBars2:GetTop());

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

    return self:GetHeight( ) * self.settings.scale;

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
    local enabled = self.settings.enabled;

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
--  Name:           StatusBars2_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnMouseDown( self, button )

    if( button == "LeftButton" and not self.isMoving ) then
        self:StartMoving();
        self.isMoving = true;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnMouseUp
--
--  Description:    Called when the mouse button goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnMouseUp( self, button )

    if( button == "LeftButton" and self.isMoving ) then
        self:StopMovingOrSizing();
        self.isMoving = false;

        -- Save the position in the settings
        StatusBars2_Settings.position = {};

        local xOffset = self:GetLeft( ) + self:GetWidth( ) / 2;
        local yOffset = self:GetTop( );
        StatusBars2_Settings.position.x = xOffset * self:GetScale( ) - self:GetParent( ):GetWidth( ) / 2;
        StatusBars2_Settings.position.y = yOffset * self:GetScale( ) - self:GetParent( ):GetHeight( ) / 2;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnHide
--
--  Description:    Called when the frame is hidden
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnHide( self )

    StatusBars2_OnMouseUp( self, "LeftButton" );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateFlash
--
--  Description:    Update a flashing bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateFlash( self, level )

    -- Only update if the bar is flashing
    if( self.flashing ) then

        -- Set the bar backdrop level
        self:SetBackdropColor( level, 0, 0, level * kFlashAlpha );
        self.flash:SetVertexColor( level * kFlashAlpha, 0, 0 );
        self.flash:Show( );

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StartFlash
--
--  Description:    Start a bar flashing
--
-------------------------------------------------------------------------------
--
function StatusBars2_StartFlash( self )

    if( not self.flashing ) then
        self.flashing = true;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EndFlash
--
--  Description:    Stop a bar from flashing
--
-------------------------------------------------------------------------------
--
function StatusBars2_EndFlash( self )

    if( self.flashing ) then
        self.flashing = false;
        self.flash:Hide( );
        self:SetBackdropColor( 0, 0, 0, 0 );
    end

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

