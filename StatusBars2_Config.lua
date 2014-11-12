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
local kAbbreviated      = addonTable.textDisplayOptions.kAbbreviated;
local kCommaSeparated   = addonTable.textDisplayOptions.kCommaSeparated;
local kUnformatted      = addonTable.textDisplayOptions.kUnformatted;
local kHidden           = addonTable.textDisplayOptions.kHidden;

local FontInfo = addonTable.fontInfo;
local kDefaultFramePosition = addonTable.kDefaultFramePosition;


-- Tab buttons
local kGlobal       = 1;
local kGroup        = 2;
local kBar          = 3;

-------------------------------------------------------------------------------
--
--  Name:           Setting variables
--
--  Description:    Global variables needed for the settings
--
-------------------------------------------------------------------------------
--
local oldOffset = 0;
local currentScrollFrame = nil;
local currentColorSwatch = nil;

local ScrollBarButtons = {}

local TextOptions  =
{
    { label = "Abbreviated",                value = kAbbreviated },
    { label = "Thousand Separators Only",   value = kCommaSeparated },
    { label = "Unformatted",                value = kUnformatted },
    { label = "Hidden",                     value = kHidden },
}

local EnableInfo =
{
    { label = "Auto",     value = "Auto" },
    { label = "Combat",   value = "Combat" },
    { label = "Always",   value = "Always" },
    { label = "Never",    value = "Never" },
}
for i, v in ipairs( EnableInfo ) do
    EnableInfo[v.value] = EnableInfo[i];
end

local PercentTextInfo =
{
    { label = "Left",   value = "Left" },
    { label = "Right",  value = "Right" },
    { label = "Hide",   value = "Hide" },
}
for i, v in ipairs( PercentTextInfo ) do
    PercentTextInfo[v.value] = PercentTextInfo[i];
end

local LayoutTypeInfo =
{
    { label = "Auto-layout", value = "AutoLayout" },
    { label = "Locked To Group", value = "GroupLocked" },
    { label = "Locked To Background", value = "Background" },
}
for i, v in ipairs( LayoutTypeInfo ) do
    LayoutTypeInfo[v.value] = LayoutTypeInfo[i];
end

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

        if( not StatusBars2_Config ) then
            CreateFrame( "Frame", "StatusBars2_Config", StatusBars2, "StatusBars2_Config_Template" );
        end

        StatusBars2.configMode = true;
        ShowUIPanel( StatusBars2_Config );
    else
        StatusBars2.configMode = false;
    end

    -- This will set all the bars into config mode or normal mode depending on the value of StatusBars2.configMode
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

    local allPanels = {};

    -- Keep track of all the panels so we can easily go through them when we have to hide them.
    table.insert( allPanels, config_panel.globalConfigTabPage );
    table.insert( allPanels, config_panel.groupConfigTabPage );
    table.insert( allPanels, config_panel.barConfigTabPage );
    table.insert( allPanels, config_panel.continuousBarConfigTabPage );
    table.insert( allPanels, config_panel.druidManaBarConfigTabPage );
    table.insert( allPanels, config_panel.targetPowerBarConfigTabPage );
    table.insert( allPanels, config_panel.auraBarConfigTabPage );
    table.insert( allPanels, config_panel.auraStackBarConfigTabPage );
    table.insert( allPanels, config_panel.barLayoutTabPage );
    config_panel.allPanels = allPanels;

    -- Hook up the appropriate the options frames
    for i, bar in ipairs( bars ) do
        bar.configPanel = config_panel[bar.optionsPanelKey];
    end

    -- The initial show will have no bar active, so make the first bar (player health) active
    StatusBars2Config_SetBar( config_panel, bars[1] );
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_Bar_UpdateLayoutUI
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_Bar_UpdateLayoutUI( configPanel, save, bar )

    local frame = bar.configPanel;
    local layoutMenu = frame.layoutTypeMenu;

    if( save ) then
        local newLayoutType = UIDropDownMenu_GetSelectedValue( layoutMenu );

        if( bar.layoutType ~= newLayoutType ) then
            bar.layoutType = newLayoutType;
            bar.position = nil; -- Reset the position, UpdateLayout will set it to what it should be.
        end
    else
        UIDropDownMenu_SetSelectedValue( layoutMenu, bar.layoutType );
        UIDropDownMenu_SetText( layoutMenu, LayoutTypeInfo[ bar.layoutType ].label );
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_Group_UpdateLayoutUI
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_Group_UpdateLayoutUI( configPanel, save, group )

    local autoLayoutList = configPanel.groupConfigTabPage.autoLayoutList;

    -- Exchange data
    if( not save ) then
        if ( autoLayoutList ) then
            autoLayoutList.allEntries = {};
            for i, bar in ipairs( bars ) do
                if( bar.group == group.key and bar.layoutType == "AutoLayout" ) then
                    table.insert( autoLayoutList.allEntries, bar );
                end
            end

            StatusBars2_GroupOptions_AutoLayoutListUpdate( autoLayoutList );
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_UpdateLayoutUI
--
--  Description:    Exchange data between settings and controls regarding the layout
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_UpdateLayoutUI( configPanel, save, bar )

    local bar = bar or UIDropDownMenu_GetSelectedValue( configPanel.barSelectMenu );
    StatusBars2Config_Group_UpdateLayoutUI( configPanel, save, groups[ bar.group ] );
    StatusBars2Config_Bar_UpdateLayoutUI( configPanel, save, bar );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_Bar_DoDataExchange
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_Bar_DoDataExchange( configPanel, save, bar )

    local rnd = StatusBars2_Round;
    local frame = bar.configPanel;
    local group = groups[ bar.group ];
    local enabledMenu = frame.enabledMenu;
    local scaleSlider = frame.scaleSlider;
    local alphaSlider = frame.alphaSlider;
    local flashButton = frame.flashButton;
    local flashThresholdSlider = frame.flashThresholdSlider;
    local showBuffsButton = frame.showBuffsButton;
    local showDebuffsButton = frame.showDebuffsButton;
    local onlyShowSelfAurasButton = frame.onlyShowSelfAurasButton;
    local onlyShowTimedAurasButton = frame.onlyShowTimedAurasButton;
    local enableTooltipsButton = frame.enableTooltipsButton;
    local showSpellButton = frame.showSpellButton;
    local showInAllFormsButton = frame.showInAllFormsButton;
    local percentTextMenu = frame.percentTextMenu;
    local customColorButton = frame.customColorButton;
    local colorSwatch = frame.colorSwatch;
    local onlyShowListedAurasButton = frame.onlyShowListedAurasButton;
    local auraList = frame.auraList;

    -- Exchange data
    if( save ) then
        bar.enabled = UIDropDownMenu_GetSelectedValue( enabledMenu );
        bar.scale = StatusBars2_Round( scaleSlider:GetValue( ), 2 );

        if( alphaSlider ) then
            local alphaValue = StatusBars2_Round( alphaSlider:GetValue( ), 2 );
            bar.alpha = alphaValue;
        end
       if( customColorButton and colorSwatch ) then
            if( customColorButton:GetChecked( )) then
                bar.color = StatusBars2_ShallowCopy( { colorSwatch:GetBackdropColor( ) } );
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
            bar.percentDisplayOption = UIDropDownMenu_GetSelectedValue( percentTextMenu );
        end
        if( onlyShowListedAurasButton ) then
            bar.onlyShowListed = onlyShowListedAurasButton:GetChecked( );
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
        UIDropDownMenu_SetSelectedValue( enabledMenu, bar.enabled );
        UIDropDownMenu_SetText( enabledMenu, EnableInfo[ bar.enabled ].label );
        scaleSlider.applyToFrame = bar;
        scaleSlider:SetValue( bar.scale or 1 );

        if( alphaSlider ) then
            alphaSlider.applyToFrame = bar;
            alphaSlider:SetValue( bar.alpha or group.alpha or StatusBars2.alpha or 1 );
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
        if( enableTooltipsButton ) then
            enableTooltipsButton:SetChecked( bar.enableTooltips );
        end
        if( showSpellButton ) then
            showSpellButton:SetChecked( bar.showSpell );
        end
        if( showInAllFormsButton ) then
            showInAllFormsButton:SetChecked( bar.showInAllForms );
        end
        if( percentTextMenu ) then
            UIDropDownMenu_SetSelectedValue( percentTextMenu, bar.percentDisplayOption );
            UIDropDownMenu_SetText( percentTextMenu, PercentTextInfo[ bar.percentDisplayOption ].label );
        end
        if( onlyShowListedAurasButton ) then
            onlyShowListedAurasButton:SetChecked( bar.onlyShowListed );
            StatusBars2_BarOptions_Enable_Aura_List( frame, bar.onlyShowListed );
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
local function StatusBars2Config_Group_DoDataExchange( configPanel, save, group )

    local scaleSlider = configPanel.groupConfigTabPage.scaleSlider;
    local alphaSlider = configPanel.groupConfigTabPage.alphaSlider;

    -- Exchange data
    if( save ) then
        group.scale = StatusBars2_Round( scaleSlider:GetValue( ), 2 );

        if( alphaSlider ) then
            local alphaValue = StatusBars2_Round( alphaSlider:GetValue( ), 2 );
            group.alpha = alphaValue;
        end
    else
        scaleSlider.applyToFrame = group;
        scaleSlider:SetValue( group.scale or 1 );

        if( alphaSlider ) then
            alphaSlider.applyToFrame = group;
            alphaSlider:SetValue( group.alpha or StatusBars2.alpha or 1 );
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
local function StatusBars2Config_DoDataExchange( configPanel, save, bar )

    local bar = bar or UIDropDownMenu_GetSelectedValue( configPanel.barSelectMenu );

    -- Get controls
    local textOptionsMenu = configPanel.globalConfigTabPage.textDisplayOptionsMenu;
    local fontMenu = configPanel.globalConfigTabPage.fontMenu;
    local fadeButton = configPanel.globalConfigTabPage.fadeButton;
    local lockedButton = configPanel.globalConfigTabPage.lockedButton;
    local showHelpButton = configPanel.globalConfigTabPage.showHelpButton;
    local scaleSlider = configPanel.globalConfigTabPage.scaleSlider;
    local alphaSlider = configPanel.globalConfigTabPage.alphaSlider;

    -- Exchange options data
    if( save ) then
        StatusBars2.textDisplayOption = UIDropDownMenu_GetSelectedValue( textOptionsMenu );
        StatusBars2.font = UIDropDownMenu_GetSelectedValue( fontMenu );
        StatusBars2.fade = fadeButton:GetChecked( );
        StatusBars2.locked = lockedButton:GetChecked( );
        StatusBars2.scale = scaleSlider:GetValue( );
        StatusBars2.alpha = StatusBars2_Round( alphaSlider:GetValue( ), 2 );
        StatusBars2.showHelp = showHelpButton:GetChecked( );
    else
        UIDropDownMenu_SetSelectedValue( textOptionsMenu, StatusBars2.textDisplayOption );
        UIDropDownMenu_SetText( textOptionsMenu, TextOptions[StatusBars2.textDisplayOption].label );
        UIDropDownMenu_SetSelectedValue( fontMenu, StatusBars2.font );
        UIDropDownMenu_SetText( fontMenu, FontInfo[UIDropDownMenu_GetSelectedValue(fontMenu)].label );
        fadeButton:SetChecked( StatusBars2.fade );
        lockedButton:SetChecked( StatusBars2.locked );
        scaleSlider.applyToFrame = StatusBars2;
        scaleSlider:SetValue( StatusBars2.scale or 1.0 );
        alphaSlider.applyToFrame = StatusBars2;
        alphaSlider:SetValue( StatusBars2.alpha or 1.0 );
        showHelpButton:SetChecked( StatusBars2.showHelp );
    end

    StatusBars2Config_Group_DoDataExchange( configPanel, save, groups[ bar.group ] );
    StatusBars2Config_Bar_DoDataExchange( configPanel, save, bar );
    StatusBars2Config_UpdateLayoutUI( configPanel, save, bar );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_OnUpdate
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_OnUpdate( self )

    StatusBars2Config_DoDataExchange( self, true );
    StatusBars2_UpdateFullLayout( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_SetupActiveBarPanel
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_SetupActiveBarPanel( config_panel )

    local activeBar = UIDropDownMenu_GetSelectedValue( config_panel.barSelectMenu );
    local activeTabID = PanelTemplates_GetSelectedTab( config_panel );
    local panelToShow;

    if( activeTabID == kGlobal ) then
        panelToShow = config_panel.globalConfigTabPage;
        StatusBars2.moveMode = "all";
    elseif( activeTabID == kGroup ) then
        panelToShow = config_panel.groupConfigTabPage;
        StatusBars2.moveMode = "group";
    elseif( activeTabID == kBar ) then
        panelToShow = activeBar.configPanel;
        StatusBars2.moveMode = "bar";
    end

    -- layoutType "Background" means the bar is never attached to any other elements, 
    -- so override any moveMode to be "bar"
    if( StatusBars2.moveMode and activeBar.layoutType == "Background" ) then
        StatusBars2.moveMode = "bar";
    end

    -- Hide everything
    for i, v in ipairs( config_panel.allPanels ) do
        v:Hide();
    end

    -- Now show the one we decided to show
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
        -- Save the settings for the previously active bar.
        -- Skip this step if the previously active bar is null (happens on initial OnShow)
        StatusBars2Config_DoDataExchange( config_panel, true, activeBar );
    end

    -- bar == nil occurs when this is called from tab select, since no new bar is chosen
    if( bar and activeBar ~= bar ) then
        if( bar ) then
            UIDropDownMenu_SetSelectedValue( barMenu, bar );
            UIDropDownMenu_SetText( barMenu, bar.displayName );
            StatusBars2Config_DoDataExchange( config_panel, false, bar );
        end
    end

    StatusBars2Config_SetupActiveBarPanel( config_panel );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Confg_OnShow
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Confg_OnShow( self )

    -- Push the bars' states into the panel display.
    StatusBars2Config_DoDataExchange( StatusBars2_Config, false );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_TabButton_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_TabButton_OnClick( self )

    local parent = self:GetParent( );
    PanelTemplates_SetTab( parent, self:GetID() );
    StatusBars2Config_SetupActiveBarPanel( parent );

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

    StatusBars2_Config.applyChanges = true;
    HideUIPanel( StatusBars2_Config );
 
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

    HideUIPanel( StatusBars2_Config );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_RevertButton_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_RevertButton_OnClick( self )

    -- Reset the bars to the last saved state.
    StatusBars2_Settings_Apply_Settings( StatusBars2_Settings, false );

    -- Push the old state into the panel display, too.
    StatusBars2Config_DoDataExchange( StatusBars2_Config, false );

	-- Unlike cancel, don't close config mode, just update layouts
	StatusBars2_Config.doUpdate = true;
	
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_OnHide
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_OnHide( self )

    if( self.applyChanges )then

        -- Set back to false so that pressing Esc to exit the panel doesn't ever wind up saving changes
        self.applyChanges = false;

        -- Pull the last set state from the panel into the bars
        StatusBars2Config_DoDataExchange( self, true );

        -- Push the settings from the bars to the saved settings
        StatusBars2_Settings_Apply_Settings( StatusBars2_Settings, true );

    else
        -- Reset the bars to the last saved state.
        StatusBars2_Settings_Apply_Settings( StatusBars2_Settings, false );
    end

    -- Disable config mode
    StatusBars2Config_SetConfigMode( false );

end

-------------------------------------------------------------------------------
--
--  Name:           Config_Movable_OnMouseDown
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Config_Movable_OnMouseDown( self, button )

    -- Move on left button down
    if( button == 'LeftButton' ) then

        local moveMode = StatusBars2_GetMoveMode( self );

        if( moveMode == "bar" ) then
            if( StatusBars2.moveMode ~= "bar" ) then
                PanelTemplates_SetTab( StatusBars2_Config, 3 );
            end
        elseif( moveMode == "group" ) then
            PanelTemplates_SetTab( StatusBars2_Config, 2 );
        elseif( moveMode == "all" ) then
            PanelTemplates_SetTab( StatusBars2_Config, 1 );
        end

        -- In config mode, keep the last move mode even if the player isn't pressing any keys now.
        StatusBars2.moveMode = moveMode or StatusBars2.moveMode;
        StatusBars2Config_SetBar( StatusBars2_Config, self );
        StatusBars2_Movable_StartMoving( self );

    elseif( button == "RightButton" ) then

        --[[
        StatusBars2Config_RightClickMenu:ClearAllPoints( );
        StatusBars2Config_RightClickMenu:SetPoint( "TOPLEFT", self, "BOTTOMRIGHT", 5, 5 );
        StatusBars2Config_RightClickMenu.bar = self;
        StatusBars2Config_RightClickMenu:Show( );
        ]]--

    end

end

-------------------------------------------------------------------------------
--
--  Name:           Config_Movable_OnMouseUp
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function Config_Movable_OnMouseUp( self, button )

    -- Move on left button down
    if( button == 'LeftButton' ) then

        StatusBars2_Movable_StopMoving( self );

    elseif( button == "RightButton" ) then

        StatusBars2Config_RightClickMenu:Hide( );

    end

end

addonTable.Config_Movable_OnMouseUp = Config_Movable_OnMouseUp;
addonTable.Config_Movable_OnMouseDown = Config_Movable_OnMouseDown;

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

    local entry = UIDropDownMenu_CreateInfo();
    local selected = UIDropDownMenu_GetSelectedValue( self )

    for i, bar in ipairs( bars ) do
        entry.func = StatusBars2Config_BarSelect_OnClick;
        entry.arg1 = self;
        entry.value = bar;
        entry.text = bar.displayName;
        entry.checked = selected == entry.value;
        UIDropDownMenu_AddButton( entry );
    end
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_TextDisplayOptionsMenu_OnClick
--
--  Description:    Called when a menu item is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_TextDisplayOptionsMenu_OnClick( self, menu )

    UIDropDownMenu_SetSelectedValue( menu, self.value );
	StatusBars2_Config.doUpdate = true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_TextDisplayOptionsMenu_Initialize
--
--  Description:    Initialize the text display options drop down menu
--
-------------------------------------------------------------------------------
--
function StatusBars2_TextDisplayOptionsMenu_Initialize( self )

    local entry = UIDropDownMenu_CreateInfo();
    local selected = UIDropDownMenu_GetSelectedValue( self )

    for i, opt in ipairs( TextOptions ) do
        entry.func = StatusBars2_TextDisplayOptionsMenu_OnClick;
        entry.arg1 = self;
        entry.value = opt.value;
        entry.text = opt.label;
        entry.checked = selected == entry.value;
        UIDropDownMenu_AddButton( entry );
    end
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_FontMenu_OnClick
--
--  Description:    Called when a menu item is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_FontMenu_OnClick( self, menu )

    UIDropDownMenu_SetSelectedValue( menu, self.value );
	StatusBars2_Config.doUpdate = true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_FontMenu_Initialize
--
--  Description:    Initialize the text display options drop down menu
--
-------------------------------------------------------------------------------
--
function StatusBars2_FontMenu_Initialize( self )

    local entry = UIDropDownMenu_CreateInfo();
    local selected = UIDropDownMenu_GetSelectedValue( self )

    for i, info in ipairs( FontInfo ) do
        entry.func = StatusBars2_FontMenu_OnClick;
        entry.arg1 = self;
        entry.value = i;
        entry.text = info.label;
        entry.checked = selected == entry.value;
        UIDropDownMenu_AddButton( entry );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_LayoutType_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2Config_LayoutType_OnClick( self, menu  )

    UIDropDownMenu_SetSelectedValue( menu, self.value );

    -- Push the settings to the bar before we update
    StatusBars2Config_UpdateLayoutUI( StatusBars2_Config, true );

    -- Update any layout settings that change because of this change
    StatusBars2Config_UpdateLayoutUI( StatusBars2_Config, false );
    StatusBars2_Config.doUpdate = true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_LayoutTypeMenu_Initialize
--
--  Description:    Initialize the enabled drop down menu
--
-------------------------------------------------------------------------------
--
function StatusBars2_LayoutTypeMenu_Initialize( self )

    local entry = UIDropDownMenu_CreateInfo();
    local selected = UIDropDownMenu_GetSelectedValue( self )

    for i, info in ipairs( LayoutTypeInfo ) do
        entry.func = StatusBars2Config_LayoutType_OnClick;
        entry.arg1 = self;
        entry.value = info.value;
        entry.text = info.label;
        entry.checked = selected == entry.value;
        UIDropDownMenu_AddButton( entry );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarEnabledMenu_OnClick
--
--  Description:    Called when a menu item is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarEnabledMenu_OnClick( self, menu )

    UIDropDownMenu_SetSelectedValue( menu, self.value );
	StatusBars2_Config.doUpdate = true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarEnabledMenu_Initialize
--
--  Description:    Initialize the enabled drop down menu
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarEnabledMenu_Initialize( self )

    local entry = UIDropDownMenu_CreateInfo();
    local selected = UIDropDownMenu_GetSelectedValue( self )

    for i, info in ipairs( EnableInfo ) do
        entry.func = StatusBars2_BarEnabledMenu_OnClick;
        entry.arg1 = self;
        entry.value = info.value;
        entry.text = info.label;
        entry.checked = selected == entry.value;
        UIDropDownMenu_AddButton( entry );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PercentTextMenu_OnClick
--
--  Description:    Called when a menu item is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_PercentTextMenu_OnClick( self, menu )

    UIDropDownMenu_SetSelectedValue( menu, self.value );
	StatusBars2_Config.doUpdate = true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PercentTextMenu_Initialize
--
--  Description:    Initialize the percent text drop down menu
--
-------------------------------------------------------------------------------
--
function StatusBars2_PercentTextMenu_Initialize( self )

    local entry = UIDropDownMenu_CreateInfo();
    local selected = UIDropDownMenu_GetSelectedValue( self )

    for i, info in ipairs( PercentTextInfo ) do
        entry.func = StatusBars2_PercentTextMenu_OnClick;
        entry.arg1 = self;
        entry.value = info.value;
        entry.text = info.label;
        entry.checked = selected == entry.value;
        UIDropDownMenu_AddButton( entry );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_Check_Enable_Aura_List_Buttons
--
--  Description:    Enable / disable buttons that perform operations on the aura list depending on if they are currently usable.
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_Check_Enable_Aura_List_Buttons( scrollFrame )

    local num_entries = 0;
    if scrollFrame.allEntries then
        num_entries = #scrollFrame.allEntries;
    end

    local deleteEntryButton = scrollFrame:GetParent( ).deleteEntryButton;
    local clearListButton = scrollFrame:GetParent( ).clearListButton

    -- Buttons are nil on the initial update because the buttons get created after the list
    if( deleteEntryButton and clearListButton ) then
        local should_enable_clear_button = num_entries > 0 and scrollFrame.isEnabled;
        local should_enabled_delete_button = should_enable_clear_button and scrollFrame.selectedIndex;

        if( should_enable_clear_button ) then
            clearListButton:Enable( );
        else
            clearListButton:Disable( );
        end

        if( should_enabled_delete_button ) then
            deleteEntryButton:Enable( );
        else
            deleteEntryButton:Disable( );
        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_Enable_Aura_List
--
--  Description:    Enable / disable user input for the aura list
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_Enable_Aura_List( frame, is_enabled )

    local aura_list = frame.auraList
    local aura_editbox = frame.auraNameInput

    aura_list.isEnabled = is_enabled;
    local buttons = aura_list.buttons;

    for i, entry in ipairs(buttons) do
        if is_enabled then
            entry:Enable();
        else
            entry:Disable();
        end
    end

    if( is_enabled ) then
        aura_editbox:Enable( );
    else
        aura_editbox:Disable( );
    end

    StatusBars2_BarOptions_Check_Enable_Aura_List_Buttons( aura_list );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_AddAuraFilterEntry
--
--  Description:    Add an aura name to the aura filter list
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_AddAuraFilterEntry( self )

    local aura_list = self:GetParent().auraList;
    local buttons = aura_list.buttons;

    if aura_list.allEntries == nil then
        aura_list.allEntries = {};
    end

    local numEntries = #aura_list.allEntries;
    local aura_name = self:GetText( );
    
    table.insert( aura_list.allEntries, aura_name );
    table.sort( aura_list.allEntries );
    StatusBars2_BarOptions_AuraListUpdate( aura_list );

    self:ClearFocus();

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_AuraListUpdate
--
--  Description:    Select an item in the list of aura names
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_AuraListUpdate( self )

    if self then
        currentScrollFrame = self;
    end

    if currentScrollFrame then

        local scrollFrame = currentScrollFrame;
        local offset = HybridScrollFrame_GetOffset(scrollFrame);

        if self or offset ~= oldOffset then
            oldOffset = offset;

            local buttons = scrollFrame.buttons;
            local button_height = buttons[1]:GetHeight();

            for i, entry in ipairs(buttons) do
                local index = i + offset;

                if scrollFrame.allEntries and scrollFrame.allEntries[index] then
                    entry:SetText( scrollFrame.allEntries[index] );
                    entry:Show();
                    entry.index = index;

                    if scrollFrame.selectedIndex == index then
                        entry:LockHighlight( );
                    else
                        entry:UnlockHighlight( );
                    end

                else
                    entry:Hide();
                end
            end

            local num_entries = 0;
            if scrollFrame.allEntries then
                num_entries = #scrollFrame.allEntries;
            end

            StatusBars2_BarOptions_Check_Enable_Aura_List_Buttons( scrollFrame );
            HybridScrollFrame_Update(scrollFrame, num_entries * button_height, scrollFrame:GetHeight());
        end
    end
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_ListEntryButton_OnClick
--
--  Description:    Select an item in the list of aura names
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_ListEntryButton_OnClick( self, button, down )

    local scrollFrame = self:GetParent( ):GetParent( );

    scrollFrame.selectedIndex = self.index;
    scrollFrame:update( );

    HybridScrollFrameScrollButton_OnClick ( self, button, down );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_DeleteAuraFilterListEntry_OnClick
--
--  Description:    Delete an aura name from the aura filter list
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_DeleteAuraFilterListEntry_OnClick( self )

    local aura_list = self:GetParent().auraList;

    if aura_list.selectedIndex then
        table.remove(aura_list.allEntries, aura_list.selectedIndex);
    end

    aura_list.selectedIndex = nil;
    StatusBars2_BarOptions_AuraListUpdate( aura_list );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_ClearAuraFilterList_OnClick
--
--  Description:    Add an aura name to the aura filter list
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_ClearAuraFilterList_OnClick( self )

    local aura_list = self:GetParent().auraList;
    aura_list.allEntries = nil;
    StatusBars2_BarOptions_AuraListUpdate( aura_list );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_Enable_ColorSelectButton
--
--  Description:    Enable / disable user input for the color select button
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_Enable_ColorSelectButton( frame, is_enabled )

    local color_select_button = frame.pickColorButton;

    if( is_enabled ) then
        color_select_button:Enable( );
    else
        color_select_button:Disable( );
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_OnSetBarColor
--
--  Description:    Called when the set bar color button is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_OnSetBarColor( restore )

    if( currentColorSwatch ) then
        local r,g,b;

        if( restore ) then
            r,g,b = unpack( restore )
        else
            r,g,b = ColorPickerFrame:GetColorRGB( );
        end

        currentColorSwatch:SetBackdropColor( r, g, b );
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_SetBarColorButton_OnClick
--
--  Description:    Called when the set bar color button is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_SetBarColorButton_OnClick( frame )

    local colorSwatch = frame.colorSwatch;
    local r,g,b = colorSwatch:GetBackdropColor( );

    -- ColorPickerFrame:SetColorRGB will call ColorPickerFrame:func, so the color
    -- swatch needs to be set before we call SetColorRGB
    currentColorSwatch = colorSwatch;
    ColorPickerFrame.func = StatusBars2_Options_OnSetBarColor;
    ColorPickerFrame.opacityFunc = StatusBars2_Options_OnSetBarColor;
    ColorPickerFrame.cancelFunc = StatusBars2_Options_OnSetBarColor;
    ColorPickerFrame:SetColorRGB(r,g,b);
    ColorPickerFrame.hasOpacity = false;
    ColorPickerFrame.opacity = 1;
    ColorPickerFrame.previousValues = {r,g,b};

    ShowUIPanel(ColorPickerFrame);

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_ResetBarPositionButton_OnClick
--
--  Description:    Called when the reset bar positions button is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_ResetBarPositionButton_OnClick( self )

    -- Set a flag and reset the positions if the OK button is clicked
    --StatusBars2_Options.resetBarPositions = true;
    for i, bar in ipairs( bars ) do
        bar.layoutType = "AutoLayout";
        bar.position = nil;
    end

    -- Change the layout UI elements to match the new settings or the new settings will get 
    -- nuked when we do the DoDataExchange in StatusBars2Config_OnUpdate
    StatusBars2Config_UpdateLayoutUI( StatusBars2_Config, false );
	StatusBars2_Config.doUpdate = true;
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_ResetGroupPositionButton_OnClick
--
--  Description:    Called when the reset group positions button is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_ResetGroupPositionButton_OnClick( self )

    -- Set a flag and reset the positions if the OK button is clicked
    --StatusBars2_Options.resetGroupPositions = true;
    for i, group in ipairs( groups ) do
        group.position = nil;
    end

    local x, y = UIParent:GetCenter( );
    StatusBars2_Movable_SetPosition( StatusBars2, x + kDefaultFramePosition.x, y + kDefaultFramePosition.y, true );
	StatusBars2_Config.doUpdate = true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarOptions_AutoLayoutListEntryButton_OnClick
--
--  Description:    Select an item in the list of aura names
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_AutoLayoutListEntryButton_OnClick( self, button, down )

    local scrollFrame = self:GetParent( ):GetParent( );

    scrollFrame.selectedIndex = self.index;
    scrollFrame:update( );

    HybridScrollFrameScrollButton_OnClick ( self, button, down );

    scrollFrame:GetParent( ).moveUpButton:Enable( );
    scrollFrame:GetParent( ).moveDownButton:Enable( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GroupOptions_AutoLayout_UpdateSelectedIndex
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2_GroupOptions_AutoLayout_UpdateSelectedIndex( scrollFrame, newSelectedIndex )

    scrollFrame.selectedIndex = newSelectedIndex
    local height = math.max(0, math.floor(scrollFrame.buttonHeight * (newSelectedIndex - (#scrollFrame.buttons)/2)));
    HybridScrollFrame_SetOffset(scrollFrame, height);
    scrollFrame:update( );
    scrollFrame.scrollBar:SetValue(height);

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GroupOptions_AutoLayoutUp_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2_GroupOptions_AutoLayoutUp_OnClick( self )

    local scrollFrame = self:GetParent( ).autoLayoutList;
    local selectedIndex = scrollFrame.selectedIndex;

    -- Only do something if this is not already the first bar in the list
    if( selectedIndex > 1 ) then
        local bar = scrollFrame.allEntries[selectedIndex];
        local upperBar = scrollFrame.allEntries[ selectedIndex - 1 ];

        -- swap indices
        bar.index, upperBar.index = upperBar.index, bar.index;

        StatusBars2_GroupOptions_AutoLayout_UpdateSelectedIndex( scrollFrame, selectedIndex - 1 );
        StatusBars2_Config.doUpdate = true;

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GroupOptions_AutoLayoutDown_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2_GroupOptions_AutoLayoutDown_OnClick( self )

    local scrollFrame = self:GetParent( ).autoLayoutList;
    local selectedIndex = scrollFrame.selectedIndex;

    -- Only do something if this is not already the last bar in the list
    if( selectedIndex < #scrollFrame.allEntries ) then

        local bar = scrollFrame.allEntries[selectedIndex];
        local lowerBar = scrollFrame.allEntries[ selectedIndex + 1 ];

        -- swap indices
        bar.index, lowerBar.index = lowerBar.index, bar.index;

        StatusBars2_GroupOptions_AutoLayout_UpdateSelectedIndex( scrollFrame, selectedIndex + 1 );
        StatusBars2_Config.doUpdate = true;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarCompareFunction
--
--  Description:    Function for comparing two bars
--
-------------------------------------------------------------------------------
--
local function StatusBars2_AutoLayout_BarCompareFunction( bar1, bar2 )

    return bar1.index < bar2.index;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GroupOptions_AutoLayoutListUpdate
--
--  Description:    Select an item in the list of aura names
--
-------------------------------------------------------------------------------
--
function StatusBars2_GroupOptions_AutoLayoutListUpdate( scrollFrame )

    local offset = HybridScrollFrame_GetOffset(scrollFrame);

    if( scrollFrame.allEntries ) then
        table.sort( scrollFrame.allEntries, StatusBars2_AutoLayout_BarCompareFunction );
    end

    local buttons = scrollFrame.buttons;
    local selectedIndex = scrollFrame.selectedIndex;
    local bar, barIndex;

    for i, entry in ipairs(buttons) do
        barIndex = i + offset;

        if scrollFrame.allEntries and scrollFrame.allEntries[barIndex] then

            bar = scrollFrame.allEntries[barIndex];
            entry.index = barIndex;
            entry:SetText( bar.displayName );
            entry:Show();

            if( selectedIndex == barIndex ) then
                entry:LockHighlight( );
            else
                entry:UnlockHighlight( );
            end

        else
            entry:Hide();
        end
    end

    local num_entries = scrollFrame.allEntries and #scrollFrame.allEntries or 0;
    HybridScrollFrame_Update(scrollFrame, num_entries * scrollFrame.buttonHeight, scrollFrame:GetHeight());
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_RightClickMenu_OnShow
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_RightClickMenu_OnShow( self )

    local bar = self.bar;
    
    if bar then
        UIDropDownMenu_SetSelectedValue( self, bar.enabled );
    end

end

--[[
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

    for i = num_buttons + 1, num_buttons_needed do
        button_frame = CreateFrame("Button", "ScrollButton"..i, StatusBars2_Config_BarSelectScrollFrame, StatusBar2_BarListEntryButtonTemplate);
        table.insert( ScrollBarButtons, button_frame );
    end


    num_buttons = #ScrollBarButtons;

    local offset = FauxScrollFrame_GetOffset(StatusBars2_Config_BarSelectScrollFrame);

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

    --FauxScrollFrame_Update(StatusBars2_Config_BarSelectScrollFrame, list_length, num_buttons_needed, button_height);
    FauxScrollFrame_Update(StatusBars2_Config_BarSelectScrollFrame,list_length,14,15);

end
--]]

