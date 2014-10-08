-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


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

local groups = addonTable.groups;
local bars = addonTable.bars;

-- Text display options
local kAbbreviated      = 1;
local kCommaSeparated   = 2;
local kUnformatted      = 3;
local kHidden           = 4;

local TextOptionLabels =
{
    "Abbreviated",
    "Thousand Separators Only",
    "Unformatted",
    "Hidden",
}

-- Tab buttons
local kGlobal       = 1;
local kGroup        = 2;
local kBarLayout    = 3;
local kBarOptions   = 4;

local FontInfo = addonTable.fontInfo;

local SB2Config_DropdownInfo = UIDropDownMenu_CreateInfo();  -- We only need one of these, we'll use it everywhere for efficiency

local ScrollBarButtons = {}

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_SetConfigMode
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_SetConfigMode( enable )

    if( StatusBars2.configMode == enable ) then
        return
    end

    if( enable ) then
        StatusBars2_Settings_Apply_Settings( false, StatusBars2_Settings )
        StatusBars2.configMode = true;
        --StatusBars2_Config:Show( );
        ShowUIPanel( StatusBars2_Config );
    else
        StatusBars2.configMode = false;
        --StatusBars2_Config:Hide( );
        HideUIPanel( StatusBars2_Config );
    end

    print("=======Config mode:", StatusBars2.configMode, "=========");
    -- Update the bar visibility and location
    StatusBars2_UpdateBars( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_Configure_Bar_Options
--
--  Description:    Configure the options panel for the bars
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_Configure_Bar_Options( config_panel )

    local initialActiveBar;
    local allPanels = {};

    -- Keep track of all the panels so we can easily go through them when we have to hide them.
    table.insert(allPanels, config_panel.globalConfigTabPage);
    table.insert(allPanels, config_panel.groupConfigTabPage);
    table.insert(allPanels, config_panel.barLayoutTabPage);
    table.insert(allPanels, config_panel.barOptionsTabPage);
    table.insert(allPanels, config_panel.continuousBarOptionsTabPage);
    table.insert(allPanels, config_panel.druidManaBarOptionsTabPage);
    table.insert(allPanels, config_panel.targetPowerBarOptionsTabPage);
    table.insert(allPanels, config_panel.auraBarOptionsTabPage);
    table.insert(allPanels, config_panel.auraStackBarOptionsTabPage);
    config_panel.allPanels = allPanels;

    -- Add a category for each bar
    for i, bar in ipairs( bars ) do
        if( i == 1 ) then
            initialActiveBar = bar;
        end
        -- Hook up the appropriate the options frame
        bar.optionsPanel = config_panel[bar.optionsPanelKey];
    end

    return initialActiveBar
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_Bar_DoDataExchange
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_Bar_DoDataExchange( configPanel, bar, save )

    local rnd = StatusBars2_Round;
    local frame = bar.optionsPanel;
    local group = groups[bar.group];
    local enabledMenu = frame.enabledMenu;
    local scaleSlider = configPanel.barLayoutTabPage.scaleSlider;
    local alphaSlider = configPanel.barLayoutTabPage.alphaSlider;
    local flashButton = frame.flashButton;
    local flashThresholdSlider = frame.flashThresholdSlider;
    local showBuffsButton = frame.showBuffsButton;
    local showDebuffsButton = frame.showDebuffsButton;
    local onlyShowSelfAurasButton = frame.onlyShowSelfAurasButton;
    local onlyShowTimedAurasButton = frame.onlyShowTimedAurasButton;
    local onlyShowListedAurasButton = frame.onlyShowListedAurasButton;
    local enableTooltipsButton = frame.enableTooltipsButton;
    local showSpellButton = frame.showSpellButton;
    local showInAllFormsButton = frame.showInAllFormsButton;
    local percentTextMenu = frame.percentTextMenu;
    local auraList = frame.auraList;
    local customColorButton = frame.customColorButton;
    local colorSwatch = frame.colorSwatch;

    -- Exchange data
    if( save ) then
        print("Saving ", bar.key, " old scale = ", rnd(bar.scale));
        bar.enabled = UIDropDownMenu_GetSelectedName( enabledMenu );
        bar.scale = StatusBars2_Round( scaleSlider:GetValue( ), 2 );
        print("Scale = ", rnd(bar.scale));

        if( alphaSlider ) then
            local alphaValue = StatusBars2_Round( alphaSlider:GetValue( ) / 100, 2 );
            bar.alpha = alphaValue;
        end
       if( customColorButton and colorSwatch ) then
            if( customColorButton:GetChecked( )) then
                bar.color = shallowCopy({colorSwatch:GetBackdropColor( )});
            else
                bar.color = nil;
            end
        end
        if( flashButton ) then
            bar.flash = flashButton:GetChecked( );
            bar.flashThreshold = StatusBars2_Round( flashThresholdSlider:GetValue( ), 2 );
        end
        if( showBuffsButton ) then
            bar.showBuffs = showBuffsButton:GetChecked( );
        end
        if( showDebuffsButton ) then
            bar.showDebuffs = showDebuffsButton:GetChecked( );
        end
        if( onlyShowSelfAurasButton ) then
            bar.onlyShowSelf = onlyShowSelfAurasButton:GetChecked( );
        end
        if( onlyShowTimedAurasButton ) then
            bar.onlyShowTimed = onlyShowTimedAurasButton:GetChecked( );
        end
        if( onlyShowListedAurasButton ) then
            bar.onlyShowListed = onlyShowListedAurasButton:GetChecked( );
        end
        if( enableTooltipsButton ) then
            bar.enableTooltips = enableTooltipsButton:GetChecked( );
        end
        if( showSpellButton ) then
            bar.showSpell = showSpellButton:GetChecked( );
        end
        if( showInAllFormsButton ) then
            bar.showInAllForms = showInAllFormsButton:GetChecked( );
        end
        if( percentTextMenu ) then
            bar.percentDisplayOption = UIDropDownMenu_GetSelectedName( percentTextMenu );
        end
        if( auraList ) then
            if( auraList.allEntries and #auraList.allEntries > 0 ) then
                bar.auraFilter = {};
                
                for i, entry in ipairs(auraList.allEntries) do
                    bar.auraFilter[entry] = true;
                end
            else
                bar.auraFilter = nil;
            end
        end

    else
        UIDropDownMenu_SetSelectedName( enabledMenu, bar.enabled );
        UIDropDownMenu_SetText( enabledMenu, bar.enabled );
        scaleSlider.applyToFrame = bar;
        scaleSlider:SetValue( bar.scale or 1 );

        if( alphaSlider ) then
            alphaSlider.applyToFrame = bar;
            alphaSlider:SetValue( ( bar.alpha or group.alpha or StatusBars2.alpha or 1 ) * 100 );
        end
        if( customColorButton and colorSwatch ) then
            local customColorEnabled = bar.color ~= nil;
            customColorButton:SetChecked( customColorEnabled );
            StatusBars2_BarOptions_Enable_ColorSelectButton( frame );
            colorSwatch:SetBackdropColor( bar:GetColor( ) );
        end
        if( flashButton ) then
            flashButton:SetChecked( bar.flash );
            flashThresholdSlider:SetValue( bar.flashThreshold );
        end
        if( showBuffsButton ) then
            showBuffsButton:SetChecked( bar.showBuffs );
        end
        if( showDebuffsButton ) then
            showDebuffsButton:SetChecked( bar.showDebuffs );
        end
        if( onlyShowSelfAurasButton ) then
            onlyShowSelfAurasButton:SetChecked( bar.onlyShowSelf );
        end
        if( onlyShowTimedAurasButton ) then
            onlyShowTimedAurasButton:SetChecked( bar.onlyShowTimed );
        end
        if( onlyShowListedAurasButton ) then
            onlyShowListedAurasButton:SetChecked( StatusBars2_Settings.bars[ bar.key ].onlyShowListed );
            StatusBars2_BarOptions_Enable_Aura_List( frame, StatusBars2_Settings.bars[ bar.key ].onlyShowListed );
        end
        if( enableTooltipsButton ) then
            enableTooltipsButton:SetChecked( StatusBars2_Settings.bars[ bar.key ].enableTooltips );
        end
        if( showSpellButton ) then
            showSpellButton:SetChecked( StatusBars2_Settings.bars[ bar.key ].showSpell );
        end
        if( showInAllFormsButton ) then
            showInAllFormsButton:SetChecked( StatusBars2_Settings.bars[ bar.key ].showInAllForms );
        end
        if( percentTextMenu ) then
            UIDropDownMenu_SetSelectedName( percentTextMenu, StatusBars2_Settings.bars[ bar.key ].percentDisplayOption );
            UIDropDownMenu_SetText( percentTextMenu, StatusBars2_Settings.bars[ bar.key ].percentDisplayOption );
        end
        if ( auraList ) then
            if( bar.auraFilter ) then
                auraList.allEntries = {};
                local i = 1;
                for name in pairs(bar.auraFilter) do
                    auraList.allEntries[i] = name;
                    i = i + 1;
                end
                
                table.sort(auraList.allEntries);
            else
                auraList.allEntries = nil;
            end

            StatusBars2_BarOptions_AuraListUpdate( auraList );
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_Group_DoDataExchange
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_Group_DoDataExchange( configPanel, bar, save )

    print("DDE group ", bar.group);
    local group = groups[bar.group];
    local scaleSlider = configPanel.groupConfigTabPage.scaleSlider;
    local alphaSlider = configPanel.groupConfigTabPage.alphaSlider;

    -- Exchange data
    if( save ) then
        group.scale = StatusBars2_Round( scaleSlider:GetValue( ), 2 );

        if( alphaSlider ) then
            local alphaValue = StatusBars2_Round( alphaSlider:GetValue( ) / 100, 2 );
            group.alpha = alphaValue;
        end
    else
        scaleSlider.applyToFrame = group;
        scaleSlider:SetValue( group.scale or 1 );

        if( alphaSlider ) then
            alphaSlider.applyToFrame = group;
            alphaSlider:SetValue( ( group.alpha or StatusBars2.alpha or 1 ) * 100 );
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_DoDataExchange
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_DoDataExchange( configPanel, bar, save )

    -- Get controls
    local textOptionsMenu = configPanel.globalConfigTabPage.textDisplayOptionsMenu;
    local fontMenu = configPanel.globalConfigTabPage.fontMenu;
    local fadeButton = configPanel.globalConfigTabPage.fadeButton;
    local lockedButton = configPanel.globalConfigTabPage.lockedButton;
    local groupedButton = configPanel.globalConfigTabPage.groupedButton;
    local groupsLockedTogetherButton = configPanel.globalConfigTabPage.groupsLockedTogetherButton;
    local scaleSlider = configPanel.globalConfigTabPage.scaleSlider;
    local alphaSlider = configPanel.globalConfigTabPage.alphaSlider;

    -- Exchange options data
    if( save ) then
        StatusBars2.textDisplayOption = UIDropDownMenu_GetSelectedValue( textOptionsMenu );
        StatusBars2.font = UIDropDownMenu_GetSelectedValue( fontMenu );
        StatusBars2.fade = fadeButton:GetChecked( );
        StatusBars2.locked = lockedButton:GetChecked( );
        StatusBars2.grouped = groupedButton:GetChecked( );
        StatusBars2.groupsLocked = groupsLockedTogetherButton:GetChecked( );
        StatusBars2.scale = scaleSlider:GetValue( );
        StatusBars2.alpha = StatusBars2_Round( alphaSlider:GetValue( ) / 100, 2 );
    else
        UIDropDownMenu_SetSelectedValue( textOptionsMenu, StatusBars2.textDisplayOption );
        UIDropDownMenu_SetText( textOptionsMenu, TextOptionLabels[StatusBars2.textDisplayOption] );
        UIDropDownMenu_SetSelectedValue( fontMenu, StatusBars2.font );
        UIDropDownMenu_SetText( fontMenu, FontInfo[UIDropDownMenu_GetSelectedValue(fontMenu)].label );
        fadeButton:SetChecked( StatusBars2.fade );
        lockedButton:SetChecked( StatusBars2.locked );
        groupedButton:SetChecked( StatusBars2.grouped );
        groupsLockedTogetherButton:SetChecked( StatusBars2.groupsLocked );
        scaleSlider.applyToFrame = StatusBars2;
        scaleSlider:SetValue( StatusBars2.scale or 1.0 );
        alphaSlider.applyToFrame = StatusBars2;
        alphaSlider:SetValue( (StatusBars2.alpha or 1.0 ) * 100 );
    end

    StatusBars2Config_Group_DoDataExchange( configPanel, bar, save );
    StatusBars2Config_Bar_DoDataExchange( configPanel, bar, save );

end
-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_ShowActivePanel
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_ShowActivePanel( config_panel )

    local activeBar = UIDropDownMenu_GetSelectedValue( config_panel.barSelectMenu );
    local activeTabID = PanelTemplates_GetSelectedTab( config_panel );
    local panelToShow;

    -- Figure out which panel we are going to show
    if( activeTabID == kGlobal ) then
        panelToShow = config_panel.globalConfigTabPage;
    elseif( activeTabID == kGroup ) then
        panelToShow = config_panel.groupConfigTabPage;
    elseif( activeTabID == kBarLayout ) then
        panelToShow = config_panel.barLayoutTabPage;
    elseif( activeTabID == kBarOptions ) then
        panelToShow = activeBar.optionsPanel;
    end
    
    -- Hide everything except for the one we are planning on showing
    for i, v in ipairs( config_panel.allPanels ) do
        if( v ~= panelToShow ) then
            v:Hide();
        end
    end

    -- Now show it
    panelToShow:Show( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_SetBar
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_SetBar( config_panel, bar )

    local barMenu = config_panel.barSelectMenu;
    local activeBar = UIDropDownMenu_GetSelectedValue( barMenu );

    if( activeBar ) then
        print("Saving bar ", activeBar.key);
        -- Save the settings for the previously active bar.
        -- Skip this step if the previously active bar is null (happens on initial OnShow)
        StatusBars2Config_DoDataExchange( config_panel, activeBar, true );
    end

    -- bar == nil occurs when this is called from tab select, since no new bar is chosen
    if( bar and activeBar ~= bar ) then
        if( bar ) then
            UIDropDownMenu_SetSelectedValue( barMenu, bar );
            UIDropDownMenu_SetText( barMenu, bar.displayName );
            print("Loading bar ", bar.key);
            StatusBars2Config_DoDataExchange( config_panel, bar, false );
        end
    end

    StatusBars2Config_ShowActivePanel( config_panel );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBar2_TabContainer_OnShow
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBar2_TabContainer_OnShow( self )

    local desiredActiveBar = UIDropDownMenu_GetSelectedValue( self.barSelectMenu );

    if( desiredActiveBar == nil ) then
        -- Initialize the config panel and get a bar to set the panel to on it's 
        -- initial open. We have to wait until the OnShow for this because the bars 
        -- might not exist yet when OnLoad is called
        desiredActiveBar = StatusBars2Config_Configure_Bar_Options( self );
    end

    StatusBars2Config_DoDataExchange( self, desiredActiveBar, false );
    StatusBars2Config_SetBar( self, desiredActiveBar );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_TabButtonOnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2_TabButtonOnClick( self )

    local parent = self:GetParent( );
    PanelTemplates_SetTab( parent, self:GetID() );
    StatusBars2Config_SetBar( parent );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_OKButton_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_OKButton_OnClick( self )

    print("======= Config mode: StatusBars2Config_OKButton_OnClick =========");

    -- Pull the settings from the panel into the bars
    local activeBar = UIDropDownMenu_GetSelectedValue( self:GetParent( ).barSelectMenu );
    StatusBars2Config_DoDataExchange( self:GetParent( ), activeBar, true );

    -- Now push the settings from the bars to the saved settings
    StatusBars2_Settings_Apply_Settings( true, StatusBars2_Settings );

    -- Disable config mode
    StatusBars2Config_SetConfigMode( false );
 
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_CancelButton_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_CancelButton_OnClick( self )

    -- Reset the bars to the last saved state.
    StatusBars2_Settings_Apply_Settings( false, StatusBars2_Settings );

    -- Disable config mode
    StatusBars2Config_SetConfigMode( false );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_DefaultButton_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_DefaultButton_OnClick( self )

    -- Disable config mode
    StatusBars2Config_SetConfigMode( false );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_BarSelect_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_BarSelect_OnClick( self, menu  )

    StatusBars2Config_SetBar( menu:GetParent( ), self.value );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_BarSelect_Initialize
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_BarSelect_Initialize( self )

    local entry = SB2Config_DropdownInfo;

    for i, bar in ipairs( bars ) do
        entry.func = StatusBars2Config_BarSelect_OnClick;
        entry.arg1 = self;
        entry.value = bar;
        entry.text = bar.displayName;
        entry.checked = UIDropDownMenu_GetSelectedValue( self ) == entry.value;
        UIDropDownMenu_AddButton( entry );
    end
    
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
        StatusBars2Config_SetBar( StatusBars2_Config, self );
        StatusBars2_StatusBar_OnMouseDown( self, button );
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

    StatusBars2_StatusBar_OnMouseUp( self, button );

end

addonTable.Config_Bar_OnMouseUp = Config_Bar_OnMouseUp;
addonTable.Config_Bar_OnMouseDown = Config_Bar_OnMouseDown;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_BarSelectScrollBar_Update
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_BarSelectScrollBar_Update()
   
    local rnd = StatusBars2_Round;

    local button_height = 13;
    local frame_height = StatusBars2_Config_BarSelectScrollFrame:GetHeight( );
    local num_buttons = #ScrollBarButtons;
    local num_buttons_needed = rnd(frame_height / button_height) + 1;
    local button_frame;
    local list_length = #bars;

    num_buttons_needed = num_buttons_needed < list_length and num_buttons_needed or list_length;
    ---[[
    for i = num_buttons + 1, num_buttons_needed do
        button_frame = CreateFrame("Button", "ScrollButton"..i, StatusBars2_Config_BarSelectScrollFrame, StatusBar2_BarListEntryButtonTemplate);
        table.insert( ScrollBarButtons, button_frame );
    end
    --]]

    num_buttons = #ScrollBarButtons;

    local offset = FauxScrollFrame_GetOffset(StatusBars2_Config_BarSelectScrollFrame);
    --[[
    for i = 1, num_buttons_needed do
        lineplusoffset = i + offset;

        if lineplusoffset <= list_length then
            button_frame = ScrollBarButtons[i];
            bar = bars[lineplusoffset];
            button_frame:SetText( bar.displayText );
            button_frame:Show( );
        else
            button_frame:Hide( );
        end
    end
    --]]

    --FauxScrollFrame_Update(StatusBars2_Config_BarSelectScrollFrame, list_length, num_buttons_needed, button_height);
    FauxScrollFrame_Update(StatusBars2_Config_BarSelectScrollFrame,list_length,14,15);

end

