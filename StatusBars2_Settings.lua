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

-- Text display options
local kAbbreviated      = addonTable.textDisplayOptions.kAbbreviated;
local kCommaSeparated   = addonTable.textDisplayOptions.kCommaSeparated;
local kUnformatted      = addonTable.textDisplayOptions.kUnformated;
local kHidden           = addonTable.textDisplayOptions.kHidden;

local groups = addonTable.groups;
local bars = addonTable.bars;

local SaveDataVersion = addonTable.saveDataVersion;
local FontInfo = addonTable.fontInfo;
local kDefaultFramePosition = addonTable.kDefaultFramePosition;

local StatusBars2_Settings = nil;

-------------------------------------------------------------------------------
--
--  Name:           Setting variables
--
--  Description:    Global variables needed for the settings
--
-------------------------------------------------------------------------------
--



-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_LoadSettings
--
--  Description:    Load settings
--
-------------------------------------------------------------------------------
--
function StatusBars2_LoadSettings( settings )

    -- Initialize the bar settings
    StatusBars2_InitializeSettings( settings );

    if( settings.SaveDataVersion ~= SaveDataVersion ) then
        -- Import old settings
        StatusBars2_ImportSettings( settings );

        -- Get rid of old setting we no longer care about
        StatisBars2_PruneSettings( settings );
        
        -- Set default settings
        StatusBars2_SetDefaultSettings( settings );

        -- We are now up to date, update the version number
        settings.SaveDataVersion = SaveDataVersion;
    end

    -- Apply the settings to the bars
    StatusBars2_Settings_Apply_Settings( false, settings );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_InitializeSettings
--
--  Description:    Initialize the settings object
--
-------------------------------------------------------------------------------
--
function StatusBars2_InitializeSettings( settings )

    -- If the bar array does not exist create it
    if( settings.bars == nil ) then
        settings.bars = {};
    end

    -- Create a structure for each bar type
    for i, bar in ipairs( bars ) do

        if( settings.bars[ bar.key ] == nil ) then
            settings.bars[ bar.key ] = {};
        end

        -- Each bar gets local access to its own settings for ease and performance
        bar.settings = settings.bars[ bar.key ];

    end

    -- Create the group array, if necessary
    if( settings.groups == nil ) then
        settings.groups = {};
    end

    -- Create a structure for each bar group
    for i, group in ipairs( groups ) do

        if( settings.groups[ i ] == nil ) then
            settings.groups[ i ] = {};
        end

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ImportSettings
--
--  Description:    Import old settings
--
-------------------------------------------------------------------------------
--
function StatusBars2_ImportSettings( settings )

    -- Import old bar enable settings
    StatusBars2_ImportEnableSetting( settings, "ShowPlayerHealth", "playerHealth" );
    StatusBars2_ImportEnableSetting( settings, "ShowPlayerPower", "playerPower" );
    StatusBars2_ImportEnableSetting( settings, "ShowDruidMana", "druidMana" );
    StatusBars2_ImportEnableSetting( settings, "ShowTargetHealth", "targetHealth" );
    StatusBars2_ImportEnableSetting( settings, "ShowTargetPower", "targetPower" );
    StatusBars2_ImportEnableSetting( settings, "ShowPetHealth", "petHealth" );
    StatusBars2_ImportEnableSetting( settings, "ShowPetPower", "petPower" );
    StatusBars2_ImportEnableSetting( settings, "ShowComboPoints", "combo" );
    StatusBars2_ImportEnableSetting( settings, "ShowRunes", "rune" );
    StatusBars2_ImportEnableSetting( settings, "ShowDeadlyPoison", "deadlyPoison" );
    StatusBars2_ImportEnableSetting( settings, "ShowSunderArmor", "sunder" );
    StatusBars2_ImportEnableSetting( settings, "ShowMaelstromWeapon", "maelstromWeapon" );

    -- Player buffs
    if( settings.ShowPlayerBuffs ~= nil ) then
        settings.bars.playerAura.showBuffs = settings.ShowPlayerBuffs;
        settings.ShowPlayerBuffs = nil;
    end

    -- Player debuffs
    if( settings.ShowPlayerDebuffs ~= nil ) then
        settings.bars.playerAura.showDebuffs = settings.ShowPlayerDebuffs;
        settings.ShowPlayerDebuffs = nil;
    end

    -- Target buffs
    if( settings.ShowTargetBuffs ~= nil ) then
        settings.bars.targetAura.showBuffs = settings.ShowTargetBuffs;
        settings.ShowTargetBuffs = nil
    end

    -- Target debuffs
    if( settings.ShowTargetDebuffs ~= nil ) then
        settings.bars.targetAura.showDebuffs = settings.ShowTargetDebuffs;
        settings.ShowTargetDebuffs = nil
    end

    -- Pet buffs
    if( settings.ShowPetBuffs ~= nil ) then
        settings.bars.petAura.showBuffs = settings.ShowPetBuffs;
        settings.ShowPetBuffs = nil;
    end

    -- Pet debuffs
    if( settings.ShowPetDebuffs ~= nil ) then
        settings.bars.petAura.showDebuffs = settings.ShowPetDebuffs;
        settings.ShowPetDebuffs = nil;
    end

    -- Only show self auras
    if( settings.OnlyShowSelfAuras ~= nil ) then
        settings.OnlyShowSelfAuras = nil;
    end

    -- Only show auras with a duration
    if( settings.OnlyShowAurasWithDuration ~= nil ) then
        settings.OnlyShowAurasWithDuration = nil;
    end

    -- Only show in combat
    if( settings.OnlyShowInCombat ~= nil ) then
        settings.OnlyShowInCombat = nil;
    end

    -- Always show target
    if( settings.AlwaysShowTarget ~= nil ) then
        settings.AlwaysShowTarget = nil;
    end

    -- Target spell
    if( settings.ShowTargetSpell ~= nil ) then
        settings.bars.playerPower.showSpell = settings.ShowTargetSpell;
        settings.ShowTargetSpell = nil;
    end

    -- Locked
    if( settings.Locked ~= nil ) then
        settings.locked = settings.Locked;
        settings.Locked = nil;
    end

    -- Scale
    if( settings.Scale ~= nil ) then
        settings.scale = settings.Scale;
        settings.Scale = nil;
    end

    -- Aura size
    if( settings.AuraSize ~= nil ) then
        settings.AuraSize = nil;
    end
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ImportEnableSetting
--
--  Description:    Import an old enabled setting
--
-------------------------------------------------------------------------------
--
function StatusBars2_ImportEnableSetting( settings, old, new )

    if( settings[ old ] ~= nil ) then
        if( settings[ old ] ) then
            settings.bars[ new ].enabled = "Auto"
        else
            settings.bars[ new ].enabled = "Never"
        end
        settings[ old ] = nil;
    end

    if( settings.bars[ new ] ) then
        local percentDisplayOption = settings.bars[ new ].percentText;

        if( percentDisplayOption ) then
            settings.bars[ new ].percentDisplayOption = percentDisplayOption;
            settings.bars[ new ].percentText = nil;
        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatisBars2_PruneSettings
--
--  Description:    Get rid of old setting we no longer care about
--
-------------------------------------------------------------------------------
--
function StatisBars2_PruneSettings( settings )

    local tempBars = {};
    
    for i, bar in ipairs( bars ) do
        tempBars[bar.key] = bar;
    end

    local barSettings = settings.bars;

    -- Clear out all the old bar settings for bars that aren't supported by the current class anyway
    for key, barSetting in pairs( barSettings ) do
        if( not tempBars[key] ) then
            barSettings[key] = nil;
        end
    end
    
    -- clear out any excess groups, since they seem to have sneaked in
    for i = #groups + 1, #settings.groups do
        settings.groups[ i ] = nil;
    end

    StatusBars2_Options.moveBars = nil;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetBarDefaultSettings
--
--  Description:    Set default settings for a bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_SetBarDefaultSettings( bar, barSettings )

    -- Enable all bars by default
    if( barSettings.enabled == nil ) then
        barSettings.enabled = bar.defaultEnabled;
    end

    -- Flash player and pet health and mana bars
    if( barSettings.flash == nil and ( bar.optionsTemplate == "StatusBars2_ContinuousBarOptionsTemplate" or bar.optionsTemplate == "StatusBars2_DruidManaBarOptionsTemplate" ) ) then
        if( ( bar.unit == "player" or bar.unit == "pet" ) and bar.type == kHealth ) then
            barSettings.flash = true;
        elseif( ( bar.unit == "player" or bar.unit == "pet" ) and bar.type == kPower ) then
            local localizedClass, englishClass = UnitClass( "player" );
            barSettings.flash = ( bar.unit == "player" and englishClass ~= "ROGUE" and englishClass ~= "WARRIOR" and englishClass ~= "DEATHKNIGHT" and englishClass ~= "MONK" and englishClass ~= "DRUID" ) or ( bar.unit == "pet" and englishClass == "WARLOCK" );
        elseif( bar.type == kDruidMana ) then
            barSettings.flash = true;
        else
            barSettings.flash = false;
        end
    end

    -- Add new fields to the position, if needed
    if( barSettings.position ) then
        barSettings.position.point = barSettings.position.point or "TOP";
        barSettings.position.relativePoint = barSettings.position.relativePoint or "BOTTOM";
    end

    -- Place continuous bar percent text on the right side
    if( barSettings.percentDisplayOption == nil and ( bar.optionsTemplate == "StatusBars2_ContinuousBarOptionsTemplate" or bar.optionsTemplate == "StatusBars2_DruidManaBarOptionsTemplate" or bar.optionsTemplate == "StatusBars2_TargetPowerBarOptionsTemplate" ) ) then
        barSettings.percentDisplayOption = "Right";
    end

    -- Set flash threshold to 40%
    if( barSettings.flashThreshold == nil ) then
        barSettings.flashThreshold = 0.40;
    end

    -- Enable buffs
    if( barSettings.showBuffs == nil and bar.type == kAura ) then
        barSettings.showBuffs = true;
    end

    -- Enable debuffs
    if( barSettings.showDebuffs == nil and bar.type == kAura ) then
        barSettings.showDebuffs = true;
    end

    -- Set scale to 1.0
    if( barSettings.scale == nil or barSettings.scale <= 0 ) then
        barSettings.scale = 1.0;
    end

    -- Show target spell
    if( bar.type == kPower and bar.unit == "target" and barSettings.showSpell == nil ) then
        barSettings.showSpell = true;
    end

    -- Show in all forms
    if( bar.type == kDruidMana and barSettings.showInAllForms == nil ) then
        barSettings.showInAllForms = true;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetDefaultSettings
--
--  Description:    Set default settings
--
-------------------------------------------------------------------------------
--
function StatusBars2_SetDefaultSettings( settings )

    -- Set defaults for the bars
    for i, bar in ipairs( bars ) do

        StatusBars2_SetBarDefaultSettings( bar, settings.bars[ bar.key ] );

    end

    -- Text display options
    if( settings.textDisplayOption == nil or settings.textDisplayOption < kAbbreviated or settings.textDisplayOption > kHidden) then
        settings.textDisplayOption = kAbbreviated;
    end

    -- Text Size
    if( settings.font == nil or not FontInfo[settings.font] ) then
        settings.font = 1;
    end

    -- Fade
    if( settings.fade == nil ) then
        settings.fade = true;
    end

    -- Locked
    if( settings.locked == nil ) then
        settings.locked = true;
    end

    -- Bars locked to groups
    if( settings.grouped == nil ) then
        settings.grouped = true;
    end

    -- Groups locked together
    if( settings.groupsLocked == nil ) then
        settings.groupsLocked = true;
    end

    -- Scale
    if( settings.scale == nil or settings.scale <= 0 ) then
        settings.scale = 1.0;
    end

    -- Opacity
    if( settings.alpha == nil or settings.alpha <= 0 or settings.alpha > 1.0 ) then
        settings.alpha = 1.0;
    end

end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Settings_Apply_BarSettings
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2_Settings_Apply_BarSettings( save, bar, barSettings )

    if( save ) then
        barSettings.scale = bar.scale ~= 1 and bar.scale or nil;
        barSettings.alpha = bar.alpha and bar.alpha < 1 and bar.alpha or nil;

        barSettings.position = bar.position and ( barSettings.position or {} ) or nil;

        if barSettings.position then
            barSettings.position.x = bar.position.x;
            barSettings.position.y = bar.position.y;
        end

        barSettings.enabled = bar.enabled;
        barSettings.color = shallowCopy( bar.color );
        barSettings.flash = bar.flash;
        barSettings.flashThreshold = bar.flashThreshold;
        barSettings.showBuffs = bar.showBuffs;
        barSettings.showDebuffs = bar.showDebuffs;
        barSettings.onlyShowSelf = bar.onlyShowSelf;
        barSettings.onlyShowTimed = bar.onlyShowTimed;
        barSettings.onlyShowListed = bar.onlyShowListed;
        barSettings.enableTooltips = bar.enableTooltips;
        barSettings.showSpell = bar.showSpell;
        barSettings.showInAllForms = bar.showInAllForms;
        barSettings.percentDisplayOption = bar.percentDisplayOption;
        barSettings.auraFilter = shallowCopy( bar.auraFilter );
    else
        bar.scale = barSettings.scale or 1.0;
        bar.alpha = barSettings.alpha or 1.0;

        bar.position = barSettings.position and ( bar.position or {} ) or nil;

        if bar.position then
            bar.position.x = barSettings.position.x;
            bar.position.y = barSettings.position.y;
        end

        bar.enabled = barSettings.enabled;
        bar.color = shallowCopy( barSettings.color );
        bar.flash = barSettings.flash;
        bar.flashThreshold = barSettings.flashThreshold;
        bar.showBuffs = barSettings.showBuffs;
        bar.showDebuffs = barSettings.showDebuffs;
        bar.onlyShowSelf = barSettings.onlyShowSelf;
        bar.onlyShowTimed = barSettings.onlyShowTimed;
        bar.onlyShowListed = barSettings.onlyShowListed;
        bar.enableTooltips = barSettings.enableTooltips;
        bar.showSpell = barSettings.showSpell;
        bar.showInAllForms = barSettings.showInAllForms;
        bar.percentDisplayOption = barSettings.percentDisplayOption;
        bar.auraFilter = barSettings.auraFilter and shallowCopy( barSettings.auraFilter ) or nil;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Settings_Apply_GroupSettings
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2_Settings_Apply_GroupSettings( save, group, groupSettings )

    if( save ) then
        groupSettings.scale = group.scale ~= 1 and group.scale or nil;
        groupSettings.alpha = group.alpha and group.alpha < 1 and group.alpha or nil;

        groupSettings.position = group.position and ( groupSettings.position or {} ) or nil;

        if groupSettings.position then
            groupSettings.position.x = group.position.x;
            groupSettings.position.y = group.position.y;
        end

    else
        group.scale = groupSettings.scale or 1.0;
        group.alpha = groupSettings.alpha or 1.0;

        group.position = groupSettings.position and ( group.position or {} ) or nil;

        if group.position then
            group.position.x = groupSettings.position.x;
            group.position.y = groupSettings.position.y;
        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Settings_Apply_Settings
--
--  Description:    Apply settings to active bars or pull them from the active 
--                  bars into the settings variables
--
-------------------------------------------------------------------------------
--
function StatusBars2_Settings_Apply_Settings( save, settings )

    local rnd = StatusBars2_Round;

    -- Exchange options data
    if( save ) then
        settings.scale = StatusBars2.scale ~= 1 and StatusBars2.scale or nil;
        settings.alpha = StatusBars2.alpha < 1 and StatusBars2.alpha or nil;

        settings.position = StatusBars2.position and ( settings.position or {} ) or nil;

        if settings.position then
            settings.position.x = StatusBars2.position.x;
            settings.position.y = StatusBars2.position.y;
        end

        settings.textDisplayOption = StatusBars2.textDisplayOption;
        settings.font = StatusBars2.font;
        settings.fade = StatusBars2.fade;
        settings.locked = StatusBars2.locked;
        settings.grouped = StatusBars2.grouped;
        settings.groupsLocked = StatusBars2.groupsLocked;
    else
        StatusBars2.scale = settings.scale or 1.0;
        StatusBars2.alpha = settings.alpha or 1.0;

        StatusBars2.position = StatusBars2.position or {};
        StatusBars2.position.x = settings.position and settings.position.x or kDefaultFramePosition.x;
        StatusBars2.position.y = settings.position and settings.position.y or kDefaultFramePosition.y;

        StatusBars2.textDisplayOption = settings.textDisplayOption;
        StatusBars2.font = settings.font;
        StatusBars2.fade = settings.fade;
        StatusBars2.locked = settings.locked;
        StatusBars2.grouped = settings.grouped;
        StatusBars2.groupsLocked = settings.groupsLocked;
    end

    -- Apply Settings to groups
    for i, group in ipairs( groups ) do
        StatusBars2_Settings_Apply_GroupSettings( save, group, settings.groups[i] );
    end

    -- Apply Settings to bars
    for k, bar in pairs( bars ) do
        StatusBars2_Settings_Apply_BarSettings( save, bar, settings.bars[bar.key] );
    end

end
