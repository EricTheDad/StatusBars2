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
--  Name:           StatusBars2_Options_OnOK
--
--  Description:    Called when the OK button is pressed in the options panel
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_OnOK( )

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
