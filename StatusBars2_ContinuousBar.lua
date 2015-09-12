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

-- Text display options
local kAbbreviated      = addonTable.textDisplayOptions.kAbbreviated;
local kCommaSeparated   = addonTable.textDisplayOptions.kCommaSeparated;
local kUnformatted      = addonTable.textDisplayOptions.kUnformated;
local kHidden           = addonTable.textDisplayOptions.kHidden;


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ContinuousBar_IsVisible
--
--  Description:    Determine if a continuous bar is visible
--
-------------------------------------------------------------------------------
--
local function StatusBars2_ContinuousBar_IsVisible( self )

    return self:BaseBar_BarIsVisible( ) and ( UnitExists( self.unit ) and not UnitIsDeadOrGhost( self.unit ) );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ContinuousBar_Update
--
--  Description:    Update a continuous bar
--
-------------------------------------------------------------------------------
--
local function StatusBars2_ContinuousBar_Update( self, current, max )

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
        if( self.flash and current / max <= self.flashThreshold ) then
            StatusBars2_StartFlash( self );
        else
            StatusBars2_EndFlash( self );
        end

        -- Abbreviate the numbers for display, if desired
        if( self.textDisplayOption == kAbbreviated ) then
            current = AbbreviateLargeNumbers( current );
            max = AbbreviateLargeNumbers( max );
        elseif( self.textDisplayOption == kCommaSeparated ) then
            current = BreakUpLargeNumbers( current );
            max = BreakUpLargeNumbers( max );
        end
            
        -- Set the text
        self.text:SetText( current .. ' / ' .. max );

     end   
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ContinuousBar_OnUpdateLayout
--
--  Description:    Continuous bar enable handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_ContinuousBar_OnUpdateLayout( self )

    -- Set the percentage text location
    if( self.percentDisplayOption == 'Hide' ) then
        self.percentText:Hide( );
    else
        self.percentText:Show( );
        if( self.percentDisplayOption == 'Left' ) then
            self.percentText:SetPoint( "CENTER", self, "CENTER", -104, 1 );
        else
            self.percentText:SetPoint( "CENTER", self, "CENTER", 102, 1 );
        end
    end

    self.text:SetFontObject(FontInfo[StatusBars2.font].filename);

    -- Call the base method
    self:BaseBar_OnUpdateLayout( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ContinuousBar_OnEnable
--
--  Description:    Continuous bar enable handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_ContinuousBar_OnEnable( self )

    -- Set to a static state if we are in config mode
    if( StatusBars2.configMode ) then
        -- Set the bar current and max values
        self.status:SetMinMaxValues( 0, 1 );
        self.status:SetValue( 1 );

        -- Set the percent text
        self.percentText:SetText( "Pct%" );
    else
        if( StatusBars2.textDisplayOption == kHidden ) then
            self.text:Hide( );
        else
            self.text:Show( );
            self.textDisplayOption = StatusBars2.textDisplayOption
        end
    end

    -- Call the base method
    self:BaseBar_OnEnable( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateContinuousBar
--
--  Description:    Create a bar to display a range of values
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateContinuousBar( group, index, removeWhenHidden, key, unit, displayName, barType, r, g, b )

    -- Create the bar
    local bar = StatusBars2_CreateBar( group, index, removeWhenHidden, key, "StatusBars2_ContinuousBarTemplate", unit, displayName, barType );
    local name = bar:GetName( );

    -- Get the status and text frames
    bar.status = _G[ name .. "_Status" ];
    bar.text = _G[ name .. "_Text" ];
    bar.percentText = _G[ name .. "_PercentText" ];
    bar.spark = _G[ name .. "_Spark" ];
    bar.flashtexture = _G[ name .. "_FlashOverlay" ];

    -- Base methods for subclasses to call
    bar.ContinuousBar_OnUpdateLayout = StatusBars2_ContinuousBar_OnUpdateLayout;
    bar.ContinuousBar_OnEnable = StatusBars2_ContinuousBar_OnEnable;
    bar.ContinuousBar_BarIsVisible = StatusBars2_ContinuousBar_IsVisible;
    bar.ContinuousBar_Update = StatusBars2_ContinuousBar_Update;

    -- Set the default configuration template
    bar.optionsPanelKey = "continuousBarConfigTabPage";

    -- Set the default methods
    bar.OnUpdateLayout = bar.ContinuousBar_OnUpdateLayout;
    bar.OnEnable = bar.ContinuousBar_OnEnable;
    bar.BarIsVisible = bar.ContinuousBar_BarIsVisible;

    -- Set the background color
    bar.status:SetBackdropColor( 0, 0, 0, 0.85 );

    -- Set the status bar color
    bar.status:SetStatusBarColor( r, g, b );

    -- Set the text color
    bar.text:SetTextColor( 1, 1, 1 );

    -- Set the status bar to draw behind the edge frame so it doesn't overlap.
    -- This should be possible with XML, but I can't figure it out with the documentation available.
    -- Would probably work if the statusbar was the parent frame to the edge frame, but that would entail a large rewrite.
    bar.status:SetFrameLevel( bar:GetFrameLevel( ) - 1 );

    return bar;

end

