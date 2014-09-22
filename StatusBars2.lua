-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally

-- Create bars and groups containers
addonTable.groups = {};
addonTable.bars = {};

addonTable.barTypes = 
{
    ["kHealth"] = 0,
    ["kPower"] = 1,
    ["kAura"] = 2,
    ["kAuraStack"] = 3,
    ["kCombo"] = 4,
    ["kRune"] = 5,
    ["kDruidMana"] = 6,
    ["kUnitPower"] = 7,
    ["kEclipse"] = 9,
    ["kDemonicFury"] = 13,
};

addonTable.fontInfo =
{
    { ["label"] = "Small", ["filename"] = "GameFontNormalSmall" },
    { ["label"] = "Medium", ["filename"] = "GameFontNormal" },
    { ["label"] = "Large", ["filename"] = "GameFontNormalLarge" },
    { ["label"] = "Huge", ["filename"] = "GameFontNormalHuge" },
}

addonTable.kDefaultPowerBarColor = { r = 0.75, g = 0.75, b = 0.75 }


-- Settings
StatusBars2_Settings = { };

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

local groups = addonTable.groups;
local bars = addonTable.bars;

local FontInfo = addonTable.fontInfo;


------------------------------ Local Variables --------------------------------

-- Last flash time
local lastFlashTime = 0;

-- Bar group spacing
local kGroupSpacing = 18;

-- Fade durations
local kFadeInTime = 0.2;
local kFadeOutTime = 1.0;

-- Flash duration
local kFlashDuration = 0.5;

local kDefaultFramePosition = { x = 0, y = -100 };

-- Spell IDs Blizzard doesn't define
local PRIEST_SHADOW_ORBS = 95740;
local HUNTER_FOCUS_FIRE = 82692;
local WARRIOR_SUNDER_ARMOR = 7386;
local MAGE_ARCANE_CHARGE = 114664;
local SHAMAN_MAELSTROM_WEAPON = 51530;
local ROGUE_ANTICIPATION = 114015;
local HUNTER_BLACK_ARROW = 3674;

-- Buff IDs Blizzard doesn't define
local BUFF_FRENZY = 19615;
local BUFF_ANTICIPATION = 115189;
local BUFF_FINGERS_OF_FROST = 112965;
local BUFF_MASTERY_ICICLES = 76613;
local BUFF_TIDAL_WAVE = 51564;
local BUFF_LOCK_AND_LOAD = 168980;
local BUFF_MAELSTROM_WEAPON = 53817;

-- Debuff IDs Blizzard doesn't define
local DEBUFF_WEAKENED_ARMOR = 113746;
local DEBUFF_ARCANE_CHARGE = 36032;

-- Specialization IDs
local SPEC_HUNTER_MARKSMAN = 2;
local SPEC_MAGE_FROST = 3;
local SPEC_SHAMAN_RESTORATION = 3;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnLoad
--
--  Description:    Main frame OnLoad handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnLoad( self )

    -- Set scripts
    self:SetScript( "OnEvent", StatusBars2_OnEvent );
    self:SetScript( "OnUpdate", StatusBars2_OnUpdate );
    
    -- We only want mouse clicks to be detected in the actual bars.  If bars or groups 
    -- are locked, the bar will push the mouse click handling up to the parent, so we don't 
    -- register the handlers with the system even though we need the handlers.
    self.OnMouseDown = StatusBars2_OnMouseDown;
    self.OnMouseUp = StatusBars2_OnMouseUp;
    
    -- Register for events
    self:RegisterEvent( "PLAYER_ENTERING_WORLD" );
    self:RegisterEvent( "ADDON_LOADED" );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnEvent
--
--  Description:    Main frame event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnEvent( self, event, ... )

    if( event == "ADDON_LOADED" ) then
    
        if( select( 1, ... ) == "StatusBars2" ) then
        
            -- local backdropInfo = { edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16 };
            -- self:SetBackdrop( backdropInfo );

            -- If we have a power bar we don't have a blizzard color for, we'll use the class color.
            local _, englishClass = UnitClass( "player" );
            kDefaultPowerBarColor = RAID_CLASS_COLORS[englishClass];

            StatusBars2_CreateGroups( );
            StatusBars2_CreateBars( );

            -- Saved variables have been loaded, we can fix up the settings now
            StatusBars2_LoadSettings( );
            
            -- Initialize the option panel controls
            StatusBars2_Options_Configure_Bar_Options( );
            StatusBars2_Options_DoDataExchange( false );
        
        end
        
    elseif( event == "PLAYER_ENTERING_WORLD" ) then

        -- Update the bars according to the settings
        StatusBars2_UpdateBars( );

        self:RegisterEvent( "UNIT_DISPLAYPOWER" );
        self:RegisterEvent( "PLAYER_TALENT_UPDATE" );
        self:RegisterEvent( "GLYPH_UPDATED" );
        self:RegisterEvent( "PLAYER_LEVEL_UP" );

    -- Druid change form
    elseif( event == "UNIT_DISPLAYPOWER" and select( 1, ... ) == "player" ) then

        local _, englishClass = UnitClass( "player" );
        
        if( englishClass == "DRUID" ) then
            StatusBars2_UpdateBars( );
        end
        
    elseif ( event == "PLAYER_TALENT_UPDATE" or event == "GLYPH_UPDATED" or event == "PLAYER_LEVEL_UP" ) then

        -- Any of these events could lead to differences in how the bars should be configured
        StatusBars2_UpdateBars( );
       
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnUpdate
--
--  Description:    Main frame update handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnUpdate( self )

    -- Get the current time
    local time = GetTime( );

    -- Get the amount of time that has elapsed since the last update
    local delta = time - lastFlashTime;

    -- If just starting or rolling over start a new flash
    if( delta < 0 or delta > kFlashDuration ) then
        delta = 0;
        lastFlashTime = time;
    end

    -- Determine how far we are along the flash
    local level = 1 - abs( delta - kFlashDuration * 0.5) / ( kFlashDuration * 0.5 );

    -- Update any flashing bars
    for i, bar in ipairs( bars ) do
        StatusBars2_UpdateFlash( bar, level );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateBars
--
--  Description:    Create all the bars
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateBars( )

    -- Get the current class and power type
    local localizedClass, englishClass = UnitClass( "player" );

    -- Player bars
    StatusBars2_CreateHealthBar( "playerHealth", "player" );
    StatusBars2_CreatePowerBar( "playerPower", "player" );
    StatusBars2_CreateAuraBar( "playerAura", "player" );

    -- Target bars
    StatusBars2_CreateHealthBar( "targetHealth", "target" );
    StatusBars2_CreatePowerBar( "targetPower", "target" );
    StatusBars2_CreateAuraBar( "targetAura", "target" );

    -- Focus bars
    StatusBars2_CreateHealthBar( "focusHealth", "focus" );
    StatusBars2_CreatePowerBar( "focusPower", "focus" );
    StatusBars2_CreateAuraBar( "focusAura", "focus" );

    -- Pet bars
    StatusBars2_CreateHealthBar( "petHealth", "pet" );
    StatusBars2_CreatePowerBar( "petPower", "pet" );
    StatusBars2_CreateAuraBar( "petAura", "pet" );

    -- Specialty bars
    
    if( englishClass == "DRUID" )  then
        StatusBars2_CreatePowerBar( "druidMana", "player", kDruidMana, SPELL_POWER_MANA );
        StatusBars2_CreateComboBar( );
        StatusBars2_CreateEclipseBar( );
    elseif( englishClass == "ROGUE" ) then
        StatusBars2_CreateComboBar( );
        StatusBars2_CreateAuraStackBar( "anticipation", "player", ROGUE_ANTICIPATION, "buff", 5, BUFF_ANTICIPATION );
    elseif( englishClass == "DEATHKNIGHT" ) then
        StatusBars2_CreateRuneBar( );
    elseif( englishClass == "WARLOCK" ) then
        StatusBars2_CreatePowerBar( "fury", "player", kDemonicFury, SPELL_POWER_DEMONIC_FURY );
        StatusBars2_CreateShardBar( );
        StatusBars2_CreateEmbersBar( );
    elseif( englishClass == "PALADIN" ) then
        StatusBars2_CreateHolyPowerBar( );
    elseif( englishClass == "PRIEST" ) then
        StatusBars2_CreateOrbsBar( );
    elseif( englishClass == "HUNTER" ) then
        StatusBars2_CreateAuraStackBar( "frenzy", "player", HUNTER_FOCUS_FIRE, "buff", 5, BUFF_FRENZY );
        StatusBars2_CreateAuraStackBar( "lockAndLoad", "player", HUNTER_BLACK_ARROW, "buff", 5, BUFF_LOCK_AND_LOAD );
    elseif( englishClass == "WARRIOR" ) then
        StatusBars2_CreateAuraStackBar( "sunder", "target", WARRIOR_SUNDER_ARMOR, "debuff", 3, DEBUFF_WEAKENED_ARMOR );
    elseif( englishClass == "MAGE" ) then
        StatusBars2_CreateAuraStackBar( "arcaneCharge", "player", MAGE_ARCANE_CHARGE, "debuff", 4, DEBUFF_ARCANE_CHARGE );
        -- Not sure these are actually useful.
        -- StatusBars2_CreateAuraStackBar( "fingersOfFrost", "player", BUFF_FINGERS_OF_FROST, "buff", 2, BUFF_FINGERS_OF_FROST );
        -- StatusBars2_CreateAuraStackBar( "masteryIcicles", "player", BUFF_MASTERY_ICICLES, "buff", 5, BUFF_MASTERY_ICICLES );
    elseif( englishClass == "SHAMAN" ) then
        StatusBars2_CreateAuraStackBar( "maelstromWeapon", "player", SHAMAN_MAELSTROM_WEAPON, "buff", 5, BUFF_MAELSTROM_WEAPON );
        -- Not sure this is actually useful.
        -- StatusBars2_CreateAuraStackBar( "tidalWave", "player", BUFF_TIDAL_WAVE, "buff", 2 );
    elseif( englishClass == "MONK" ) then
        StatusBars2_CreateChiBar( );
    end
   
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateBars
--
--  Description:    Update bar visibility and location
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateBars( )

    -- Hide the bars
    for i, bar in ipairs( bars ) do
        StatusBars2_DisableBar( bar );
    end

    -- Get the current class and power type
    local localizedClass, englishClass = UnitClass( "player" );
    local powerType = UnitPowerType( "player" );

    for i, bar in ipairs( bars ) do

        if( bar.key == "playerHealth" ) then
            StatusBars2_EnableBar( bar, 1, 1 );
        elseif( bar.key == "playerPower" and ( englishClass ~= "DRUID" or powerType ~= SPELL_POWER_MANA ) ) then
            StatusBars2_EnableBar( StatusBars2_playerPowerBar, 1, 2 );
        elseif( bar.key == "playerAura" and ( bar.settings.showBuffs or bar.settings.showDebuffs ) ) then
            StatusBars2_EnableBar( bar, 1, 20 );
        elseif( bar.key == "targetHealth" ) then
            StatusBars2_EnableBar( bar, 2, 1 );
        elseif( bar.key == "targetPower" ) then
            StatusBars2_EnableBar( bar, 2, 2, true );
        elseif( bar.key == "targetAura" and ( bar.settings.showBuffs or bar.settings.showDebuffs ) ) then
            StatusBars2_EnableBar( bar, 2, 3 );
        elseif( bar.key == "focusHealth" ) then
            StatusBars2_EnableBar( bar, 3, 1 );
        elseif( bar.key == "focusPower" ) then
            StatusBars2_EnableBar( bar, 3, 2, true );
        elseif( bar.key == "focusAura" and ( bar.settings.showBuffs or bar.settings.focusAura.showDebuffs ) ) then
            StatusBars2_EnableBar( bar, 3, 3 );
        elseif( bar.key == "petHealth" ) then
            StatusBars2_EnableBar( bar, 4, 1 );
        elseif( bar.key == "petPower" ) then
            StatusBars2_EnableBar( bar, 4, 2 );
        elseif( bar.key == "petAura" and ( bar.settings.showBuffs or bar.settings.showDebuffs ) ) then
            StatusBars2_EnableBar( bar, 4, 3 );
        -- Special Druid Bars
        elseif( bar.key == "druidMana" and ( bar.settings.showInAllForms or powerType == SPELL_POWER_MANA ) ) then
            StatusBars2_EnableBar( bar, 1, 3 );
        elseif( bar.key == "eclipse" and powerType == SPELL_POWER_MANA and GetSpecialization() == 1 ) then
            StatusBars2_EnableBar( bar, 1, 8 );
        -- Special Rogue Bars
        elseif( bar.key == "combo" and powerType == SPELL_POWER_ENERGY ) then
            StatusBars2_EnableBar( bar, 1, 4 );
        elseif( bar.key == "anticipation" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar, 1, 16 );
        -- Special Death Knight Bars
        elseif( bar.key == "rune" ) then
            StatusBars2_EnableBar( bar, 1, 7 );
        -- Special Warlock Bars
        elseif( bar.key == "fury" and GetSpecialization() == SPEC_WARLOCK_DEMONOLOGY ) then
            StatusBars2_EnableBar( bar, 1, 14 );
        elseif( bar.key == "shard" and IsPlayerSpell( WARLOCK_SOULBURN ) ) then
            StatusBars2_EnableBar( bar, 1, 5 );
        elseif( bar.key == "embers" and IsPlayerSpell( WARLOCK_BURNING_EMBERS ) ) then
            StatusBars2_EnableBar( bar, 1, 13 );
        -- Special Paladin Bars
        elseif( bar.key == "holyPower" ) then
            StatusBars2_EnableBar( bar, 1, 6 );
        -- Special Priest Bars
        elseif( bar.key == "orbs" and IsSpellKnown( PRIEST_SHADOW_ORBS ) ) then
            StatusBars2_EnableBar( bar, 1, 12 );
        -- Special Hunter Bars
        elseif( bar.key == "frenzy" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar, 1, 18 );
        elseif( bar.key == "lockAndLoad" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar, 1, 19 );
        -- Special Warrior Bars
        elseif( bar.key == "sunder" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar, 1, 10 );
        -- Special Mage Bars
        elseif( bar.key == "arcaneCharge" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar, 1, 15 );
        elseif( bar.key == "fingersOfFrost" and GetSpecialization() == SPEC_MAGE_FROST and GetUnitLevel( bar.unit ) == 24 ) then
            StatusBars2_EnableBar( bar, 1, 16 );
        elseif( bar.key == "masteryIcicles" and GetSpecialization() == SPEC_MAGE_FROST and GetUnitLevel( bar.unit ) == 80 ) then
            StatusBars2_EnableBar( bar, 1, 17 );
        -- Special Shaman Bars
        elseif( bar.key == "maelstromWeapon" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar, 1, 9 );
        -- Special Monk Bars
        elseif( bar.key == "chi" ) then
            StatusBars2_EnableBar( bar, 1, 11 );
        end

    end

    -- Set the global scale and alpha
    StatusBars2:SetScale( StatusBars2_Settings.scale );
    StatusBars2:SetAlpha( StatusBars2_Settings.alpha );

    -- Update the layout
    StatusBars2_UpdateLayout( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_BarCompareFunction
--
--  Description:    Function for comparing two bars
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarCompareFunction( bar1, bar2 )

    return bar1.group < bar2.group or ( bar1.group == bar2.group and bar1.index < bar2.index );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateLayout
--
--  Description:    Update the layout of the bars
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateLayout( )

    -- Set Main Frame Position
    local x = kDefaultFramePosition.x;
    local y = kDefaultFramePosition.y;

    if ( StatusBars2_Settings.position ~= nil ) then
        x = StatusBars2_Settings.position.x;
        y = StatusBars2_Settings.position.y;
    end

    StatusBars2:ClearAllPoints( );
    StatusBars2:SetPoint( "TOP", UIPARENT, "CENTER", x / StatusBars2:GetScale( ), y / StatusBars2:GetScale( ) );

    local layoutBars = {}

    -- Build a list of bars to layout
    for i, bar in ipairs( bars ) do
        -- If the bar has a group and index set include it in the layout
        if( bar.group ~= nil and bar.index ~= nil and ( not bar.removeWhenHidden or bar.visible ) ) then
            table.insert( layoutBars, bar );
        end
    end

    -- Order the bars
    table.sort( layoutBars, StatusBars2_BarCompareFunction );

    -- Lay them out
    local group = nil;
    local offset = 0;
    local group_offset = 0;
    for i, bar in ipairs( layoutBars ) do

        -- Set the group frame position
        if( group ~= bar.group ) then
            group = bar.group;
            group_offset = group_offset + offset;
            StatusBars2_Group_SetPosition( groups[ group ], 0, group_offset );
            group_offset = group_offset - kGroupSpacing;
            offset = 0;
        end

        -- Aura bars need a bit more space
        if( bar.type == kAura ) then
            offset = offset - 1;
        end

        -- Position the bar
        bar:SetBarPosition( 0, offset );

        -- Update the offset
        offset = offset - ( bar:GetBarHeight( ) - 2 );

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EnableBar
--
--  Description:    Enable a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_EnableBar( bar, group, index, removeWhenHidden )

    -- Set the layout properties
    bar.group = group;
    bar.index = index;
    bar.removeWhenHidden = removeWhenHidden;

    -- Set the parent to the appropriate group frame
    bar:SetParent( groups[ group ] );

    -- Set the scale
    bar:SetBarScale( bar.settings.scale );

    -- Set maximum opacity
    bar.maxAlpha = bar.settings.alpha or 1.0;

    -- Notify the bar is is enabled
    bar:OnEnable( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_DisableBar
--
--  Description:    Disable a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_DisableBar( bar )

    -- Remove the event and update handlers
    bar:SetScript( "OnEvent", nil );
    bar:SetScript( "OnUpdate", nil );

    -- Disable the mouse
    bar:EnableMouse( false );

    -- Clear the layout properties
    bar.group = nil;
    bar.index = nil;
    bar.removeWhenHidden = false;

    -- Hide the bar
    bar:Hide( );
    bar.visible = false;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HideBar
--
--  Description:    Hide a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_HideBar( bar, immediate )

    if( bar.visible ) then
        if( not immediate and StatusBars2_Settings.fade ) then
            local fadeInfo = {};
            fadeInfo.mode = "OUT";
            fadeInfo.timeToFade = kFadeOutTime;
            fadeInfo.startAlpha = bar.maxAlpha;
            fadeInfo.endAlpha = 0;
            fadeInfo.finishedFunc = StatusBars2_FadeOutFinished;
            fadeInfo.finishedArg1 = bar;
            UIFrameFade( bar, fadeInfo );
        else
            StatusBars2_FadeOutFinished( bar );
        end
        bar.visible = false;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_FadeOutFinished
--
--  Description:    Called when fading out finishes
--
-------------------------------------------------------------------------------
--
function StatusBars2_FadeOutFinished( bar )

    bar:Hide( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ShowBar
--
--  Description:    Show a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_ShowBar( bar )

    if( not bar.visible ) then
        if( StatusBars2_Settings.fade ) then
            UIFrameFadeIn( bar, kFadeInTime, 0, bar.maxAlpha );
        else
            bar:SetAlpha( bar.maxAlpha );
            bar:Show( );
        end
        bar.visible = true;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateSpecialtyBar
--
--  Description:    Create a generic specialty bar that displays a class/spec specific resource (combo points/holy power/burning embers etc.)
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateSpecialtyBar( key, unit, displayName, barType )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( key, unit, displayName, barType, 0 );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_SpecialtyBar_OnEvent;
    bar.OnEnable = StatusBars2_SpecialtyBar_OnEnable;
    bar.Update = StatusBars2_UpdateDiscreteBar;
    bar.HandleEvent = StatusBars2_SpecialtyBars_HandleEvent;
    bar.SetupBoxes = StatusBars2_SetDiscreteBarBoxCount;
    bar.IsDefault = StatusBars2_SpecialtyBar_ZeroIsDefault;

    -- Register for events
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_OnEvent
--
--  Description:    Specialty bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_SpecialtyBar_OnEvent( self, event, ... )

    -- Do the actual event handling
    self:HandleEvent( event, ... );

    -- Update visibility
    if( self:BarIsVisible( ) ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_HandleEvent
--
--  Description:    Specialty bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_SpecialtyBar_HandleEvent( self, event, ... )
    
    -- Entering combat
    if( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_OnEnable
--
--  Description:    Specialty bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_SpecialtyBar_OnEnable( self )

    -- Set the number of boxes we should be seeing
    self:SetupBoxes( self:GetMaxCharges( ) );

    -- Update
    self:Update( self:GetCharges( ) );

    -- Call the base method
    StatusBars2_DiscreteBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_ZeroIsDefault
--
--  Description:    Determine if a specialty bar is at its default state when zero power is default
--
-------------------------------------------------------------------------------
--
function StatusBars2_SpecialtyBar_ZeroIsDefault( self )

    return self:GetCharges( ) == 0;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SpecialtyBar_MaxIsDefault
--
--  Description:    Determine if a specialty bar is at its default state when max power is default
--
-------------------------------------------------------------------------------
--
function StatusBars2_SpecialtyBar_MaxIsDefault( self )

    return self:GetCharges( ) == self:GetMaxCharges( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateComboBar
--
--  Description:    Create a combo point bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateComboBar( )

    -- Create the bar
    local bar = StatusBars2_CreateSpecialtyBar( "combo", "player", COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT, kCombo );

    bar.HandleEvent = StatusBars2_ComboBar_HandleEvent;
    bar.GetCharges = StatusBars2_GetComboPoints;
    bar.GetMaxCharges = StatusBars2_GetMaxComboPoints;
    
    -- Register for events
    bar:RegisterEvent( "UNIT_COMBO_POINTS" );
    bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ComboBar_HandleEvent
--
--  Description:    Combo bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ComboBar_HandleEvent( self, event, ... )

    -- Target changed
    if( event == "PLAYER_TARGET_CHANGED" ) then
        StatusBars2_UpdateDiscreteBar( self, self:GetCharges( ) );

    -- Combo points changed
    elseif( event == "UNIT_COMBO_POINTS" ) then
        local unit = ...;
        if( unit == self.unit ) then
            StatusBars2_UpdateDiscreteBar( self, self:GetCharges( ) );
        end
    else
        StatusBars2_SpecialtyBar_HandleEvent( self, event, ... );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetMaxCharges
--
--  Description:    Get the max number of combo points/shards/holy power etc.
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetMaxComboPoints( )

    return MAX_COMBO_POINTS;
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateUnitPowerBar
--
--  Description:    Create a bar that processes the unit power (this is how most specialty charges operate)
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateUnitPowerBar( key, displayName )
    
    -- Create the bar
    local bar = StatusBars2_CreateSpecialtyBar( key, "player", displayName, kUnitPower );

    local powerType, powerToken, powerEvent = StatusBars2_GetSpecialtyUnitPowerType( key );

    -- Save the unit power type 
    bar.powerType = powerType;
    bar.powerToken = powerToken;
    
    -- Blizzard sometimes listens to "UNIT_POWER" and sometimes to "UNIT_POWER_FREQUENT" to update their
    -- displays.  I'll just listen to the event they tell me to listen for.
    bar.powerEvent = powerEvent;
    
    -- Set the event handlers
    bar.HandleEvent = StatusBars2_UnitPower_HandleEvent;
    
    bar.GetCharges = StatusBars2_GetUnitPowerCharges;
    bar.GetMaxCharges = StatusBars2_GetMaxUnitPowerCharges;

    -- Register for events
    bar:RegisterEvent( powerEvent );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UnitPower_HandleEvent
--
--  Description:    Unit power bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_UnitPower_HandleEvent( self, event, ... )
    
    -- Number of charges changed
    if( event == self.powerEvent ) then
        local unit, powerToken = ...;

        if( unit == self.unit and powerToken == self.powerToken ) then
            self:Update( self:GetCharges( ) );
        end
    else
        StatusBars2_SpecialtyBar_HandleEvent( self, event, ... );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetSpecialtyUnitPowerType
--
--  Description:    Get the power type and power token based on the bar type
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetSpecialtyUnitPowerType( key )

    if( key == "shard" ) then
        return SPELL_POWER_SOUL_SHARDS, "SOUL_SHARDS", "UNIT_POWER_FREQUENT";
    elseif( key == "holyPower" ) then
        return SPELL_POWER_HOLY_POWER, "HOLY_POWER", "UNIT_POWER";
    elseif( key == "chi" ) then
        -- Contrary to the documentation, the power token for CHI appears to be "CHI"
        return SPELL_POWER_CHI, "CHI", "UNIT_POWER_FREQUENT";
    elseif( key == "orbs" ) then
        return SPELL_POWER_SHADOW_ORBS, "SHADOW_ORBS", "UNIT_POWER_FREQUENT";
    elseif( key == "embers" ) then
        return SPELL_POWER_BURNING_EMBERS, "BURNING_EMBERS", "UNIT_POWER_FREQUENT";
    else
        assert(false, "unknown bar type");
    end
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetUnitPowerCharges
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetUnitPowerCharges( self )

    -- undocumented parameter "true" in Unitpower delivers the Emberparticles
    return UnitPower( self.unit, self.powerType, self.powerType == SPELL_POWER_BURNING_EMBERS );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetMaxUnitPowerCharges
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetMaxUnitPowerCharges( self )

    return UnitPowerMax( self.unit, self.powerType );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateShardBar
--
--  Description:    Create a soul shard bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateShardBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "shard", SOUL_SHARDS );

    -- Override event handlers for this specific type of bar
    bar.IsDefault = StatusBars2_SpecialtyBar_MaxIsDefault;
    
    return bar;
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateHolyPowerBar
--
--  Description:    Create a holy power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateHolyPowerBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "holyPower", HOLY_POWER );
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateChiBar
--
--  Description:    Create a chi bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateChiBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "chi", CHI_POWER );
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateOrbsBar
--
--  Description:    Create a orbs bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateOrbsBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "orbs", SHADOW_ORBS );
    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateEmbersBar
--
--  Description:    Create a Embers bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateEmbersBar( )

    -- Create the bar
    local bar = StatusBars2_CreateUnitPowerBar( "embers", BURNING_EMBERS );

    -- Set the event handlers
    bar.IsDefault = StatusBars2_EmbersBar_IsDefault;
    bar.SetupBoxes = StatusBars2_SetEmbersBoxCount;
    bar.Update = StatusBars2_UpdateEmbersBar;

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetEmbersBoxCount
--
--  Description:    Set up the number of embers boxes and initialize them specially for embers
--
-------------------------------------------------------------------------------
--
function StatusBars2_SetEmbersBoxCount( self, boxCount )

    -- Call the base class
    StatusBars2_SetDiscreteBarBoxCount( self, boxCount );
    
    -- Modify the boxes to display ember particles
    boxes = { self:GetChildren( ) };
    
    -- MAX_POWER_PER_EMBER defined in Blizzard constants
    for i, box in ipairs(boxes) do
    
       local status = box:GetChildren( );
       status:SetMinMaxValues( 0, MAX_POWER_PER_EMBER );

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateEmbersBar
--
--  Description:    Custom update for the semi-discrete embers bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateEmbersBar( self, current )

    local current = current;
    
    -- Update the boxes
    boxes = { self:GetChildren( ) };
    
    -- Initialize the boxes
    for i, box in ipairs(boxes) do
    
       local status = box:GetChildren( );
       local _, maxValue = status:GetMinMaxValues( );
       
        if current < maxValue then
            status:SetValue( current );
            current = 0;
        else
            status:SetValue( maxValue );
            current = current - maxValue;
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EmbersBar_IsDefault
--
--  Description:    Determine if a Embers bar is at its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_EmbersBar_IsDefault( self )

    -- Default is exactly one full ember
    return self:GetCharges( ) == MAX_POWER_PER_EMBER;

end
