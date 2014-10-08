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

    -- Base methods for subclasses to call
    bar.Bar_OnEnable = StatusBars2_StatusBar_OnEnable;
    bar.Bar_OnMouseDown = StatusBars2_StatusBar_OnMouseDown;
    bar.Bar_OnMouseUp = StatusBars2_StatusBar_OnMouseUp;
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
    bar.SetBarPosition = StatusBars2_StatusBar_SetPosition;
    bar.GetBarHeight = StatusBars2_StatusBar_GetHeight;
    bar.OnMouseDown = bar.Bar_OnMouseDown;
    bar.OnMouseUp = bar.Bar_OnMouseUp;

    -- Set the mouse event handlers
    bar:SetScript( "OnHide", StatusBars2_StatusBar_OnHide );

    -- Default the bar to Auto enabled
    bar.defaultEnabled = "Auto";

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
--  Name:           ConfigShouldPassClickToParent
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function ConfigShouldPassClickToParent( )
    return not IsShiftKeyDown( ) and ( IsControlKeyDown( ) or IsAltKeyDown( ) )
end

-------------------------------------------------------------------------------
--
--  Name:           NormalShouldPassClickToParent
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function NormalShouldPassClickToParent( )
    return not IsShiftKeyDown( ) and ( StatusBars2.grouped or IsControlKeyDown( ) or IsAltKeyDown( ) )
end

-------------------------------------------------------------------------------
--
--  Name:           ConfigShouldProcessClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function ConfigShouldProcessClick( )
    return IsShiftKeyDown( );
end

-------------------------------------------------------------------------------
--
--  Name:           NormalShouldProcessClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function NormalShouldProcessClick( )
    return IsShiftKeyDown( ) or not StatusBars2.locked;
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
        -- If grouped move the main frame
        if( self:ShouldPassClickToParent( ) ) then
            self:GetParent( ):OnMouseDown( button );

        -- Otherwise move this bar
        elseif( self:ShouldProcessClick( ) ) then
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

        -- If the parent frame is the one that was put into motion, call it's handler
        if( parentFrame.isMoving or StatusBars2.isMoving ) then
            parentFrame:OnMouseUp( button );

        -- Otherwise move this bar
        elseif( self.isMoving ) then
            -- End moving
            self:StopMovingOrSizing( );
            self.isMoving = false;

            -- Moving the frame clears the points and attaches it to the UIParent frame
            -- This will re-attach it to it's group frame
            local x, y = self:GetCenter( );
            y = self:GetTop( );
            StatusBars2_StatusBar_SetPosition( self, x * self:GetScale( ), y * self:GetScale( ), true );
        end
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

        -- Base methods for subclasses to call
        self.Bar_OnMouseDown = addonTable.Config_Bar_OnMouseDown;
        self.Bar_OnMouseUp = addonTable.Config_Bar_OnMouseUp;

        self.ShouldPassClickToParent = ConfigShouldPassClickToParent;
        self.ShouldProcessClick = ConfigShouldProcessClick;

        -- In config mode, the mouse is always enabled
        self:EnableMouse( true );
        StatusBars2_ShowBar( self );

    else

        -- Base methods for subclasses to call
        self.Bar_OnMouseDown = StatusBars2_StatusBar_OnMouseDown;
        self.Bar_OnMouseUp = StatusBars2_StatusBar_OnMouseUp;

        self.ShouldPassClickToParent = NormalShouldPassClickToParent;
        self.ShouldProcessClick = NormalShouldProcessClick;

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

            -- If not locked enable the mouse for moving
            -- Don't enable mouse on aura bars, we only want the mouse to be able to grab active icons
            -- self:EnableMouse( not StatusBars2.locked and self.type ~= kAura );
            self:EnableMouse( not StatusBars2.locked );

            if( self:BarIsVisible( ) ) then
                StatusBars2_ShowBar( self );
            end
        end
    end

    self.OnMouseDown = self.Bar_OnMouseDown;
    self.OnMouseUp = self.Bar_OnMouseUp;

    if( self:IsMouseEnabled( ) ) then
        -- Set the mouse event handlers
        self:SetScript( "OnMouseDown", self.OnMouseDown );
        self:SetScript( "OnMouseUp", self.OnMouseUp );
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

    if self.key == "playerHealth" then
        print(self.key, " setting scale to ", scale);
        print(debugstack(1, 4));
    end

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
function StatusBars2_StatusBar_SetPosition( self, x, y, savePosition )

    local rnd = StatusBars2_Round;

    --local ux, uy = UIParent:GetSize();
    --print("ux:"..rnd(ux).." uy:"..rnd(uy));

    local parentFrame = self:GetParent( );
    local px, py = parentFrame:GetCenter( );
    local relativeTo;

    if ( parentFrame == UIParent ) then 
        relativeTo = "CENTER";
    else
        py = parentFrame:GetTop( );
        relativeTo = "TOP";
    end

    local scale = self.scale;
    local inv_scale = 1 / scale;

    local nx = x;
    local ny = y;

    local dx = nx - px;
    local dy = ny - py;

    if savePosition then
        print("Saving Position");
        self.position = self.position or {};
        self.position.x = dx;
        self.position.y = dy;
    end

    local invScale = 1 / self.scale;
    local xOffset = ( self.position and self.position.x or dx ) * invScale;
    local yOffset = ( self.position and self.position.y or dy ) * invScale;

    --[[
    if( self.key == "playerHealth" ) then
    --if true then
        print("StatusBars2_StatusBar_SetPosition");
        print((self.key or "Main"), " x:", rnd(x), " y:", rnd(y));

        print("Saving Position = ", savePosition);
        print("scale:", scale);

        if self.position then
            print("Saved Pos x:", rnd(self.position.x), " y:", rnd(self.position.y));
        else
            print("No saved pos");
        end

        print("nx: ", rnd(nx), " ny:", rnd(ny));
        print("px: ", rnd(px), " py:", rnd(py));
        print("dx: ", rnd(dx), " dy:", rnd(dy), "relTo:", relativeTo);
        print("xoff:", rnd(xOffset), " yoff:", rnd(yOffset));
    end
    --]]

    -- Set the bar position
    self:ClearAllPoints( );
    self:SetPoint( "TOP", parentFrame, relativeTo, xOffset, yOffset );
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

