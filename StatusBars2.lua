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

-- Settings
StatusBars2_Settings = { };

local groups = addonTable.groups;
local bars = addonTable.bars;

-- Last flash time
local lastFlashTime = 0;

-- Bar group spacing
local kGroupSpacing = 18;

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

local FontInfo = addonTable.fontInfo;

-- Fade durations
local kFadeInTime = 0.2;
local kFadeOutTime = 1.0;

-- Flash duration
local kFlashDuration = 0.5;

-- Max flash alpha
local kFlashAlpha = 0.8;

local kDefaultPowerBarColor = { r = 0.75, g = 0.75, b = 0.75 }
local kDefaultFramePosition = { x = 0, y = -100 };

-- Spell IDs Blizzard doesn't define
local PRIEST_SHADOW_ORBS = 95740;
local HUNTER_FRENZY = 19623;
local WARRIOR_SUNDER_ARMOR = 7386;
local MAGE_ARCANE_CHARGE = 114664;
local SHAMAN_MAELSTROM_WEAPON = 51530;
local ROGUE_ANTICIPATION = 114015;
local HUNTER_STEADY_SHOT = 56641;

-- Buff IDs Blizzard doesn't define
local BUFF_FRENZY = 19615;
local BUFF_ANTICIPATION = 115189;
local BUFF_MASTER_MARKSMAN = 34487;
local BUFF_FINGERS_OF_FROST = 112965;
local BUFF_MASTERY_ICICLES = 76613;
local BUFF_LIGHTNING_SHIELD = 324;
local BUFF_TIDAL_WAVE = 51564;

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
        StatusBars2_CreateAuraStackBar( "frenzy", "player", HUNTER_FRENZY, "buff", 5, BUFF_FRENZY );
        StatusBars2_CreateAuraStackBar( "masterMarksman", "player", HUNTER_STEADY_SHOT, "buff", 3, BUFF_MASTER_MARKSMAN );
    elseif( englishClass == "WARRIOR" ) then
        StatusBars2_CreateAuraStackBar( "sunder", "target", WARRIOR_SUNDER_ARMOR, "debuff", 3, DEBUFF_WEAKENED_ARMOR );
    elseif( englishClass == "MAGE" ) then
        StatusBars2_CreateAuraStackBar( "arcaneCharge", "player", MAGE_ARCANE_CHARGE, "debuff", 4, DEBUFF_ARCANE_CHARGE );
        -- Not sure these are actually useful.
        -- StatusBars2_CreateAuraStackBar( "fingersOfFrost", "player", BUFF_FINGERS_OF_FROST, "buff", 2, BUFF_FINGERS_OF_FROST );
        -- StatusBars2_CreateAuraStackBar( "masteryIcicles", "player", BUFF_MASTERY_ICICLES, "buff", 5, BUFF_MASTERY_ICICLES );
    elseif( englishClass == "SHAMAN" ) then
        StatusBars2_CreateAuraStackBar( "maelstromWeapon", "player", SHAMAN_MAELSTROM_WEAPON, "buff", 5 );
        StatusBars2_CreateAuraStackBar( "lightningShield", "player", BUFF_LIGHTNING_SHIELD, "buff", 7 );
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
        elseif( bar.key == "playerAura" and ( StatusBars2_Settings.bars.playerAura.showBuffs or StatusBars2_Settings.bars.playerAura.showDebuffs ) ) then
            StatusBars2_EnableBar( bar, 1, 20 );
        elseif( bar.key == "targetHealth" ) then
            StatusBars2_EnableBar( bar, 2, 1 );
        elseif( bar.key == "targetPower" ) then
            StatusBars2_EnableBar( bar, 2, 2, true );
        elseif( bar.key == "targetAura" and ( StatusBars2_Settings.bars.targetAura.showBuffs or StatusBars2_Settings.bars.targetAura.showDebuffs ) ) then
            StatusBars2_EnableBar( bar, 2, 3 );
        elseif( bar.key == "focusHealth" ) then
            StatusBars2_EnableBar( bar, 3, 1 );
        elseif( bar.key == "focusPower" ) then
            StatusBars2_EnableBar( bar, 3, 2, true );
        elseif( bar.key == "focusAura" and ( StatusBars2_Settings.bars.focusAura.showBuffs or StatusBars2_Settings.bars.focusAura.showDebuffs ) ) then
            StatusBars2_EnableBar( bar, 3, 3 );
        elseif( bar.key == "petHealth" ) then
            StatusBars2_EnableBar( bar, 4, 1 );
        elseif( bar.key == "petPower" ) then
            StatusBars2_EnableBar( bar, 4, 2 );
        elseif( bar.key == "petAura" and ( StatusBars2_Settings.bars.petAura.showBuffs or StatusBars2_Settings.bars.petAura.showDebuffs ) ) then
            StatusBars2_EnableBar( bar, 4, 3 );
        -- Special Druid Bars
        elseif( bar.key == "druidMana" and ( StatusBars2_Settings.bars.druidMana.showInAllForms or powerType == SPELL_POWER_MANA ) ) then
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
        elseif( bar.key == "masterMarksman" and IsSpellKnown( bar.spellID ) and GetSpecialization() == SPEC_HUNTER_MARKSMAN ) then
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
        elseif( bar.key == "lightningShield" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar, 1, 10 );
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
--  Name:           StatusBars2_EnableBar
--
--  Description:    Enable a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_EnableBar( bar, group, index, removeWhenHidden )

    -- Check if the bar type is enabled
    if( StatusBars2_Settings.bars[ bar.key ].enabled ~= "Never" ) then

        -- Set the layout properties
        bar.group = group;
        bar.index = index;
        bar.removeWhenHidden = removeWhenHidden;

        -- Initialize the incombat flag
        bar.inCombat = UnitAffectingCombat( "player" );

        -- Enable the event and update handlers
        bar:SetScript( "OnEvent", bar.OnEvent );
        bar:SetScript( "OnUpdate", bar.OnUpdate );

        -- If not locked enable the mouse for moving
        -- Don't enable mouse on aura bars, we only want the mouse to be able to grab active icons
        bar:EnableMouse( not StatusBars2_Settings.locked and bar.type ~= kAura );

        -- Set the parent to the appropriate group frame
        bar:SetParent( groups[ group ] );

        -- Set the scale
        bar:SetBarScale( StatusBars2_Settings.bars[ bar.key ].scale );

        -- Set maximum opacity
        bar.maxAlpha = StatusBars2_Settings.bars[ bar.key ].alpha or 1.0;

        -- Notify the bar is is enabled
        bar:OnEnable( );

    end

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
--  Name:           StatusBars2_CreateHealthBar
--
--  Description:    Create a health bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateHealthBar( key, unit )

    local barType = kHealth;
    local displayName = StatusBars2_ConstructDisplayName( unit, barType );

    -- Create the bar
    local bar = StatusBars2_CreateContinuousBar( key, unit, displayName, barType, 1, 0, 0 );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_HealthBar_OnEvent;
    bar.OnEnable = StatusBars2_HealthBar_OnEnable;
    bar.IsDefault = StatusBars2_HealthBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "UNIT_HEALTH" );
    bar:RegisterEvent( "UNIT_MAXHEALTH" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    if( unit == "target" ) then
        bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
    elseif( unit == "focus" ) then
        bar:RegisterEvent( "PLAYER_FOCUS_CHANGED" );
    elseif( unit == "pet" ) then
        bar:RegisterEvent( "UNIT_PET" );
    end

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HealthBar_OnEvent
--
--  Description:    Health bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_HealthBar_OnEvent( self, event, ... )

    -- Entering combat
    if( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Exiting combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update
    StatusBars2_UpdateHealthBar( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HealthBar_OnEnable
--
--  Description:    Health bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_HealthBar_OnEnable( self )

    -- Update
    StatusBars2_UpdateHealthBar( self );

    -- Call the base method
    StatusBars2_ContinuousBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateHealthBar
--
--  Description:    Update a health bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateHealthBar( self )

    -- Get the current and max health
    local health = UnitHealth( self.unit );
    local maxHealth = UnitHealthMax( self.unit );

    -- Update the bar
    StatusBars2_UpdateContinuousBar( self, health, maxHealth );

    -- If the bar is still visible update its color
    if( self.visible ) then

        -- Determine the percentage of health remaining
        local percent = health / maxHealth;

        -- Set the bar color based on the percentage of remaining health
        if( percent >= 0.75 ) then
            self.status:SetStatusBarColor( 0, 1, 0 );
        elseif( percent >= 0.50 ) then
            self.status:SetStatusBarColor( 1, 1, 0 );
        elseif( percent >= 0.25 ) then
            self.status:SetStatusBarColor( 1, 0.5, 0 );
        else
            self.status:SetStatusBarColor( 1, 0, 0 );
        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HealthBar_IsDefault
--
--  Description:    Determine if a health bar is at its default level
--
-------------------------------------------------------------------------------
--
function StatusBars2_HealthBar_IsDefault( self )

    -- Get the current and max health
    local health = UnitHealth( self.unit );
    local maxHealth = UnitHealthMax( self.unit );

    return health == maxHealth;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreatePowerBar
--
--  Description:    Create a power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreatePowerBar( key, unit, barType, powerType )

    if( not barType ) then barType = kPower end
    
    local displayName = StatusBars2_ConstructDisplayName( unit, barType );

    -- Create the power bar
    local bar = StatusBars2_CreateContinuousBar( key, unit, displayName, barType, 1, 1, 0 );

    -- If its the druid mana bar use a special options template
    if( barType == kDruidMana ) then
        bar.optionsTemplate = "StatusBars2_DruidManaBarOptionsTemplate";
    -- If its a target power bar use a special options template
    elseif( bar.unit == "target" ) then
        bar.optionsTemplate = "StatusBars2_TargetPowerBarOptionsTemplate";
    end

    bar.powerType = powerType;

    -- Set the color
    StatusBars2_SetPowerBarColor( bar );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_PowerBar_OnEvent;
    bar.OnUpdate = StatusBars2_PowerBar_OnUpdate;
    bar.OnEnable = StatusBars2_PowerBar_OnEnable;
    bar.BarIsVisible = StatusBars2_PowerBar_IsVisible;
    bar.IsDefault = StatusBars2_PowerBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "UNIT_POWER" );
    bar:RegisterEvent( "UNIT_MAXPOWER" );

    if( bar.unit == "target" ) then
        bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
        bar:RegisterEvent( "UNIT_SPELLCAST_START" );
        bar:RegisterEvent( "UNIT_SPELLCAST_STOP" );
        bar:RegisterEvent( "UNIT_SPELLCAST_FAILED" );
        bar:RegisterEvent( "UNIT_SPELLCAST_INTERRUPTED" );
        bar:RegisterEvent( "UNIT_SPELLCAST_DELAYED" );
        bar:RegisterEvent( "UNIT_SPELLCAST_CHANNEL_START" );
        bar:RegisterEvent( "UNIT_SPELLCAST_CHANNEL_UPDATE" );
        bar:RegisterEvent( "UNIT_SPELLCAST_CHANNEL_STOP" );
    elseif( bar.unit == "focus" ) then
        bar:RegisterEvent( "PLAYER_FOCUS_CHANGED" );
    elseif( bar.unit == "pet" ) then
        bar:RegisterEvent( "UNIT_PET" );
    end

    if( powerType == nil ) then
        bar:RegisterEvent( "UNIT_DISPLAYPOWER" );
    elseif( bar:IsEventRegistered( "UNIT_DISPLAYPOWER" ) ) then
        bar:UnregisterEvent( "UNIT_DISPLAYPOWER" );
    end

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_OnEvent
--
--  Description:    Power bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_PowerBar_OnEvent( self, event, ... )

    -- Target changed
    if( event == "PLAYER_TARGET_CHANGED" ) then

        -- Bar is visible
        if( self:BarIsVisible( ) ) then

            -- Update the casting bar if applicable
            StatusBars2_PowerBar_StartCasting( self );

            -- If not in casting mode update as normal
            if( not self.casting and not self.channeling ) then
                StatusBars2_SetPowerBarColor( self );
                self.status:SetMinMaxValues( 0, UnitPowerMax( self.unit, StatusBars2_GetPowerType( self ) ) );
            end

            -- Show the bar and update the layout
            StatusBars2_ShowBar( self );
            StatusBars2_UpdateLayout( );

        -- Bar is not visible
        else
            local unitExists = UnitExists( self.unit );
            StatusBars2_HideBar( self, unitExists );
            if( unitExists ) then
                StatusBars2_UpdateLayout( );
            end
        end

    -- Show the bar when power ticks
    elseif( event == "UNIT_POWER" ) then

        if( self:BarIsVisible( ) and not self.visible ) then
            StatusBars2_SetPowerBarColor( self );
            StatusBars2_ShowBar( self );
            StatusBars2_UpdateLayout( );
        end

    -- Update max power
    elseif( event == "UNIT_MAXPOWER" and not self.casting and not self.channeling ) then
        self.status:SetMinMaxValues( 0, UnitPowerMax( self.unit, StatusBars2_GetPowerType( self ) ) );

    -- Show when entering combat
    elseif( event == 'PLAYER_REGEN_DISABLED' ) then
        self.inCombat = true;
        if( self:BarIsVisible( ) and not self.visible ) then
            StatusBars2_SetPowerBarColor( self );
            StatusBars2_ShowBar( self );
            StatusBars2_UpdateLayout( );
        end

    -- Exiting combat
    elseif( event == 'PLAYER_REGEN_ENABLED' ) then
        self.inCombat = false;

    -- Pet changed
    elseif( event == "UNIT_PET" or event == "PLAYER_FOCUS_CHANGED") then
        if( self:BarIsVisible( ) ) then
            StatusBars2_SetPowerBarColor( self );
            StatusBars2_ShowBar( self );
            StatusBars2_UpdatePowerBar( self );
            StatusBars2_UpdateLayout( );
        -- Bar is not visible
        else
            local unitExists = UnitExists( self.unit );
            StatusBars2_HideBar( self, unitExists );
            if( unitExists ) then
                StatusBars2_UpdateLayout( );
            end
        end

    -- Unit shapeshifted
    elseif( event == "UNIT_DISPLAYPOWER" and select( 1, ... ) == self.unit ) then
        StatusBars2_SetPowerBarColor( self );
        StatusBars2_UpdatePowerBar( self );

    -- Casting started
    elseif( select( 1, ... ) == self.unit and ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"  ) and StatusBars2_Settings.bars[ self.key ].showSpell ) then

        -- Set to casting mode
        StatusBars2_PowerBar_StartCasting( self );

        -- If the bar is currently hidden show it and update the layout
        if not self.visible then
            StatusBars2_ShowBar( self );
            StatusBars2_UpdateLayout( );
        end

    -- Casting ended
    elseif( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_CHANNEL_STOP" ) then

        if( select( 1, ... ) == self.unit and ( event == "UNIT_SPELLCAST_CHANNEL_STOP" or select( 4, ... ) == self.castID ) ) then

            -- End casting mode
            StatusBars2_PowerBar_EndCasting( self );

            -- If the bar should no longer be visible hide it and update the layout
            if( not self:BarIsVisible( ) ) then
                self:Hide( );
                self.visible = false;
                StatusBars2_UpdateLayout( );
            end

        end

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_OnUpdate
--
--  Description:    Power bar update handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_PowerBar_OnUpdate( self, elapsed )

    -- Casting mode
    if( self.casting or self.channeling ) then

        -- Update the current value
        if( self.casting ) then
            self.value = self.value + elapsed;
        else
            self.value = self.value - elapsed;
        end

        -- Casting finished
        if( ( self.casting and self.value >= self.maxValue ) or ( self.value <= 0 ) ) then
            StatusBars2_PowerBar_EndCasting( self );

        -- Casting continuing
        else
            self.status:SetValue( self.value );
            self.spark:SetPoint( "CENTER", self.status, "LEFT", ( self.value / self.maxValue ) * self.status:GetWidth( ), 0 );
            self.percentText:SetText( StatusBars2_Round( self.value / self.maxValue * 100 ) .. "%" );
        end

    -- Normal mode
    else
        StatusBars2_UpdatePowerBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_StartCasting
--
--  Description:    Start spell casting
--
-------------------------------------------------------------------------------
--
function StatusBars2_PowerBar_StartCasting( self )

        -- Get spell info
        local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo( self.unit );

        -- If that failed try getting channeling info
        channeling = false;
        if( name == nil ) then
            name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo( self.unit );
            channeling = true;
        end

        -- If the unit is casting a spell update the power bar
        if( name ~= nil ) then

            -- Get the current and max values
            if( not channeling ) then
                self.value = GetTime( ) - ( startTime / 1000 );
                self.maxValue = ( endTime - startTime ) / 1000;
                self.castID = castID;
            else
                self.value = ( ( endTime / 1000 ) - GetTime( ) );
                self.maxValue = ( endTime - startTime ) / 1000;
            end

            -- Set the bar min, max and current values
            self.status:SetMinMaxValues( 0, self.maxValue );
            self.status:SetValue( self.value );

            -- Set the text
            self.text:SetText( name );

            -- Show the bar spark
            self.spark:Show( );

            -- Set the bar color
            if( notInterruptible ) then
                self.status:SetStatusBarColor( 1.0, 0.0, 0.0 );
            elseif( channeling ) then
                self.status:SetStatusBarColor( 1.0, 0.7, 0.0 );
            else
                self.status:SetStatusBarColor( 0.0, 1.0, 0.0 );
            end

            -- Enter channeling mode
            self.casting = not channeling;
            self.channeling = channeling;
        end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_EndCasting
--
--  Description:    End spell casting
--
-------------------------------------------------------------------------------
--
function StatusBars2_PowerBar_EndCasting( self )

    -- Exit casting mode
    self.casting = false;
    self.channeling = false;
    self.castID = nil;

    -- Reset the min and max values
    self.status:SetMinMaxValues( 0, UnitPowerMax( self.unit, StatusBars2_GetPowerType( self ) ) );

    -- Hide the bar spark
    self.spark:Hide( );

    -- Reset the color
    StatusBars2_SetPowerBarColor( self );

    -- Update the bar
    StatusBars2_UpdatePowerBar( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_OnEnable
--
--  Description:    Power bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_PowerBar_OnEnable( self )

    -- Set the color
    StatusBars2_SetPowerBarColor( self );

    -- Update
    StatusBars2_UpdatePowerBar( self );

    -- Call the base method
    StatusBars2_ContinuousBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_IsVisible
--
--  Description:    Determine if a power bar should be visible
--
-------------------------------------------------------------------------------
--
function StatusBars2_PowerBar_IsVisible( self )

    return StatusBars2_ContinuousBar_IsVisible( self ) and ( UnitPowerMax( self.unit, StatusBars2_GetPowerType( self ) ) > 0 or self.casting or self.channeling );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_IsDefault
--
--  Description:    Determine if a power bar is at its default level
--
-------------------------------------------------------------------------------
--
function StatusBars2_PowerBar_IsDefault( self )

    local isDefault = true;

    -- If casting the bar is not at the default level
    if self.casting or self.channeling then
        isDefault = false

    -- Otherwise check the power level
    else

        -- Get the power type
        local powerType = StatusBars2_GetPowerType( self );

        -- Get the current power
        local power = UnitPower( self.unit, powerType );

        -- Determine if power is at it's default state
        if( powerType == SPELL_POWER_RAGE or powerType == SPELL_POWER_RUNIC_POWER ) then
            isDefault = ( power == 0 );
        elseif( powerType == SPELL_POWER_DEMONIC_FURY ) then
            isDefault = ( power == 200 );
        else
            local maxPower = UnitPowerMax( self.unit, powerType );
            isDefault = ( power == maxPower );
        end
    end

    return isDefault;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdatePowerBar
--
--  Description:    Update a power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdatePowerBar( self )

    -- Get the current and max power
    local power = UnitPower( self.unit, StatusBars2_GetPowerType( self ) );
    local maxPower = UnitPowerMax( self.unit, StatusBars2_GetPowerType( self ) );

    -- Update the bar
    StatusBars2_UpdateContinuousBar( self, power, maxPower );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetPowerType
--
--  Description:    Get the power type that a power bar is displaying
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetPowerType( self )

    if( self.powerType ~= nil ) then
        return self.powerType;
    else
        return UnitPowerType( self.unit );
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetPowerBarColor
--
--  Description:    Set the color of a power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetPowerBarColor( powerToken )

    -- PowerBarColor defined by Blizzard unit frame
    local color = PowerBarColor[powerToken];
    
    if( not color ) then 
        if( powerToken == SPELL_POWER_DEMONIC_FURY or powerToken == "DEMONIC_FURY" ) then
            color = { r = 0.57, g = 0.12, b = 1 };
        elseif( powerToken == SPELL_POWER_BURNING_EMBERS or powerToken == "BURNING_EMBERS") then
            color = { r = 1, g = 0.33, b = 0 };
        elseif( powerToken == SPELL_POWER_SHADOW_ORBS or powerToken == "SHADOW_ORBS") then
            color = { r = 162/255, g = 51/255, b = 209/255 };
        else
            color = kDefaultPowerBarColor; 
        end
    end
    
    return color.r, color.g, color.b;
        
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetPowerBarColor
--
--  Description:    Set the color of a power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_SetPowerBarColor( self )

    local powerType = StatusBars2_GetPowerType( self );
    self.status:SetStatusBarColor( StatusBars2_GetPowerBarColor( powerType ) );
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
    -- displays.  I'll just listen to the approriate event they listen for.
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

    -- Set the visible handler
    bar.BarIsVisible = StatusBars2_ContinuousBar_IsVisible;

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
--  Name:           StatusBars2_UpdateContinuousBar
--
--  Description:    Update a continuous bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateContinuousBar( self, current, max )

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
        if( StatusBars2_Settings.bars[ self.key ].flash and current / max <= StatusBars2_Settings.bars[ self.key ].flashThreshold ) then
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
    if( StatusBars2_Settings.bars[ self.key ].percentText == 'Hide' ) then
        self.percentText:Hide( );
    else
        self.percentText:Show( );
        if( StatusBars2_Settings.bars[  self.key ].percentText == 'Left' ) then
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
    StatusBars2_StatusBar_OnEnable( self );

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

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateDiscreteBar
--
--  Description:    Create a bar to track a discrete number of values.
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateDiscreteBar( key, unit, displayName, barType, boxCount )

    -- Create the bar
    local bar = StatusBars2_CreateBar( key, "StatusBars2_DiscreteBarTemplate", unit, displayName, barType );

    -- Set custom options template
    bar.optionsTemplate = "StatusBars2_AuraStatckBarOptionsTemplate";

    -- Override default methods as needed
    bar.OnEnable = StatusBars2_DiscreteBar_OnEnable;

    -- Save the color in the settings.  I'll make this editable in the future.
    bar.GetColor = StatusBars2_GetDiscreteBarColor;

    -- Bar starts off with no boxes created.
    bar.boxCount = 0;

    -- Now create the number of boxes initially requested.  We may create more or hide
    -- some in the future, depending on spec/glyph/talent changes.
    StatusBars2_SetDiscreteBarBoxCount( bar, boxCount );

    return bar;

end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetDiscreteBarBoxCount
--
--  Description:    Adjusts the number of boxes on a discrete bar.
--
-------------------------------------------------------------------------------
--
function StatusBars2_SetDiscreteBarBoxCount( bar, boxCount )

    if ( bar.boxCount ~= boxCount ) then
        StatusBars2_CreateDiscreteBarBoxes( bar, boxCount );
        StatusBars2_AdjustDiscreteBarBoxes( bar, boxCount );
    end
end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateDiscreteBarBoxes
--
--  Description:    Creates boxes on a discrete bar.
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateDiscreteBarBoxes( bar, desiredBoxCount )

    assert( desiredBoxCount < 20, "Way too many discrete boxes" );
    
    local boxes = { bar:GetChildren( ) };
    local boxesAvailableCount = #boxes;

    if ( boxesAvailableCount < desiredBoxCount ) then

        local name = bar:GetName( );

        -- Initialize the boxes
        local i;
        for i = boxesAvailableCount, desiredBoxCount do
            local boxName = name .. '_Box' .. i;
            local statusName = name .. '_Box' .. i .. '_Status';
            local box = CreateFrame( "Frame", boxName, bar, "StatusBars2_DiscreteBoxTemplate" );
            local status = box:GetChildren( );
            status:SetValue( 0 );
        end
    end

end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AdjustDiscreteBarBoxes
--
--  Description:    Adjusts the number and size of boxes visible on a discrete bar.
--
-------------------------------------------------------------------------------
--
function StatusBars2_AdjustDiscreteBarBoxes( bar, boxCount )

    bar.boxCount = boxCount;
    
    -- The boxes look too far apart if you put them side by side because the frame
    -- has a pretty wide shadow on it.  Let them overlap a bit to snuggle them to
    -- a more aesthetically pleasing spacing
    local overlap = 3;
    local statusWidthDiff = 8;
    local combinedBoxWidth = bar:GetWidth( ) + ( boxCount - 1 ) * overlap;
    local boxWidth = combinedBoxWidth / boxCount;
    local boxLeft = 0;
    
    local backdropInfo = { edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16 };
    
    -- If the box size gets below 32, the edge elements within a box start to overlap and it looks crappy.
    -- So if that happens, scale the edge size down just enough that the elements don't overlap.
    if ( boxWidth < 32 ) then

        -- With the edge smaller, we also want less overlap
        overlap = overlap * boxWidth / 32;
        statusWidthDiff = statusWidthDiff * boxWidth / 32;

        -- Recalculate box size to go with the new overlap.
        combinedBoxWidth = bar:GetWidth( ) + ( boxCount - 1 ) * overlap;
        boxWidth = combinedBoxWidth / boxCount;

        -- Now we're ready to calculate tne new edge size
        backdropInfo.edgeSize = 16 * boxWidth / 32;

    end

    local boxes = { bar:GetChildren( ) };

    -- Initialize the boxes
    for i, box in ipairs(boxes) do

        box:SetBackdrop( backdropInfo );

        if ( i <= bar.boxCount ) then
            local status = box:GetChildren( );
            box:SetWidth( boxWidth );
            status:SetWidth( boxWidth - statusWidthDiff );

            -- Set the status bar to draw behind the edge frame so it doesn't overlap.
            -- This should be possible in XML, but the documentation is too sketchy for me to figure it out.
            status:SetFrameLevel( box:GetFrameLevel( ) - 1 );
            status:SetBackdropColor( 0, 0, 0, 0.85 );

            box:SetPoint( "TOPLEFT", bar, "TOPLEFT", boxLeft , 0 );
            boxLeft = boxLeft + boxWidth - overlap;
            box:Show( );
        else
            box:Hide( );
        end
    end

end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateDiscreteBarBoxColors
--
--  Description:    Set the color of the boxes on a discrete bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateDiscreteBarBoxColors( bar )

    local boxes = { bar:GetChildren( ) };

    -- Initialize the boxes
    for i, box in ipairs(boxes) do
        local status = box:GetChildren( );
        status:SetStatusBarColor( bar:GetColor( i ) );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateDiscreteBar
--
--  Description:    Update a discrete bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateDiscreteBar( bar, current )

    -- Update the boxes
    boxes = { bar:GetChildren( ) };
    
    -- Initialize the boxes
    for i, box in ipairs(boxes) do
    
        local status = box:GetChildren( );
       
        if i <= current then
            status:SetValue( 1 );
        else
            status:SetValue( 0 );
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetDiscreteBarColor
--
--  Description:    Get the color for the boxes of a discrete bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetDiscreteBarColor( bar, boxIndex )

    if( StatusBars2_Settings.bars[ bar.key ].color ) then
        return unpack(StatusBars2_Settings.bars[ bar.key ].color);
    elseif( bar.type == kCombo ) then
        return 1, 0, 0;
    elseif( bar.type == kAuraStack ) then
        if( bar.key == "anticipation" ) then
            return 0.6, 0, 0;
        elseif( bar.key == "maelstromWeapon" ) then
            return 0, 0.5, 1;
        elseif( bar.key == "frenzy" ) then
            return 1, 0.6, 0;
        end
    else
        return StatusBars2_GetPowerBarColor( bar.powerToken );
    end

    return kDefaultPowerBarColor.r, kDefaultPowerBarColor.g, kDefaultPowerBarColor.b;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_DiscreteBar_OnEnable
--
--  Description:    Discrete bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_DiscreteBar_OnEnable( self )

    StatusBars2_UpdateDiscreteBarBoxColors( self );

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateBar
--
--  Description:    Create a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateBar( key, template, unit, displayName, barType )

    -- Create the bar
    local bar = CreateFrame( "Frame", "StatusBars2_"..key.."Bar", StatusBars2, template );
    bar:Hide( );

    -- Store bar settings
    bar.unit = unit;
    bar.key = key;
    bar.displayName = displayName;
    bar.type = barType;
    bar.inCombat = false;

    -- Set the default options template
    bar.optionsTemplate = "StatusBars2_BarOptionsTemplate";

    -- Set the default methods
    bar.OnEnable = StatusBars2_StatusBar_OnEnable;
    bar.BarIsVisible = StatusBars2_StatusBar_IsVisible;
    bar.IsDefault = StatusBars2_StatusBar_IsDefault;
    bar.SetBarScale = StatusBars2_StatusBar_SetScale;
    bar.SetBarPosition = StatusBars2_StatusBar_SetPosition;
    bar.GetBarHeight = StatusBars2_StatusBar_GetHeight;

    -- Set the mouse event handlers
    bar:SetScript( "OnMouseDown", StatusBars2_StatusBar_OnMouseDown );
    bar:SetScript( "OnMouseUp", StatusBars2_StatusBar_OnMouseUp );
    bar:SetScript( "OnHide", StatusBars2_StatusBar_OnHide );

    -- Default the bar to Auto enabled
    bar.defaultEnabled = "Auto";

    -- Initialize flashing variables
    bar.flashing = false;

    -- Save it in the bar collection
    table.insert( bars, bar );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnEnable
--
--  Description:    Called when a status bar is enabled
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_OnEnable( self )

    if( self:BarIsVisible( ) ) then
        StatusBars2_ShowBar( self );
    end;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_OnMouseDown( self, button )

    -- Move on left button down
    if( button == 'LeftButton' ) then

        -- print("StatusBars2_StatusBar_OnMouseDown "..self:GetName().." x "..self:GetLeft().." y "..self:GetTop().." parent "..self:GetParent():GetName());
        -- point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        -- print("Anchor "..relativePoint.." of "..relativeTo:GetName().." to "..point.." xoff "..xOfs.." yoff "..yOfs);

        -- If grouped move the main frame
        if( StatusBars2_Settings.grouped ) then
            self:GetParent( ):OnMouseDown( button );
            -- StatusBars2_OnMouseDown( StatusBars2, button );

        -- Otherwise move this bar
        else
            self:StartMoving( );
            self.isMoving = true;
        end

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnMouseUp
--
--  Description:    Called when the mouse button goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_OnMouseUp( self, button )

    -- Move with left button
    if( button == 'LeftButton' ) then

        local parentFrame = self:GetParent( );

        -- If grouped move the main frame
        if( StatusBars2_Settings.grouped ) then
            parentFrame:OnMouseUp( button );
            -- StatusBars2_OnMouseUp( StatusBars2, button );

        -- Otherwise move this bar
        elseif( self.isMoving ) then

            -- End moving
            self:StopMovingOrSizing( );
            self.isMoving = false;
            
            -- Get the scaled position
            local left = self:GetLeft( ) * self:GetScale( );
            local top = self:GetTop( ) * self:GetScale( );

            -- Get the offsets relative to the main frame
            local xOffset = left - parentFrame:GetLeft( );
            local yOffset = top - parentFrame:GetTop( );

            -- Save the position in the settings
            StatusBars2_Settings.bars[ self.key ].position = {};
            StatusBars2_Settings.bars[ self.key ].position.x = xOffset;
            StatusBars2_Settings.bars[ self.key ].position.y = yOffset;

            -- Moving the bar de-anchored it from its group frame and anchored it to the screen.
            -- We don't want that, so re-anchor the bar to its group frame
            self:ClearAllPoints( );
            self:SetPoint( "TOPLEFT", groups[ self.group ], "TOPLEFT", xOffset * ( 1 / self:GetScale( ) ), yOffset * ( 1 / self:GetScale( ) ) );

        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_OnHide
--
--  Description:    Called when the frame is hidden
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_OnHide( self )

    StatusBars2_StatusBar_OnMouseUp( self, "LeftButton" );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_IsDefault
--
--  Description:    Determine if a status bar is in the default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_IsDefault( self )

    return true;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_SetScale
--
--  Description:    Set the bar scale
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_SetScale( self, scale )

    self:SetScale( scale );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_SetPosition
--
--  Description:    Set the bar position
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_SetPosition( self, x, y )

    local xOffset;
    local yOffset;

    -- If the bar has a saved position use it
    if( StatusBars2_Settings.bars[ self.key ].position ~= nil ) then
        xOffset = StatusBars2_Settings.bars[ self.key ].position.x * ( 1 / self:GetScale( ) );
        yOffset = StatusBars2_Settings.bars[ self.key ].position.y * ( 1 / self:GetScale( ) );

    -- If using default positioning need to adjust for the scale
    else
        xOffset = ( 85 * ( 1 / StatusBars2_Settings.bars[ self.key ].scale ) ) + ( -self:GetWidth( ) / 2 );
        yOffset = y * ( 1 / StatusBars2_Settings.bars[ self.key ].scale );
    end

    -- Set the bar position
    self:ClearAllPoints( );
    self:SetPoint( "TOPLEFT", groups[ self.group ], "TOPLEFT", xOffset, yOffset );

    -- if( self:IsVisible() ~= nil) then
    --     print("StatusBars2_StatusBar_SetPosition "..self:GetName().." x "..x.." y "..y.." xOffset "..xOffset.." yOffset "..yOffset.." vis "..self:IsVisible());
    -- else
    --     print("StatusBars2_StatusBar_SetPosition "..self:GetName().." x "..x.." y "..y.." xOffset "..xOffset.." yOffset "..yOffset.." vis unknown");
    -- end

    -- print("StatusBars2 pos "..StatusBars2:GetLeft().." "..StatusBars2:GetTop());

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_GetHeight
--
--  Description:    Get the bar height
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_GetHeight( self )

    return self:GetHeight( ) * StatusBars2_Settings.bars[ self.key ].scale;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StatusBar_IsVisible
--
--  Description:    Determine if a status bar should be visible
--
-------------------------------------------------------------------------------
--
function StatusBars2_StatusBar_IsVisible( self )

    -- Get the enable type
    local enabled = StatusBars2_Settings.bars[ self.key ].enabled;

    local visible = false;

    -- Auto
    if( enabled == "Auto" ) then
        visible = self.inCombat or not self:IsDefault( );

    -- Combat
    elseif( enabled == "Combat" ) then
        visible = self.inCombat;

    -- Always
    elseif( enabled == "Always" ) then
        visible = true;
    end

    return visible;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnMouseDown( self, button )

    if( button == "LeftButton" and not self.isMoving ) then
        self:StartMoving();
        self.isMoving = true;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnMouseUp
--
--  Description:    Called when the mouse button goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnMouseUp( self, button )

    if( button == "LeftButton" and self.isMoving ) then
        self:StopMovingOrSizing();
        self.isMoving = false;

        -- Save the position in the settings
        StatusBars2_Settings.position = {};

        local xOffset = self:GetLeft( ) + self:GetWidth( ) / 2;
        local yOffset = self:GetTop( );
        StatusBars2_Settings.position.x = xOffset * self:GetScale( ) - self:GetParent( ):GetWidth( ) / 2;
        StatusBars2_Settings.position.y = yOffset * self:GetScale( ) - self:GetParent( ):GetHeight( ) / 2;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnHide
--
--  Description:    Called when the frame is hidden
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnHide( self )

    StatusBars2_OnMouseUp( self, "LeftButton" );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateFlash
--
--  Description:    Update a flashing bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateFlash( self, level )

    -- Only update if the bar is flashing
    if( self.flashing ) then

        -- Set the bar backdrop level
        self:SetBackdropColor( level, 0, 0, level * kFlashAlpha );
        self.flash:SetVertexColor( level * kFlashAlpha, 0, 0 );
        self.flash:Show( );

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_StartFlash
--
--  Description:    Start a bar flashing
--
-------------------------------------------------------------------------------
--
function StatusBars2_StartFlash( self )

    if( not self.flashing ) then
        self.flashing = true;
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EndFlash
--
--  Description:    Stop a bar from flashing
--
-------------------------------------------------------------------------------
--
function StatusBars2_EndFlash( self )

    if( self.flashing ) then
        self.flashing = false;
        self.flash:Hide( );
        self:SetBackdropColor( 0, 0, 0, 0 );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ConstructDisplayName
--
--  Description:    Construct the appropriate display name for a bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_ConstructDisplayName( unit, barType )

    local barTypeText;
    
    if( barType == kDruidMana ) then
        local localizedClass = UnitClass( unit );
        return localizedClass.." "..MANA;
    elseif( barType == kDemonicFury ) then
        return DEMONIC_FURY;
    elseif( barType == kHealth ) then
        barTypeText = HEALTH;
    elseif( barType == kPower ) then
        -- A little odd, but as far as Blizzard defined strings go, the text for PET_BATTLE_STAT_POWER 
        -- probably best embodies a generic power bar for all languages
        barTypeText = PET_BATTLE_STAT_POWER;
    elseif( barType == kAura ) then
        barTypeText = AURAS;
    else
        assert( false, "unknown bar type");
    end
    
    local unitText;
    
    if( unit == "player" ) then
        unitText = STATUS_TEXT_PLAYER;
    elseif( unit == "target" ) then
        unitText = STATUS_TEXT_TARGET;
    elseif( unit == "focus" ) then
        unitText = FOCUS;
    elseif( unit == "pet" ) then
        unitText = STATUS_TEXT_PET;
    else
        assert( false, "Unknown unit type" );
    end

    return unitText.." "..barTypeText;
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetComboPoints
--
--  Description:    Get the number of combo points for the current player
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetComboPoints( )

    -- Check if the target is dead
    if UnitIsDeadOrGhost( 'target' ) then
        return 0;
    else
        return GetComboPoints( "player", "target" );
    end;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetAuraStack
--
--  Description:    Get the stack size of the specified aura
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetAuraStack( unit, aura, auraType )

    local stack = 0;

    -- Iterate over the auras on the target
    local i;
    for i = 1, 40 do

        -- Get the aura
        local name, rank, texture, count;
        if( auraType == "buff" ) then
            name, rank, texture, count = UnitBuff( unit, i );
        else
            name, rank, texture, count = UnitDebuff( unit, i );
        end

        -- Check the name
        if( name == nil ) then
            break;
        elseif( string.find( name, aura, 1, true ) ) then
            stack = count;
            break;
        end;
    end

    return stack;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Trace
--
--  Description:    Trace a message to the console
--
-------------------------------------------------------------------------------
--
function StatusBars2_Trace( message )
    DEFAULT_CHAT_FRAME:AddMessage( message );
end

-------------------------------------------------------------------------------
--
--  Name:
--
--  Description:    Trace a message to the console
--
-------------------------------------------------------------------------------
--
function safePrint( value )
    if value then
        return value;
    else
        return "nil";
    end
end

-------------------------------------------------------------------------------
--
--  Name:
--
--  Description:    Trace a message to the console
--
-------------------------------------------------------------------------------
--
function printBool( boolVal )
    if boolVal then
        return "true";
    else
        return "false";
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Round
--
--  Description:    Round a number
--
-------------------------------------------------------------------------------
--
function StatusBars2_Round( x, places )
    local mult = 10 ^  ( places or 0 )
    return floor( x * mult + 0.5 ) / mult
end
