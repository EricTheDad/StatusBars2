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
local kDefaultFramePosition = addonTable.kDefaultFramePosition;


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

        --[[
        -- Create the option frame
        local frame = CreateFrame( "Frame", bar:GetName( ) .. "_OptionFrame", StatusBars2_Options, bar.optionsTemplate );

        -- Initialize the frame
        frame.name = bar.displayName;
        frame.parent = "StatusBars2";
        frame.bar = bar;

        -- Add it
        InterfaceOptions_AddCategory( frame );
        --]]

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

    -- Now push the settings from the bars to the saved settings
    StatusBars2_Settings_Apply_Settings( true, StatusBars2_Settings );

    -- Update the bar visibility and location
    StatusBars2_UpdateBars( );

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
        bar.position = nil;
    end

    StatusBars2_UpdateBars( );
    
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
    StatusBars2_StatusBar_SetPosition( StatusBars2, x + kDefaultFramePosition.x, y + kDefaultFramePosition.y, true );
    StatusBars2_UpdateBars( );

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

    -- Exchange options data
    if( save ) then
        StatusBars2.textDisplayOption = UIDropDownMenu_GetSelectedValue( textOptionsMenu );
        StatusBars2.font = UIDropDownMenu_GetSelectedValue( fontMenu );
    else
        UIDropDownMenu_SetSelectedValue( textOptionsMenu, StatusBars2.textDisplayOption );
        UIDropDownMenu_SetText( textOptionsMenu, TextOptionLabels[StatusBars2.textDisplayOption] );
        UIDropDownMenu_SetSelectedValue( fontMenu, StatusBars2.font );
        UIDropDownMenu_SetText( fontMenu, FontInfo[UIDropDownMenu_GetSelectedValue(fontMenu)].label );
    end

end
