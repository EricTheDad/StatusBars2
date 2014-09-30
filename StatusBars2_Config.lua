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

local SB2Config_DropdownInfo = UIDropDownMenu_CreateInfo();  -- We only need one of these, we'll use it everywhere for efficiency

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
        StatusBars2_Config:Show( );
    else
        StatusBars2.configMode = false;
        StatusBars2_Config:Hide( );
        StatusBars2_UpdateBars( );
    end;

    print("Config Mode = "..printBool(StatusBars2.configMode));

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
function StatusBars2Config_Configure_Bar_Options( )

    -- Add a category for each bar
    for i, bar in ipairs( bars ) do

        -- Create the option frame
        -- local frame = CreateFrame( "Frame", bar:GetName( ) .. "_OptionFrame", StatusBars2_Config, bar.optionsTemplate );
        local frame = CreateFrame( "Frame", bar:GetName( ) .. "_ConfigFrame", StatusBars2_Config, bar.configTemplate );
        --local frame = CreateFrame( "Frame", bar:GetName( ) .. "_ConfigFrame", StatusBars2_Config, "StatusBars2_BarOptionsTemplate");

        --Bar_ShowBackdrop(frame);

        -- Initialize the frame
        frame.bar = bar;
        bar.panel = frame;

    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_Setup_BarPanel
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_Setup_BarPanel( bar )

    if StatusBars2_Config.activePanel then
        StatusBars2_Config.activePanel:Hide( );
    end

    StatusBars2_Config.activePanel = bar.panel;

    bar.panel:SetAllPoints( StatusBars2_Config.inlayFrame );
    StatusBars2Config_Bar_DoDataExchange( false, bar.panel, bar );
    bar.panel:Show( );
end

local ScrollBarButtons = {}
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
    print(frame_height);
    print(frame_height / button_height);
    print(rnd(frame_height / button_height))
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

    print(list_length, num_buttons, num_buttons_needed, button_height);
    print(StatusBars2_Config.barSelectScrollFrame)
    print(StatusBars2_Config_BarSelectScrollFrame)
    --FauxScrollFrame_Update(StatusBars2_Config_BarSelectScrollFrame, list_length, num_buttons_needed, button_height);
    FauxScrollFrame_Update(StatusBars2_Config_BarSelectScrollFrame,list_length,14,15);
    print("We're at "..FauxScrollFrame_GetOffset(StatusBars2_Config_BarSelectScrollFrame));
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
        
        local menu = StatusBars2_Config.barSelectMenu;
        UIDropDownMenu_SetSelectedValue( menu, self );
        UIDropDownMenu_SetText( menu, self.displayName );

        StatusBars2Config_Setup_BarPanel( self );

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

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2Config_OKButton_OnClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_OKButton_OnClick( self )

    -- Disable config mode
    StatusBars2_Settings_Apply_Settings( true, StatusBars2_Settings )
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

    -- Disable config mode
    StatusBars2_Settings_Apply_Settings( false, StatusBars2_Settings )
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

    UIDropDownMenu_SetSelectedValue( menu, self.value );
    StatusBars2Config_Setup_BarPanel( self.value );

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
--  Name:           StatusBars2Config_Bar_DoDataExchange
--
--  Description:    Exchange data between settings and controls
--
-------------------------------------------------------------------------------
--
function StatusBars2Config_Bar_DoDataExchange( save, frame, bar )

    -- Exchange data
    if( save ) then
        bar.enabled = UIDropDownMenu_GetSelectedName( frame.enabledMenu );
        bar.scale = StatusBars2_Round( scaleSlider:GetValue( ), 2 );

        if( frame.alphaSlider ) then
            local alphaValue = StatusBars2_Round( frame.alphaSlider:GetValue( ), 2 );
            bar.alpha = alphaValue < 1 and alphaValue or nil;
        end
       if( frame.customColorButton and frame.colorSwatch ) then
            if( frame.customColorButton:GetChecked( )) then
                bar.color = shalowCopy(frame.colorSwatch:GetBackdropColor( ));
            else
                bar.color = nil;
            end
        end
        if( frame.flashButton ) then
            bar.flash = frame.flashButton:GetChecked( );
            bar.flashThreshold = StatusBars2_Round( frame.flashThresholdSlider:GetValue( ), 2 );
        end
        if( frame.showBuffsButton ) then
            bar.showBuffs = frame.showBuffsButton:GetChecked( );
        end
        if( frame.showDebuffsButton ) then
            bar.showDebuffs = frame.showDebuffsButton:GetChecked( );
        end
        if( frame.onlyShowSelfAurasButton ) then
            bar.onlyShowSelf = frame.onlyShowSelfAurasButton:GetChecked( );
        end
        if( frame.onlyShowTimedAurasButton ) then
            bar.onlyShowTimed = frame.onlyShowTimedAurasButton:GetChecked( );
        end
        if( frame.onlyShowListedAurasButton ) then
            bar.onlyShowListed = frame.onlyShowListedAurasButton:GetChecked( );
        end
        if( frame.enableTooltipsButton ) then
            bar.enableTooltips = frame.enableTooltipsButton:GetChecked( );
        end
        if( frame.showSpellButton ) then
            bar.showSpell = frame.showSpellButton:GetChecked( );
        end
        if( frame.showInAllFormsButton ) then
            bar.showInAllForms = frame.showInAllFormsButton:GetChecked( );
        end
        if( frame.percentTextMenu ) then
            bar.percentDisplayOption = UIDropDownMenu_GetSelectedName( frame.percentTextMenu );
        end
        if( frame.auraList ) then
            if( frame.auraList.allEntries and #frame.auraList.allEntries > 0 ) then
                bar.auraFilter = {};
                
                for i, entry in ipairs(frame.auraList.allEntries) do
                    bar.auraFilter[entry] = true;
                end
            else
                bar.auraFilter = nil;
            end
        end

    else
        UIDropDownMenu_SetSelectedName( frame.enabledMenu, bar.enabled );
        UIDropDownMenu_SetText( frame.enabledMenu, bar.enabled );
        frame.scaleSlider:SetValue( bar.scale or 1 );

        if( frame.alphaSlider ) then
            frame.alphaSlider:SetValue( bar.alpha or StatusBars2.alpha or 1 );
        end
        if( frame.customColorButton and frame.colorSwatch ) then
            local customColorEnabled = bar.color ~= nil;
            frame.customColorButton:SetChecked( customColorEnabled );
            StatusBars2_BarOptions_Enable_ColorSelectButton( frame, customColorEnabled );
            frame.colorSwatch:SetBackdropColor( bar:GetColor( ) );
        end
        if( frame.flashButton ) then
            frame.flashButton:SetChecked( bar.flash );
            frame.flashThresholdSlider:SetValue( bar.flashThreshold );
        end
        if( frame.showBuffsButton ) then
            frame.showBuffsButton:SetChecked( bar.showBuffs );
        end
        if( frame.showDebuffsButton ) then
            frame.showDebuffsButton:SetChecked( bar.showDebuffs );
        end
        if( frame.onlyShowSelfAurasButton ) then
            frame.onlyShowSelfAurasButton:SetChecked( bar.onlyShowSelf );
        end
        if( frame.onlyShowTimedAurasButton ) then
            frame.onlyShowTimedAurasButton:SetChecked( bar.onlyShowTimed );
        end
        if( frame.onlyShowListedAurasButton ) then
            frame.onlyShowListedAurasButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].onlyShowListed );
            StatusBars2_BarOptions_Enable_Aura_List( frame, StatusBars2_Settings.bars[ frame.bar.key ].onlyShowListed );
        end
        if( frame.enableTooltipsButton ) then
            frame.enableTooltipsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].enableTooltips );
        end
        if( frame.showSpellButton ) then
            frame.showSpellButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showSpell );
        end
        if( frame.showInAllFormsButton ) then
            frame.showInAllFormsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showInAllForms );
        end
        if( frame.percentTextMenu ) then
            UIDropDownMenu_SetSelectedName( frame.percentTextMenu, StatusBars2_Settings.bars[ frame.bar.key ].percentDisplayOption );
            UIDropDownMenu_SetText( frame.percentTextMenu, StatusBars2_Settings.bars[ frame.bar.key ].percentDisplayOption );
        end
        if ( frame.auraList ) then
            if( bar.auraFilter ) then
                frame.auraList.allEntries = {};
                local i = 1;
                for name in pairs(bar.auraFilter) do
                    frame.auraList.allEntries[i] = name;
                    i = i + 1;
                end
                
                table.sort(auraList.allEntries);
            else
                auraList.allEntries = nil;
            end

            StatusBars2_BarOptions_AuraListUpdate( frame.auraList );
        end
    end
end

addonTable.Config_Bar_OnMouseUp = Config_Bar_OnMouseUp;
addonTable.Config_Bar_OnMouseDown = Config_Bar_OnMouseDown;

