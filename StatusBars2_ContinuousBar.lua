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
--  Name:           Config_ContinuousBar_OnEnable
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Config_ContinuousBar_OnEnable ( self )

    -- Set the bar current and max values
    self.status:SetMinMaxValues( 0, 1 );
    self.status:SetValue( 1 );

    -- Set the percent text
    self.percentText:SetText( "Pct%" );

    -- As it happens, we want to do everything that we do for normal OnEnable here, too
    StatusBars2_ContinuousBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           ContinuousBar_SetNormalHandlers
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function ContinuousBar_SetNormalHandlers( bar )

    -- Base methods for subclasses to call
    bar.ContinuousBar_OnEnable = StatusBars2_ContinuousBar_OnEnable;

    bar:Bar_SetNormalHandlers( );

end
    
-------------------------------------------------------------------------------
--
--  Name:           ContinuousBar_SetConfigHandlers
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function ContinuousBar_SetConfigHandlers( bar )

    -- Base methods for subclasses to call
    bar.ContinuousBar_OnEnable = Config_ContinuousBar_OnEnable;

    bar:Bar_SetConfigHandlers( );

end
    
-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateContinuousBar
--
--  Description:    Create a bar to display a range of values
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateContinuousBar( key, unit, displayName, barType, r, g, b )

    -- Create the bar
    local bar = StatusBars2_CreateBar( key, "StatusBars2_ContinuousBarTemplate", unit, displayName, barType );
    local name = bar:GetName( );
    
    -- Get the status and text frames
    bar.status = _G[ name .. "_Status" ];
    bar.text = _G[ name .. "_Text" ];
    bar.percentText = _G[ name .. "_PercentText" ];
    bar.spark = _G[ name .. "_Spark" ];
    bar.flash = _G[ name .. "_FlashOverlay" ];
    
    -- Set the options template
    bar.optionsTemplate = "StatusBars2_ContinuousBarOptionsTemplate";

    -- Set the functions to switch between normal and config modes
    bar.ContinuousBar_SetNormalHandlers = ContinuousBar_SetNormalHandlers;
    bar.ContinuousBar_SetConfigHandlers = ContinuousBar_SetConfigHandlers;

    -- Set the bar to normal mode
    bar:ContinuousBar_SetNormalHandlers( );
    
    -- Set the visibility handler
    bar.BarIsVisible = StatusBars2_ContinuousBar_IsVisible;

    -- Base methods for subclasses to call
    bar.ContinuousBar_Update = StatusBars2_ContinuousBar_Update;

    -- Set the background color
    bar.status:SetBackdropColor( 0, 0, 0, 0.85 );

    -- Set the status bar color
    bar.status:SetStatusBarColor( r, g, b );

    -- Set the text color
    bar.text:SetTextColor( 1, 1, 1 );

    -- Set the options template
    bar.optionsTemplate = "StatusBars2_ContinuousBarOptionsTemplate";

    -- Set the status bar to draw behind the edge frame so it doesn't overlap.  
    -- This should be possible with XML, but I can't figure it out with the documentation available.
    -- Would probably work if the statusbar was the parent frame to the edge frame, but that would entail a large rewrite.
    bar.status:SetFrameLevel( bar:GetFrameLevel( ) - 1 );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ContinuousBar_Update
--
--  Description:    Update a continuous bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_ContinuousBar_Update( self, current, max )

    -- If the bar should not be visible, hide it
    if( not self:BarIsVisible( ) ) then
        StatusBars2_HideBar( self );

    -- Otherwise update the bar
    else

        -- Show the bar
        StatusBars2_ShowBar( self );

        -- Set the bar current and max values
        self.status:SetMinMaxValues( 0, max );
        self.status:SetValue( current );
        
        -- Set the percent text
        self.percentText:SetText( StatusBars2_Round( current / max * 100 ) .. "%" );

        -- If below the flash threshold start the bar flashing, otherwise end flashing
        if( self.settings.flash and current / max <= self.settings.flashThreshold ) then
            StatusBars2_StartFlash( self );
        else
            StatusBars2_EndFlash( self );
        end

        -- Abbreviate the numbers for display, if desired
        if( StatusBars2_Settings.textDisplayOption == kAbbreviated ) then
            current = AbbreviateLargeNumbers( current );
            max = AbbreviateLargeNumbers( max );
        elseif( StatusBars2_Settings.textDisplayOption == kCommaSeparated ) then
            current = BreakUpLargeNumbers( current );
            max = BreakUpLargeNumbers( max );
        end
            
        -- Set the text
        self.text:SetText( current .. ' / ' .. max );
     end   
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ContinuousBar_OnEnable
--
--  Description:    Continuous bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ContinuousBar_OnEnable( self )

    -- Set the percentage text location
    if( self.settings.percentText == 'Hide' ) then
        self.percentText:Hide( );
    else
        self.percentText:Show( );
        if( self.settings.percentText == 'Left' ) then
            self.percentText:SetPoint( "CENTER", self, "CENTER", -104, 1 );
        else
            self.percentText:SetPoint( "CENTER", self, "CENTER", 102, 1 );
        end
    end

    if( StatusBars2_Settings.textDisplayOption == kHidden ) then
        self.text:Hide( );
    else
        self.text:Show( );
    end

    self.text:SetFontObject(FontInfo[StatusBars2_Settings.font].filename);

    -- Call the base method
    self:Bar_OnEnable( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ContinuousBar_IsVisible
--
--  Description:    Determine if a continuous bar is visible
--
-------------------------------------------------------------------------------
--
function StatusBars2_ContinuousBar_IsVisible( self )

    return StatusBars2_StatusBar_IsVisible( self ) and ( UnitExists( self.unit ) and not UnitIsDeadOrGhost( self.unit ) );

end

