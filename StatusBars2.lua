-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally

-- Create bars and groups containers
addonTable.groups = {};
addonTable.bars = {};

addonTable.groupIDs =
{
    kPlayerGroup              = 1,
    kTargetGroup              = 2,
    kFocusGroup               = 3,
    kPetGroup                 = 4.
};

addonTable.barTypes = 
{
    kHealth = 0,
    kPower = 1,
    kAura = 2,
    kAuraStack = 3,
    kCombo = 4,
    kRune = 5,
    kDruidMana = 6,
    kUnitPower = 7,
    kEclipse = 9,
    kDemonicFury = 13,
};

-- Text display options
addonTable.textDisplayOptions =
{
    kAbbreviated      = 1,
    kCommaSeparated   = 2,
    kUnformatted      = 3,
    kHidden           = 4,
};

-- Text display options
local kAbbreviated      = addonTable.textDisplayOptions.kAbbreviated;
local kCommaSeparated   = addonTable.textDisplayOptions.kCommaSeparated;
local kUnformatted      = addonTable.textDisplayOptions.kUnformatted;
local kHidden           = addonTable.textDisplayOptions.kHidden;

addonTable.fontInfo =
{
    { label = "Small",  filename = "GameFontNormalSmall" },
    { label = "Medium", filename = "GameFontNormal" },
    { label = "Large",  filename = "GameFontNormalLarge" },
    { label = "Huge",   filename = "GameFontNormalHuge" },
}

addonTable.kDefaultPowerBarColor = { r = 0.75, g = 0.75, b = 0.75 }

addonTable.debugLayout = false;

addonTable.kDefaultFramePosition = { x = 0, y = 0 };

addonTable.saveDataVersion = 1.2;

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

-- Group ids
local kPlayerGroup              = addonTable.groupIDs.kPlayerGroup;
local kTargetGroup              = addonTable.groupIDs.kTargetGroup;
local kFocusGroup               = addonTable.groupIDs.kFocusGroup;
local kPetGroup                 = addonTable.groupIDs.kPetGroup;

local kDefaultPowerBarColor = addonTable.kDefaultPowerBarColor;

local groups = addonTable.groups;
local bars = addonTable.bars;

local FontInfo = addonTable.fontInfo;
local kDefaultFramePosition = addonTable.kDefaultFramePosition;

local debugLayout = addonTable.debugLayout;

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

-- Spell IDs Blizzard doesn't define
local PRIEST_SHADOW_ORBS = 95740;
local HUNTER_FOCUS_FIRE = 82692;
local WARRIOR_SUNDER_ARMOR = 7386;
local MAGE_ARCANE_CHARGE = 114664;
local SHAMAN_MAELSTROM_WEAPON = 51530;
local ROGUE_ANTICIPATION = 114015;
local HUNTER_BLACK_ARROW = 3674;
local MAGE_ARCANE_MISSILES = 5143;

-- Buff IDs Blizzard doesn't define
local BUFF_FRENZY = 19615;
local BUFF_ANTICIPATION = 115189;
local BUFF_FINGERS_OF_FROST = 112965;
local BUFF_MASTERY_ICICLES = 76613;
local BUFF_TIDAL_WAVE = 51564;
local BUFF_LOCK_AND_LOAD = 168980;
local BUFF_MAELSTROM_WEAPON = 53817;
local BUFF_ARCANE_MISSILES = 79683;

-- Debuff IDs Blizzard doesn't define
local DEBUFF_WEAKENED_ARMOR = 113746;
local DEBUFF_ARCANE_CHARGE = 36032;

-- Specialization IDs
local SPEC_HUNTER_MARKSMAN = 2;
local SPEC_MAGE_FROST = 3;
local SPEC_SHAMAN_RESTORATION = 3;

-- Slash commands
SLASH_STATUSBARS21, SLASH_STATUSBARS22 = '/statusbars2', '/sb2';

-------------------------------------------------------------------------------
--
--  Name:           Slash_Cmd_Handler 
--
--  Description:    Handler for slash commands
--
-------------------------------------------------------------------------------
--

local function Slash_Cmd_Handler( msg, editbox )

	local command = msg:lower()

    if command == 'config' then
        -- Enable config mode
        StatusBars2Config_SetConfigMode( true );
    elseif command == '' then
        -- This is dumb, but if you seem to need to call once to open the panel and once to actually set it to the right category
        ShowUIPanel(InterfaceOptionsFrame);
        --InterfaceOptionsFrame_OpenToCategory(StatusBars2_Options);
        InterfaceOptionsFrame_OpenToCategory(StatusBars2_Options);
    else
        print("Usage: /statusbars2 or /sb2 - show the Statusbars2 Blizzard interface panel");
        print("Options: config - switch Statusbars2 into configuration mode");
    end
end

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
    
    -- Add mouse click handlers
    StatusBars2_MakeMovable( self, "all");

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

            if debugLayout then
                StatusBars2_Frame_ShowBackdrop( self )
                self.text:SetFontObject(FontInfo[1].filename);
                self.text:SetTextColor( 1, 1, 1 );
                self.text:SetText( self:GetName() );
                self.text:Show( );
            end

            -- If we have a power bar we don't have a blizzard color for, we'll use the class color.
            local _, englishClass = UnitClass( "player" );
            addonTable.kDefaultPowerBarColor = StatusBars2_ShallowCopy(RAID_CLASS_COLORS[englishClass]);

            StatusBars2_CreateGroups( );
            StatusBars2_CreateBars( );

            -- Saved variables have been loaded, we can fix up the settings now
            StatusBars2_LoadSettings( StatusBars2_Settings );

            -- Install slash command handler
            SlashCmdList["STATUSBARS2"] = Slash_Cmd_Handler;

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
    StatusBars2_CreateHealthBar( kPlayerGroup, 1, false, "playerHealth", "player" );
    StatusBars2_CreatePowerBar( kPlayerGroup, 2, false, "playerPower", "player" );
    StatusBars2_CreateAuraBar( kPlayerGroup, 7, false, "playerAura", "player" );

    -- Target bars
    StatusBars2_CreateHealthBar( kTargetGroup, 1, false, "targetHealth", "target" );
    StatusBars2_CreatePowerBar( kTargetGroup, 2, true, "targetPower", "target" );
    StatusBars2_CreateAuraBar( kTargetGroup, 7, false, "targetAura", "target" );

    -- Focus bars
    StatusBars2_CreateHealthBar( kFocusGroup, 1, false, "focusHealth", "focus" );
    StatusBars2_CreatePowerBar( kFocusGroup, 2, true, "focusPower", "focus" );
    StatusBars2_CreateAuraBar( kFocusGroup, 7, false, "focusAura", "focus" );

    -- Pet bars
    StatusBars2_CreateHealthBar( kPetGroup, 1, false, "petHealth", "pet" );
    StatusBars2_CreatePowerBar( kPetGroup, 2, false, "petPower", "pet" );
    StatusBars2_CreateAuraBar( kPetGroup, 7, false, "petAura", "pet" );

    -- Specialty bars
    
    if( englishClass == "DRUID" )  then
        StatusBars2_CreatePowerBar( kPlayerGroup, 4, false, "druidMana", "player", kDruidMana, SPELL_POWER_MANA );
        StatusBars2_CreateComboBar( kPlayerGroup, 5);
        StatusBars2_CreateEclipseBar( kPlayerGroup, 6);
    elseif( englishClass == "ROGUE" ) then
        StatusBars2_CreateComboBar( kPlayerGroup, 4);
        StatusBars2_CreateAuraStackBar( kPlayerGroup, 5, false, "anticipation", "player", ROGUE_ANTICIPATION, "buff", 5, BUFF_ANTICIPATION );
    elseif( englishClass == "DEATHKNIGHT" ) then
        StatusBars2_CreateRuneBar( kPlayerGroup, 4 );
    elseif( englishClass == "WARLOCK" ) then
        StatusBars2_CreatePowerBar( kPlayerGroup, 4, false, "fury", "player", kDemonicFury, SPELL_POWER_DEMONIC_FURY );
        StatusBars2_CreateShardBar( kPlayerGroup, 5);
        StatusBars2_CreateEmbersBar( kPlayerGroup, 6);
    elseif( englishClass == "PALADIN" ) then
        StatusBars2_CreateHolyPowerBar( kPlayerGroup, 4);
    elseif( englishClass == "PRIEST" ) then
        StatusBars2_CreateOrbsBar( kPlayerGroup, 4 );
    elseif( englishClass == "HUNTER" ) then
        StatusBars2_CreateAuraStackBar( kPlayerGroup, 4, false, "frenzy", "player", HUNTER_FOCUS_FIRE, "buff", 5, BUFF_FRENZY );
        StatusBars2_CreateAuraStackBar( kPlayerGroup, 5, false, "lockAndLoad", "player", HUNTER_BLACK_ARROW, "buff", 5, BUFF_LOCK_AND_LOAD );
    elseif( englishClass == "MAGE" ) then
        StatusBars2_CreateAuraStackBar( kPlayerGroup, 4, false, "arcaneCharge", "player", MAGE_ARCANE_CHARGE, "debuff", 4, DEBUFF_ARCANE_CHARGE );
        StatusBars2_CreateAuraStackBar( kPlayerGroup, 5, false, "arcaneMissiles", "player", MAGE_ARCANE_MISSILES, "buff", 3, BUFF_ARCANE_MISSILES, { 0.90, 0.57, 0.94 } );
    elseif( englishClass == "SHAMAN" ) then
        StatusBars2_CreateAuraStackBar( kPlayerGroup, 4, false, "maelstromWeapon", "player", SHAMAN_MAELSTROM_WEAPON, "buff", 5, BUFF_MAELSTROM_WEAPON );
    elseif( englishClass == "MONK" ) then
        StatusBars2_CreateChiBar( kPlayerGroup, 4 );
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
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "playerPower" and ( englishClass ~= "DRUID" or powerType ~= SPELL_POWER_MANA ) ) then
            StatusBars2_EnableBar( StatusBars2_playerPowerBar );
        elseif( bar.key == "playerAura" and ( bar.showBuffs or bar.showDebuffs ) ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "targetHealth" ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "targetPower" ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "targetAura" and ( bar.showBuffs or bar.showDebuffs ) ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "focusHealth" ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "focusPower" ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "focusAura" and ( bar.showBuffs or bar.showDebuffs ) ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "petHealth" ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "petPower" ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "petAura" and ( bar.showBuffs or bar.showDebuffs ) ) then
            StatusBars2_EnableBar( bar );
        -- Special Druid Bars
        elseif( bar.key == "druidMana" and ( bar.showInAllForms or powerType == SPELL_POWER_MANA ) ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "eclipse" and powerType == SPELL_POWER_MANA and GetSpecialization() == 1 ) then
            StatusBars2_EnableBar( bar );
        -- Special Rogue Bars
        elseif( bar.key == "combo" and powerType == SPELL_POWER_ENERGY ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "anticipation" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar );
        -- Special Death Knight Bars
        elseif( bar.key == "rune" ) then
            StatusBars2_EnableBar( bar );
        -- Special Warlock Bars
        elseif( bar.key == "fury" and GetSpecialization() == SPEC_WARLOCK_DEMONOLOGY ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "shard" and IsPlayerSpell( WARLOCK_SOULBURN ) ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "embers" and IsPlayerSpell( WARLOCK_BURNING_EMBERS ) ) then
            StatusBars2_EnableBar( bar );
        -- Special Paladin Bars
        elseif( bar.key == "holyPower" ) then
            StatusBars2_EnableBar( bar );
        -- Special Priest Bars
        elseif( bar.key == "orbs" and GetSpecialization() == SPEC_PRIEST_SHADOW ) then
            StatusBars2_EnableBar( bar );
        -- Special Hunter Bars
        elseif( bar.key == "frenzy" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "lockAndLoad" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar );
        -- Special Warrior Bars
        elseif( bar.key == "sunder" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar );
        -- Special Mage Bars
        elseif( bar.key == "arcaneCharge" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "arcaneMissiles" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "fingersOfFrost" and GetSpecialization() == SPEC_MAGE_FROST and GetUnitLevel( bar.unit ) == 24 ) then
            StatusBars2_EnableBar( bar );
        elseif( bar.key == "masteryIcicles" and GetSpecialization() == SPEC_MAGE_FROST and GetUnitLevel( bar.unit ) == 80 ) then
            StatusBars2_EnableBar( bar );
        -- Special Shaman Bars
        elseif( bar.key == "maelstromWeapon" and IsSpellKnown( bar.spellID ) ) then
            StatusBars2_EnableBar( bar );
        -- Special Monk Bars
        elseif( bar.key == "chi" ) then
            StatusBars2_EnableBar( bar );
        end

    end

    -- Set up the groups
    for i, group in ipairs( groups ) do
        group:OnEnable( );
    end

    -- Update the layout
    StatusBars2_UpdateFullLayout( )

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

    local rnd = StatusBars2_Round;

    local layoutBars = {}
    local positionedBars = {}

    -- Build a list of bars to layout
    for i, bar in ipairs( bars ) do
        -- If the bar has a group and index set include it in the layout
        if( bar.isEnabled and ( not bar.removeWhenHidden or bar.visible ) ) then
            if( bar.layoutType == "AutoLayout" ) then
                table.insert( layoutBars, bar );
            else
                table.insert( positionedBars, bar );
            end
        end
    end

    -- Order the bars
    table.sort( layoutBars, StatusBars2_BarCompareFunction );

    -- Lay them out
    local group;
    local groupFrame;
    local px, py = StatusBars2:GetCenter( );
    py = StatusBars2:GetTop( );
    local gx, gy = px, py;
    local offset = 0;
    local group_offset = 0;

    for i, bar in ipairs( layoutBars ) do

        -- Set the group frame position
        if( group ~= bar.group ) then
            group = bar.group;
            groupFrame = groups[ group ];
            group_offset = group_offset + offset;
            gx = px;
            gy = py + group_offset;
            StatusBars2_Movable_SetPosition( groupFrame, gx, gy);
            gx = groupFrame:GetCenter( );
            gy = groupFrame:GetTop( );
            group_offset = group_offset - kGroupSpacing;
            offset = 0;
        end

        -- Aura bars need a bit more space
        if( bar.type == kAura ) then
            offset = offset - 1;
        end

        bar:SetBarPosition( gx, gy + offset );

        -- Update the offset
        offset = offset - ( bar:GetBarHeight( ) - 2 );
    end

    for i, bar in ipairs( positionedBars ) do
        if( not bar.position ) then
            -- Fake letting go of the mouse button
            bar.startX = 10000;
            bar.startY = 10000;
            bar.isMoving = true;
            StatusBars2_Movable_StopMoving( bar );
        end

        bar:SetBarPosition( 0, 0 );
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
function StatusBars2_UpdateFullLayout( )

    -- Set the Main Frame scale and alpha
    StatusBars2:SetScale( StatusBars2.scale );
    StatusBars2:SetAlpha( StatusBars2.alpha );

    -- Set Main Frame Position
    StatusBars2_Movable_SetPosition( StatusBars2, kDefaultFramePosition.x, kDefaultFramePosition.y );

    -- Set group scale and alpha
    for i, group in ipairs( groups ) do
        group:SetScale( group.scale or 1 );
        group:SetAlpha( group.alpha or 1 );
    end

    for i, bar in ipairs( bars ) do
        bar:OnUpdateLayout( );
    end

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
function StatusBars2_EnableBar( bar )

    bar.isEnabled = true;

    -- Set the parent to the appropriate group frame
    bar:SetParent( groups[ bar.group ] );

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

    -- If the frame was being dragged, drop it.
    StatusBars2_Movable_StopMoving( bar );

    -- Remove the event and update handlers
    bar:SetScript( "OnEvent", nil );
    bar:SetScript( "OnUpdate", nil );

    -- Disable the mouse
    bar:EnableMouse( false );

    -- Unregister all events
    bar:UnregisterAllEvents( );

    -- Hide the bar
    bar:Hide( );
    bar.visible = false;

    bar.isEnabled = false;

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
        if( not immediate and StatusBars2.fade ) then
            local fadeInfo = {};
            fadeInfo.mode = "OUT";
            fadeInfo.timeToFade = kFadeOutTime;
            fadeInfo.startAlpha = bar.alpha;
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
        if( StatusBars2.fade ) then
            UIFrameFadeIn( bar, kFadeInTime, 0, bar.alpha );
        else
            bar:SetAlpha( bar.alpha );
            bar:Show( );
        end
        bar.visible = true;
    end

end

-- Max flash alpha
local kFlashAlpha = 0.8;

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
        self.flashtexture:SetVertexColor( level * kFlashAlpha, 0, 0 );
        self.flashtexture:Show( );

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
        self.flashtexture:Hide( );
        self:SetBackdropColor( 0, 0, 0, 0 );
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

    StatusBars2_Movable_StopMoving( self );

end

