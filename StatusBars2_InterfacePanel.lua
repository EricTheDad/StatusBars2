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

local FontInfo = addonTable.fontInfo;

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

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_OnLoad
--
--  Description:    Options frame OnLoad handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_OnLoad( self )

    -- Setup the top level category
    self.name = "StatusBars2";
    self.okay = StatusBars2_Options_OnOK;
    self.cancel = StatusBars2_Options_OnCancel;
    InterfaceOptions_AddCategory( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_Configure_Bar_Options
--
--  Description:    Configure the options panel for the bars
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_Configure_Bar_Options(  )

    -- Add a category for each bar
    for i, bar in ipairs( bars ) do

        -- Create the option frame
        local frame = CreateFrame( "Frame", bar:GetName( ) .. "_OptionFrame", StatusBars2_Options, bar.optionsTemplate );

        -- Initialize the frame
        frame.name = bar.displayName;
        frame.parent = "StatusBars2";
        frame.bar = bar;

        -- Add it
        InterfaceOptions_AddCategory( frame );

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_OnOK
--
--  Description:    Called when the OK button is pressed in the options panel
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_OnOK( )

    -- Update the settings
    StatusBars2_Options_DoDataExchange( true );

    -- If the reset position button was pressed null out the position data
    if( StatusBars2_Options.resetGroupPositions ) then
        StatusBars2_Settings.position = nil;

        for i, group in ipairs( groups ) do
            StatusBars2_Settings.groups[ i ].position = nil;
        end
    end

    if( StatusBars2_Options.resetBarPositions ) then
        for i, bar in ipairs( bars ) do
            StatusBars2_Settings.bars[ bar.key ].position = nil;
        end
    end

    -- Apply the settings to the active bars
    StatusBars2_Settings_Apply_Settings( false, StatusBars2_Settings );

    -- Update the bar visibility and location
    StatusBars2_UpdateBars( );

    -- Reset the position flag
    StatusBars2_Options.resetGroupPositions = false;
    StatusBars2_Options.resetBarPositions = false;


end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_OnCancel
--
--  Description:    Called when the Cancel button is pressed in the options panel
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_OnCancel( )

    -- Revert changes
    StatusBars2_Options.resetBarPositions = false;
    StatusBars2_Options_DoDataExchange( false );

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

    -- Abbreviated
    local abbreviated = UIDropDownMenu_CreateInfo();
    abbreviated.func = StatusBars2_TextDisplayOptionsMenu_OnClick;
    abbreviated.arg1 = self;
    abbreviated.value = kAbbreviated;
    abbreviated.text = TextOptionLabels[kAbbreviated];
    UIDropDownMenu_AddButton( abbreviated );

    -- Broken up
    local brokenup = UIDropDownMenu_CreateInfo();
    brokenup.func = StatusBars2_TextDisplayOptionsMenu_OnClick;
    brokenup.arg1 = self;
    brokenup.value = kCommaSeparated;
    brokenup.text = TextOptionLabels[kCommaSeparated];
    UIDropDownMenu_AddButton( brokenup );

    -- Old School
    local oldschool = UIDropDownMenu_CreateInfo();
    oldschool.func = StatusBars2_TextDisplayOptionsMenu_OnClick;
    oldschool.arg1 = self;
    oldschool.value = kUnformatted;
    oldschool.text = TextOptionLabels[kUnformatted];
    UIDropDownMenu_AddButton( oldschool );

    -- Hidden
    local hidden = UIDropDownMenu_CreateInfo();
    hidden.func = StatusBars2_TextDisplayOptionsMenu_OnClick;
    hidden.arg1 = self;
    hidden.value = kHidden;
    hidden.text = TextOptionLabels[kHidden];
    UIDropDownMenu_AddButton( hidden );

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

    for i, info in ipairs( FontInfo ) do
        entry.func = StatusBars2_FontMenu_OnClick;
        entry.arg1 = self;
        entry.value = i;
        entry.text = info.label;
        entry.checked = UIDropDownMenu_GetSelectedValue( self ) == i;
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

    -- Auto
    local auto = UIDropDownMenu_CreateInfo();
    auto.func = StatusBars2_BarEnabledMenu_OnClick;
    auto.arg1 = self;
    auto.text = "Auto";
    UIDropDownMenu_AddButton( auto );

    -- Combat
    local combat = UIDropDownMenu_CreateInfo();
    combat.func = StatusBars2_BarEnabledMenu_OnClick;
    combat.arg1 = self;
    combat.text = "Combat";
    UIDropDownMenu_AddButton( combat );

    -- Always
    local always = UIDropDownMenu_CreateInfo();
    always.func = StatusBars2_BarEnabledMenu_OnClick;
    always.arg1 = self;
    always.text = "Always";
    UIDropDownMenu_AddButton( always );

    -- Never
    local never = UIDropDownMenu_CreateInfo();
    never.func = StatusBars2_BarEnabledMenu_OnClick;
    never.arg1 = self;
    never.text = "Never";
    UIDropDownMenu_AddButton( never );

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

    UIDropDownMenu_SetSelectedName( menu, self:GetText( ) );

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

    -- Button info
    local info = {};
    info.func = StatusBars2_PercentTextMenu_OnClick;
    info.arg1 = self;

    -- Left
    local left = UIDropDownMenu_CreateInfo();
    left.func = StatusBars2_PercentTextMenu_OnClick;
    left.arg1 = self;
    left.text = "Left";
    UIDropDownMenu_AddButton( left );

    -- Right
    local right = UIDropDownMenu_CreateInfo();
    right.func = StatusBars2_PercentTextMenu_OnClick;
    right.arg1 = self;
    right.text = "Right";
    UIDropDownMenu_AddButton( right );

    -- Hide
    local hide = UIDropDownMenu_CreateInfo();
    hide.func = StatusBars2_PercentTextMenu_OnClick;
    hide.arg1 = self;
    hide.text = "Hide";
    UIDropDownMenu_AddButton( hide );

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

    UIDropDownMenu_SetSelectedName( menu, self:GetText( ) );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraFilterMenu_Initialize
--
--  Description:    Initialize the list of auras to display menu
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraFilterMenu_Initialize( self )

    -- Auto
    local auto = UIDropDownMenu_CreateInfo();
    auto.func = StatusBars2_BarEnabledMenu_OnClick;
    auto.arg1 = self;
    auto.text = "Auto";
    UIDropDownMenu_AddButton( auto );

    -- Combat
    local combat = UIDropDownMenu_CreateInfo();
    combat.func = StatusBars2_BarEnabledMenu_OnClick;
    combat.arg1 = self;
    combat.text = "Combat";
    UIDropDownMenu_AddButton( combat );

    -- Always
    local always = UIDropDownMenu_CreateInfo();
    always.func = StatusBars2_BarEnabledMenu_OnClick;
    always.arg1 = self;
    always.text = "Always";
    UIDropDownMenu_AddButton( always );

    -- Never
    local never = UIDropDownMenu_CreateInfo();
    never.func = StatusBars2_BarEnabledMenu_OnClick;
    never.arg1 = self;
    never.text = "Never";
    UIDropDownMenu_AddButton( never );

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

    local deleteEntryButton = _G[ scrollFrame:GetParent( ):GetName( ) .. "_DeleteAuraListEntryButton" ];
    local clearListButton = _G[ scrollFrame:GetParent( ):GetName( ) .. "_ClearAuraListButton" ];

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

    local aura_list = _G[ frame:GetName( ) .. "_AuraFilterList" ];
    local aura_editbox = _G[ frame:GetName( ) .. "_AuraNameInput" ];

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

    local aura_list = _G[ self:GetParent():GetName( ) .. "_AuraFilterList" ];
    local buttons = aura_list.buttons;

    if aura_list.allEntries == nil then
        aura_list.allEntries = {};
    end

    local numEntries = #aura_list.allEntries;
    local aura_name = self:GetText( );
    
    aura_list.allEntries[numEntries+1] = aura_name;
    table.sort(aura_list.allEntries);
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
function StatusBars2_BarOptions_ListEntryButton_OnClick( self )

    local aura_list = self:GetParent():GetParent();

    aura_list.selectedIndex = self.index;
    StatusBars2_BarOptions_AuraListUpdate( aura_list );

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

    local aura_list = _G[ self:GetParent():GetName( ) .. "_AuraFilterList" ];

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

    local aura_list = _G[ self:GetParent():GetName( ) .. "_AuraFilterList" ];
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

    local color_select_button = _G[ frame:GetName( ) .. "_PickColorButton" ];

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

    local colorSwatch = _G[ frame:GetName( ) .. "_ColorSwatch" ];
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
--  Name:           StatusBars2_BarOptions_DoDataExchange
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarOptions_DoDataExchange( save, frame )

    -- Get controls
    local enabledMenu = _G[ frame:GetName( ) .. "_EnabledMenu" ];
    local scaleSlider = _G[ frame:GetName( ) .. "_ScaleSlider" ];
    local alphaSlider = _G[ frame:GetName( ) .. "_AlphaSlider" ];
    local flashButton = _G[ frame:GetName( ) .. "_FlashButton" ];
    local flashThresholdSlider = _G[ frame:GetName( ) .. "_FlashThresholdSlider" ];
    local showBuffsButton = _G[ frame:GetName( ) .. "_ShowBuffsButton" ];
    local showDebuffsButton = _G[ frame:GetName( ) .. "_ShowDebuffsButton" ];
    local onlyShowSelfAurasButton = _G[ frame:GetName( ) .. "_OnlyShowSelfAurasButton" ];
    local onlyShowTimedAurasButton = _G[ frame:GetName( ) .. "_OnlyShowTimedAurasButton" ];
    local onlyShowListedAurasButton = _G[ frame:GetName( ) .. "_OnlyShowListedAurasButton" ];
    local enableTooltipsButton = _G[ frame:GetName( ) .. "_EnableTooltips" ];
    local showSpellButton = _G[ frame:GetName( ) .. "_ShowSpellButton" ];
    local showInAllFormsButton = _G[ frame:GetName( ) .. "_ShowInAllForms" ];
    local percentTextMenu = _G[ frame:GetName( ) .. "_PercentTextMenu" ];
    local auraList = _G[ frame:GetName( ) .. "_AuraFilterList" ];
    local customColorButton = _G[ frame:GetName( ) .. "_CustomColorButton" ];
    local colorSwatch = _G[ frame:GetName( ) .. "_ColorSwatch" ];

    -- Exchange data
    if( save ) then
        StatusBars2_Settings.bars[ frame.bar.key ].enabled = UIDropDownMenu_GetSelectedName( enabledMenu );
        StatusBars2_Settings.bars[ frame.bar.key ].scale = StatusBars2_Round( scaleSlider:GetValue( ), 2 );

        local alphaValue = StatusBars2_Round( alphaSlider:GetValue( ), 2 );
        if( alphaValue < 1 ) then
            StatusBars2_Settings.bars[ frame.bar.key ].alpha = alphaValue;
        else
            StatusBars2_Settings.bars[ frame.bar.key ].alpha = nil;
        end
        if( customColorButton and colorSwatch ) then
            if( customColorButton:GetChecked( )) then
                StatusBars2_Settings.bars[ frame.bar.key ].color = {colorSwatch:GetBackdropColor( )};
            else
                StatusBars2_Settings.bars[ frame.bar.key ].color = nil;
            end
        end
        if( flashButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].flash = flashButton:GetChecked( );
            StatusBars2_Settings.bars[ frame.bar.key ].flashThreshold = StatusBars2_Round( flashThresholdSlider:GetValue( ), 2 );
        end
        if( showBuffsButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].showBuffs = showBuffsButton:GetChecked( );
        end
        if( showDebuffsButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].showDebuffs = showDebuffsButton:GetChecked( );
        end
        if( onlyShowSelfAurasButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].onlyShowSelf = onlyShowSelfAurasButton:GetChecked( );
        end
        if( onlyShowTimedAurasButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].onlyShowTimed = onlyShowTimedAurasButton:GetChecked( );
        end
        if( onlyShowListedAurasButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].onlyShowListed = onlyShowListedAurasButton:GetChecked( );
        end
        if( enableTooltipsButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].enableTooltips = enableTooltipsButton:GetChecked( );
        end
        if( showSpellButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].showSpell = showSpellButton:GetChecked( );
        end
        if( showInAllFormsButton ) then
            StatusBars2_Settings.bars[ frame.bar.key ].showInAllForms = showInAllFormsButton:GetChecked( );
        end
        if( percentTextMenu ) then
            StatusBars2_Settings.bars[ frame.bar.key ].percentDisplayOption = UIDropDownMenu_GetSelectedName( percentTextMenu );
        end
        if( auraList ) then
            if( auraList.allEntries and #auraList.allEntries > 0 ) then
                StatusBars2_Settings.bars[ frame.bar.key ].auraFilter = {};
                
                for i, entry in ipairs(auraList.allEntries) do
                    StatusBars2_Settings.bars[ frame.bar.key ].auraFilter[entry] = true;
                end
            else
                StatusBars2_Settings.bars[ frame.bar.key ].auraFilter = nil;
            end
        end

    else
        UIDropDownMenu_SetSelectedName( enabledMenu, StatusBars2_Settings.bars[ frame.bar.key ].enabled );
        UIDropDownMenu_SetText( enabledMenu, StatusBars2_Settings.bars[ frame.bar.key ].enabled );
        scaleSlider:SetValue( StatusBars2_Settings.bars[ frame.bar.key ].scale or 1 );

        if( alphaSlider ) then
            alphaSlider:SetValue( StatusBars2_Settings.bars[ frame.bar.key ].alpha or StatusBars2_Settings.alpha or 1 );
        end
        if( customColorButton and colorSwatch ) then
            local customColorEnabled = StatusBars2_Settings.bars[ frame.bar.key ].color ~= nil;
            customColorButton:SetChecked( customColorEnabled );
            StatusBars2_BarOptions_Enable_ColorSelectButton( frame, customColorEnabled );
            colorSwatch:SetBackdropColor( frame.bar:GetColor( ) );
        end
        if( flashButton ) then
            flashButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].flash );
            flashThresholdSlider:SetValue( StatusBars2_Settings.bars[ frame.bar.key ].flashThreshold );
        end
        if( showBuffsButton ) then
            showBuffsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showBuffs );
        end
        if( showDebuffsButton ) then
            showDebuffsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showDebuffs );
        end
        if( onlyShowSelfAurasButton ) then
            onlyShowSelfAurasButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].onlyShowSelf );
        end
        if( onlyShowTimedAurasButton ) then
            onlyShowTimedAurasButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].onlyShowTimed );
        end
        if( onlyShowListedAurasButton ) then
            onlyShowListedAurasButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].onlyShowListed );
            StatusBars2_BarOptions_Enable_Aura_List( frame, StatusBars2_Settings.bars[ frame.bar.key ].onlyShowListed );
        end
        if( enableTooltipsButton ) then
            enableTooltipsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].enableTooltips );
        end
        if( showSpellButton ) then
            showSpellButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showSpell );
        end
        if( showInAllFormsButton ) then
            showInAllFormsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showInAllForms );
        end
        if( percentTextMenu ) then
            UIDropDownMenu_SetSelectedName( percentTextMenu, StatusBars2_Settings.bars[ frame.bar.key ].percentDisplayOption );
            UIDropDownMenu_SetText( percentTextMenu, StatusBars2_Settings.bars[ frame.bar.key ].percentDisplayOption );
        end
        if ( auraList ) then
            local auraFilter = StatusBars2_Settings.bars[ frame.bar.key ].auraFilter;

            if( auraFilter ) then
                auraList.allEntries = {};
                local i = 1;
                for name in pairs(auraFilter) do
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
--  Name:           StatusBars2_Options_ResetBarPositionButton_OnClick
--
--  Description:    Called when the reset bar positions button is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_ResetBarPositionButton_OnClick( self )

    -- Set a flag and reset the positions if the OK button is clicked
    StatusBars2_Options.resetBarPositions = true;

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
    StatusBars2_Options.resetGroupPositions = true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_ToggleMoveBars_OnClick
--
--  Description:    Called when the reset bar position button is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_ToggleMoveBars_OnClick( self )

    -- Close the interface options panel
    HideUIPanel(InterfaceOptionsFrame);
    -- Close the game frame menu in case the player opened the interface options 
    -- panel from there, in which case it will re-open
    HideUIPanel(GameMenuFrame);

    -- Enable config mode
    StatusBars2Config_SetConfigMode( true );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_DoDataExchange
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_DoDataExchange( save )

    -- Get controls
    local textOptionsMenu = StatusBars2_Options_TextDisplayOptionsMenu;
    local fontMenu = StatusBars2_Options_TextSizeMenu;

    if not save then
        StatusBars2_Settings_Apply_Settings( true, StatusBars2_Settings );
    end

    -- Exchange bar data
    for i, bar in ipairs( bars ) do
        local frame = _G[ bar:GetName( ) .. "_OptionFrame" ];
        StatusBars2_BarOptions_DoDataExchange( save, frame );
    end

    -- Exchange options data
    if( save ) then
        StatusBars2_Settings.textDisplayOption = UIDropDownMenu_GetSelectedValue( textOptionsMenu );
        StatusBars2_Settings.font = UIDropDownMenu_GetSelectedValue( fontMenu );
        StatusBars2_Settings.fade = StatusBars2_Options_FadeButton:GetChecked( );
        StatusBars2_Settings.locked = StatusBars2_Options_LockedButton:GetChecked( );
        StatusBars2_Settings.grouped = StatusBars2_Options_GroupedButton:GetChecked( );
        StatusBars2_Settings.groupsLocked = StatusBars2_Options_LockGroupsTogetherButton:GetChecked( );
        StatusBars2_Settings.scale = StatusBars2_Options_ScaleSlider:GetValue( );
        StatusBars2_Settings.alpha = StatusBars2_Options_AlphaSlider:GetValue( );
    else
        UIDropDownMenu_SetSelectedValue( textOptionsMenu, StatusBars2_Settings.textDisplayOption );
        UIDropDownMenu_SetText( textOptionsMenu, TextOptionLabels[StatusBars2_Settings.textDisplayOption] );
        UIDropDownMenu_SetSelectedValue( fontMenu, StatusBars2_Settings.font );
        UIDropDownMenu_SetText( fontMenu, FontInfo[UIDropDownMenu_GetSelectedValue(fontMenu)].label );
        StatusBars2_Options_FadeButton:SetChecked( StatusBars2_Settings.fade );
        StatusBars2_Options_LockedButton:SetChecked( StatusBars2_Settings.locked );
        StatusBars2_Options_GroupedButton:SetChecked( StatusBars2_Settings.grouped );
        StatusBars2_Options_LockGroupsTogetherButton:SetChecked( StatusBars2_Settings.groupsLocked );
        StatusBars2_Options_ScaleSlider:SetValue( StatusBars2_Settings.scale or 1.0 );
        StatusBars2_Options_AlphaSlider:SetValue( StatusBars2_Settings.alpha or 1.0 );
    end

end
