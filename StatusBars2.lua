-- Settings
StatusBars2_Settings = { };

-- Bars
local bars = {};

-- Last flash time
local lastFlashTime = 0;

-- Bar group spacing
local kGroupSpacing = 18;

-- Bar types
local kHealth = 0;
local kPower = 1;
local kAura = 2;
local kAuraStack = 3;
local kCombo = 4;
local kRune = 5;
local kDruidMana = 6;
local kShard = 7;
local kHolyPower = 8;
local kEclipse = 9;
local kChi = 10;
local kOrbs = 11;
local kEmbers = 12;
local kFury = 13;
local kAnticipation = 14;
-- Number of runes
local kMaxRunes = 6;

-- Fade durations
local kFadeInTime = 0.2;
local kFadeOutTime = 1.0;

-- Flash duration
local kFlashDuration = 0.5;

-- Max flash alpha
local kFlashAlpha = 0.8;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OnLoad
--
--  Description:    Main frame OnLoad handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_OnLoad( self )

    -- Create bars
    StatusBars2_CreateBars( );
	
    -- Set scripts
    self:SetScript( "OnEvent", StatusBars2_OnEvent );
    self:SetScript( "OnUpdate", StatusBars2_OnUpdate );
    self:SetScript( "OnMouseDown", StatusBars2_OnMouseDown );
    self:SetScript( "OnMouseUp", StatusBars2_OnMouseUp );
    self:SetScript( "OnHide", StatusBars2_OnHide );

    -- Register for events
    self:RegisterEvent( "PLAYER_ENTERING_WORLD" );
    self:RegisterEvent( "UNIT_DISPLAYPOWER" );
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    -- Print a status message
    StatusBars2_Trace( 'StatusBars 2 initialized' );

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

    -- Player entering world, initialize the addon
    if( event == "PLAYER_ENTERING_WORLD" ) then

        -- Load settings
        StatusBars2_LoadSettings( );

      -- Update bar visibility and location
        StatusBars2_UpdateBars( );

        -- Initialize the option panel controls
        StatusBars2_Options_DoDataExchange( false );

    -- Druid change form
    elseif( event == "UNIT_DISPLAYPOWER" and select( 1, ... ) == "player" ) then

        local localizedClass, englishClass = UnitClass( "player" );
        if( englishClass == "DRUID" ) then
            StatusBars2_UpdateBars( );
        end
    elseif (event == "ACTIVE_TALENT_GROUP_CHANGED")	then
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

    -- Player bars
    StatusBars2_CreateHealthBar( "StatusBars2_HealthBar", "player", "Player Health", "playerHealth" );
    StatusBars2_CreatePowerBar( "StatusBars2_PowerBar", "player", nil, "Player Power", "playerPower" );
    StatusBars2_CreatePowerBar( "StatusBars2_DruidManaBar", "player", SPELL_POWER_MANA, "Druid Mana", "druidMana", kDruidMana );
    StatusBars2_CreateAuraBar( "StatusBars2_AuraBar", "player", "Player Auras", "playerAura" );

    -- Target bars
    StatusBars2_CreateHealthBar( "StatusBars2_TargetHealthBar", "target", "Target Health", "targetHealth" );
    StatusBars2_CreatePowerBar( "StatusBars2_TargetPowerBar", "target", nil, "Target Power", "targetPower" );
    StatusBars2_CreateAuraBar( "StatusBars2_TargetAuraBar", "target", "Target Auras", "targetAura" );

    -- Focus bars
    StatusBars2_CreateHealthBar( "StatusBars2_FocusHealthBar", "focus", "Focus Health", "focusHealth" );
    StatusBars2_CreatePowerBar( "StatusBars2_FocusPowerBar", "focus", nil, "Focus Power", "focusPower" );
    StatusBars2_CreateAuraBar( "StatusBars2_FocusAuraBar", "focus", "Focus Auras", "focusAura" );

    -- Pet bars
    StatusBars2_CreateHealthBar( "StatusBars2_PetHealthBar", "pet", "Pet Health", "petHealth" );
    StatusBars2_CreatePowerBar( "StatusBars2_PetPowerBar", "pet", nil, "Pet Power", "petPower" );
    StatusBars2_CreateAuraBar( "StatusBars2_PetAuraBar", "pet", "Pet Auras", "petAura" );
	StatusBars2_CreateAuraStackBar( "StatusBars2_FrenzyBar", GetSpellInfo( 19623 ), "buff", "pet", 5, 1, 0, 1, "Frenzy", "frenzy" );

    -- Specialty bars
    StatusBars2_CreateComboBar( "StatusBars2_ComboBar", "Combo Points", "combo" );
    StatusBars2_CreateAuraStackBar( "StatusBars2_AnticipationBar", GetSpellInfo( 115189 ), "buff", "player", 5, 1, 0, 1, "Anticipation", "anticipation" );
    StatusBars2_CreateRuneBar( "StatusBars2_RuneBar", "Runes", "rune" );
    StatusBars2_CreateAuraStackBar( "StatusBars2_SunderBar", GetSpellInfo( 113746 ), "debuff", "target", 3, 1, 0.5, 0, "Sunder Armor", "sunder" );
    StatusBars2_CreateAuraStackBar( "StatusBars2_ArcaneChargesBar", GetSpellInfo( 36032 ), "debuff", "player", 6, 95/255, 182/255, 255/255, "Arcane Charges", "arcaneCharges" );
    StatusBars2_CreateAuraStackBar( "StatusBars2_MaelstromWeaponBar", GetSpellInfo( 51528 ), "buff", "player", 5, 1, 0, 1, "Maelstrom Weapon", "maelstromWeapon" );
	StatusBars2_CreateAuraStackBar( "StatusBars2_RenewingMistBar", GetSpellInfo( 119607 ), "buff", "player", 3, 1, 0, 1, "Renewing Mist", "renewingMist" );
	StatusBars2_CreateShardBar( "StatusBars2_ShardBar", "Soul Shards", "shard" );
	StatusBars2_CreateHolyPowerBar( "StatusBars2_HolyPowerBar", "Holy Power", "holyPower" );
	StatusBars2_CreateEclipseBar( "StatusBars2_EclipseBar", "Eclipse", "eclipse" );
   	StatusBars2_CreatePowerBar( "StatusBars2_FuryBar", "player", SPELL_POWER_DEMONIC_FURY, "Demonic Fury", "fury", kFury );
	StatusBars2_CreateChiBar( "StatusBars2_ChiBar", "Chi", "chi" );
	StatusBars2_CreateOrbsBar( "StatusBars2_OrbsBar", "Orbs", "orbs" );
	StatusBars2_CreateEmbersBar( "StatusBars2_EmbersBar", "Embers", "embers" );
    -- StatusBars2_CreateAuraStackBar( "StatusBars2_DeadlyPoisonBar", GetSpellInfo( 2823 ), "debuff", "target", 5, 0, 1, 0, "Deadly Poison", "deadlyPoison" );


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

    -- Player health
    StatusBars2_EnableBar( StatusBars2_HealthBar, 1, 1 );

    -- Player power
    if( englishClass ~= "DRUID" or powerType ~= SPELL_POWER_MANA ) then
        StatusBars2_EnableBar( StatusBars2_PowerBar, 1, 2 );
    end

    -- Druid mana
    if( englishClass == "DRUID" and ( StatusBars2_Settings.bars.druidMana.showInAllForms == true or ( powerType == SPELL_POWER_MANA ) ) ) then
        StatusBars2_EnableBar( StatusBars2_DruidManaBar, 1, 3 );
    end

    -- Combo points
    if( englishClass == "DRUID" and powerType == SPELL_POWER_ENERGY )  then
        StatusBars2_EnableBar( StatusBars2_ComboBar, 1, 4 );
    elseif( englishClass == "ROGUE" ) then
        StatusBars2_EnableBar( StatusBars2_ComboBar, 1, 4 );

        if (IsUsableSpell( 115189 )) then
            StatusBars2_EnableBar( StatusBars2_AnticipationBar, 1, 16 );
        end
    end

	-- Shards
	if ( englishClass == "WARLOCK" and GetSpecialization() == 1 ) then
		StatusBars2_EnableBar( StatusBars2_ShardBar, 1, 5 );
	elseif ( englishClass == "WARLOCK" and GetSpecialization() == 3 ) then
		StatusBars2_EnableBar( StatusBars2_EmbersBar, 1, 13 );
	elseif ( englishClass == "WARLOCK" and GetSpecialization() == 2 ) then
		StatusBars2_EnableBar( StatusBars2_FuryBar, 1, 14 );
	end

	-- Holy Power
	if( englishClass == "PALADIN" ) then
		StatusBars2_EnableBar( StatusBars2_HolyPowerBar, 1, 6 );
	end

    -- Runes
    if( englishClass == "DEATHKNIGHT" ) then
        StatusBars2_EnableBar( StatusBars2_RuneBar, 1, 7 );
    end

	-- Eclipse
	if( englishClass == "DRUID" ) then
		if( powerType == SPELL_POWER_MANA and GetSpecialization() == 1 ) then
			StatusBars2_EnableBar( StatusBars2_EclipseBar, 1, 8 );
		end
	end

    -- Maelstrom Weapon
    if( englishClass == "SHAMAN" ) then
        StatusBars2_EnableBar( StatusBars2_MaelstromWeaponBar, 1, 9 );
    end

	-- Arcane Charges
    if( englishClass == "MAGE" and GetSpecialization() == 1 ) then
        StatusBars2_EnableBar( StatusBars2_ArcaneChargesBar, 1, 15 );
    end

	-- monk's chi
    if( englishClass == "MONK" ) then
        StatusBars2_EnableBar( StatusBars2_ChiBar, 1, 11 );
		if GetSpecialization() == 2 then
		StatusBars2_EnableBar( StatusBars2_RenewingMistBar, 1, 18 );
		end
    end

    -- priest's orbs
    if( englishClass == "PRIEST"  and GetSpecialization() == 3 )then
		StatusBars2_EnableBar( StatusBars2_OrbsBar, 1, 12 );
    end

    -- Sunder armor
    StatusBars2_EnableBar( StatusBars2_SunderBar, 1, 10 );

    -- Deadly poison
    -- StatusBars2_EnableBar( StatusBars2_DeadlyPoisonBar, 1, 11 );

    -- Player auras
    if( StatusBars2_Settings.bars.playerAura.showBuffs == true or StatusBars2_Settings.bars.playerAura.showDebuffs == true ) then
        StatusBars2_EnableBar( StatusBars2_AuraBar, 1, 17 );
    end

    -- Target health
    StatusBars2_EnableBar( StatusBars2_TargetHealthBar, 2, 1 );

    -- Target power
    StatusBars2_EnableBar( StatusBars2_TargetPowerBar, 2, 2, true );

    -- Target auras
    if( StatusBars2_Settings.bars.targetAura.showBuffs == true or StatusBars2_Settings.bars.targetAura.showDebuffs == true ) then
        StatusBars2_EnableBar( StatusBars2_TargetAuraBar, 2, 3 );
    end

    -- Focus health
    StatusBars2_EnableBar( StatusBars2_FocusHealthBar, 3, 1 );

    -- Focus power
    StatusBars2_EnableBar( StatusBars2_FocusPowerBar, 3, 2, true );

    -- Focus auras
    if( StatusBars2_Settings.bars.focusAura.showBuffs == true or StatusBars2_Settings.bars.focusAura.showDebuffs == true ) then
        StatusBars2_EnableBar( StatusBars2_FocusAuraBar, 3, 3 );
    end

    -- Pet health
     StatusBars2_EnableBar( StatusBars2_PetHealthBar, 4, 1 );

    -- Pet power
    StatusBars2_EnableBar( StatusBars2_PetPowerBar, 4, 2 );

    -- Pet araus
    if( StatusBars2_Settings.bars.petAura.showBuffs == true or StatusBars2_Settings.bars.petAura.showDebuffs == true ) then
        StatusBars2_EnableBar( StatusBars2_PetAuraBar, 4, 3 );
    end

    if( englishClass == "HUNTER" ) then
        StatusBars2_EnableBar( StatusBars2_FrenzyBar, 4, 4 );
    end
   
    -- If grouped and not locked enable the mouse for moving
    if( StatusBars2_Settings.grouped == true and StatusBars2_Settings.locked ~= true ) then
        StatusBars2:EnableMouse( true );
    else
        StatusBars2:EnableMouse( false );
    end

    -- Set the global scale
    StatusBars2:SetScale( StatusBars2_Settings.scale );
 
    -- Set Main Frame Position
    StatusBars2:ClearAllPoints( );
    StatusBars2:SetPoint( "TOP", UIPARENT, "CENTER", StatusBars2_Settings.position.x / StatusBars2:GetScale( ), StatusBars2_Settings.position.y / StatusBars2:GetScale( ) );

    -- print("update: frame x = "..StatusBars2:GetLeft( ).." frame y = "..StatusBars2:GetTop( ).." scale = "..StatusBars2:GetScale( ));
    -- print("update: frame width = "..StatusBars2:GetWidth( ).." frame height = "..StatusBars2:GetHeight( ));
    -- print("update: mid x = "..StatusBars2:GetLeft( ) + StatusBars2:GetWidth( ) / 2 .." mid y = "..StatusBars2:GetTop( ) - StatusBars2:GetHeight( ) / 2);
    -- print("update: parent width = "..StatusBars2:GetParent( ):GetWidth( ).." parent height = "..StatusBars2:GetParent( ):GetHeight( ));
    -- print("update: x = "..StatusBars2_Settings.position.x.." y = "..StatusBars2_Settings.position.y);

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
        local inCombat = UnitAffectingCombat( "player" );
        bar.inCombat = inCombat ~= nil;

        -- Enable the event and update handlers
        bar:SetScript( "OnEvent", bar.OnEvent );
        bar:SetScript( "OnUpdate", bar.OnUpdate );

        -- If not locked enable the mouse for moving
        if( StatusBars2_Settings.locked ~= true ) then
            bar:EnableMouse( true );
        end

        -- Set the scale
        bar:SetBarScale( StatusBars2_Settings.bars[ bar.key ].scale );

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
    bar.removeWhenHidden = nil;

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

    if( bar.visible == true ) then
        if( immediate ~= true and StatusBars2_Settings.fade == true ) then
            local fadeInfo = {};
            fadeInfo.mode = "OUT";
            fadeInfo.timeToFade = kFadeOutTime;
            fadeInfo.startAlpha = 1,0;
            fadeInfo.endAlpha = 0;
            fadeInfo.finishedFunc = StatusBars2_FadeOutFinished;
            fadeInfo.finishedArg1 = bar;
            UIFrameFade( bar, fadeInfo );
        else
            bar:Hide( );
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

    if( bar.visible == false ) then
        if( StatusBars2_Settings.fade == true ) then
            UIFrameFadeIn( bar, kFadeInTime, 0, 1.0 );
        else
            bar:SetAlpha( 1.0 );
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

    local layoutBars = {}

    -- Build a list of bars to layout
    for i, bar in ipairs( bars ) do

        -- If the bar has a group and index set include it in the layout
        if( bar.group ~= nil and bar.index ~= nil and ( bar.removeWhenHidden == nil or bar.visible == true or StatusBars2_Options.moveBars == true ) ) then
            table.insert( layoutBars, bar );
        end
    end

    -- Order the bars
    table.sort( layoutBars, StatusBars2_BarCompareFunction );

    -- Lay them out
    local group = nil;
    local offset = 0;
    for i, bar in ipairs( layoutBars ) do

        -- Add space between groups
        if( group ~= nil and group ~= bar.group ) then
            offset = offset - kGroupSpacing;
        end
        group = bar.group;

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
function StatusBars2_CreateHealthBar( name, unit, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateContinuousBar( name, unit, 1, 0, 0, displayName, key, kHealth );

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
    if( self.visible == true ) then

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
function StatusBars2_CreatePowerBar( name, unit, powerType, displayName, key, barType )

    -- Create the power bar
    local bar = StatusBars2_CreateContinuousBar( name, unit, 1, 1, 0, displayName, key, barType or kPower );

    -- If its a target power bar use a special options template
    if( unit == "target" ) then
        bar.optionsTemplate = "StatusBars2_TargetPowerBarOptionsTemplate";
    end

    -- If its the druid mana bar use a special options template
    if( bar.type == kDruidMana ) then
        bar.optionsTemplate = "StatusBars2_DruidManaBarOptionsTemplate";
    end

    -- Save the power type
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

    if( unit == "target" ) then
        bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
        bar:RegisterEvent( "UNIT_SPELLCAST_START" );
        bar:RegisterEvent( "UNIT_SPELLCAST_STOP" );
        bar:RegisterEvent( "UNIT_SPELLCAST_FAILED" );
        bar:RegisterEvent( "UNIT_SPELLCAST_INTERRUPTED" );
        bar:RegisterEvent( "UNIT_SPELLCAST_DELAYED" );
        bar:RegisterEvent( "UNIT_SPELLCAST_CHANNEL_START" );
        bar:RegisterEvent( "UNIT_SPELLCAST_CHANNEL_UPDATE" );
        bar:RegisterEvent( "UNIT_SPELLCAST_CHANNEL_STOP" );
    elseif( unit == "pet" ) then
        bar:RegisterEvent( "UNIT_PET" );
    end
    if( powerType == nil ) then
        bar:RegisterEvent( "UNIT_DISPLAYPOWER" );
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
        if( self:BarIsVisible( ) == true ) then

			-- Update the casting bar if applicable
			StatusBars2_PowerBar_StartCasting( self );

			-- If not in casting mode update as normal
			if( self.casting ~= true and self.channeling ~= true ) then
				StatusBars2_SetPowerBarColor( self );
				self.status:SetMinMaxValues( 0, UnitPowerMax( self.unit, StatusBars2_GetPowerType( self ) ) );
			end

			-- Show the bar and update the layout
			StatusBars2_ShowBar( self );
			StatusBars2_UpdateLayout( );

		-- Bar is not visible
        else
            local unitExists = UnitExists( self.unit );
            StatusBars2_HideBar( self, unitExists == 1 );
            if( unitExists == 1 ) then
                StatusBars2_UpdateLayout( );
            end
        end

    -- Show the bar when power ticks
    elseif( event == "UNIT_POWER" ) then
        if( self:BarIsVisible( ) == true and self.visible == false ) then
            StatusBars2_SetPowerBarColor( self );
            StatusBars2_ShowBar( self );
            StatusBars2_UpdateLayout( );
        end

    -- Update max power
    elseif( event == "UNIT_MAXPOWER" and self.casting ~= true and self.channeling ~= true ) then
        self.status:SetMinMaxValues( 0, UnitPowerMax( self.unit, StatusBars2_GetPowerType( self ) ) );

    -- Show when entering combat
    elseif( event == 'PLAYER_REGEN_DISABLED' ) then
        self.inCombat = true;
        if( self:BarIsVisible( ) == true and self.visible == false ) then
            StatusBars2_SetPowerBarColor( self );
            StatusBars2_ShowBar( self );
            StatusBars2_UpdateLayout( );
        end

    -- Exiting combat
    elseif( event == 'PLAYER_REGEN_ENABLED' ) then
        self.inCombat = false;

    -- Pet changed
    elseif( event == "UNIT_PET" ) then
        StatusBars2_UpdatePowerBar( self );

    -- Unit shapeshifted
    elseif( event == "UNIT_DISPLAYPOWER" and select( 1, ... ) == self.unit ) then
        StatusBars2_SetPowerBarColor( self );
        StatusBars2_UpdatePowerBar( self );

    -- Casting started
    elseif( select( 1, ... ) == self.unit and ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"  ) and StatusBars2_Settings.bars[ self.key ].showSpell == true ) then

		-- Set to casting mode
		StatusBars2_PowerBar_StartCasting( self );

		-- If the bar is currently hidden show it and update the layout
		if self.visible == false then
			StatusBars2_ShowBar( self );
			StatusBars2_UpdateLayout( );
		end

    -- Casting ended
    elseif( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_CHANNEL_STOP" ) then

        if( select( 1, ... ) == self.unit and ( event == "UNIT_SPELLCAST_CHANNEL_STOP" or select( 4, ... ) == self.castID ) ) then

			-- End casting mode
            StatusBars2_PowerBar_EndCasting( self );

			-- If the bar should no longer be visible hide it and update the layout
			if( self:BarIsVisible( ) == false ) then
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
    if( self.casting == true or self.channeling == true ) then

        -- Update the current value
        if( self.casting == true ) then
            self.value = self.value + elapsed;
        else
            self.value = self.value - elapsed;
        end

        -- Casting finished
        if( ( self.casting == true and self.value >= self.maxValue ) or ( self.value <= 0 ) ) then
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
            if( channeling == false ) then
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
			if( notInterruptible == true ) then
				self.status:SetStatusBarColor( 1.0, 0.0, 0.0 );
            elseif( channeling == true ) then
                self.status:SetStatusBarColor( 1.0, 0.7, 0.0 );
            else
                self.status:SetStatusBarColor( 0.0, 1.0, 0.0 );
            end

            -- Enter channeling mode
            self.casting = channeling == false;
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

    return StatusBars2_ContinuousBar_IsVisible( self ) and ( UnitPowerMax( self.unit, StatusBars2_GetPowerType( self ) ) > 0  or ( self.casting == true or self.channeling == true ) );

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
	if self.casting == true or self.channeling == true then
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
--  Name:           StatusBars2_SetPowerBarColor
--
--  Description:    Set the color of a power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_SetPowerBarColor( self )

    -- Get the power type
    local powerType = StatusBars2_GetPowerType( self );

    -- Get the color based on the power type
    local r, g, b;
    if( powerType == SPELL_POWER_ENERGY ) then
        r, g, b = 1, 1, 0;
    elseif( powerType == SPELL_POWER_RAGE ) then
        r, g, b = 1, 0, 0;
    elseif( powerType == SPELL_POWER_MANA ) then
        r, g, b = 0, 0, 1;
    elseif( powerType == SPELL_POWER_FOCUS ) then
        r, g, b = 1, 0.5, 0;
    elseif( powerType == SPELL_POWER_RUNIC_POWER ) then
        r, g, b = 0, 0.82, 1;
	elseif( powerType == SPELL_POWER_DEMONIC_FURY ) then
        r, g, b = 0.57, 0.12, 1;
    else
        r, g, b = 1, 0, 0;
    end

    -- Set the bar color
    self.status:SetStatusBarColor( r, g, b );
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateComboBar
--
--  Description:    Create a combo point bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateComboBar( name, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( name, "player", MAX_COMBO_POINTS, 1, 0, 0, displayName, key, kCombo );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_ComboBar_OnEvent;
    bar.OnEnable = StatusBars2_ComboBar_OnEnable;
    bar.IsDefault = StatusBars2_ComboBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
    bar:RegisterEvent( "UNIT_COMBO_POINTS" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ComboBar_OnEvent
--
--  Description:    Combo bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ComboBar_OnEvent( self, event, ... )

    -- Target changed
    if( event == "PLAYER_TARGET_CHANGED" ) then
        StatusBars2_UpdateDiscreteBar( self, StatusBars2_GetComboPoints( ) );

    -- Combo points changed
    elseif( event == "UNIT_COMBO_POINTS" ) then
        local unit = ...;
        if( unit == "player" ) then
            StatusBars2_UpdateDiscreteBar( self, StatusBars2_GetComboPoints( ) );
        end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ComboBar_OnEnable
--
--  Description:    Combo bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ComboBar_OnEnable( self )

    -- Update
    StatusBars2_UpdateDiscreteBar( self, StatusBars2_GetComboPoints( ) );

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ComboBar_IsDefault
--
--  Description:    Determine if a combo bar is at its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_ComboBar_IsDefault( self )

    return StatusBars2_GetComboPoints( ) == 0;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateShardBar
--
--  Description:    Create a soul shard bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateShardBar( name, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( name, "player", SHARD_BAR_NUM_SHARDS, 0.50, 0.32, 0.55, displayName, key, kShard );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_ShardBar_OnEvent;
    bar.OnEnable = StatusBars2_ShardBar_OnEnable;
    bar.IsDefault = StatusBars2_ShardBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "UNIT_POWER" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ShardBar_OnEvent
--
--  Description:    Shard bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ShardBar_OnEvent( self, event, ... )

    -- Number of shards changed
    if( event == "UNIT_POWER" ) then
        local unit, powerToken = ...;

        if( unit == self.unit and powerToken == "SOUL_SHARDS" ) then
            StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, SPELL_POWER_SOUL_SHARDS ) );
        end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ShardBar_OnEnable
--
--  Description:    Shard bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ShardBar_OnEnable( self )

    -- Update
    StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, SPELL_POWER_SOUL_SHARDS ) );

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ShardBar_IsDefault
--
--  Description:    Determine if a shard is at its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_ShardBar_IsDefault( self )

    return UnitPower( self.unit, SPELL_POWER_SOUL_SHARDS ) == UnitPowerMax( self.unit, SPELL_POWER_SOUL_SHARDS );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateHolyPowerBar
--
--  Description:    Create a holy power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateHolyPowerBar( name, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( name, "player", MAX_HOLY_POWER, 0.95, 0.90, 0.60, displayName, key, kHolyPower );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_HolyPowerBar_OnEvent;
    bar.OnEnable = StatusBars2_HolyPowerBar_OnEnable;
    bar.IsDefault = StatusBars2_HolyPowerBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "UNIT_POWER" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HolyPowerBar_OnEvent
--
--  Description:    Holy power bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_HolyPowerBar_OnEvent( self, event, ... )

    -- Number of shards changed
    if( event == "UNIT_POWER" ) then
        local unit, powerToken = ...;

        if( unit == self.unit and powerToken == "HOLY_POWER" ) then
            StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, SPELL_POWER_HOLY_POWER ) );
        end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HolyPowerBar_OnEnable
--
--  Description:    Holy power bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_HolyPowerBar_OnEnable( self )

    -- Update
    StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, SPELL_POWER_HOLY_POWER ) );

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_HolyPowerBar_IsDefault
--
--  Description:    Determine if a holy power bar is at its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_HolyPowerBar_IsDefault( self )

    return UnitPower( self.unit, SPELL_POWER_HOLY_POWER ) == 0;

end


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateChiBar
--
--  Description:    Create a chi bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateChiBar( name, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( name, "player", 4, 0, 1, 0.59, displayName, key, kChi );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_ChiBar_OnEvent;
    bar.OnEnable = StatusBars2_ChiBar_OnEnable;
    bar.IsDefault = StatusBars2_ChiBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "UNIT_POWER" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ChiBar_OnEvent
--
--  Description:    Chi bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ChiBar_OnEvent( self, event, ... )

    -- Number of shards changed
    if( event == "UNIT_POWER" ) then
        local unit, powerToken = ...;

        if( unit == self.unit and powerToken == "LIGHT_FORCE" ) then
            StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, 12 ) );
        end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end



-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ChiBar_OnEnable
--
--  Description:    Chi bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_ChiBar_OnEnable( self )

    -- Update
    StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, 12 ) );

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ChiBar_IsDefault
--
--  Description:    Determine if a Chi bar is at its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_ChiBar_IsDefault( self )

    return UnitPower( self.unit, 12 ) == 0;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateOrbsBar
--
--  Description:    Create a orbs bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateOrbsBar( name, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( name, "player", 3, 0.57, 0.12, 1, displayName, key, kOrbs );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_OrbsBar_OnEvent;
    bar.OnEnable = StatusBars2_OrbsBar_OnEnable;
    bar.IsDefault = StatusBars2_OrbsBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "UNIT_POWER" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OrbsBar_OnEvent
--
--  Description:    Orbs bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_OrbsBar_OnEvent( self, event, ... )

    -- Number of shards changed
    if( event == "UNIT_POWER" ) then
        local unit, powerToken = ...;

        if( unit == self.unit and powerToken == "SHADOW_ORBS" ) then
            StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, SPELL_POWER_SHADOW_ORBS ) );
        end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_OrbsBar_OnEnable
--
--  Description:    Orbs bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_OrbsBar_OnEnable( self )

    -- Update
    StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, SPELL_POWER_SHADOW_ORBS ) );

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ChiBar_IsDefault
--
--  Description:    Determine if a Orbs bar is at its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_OrbsBar_IsDefault( self )

    return UnitPower( self.unit, SPELL_POWER_SHADOW_ORBS ) == 0;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateEmbersBar
--
--  Description:    Create a Embers bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateEmbersBar( name, displayName, key )

    -- Calculate the number of embers
    local maxPower = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true);
	local power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true);
	local numEmbers = floor(maxPower / MAX_POWER_PER_EMBER);

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( name, "player", numEmbers, 0.57, 0.12, 1, displayName, key, kEmbers );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_EmbersBar_OnEvent;
    bar.OnEnable = StatusBars2_EmbersBar_OnEnable;
    bar.IsDefault = StatusBars2_EmbersBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "UNIT_POWER" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EmbersBar_OnEvent
--
--  Description:    Orbs bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_EmbersBar_OnEvent( self, event, ... )

    -- Number of Embers changed
    if( event == "UNIT_POWER" ) then
        local unit, powerToken = ...;

        if( unit == self.unit and powerToken == "BURNING_EMBERS" ) then
            StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, SPELL_POWER_BURNING_EMBERS ) );
        end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EmbersBar_OnEnable
--
--  Description:    Embers bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_EmbersBar_OnEnable( self )

    -- Update
    StatusBars2_UpdateDiscreteBar( self, UnitPower( self.unit, SPELL_POWER_BURNING_EMBERS ) );

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

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

    return UnitPower( self.unit, SPELL_POWER_BURNING_EMBERS ) == 1;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateEclipseBar
--
--  Description:    Create an eclipse bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateEclipseBar( name, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateBar( name, "player", "StatusBars2_EclipseBarTemplate", displayName, key, kEclipse );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_EclipseBar_OnEvent;
    bar.OnEnable = StatusBars2_EclipseBar_OnEnable;
	bar.OnUpdate = StatusBars2_EclipseBar_OnUpdate;

    -- Register for events
    bar:RegisterEvent( "UNIT_AURA" );
    bar:RegisterEvent( "ECLIPSE_DIRECTION_CHANGE" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EclipseBar_OnEvent
--
--  Description:    Eclipse bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_EclipseBar_OnEvent( self, event, ... )

	if event == "UNIT_AURA" then
		local arg1 = ...;
		if arg1 ==  PlayerFrame.unit then
			EclipseBar_CheckBuffs(self);
		end
	elseif event == "ECLIPSE_DIRECTION_CHANGE" then
		local isLunar = ...;
		if isLunar then
			self.marker:SetTexCoord( unpack(ECLIPSE_MARKER_COORDS["sun"]));
		else
			self.marker:SetTexCoord( unpack(ECLIPSE_MARKER_COORDS["moon"]));
		end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end


end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EclipseBar_OnEnable
--
--  Description:    Eclipse bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_EclipseBar_OnEnable( self )

	-- Update
	StatusBars2_EclipseBar_OnUpdate( self )

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EclipseBar_OnUpdate
--
--  Description:    Eclipse bar update handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_EclipseBar_OnUpdate( self )
	local power = UnitPower( "player", SPELL_POWER_ECLIPSE );
	local maxPower = UnitPowerMax( "player", SPELL_POWER_ECLIPSE );
	if self.showPercent then
		self.powerText:SetText(abs(power/maxPower*100).."%");
	else
		self.powerText:SetText(abs(power));
	end

	local xpos =  47*(power/maxPower)
	self.marker:SetPoint("CENTER", xpos, 0);
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_EclipseBar_OnShow
--
--  Description:    Eclipse bar show handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_EclipseBar_OnShow( self )

	local direction = GetEclipseDirection();
	if direction then
		self.marker:SetTexCoord( unpack(ECLIPSE_MARKER_COORDS[direction]));
	end

	local hasLunarEclipse = false;
	local hasSolarEclipse = false;

	local unit = "player";
	local j = 1;
	local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	while name do
		if spellID == ECLIPSE_BAR_SOLAR_BUFF_ID then
			hasSolarEclipse = true;
		elseif spellID == ECLIPSE_BAR_LUNAR_BUFF_ID then
			hasLunarEclipse = true;
		end
		j=j+1;
		name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
	end

	if hasLunarEclipse then
		self.glow:ClearAllPoints();
		local glowInfo = ECLIPSE_ICONS["moon"].big;
		self.glow:SetPoint("CENTER", self.moon, "CENTER", 0, 0);
		self.glow:SetWidth(glowInfo.x);
		self.glow:SetHeight(glowInfo.y);
		self.glow:SetTexCoord(glowInfo.left, glowInfo.right, glowInfo.top, glowInfo.bottom);
		self.sunBar:SetAlpha(0);
		self.darkMoon:SetAlpha(0);
		self.moonBar:SetAlpha(1);
		self.darkSun:SetAlpha(1);
		self.glow:SetAlpha(1);
		self.glow.pulse:Play();
	elseif hasSolarEclipse then
		self.glow:ClearAllPoints();
		local glowInfo = ECLIPSE_ICONS["sun"].big;
		self.glow:SetPoint("CENTER", self.sun, "CENTER", 0, 0);
		self.glow:SetWidth(glowInfo.x);
		self.glow:SetHeight(glowInfo.y);
		self.glow:SetTexCoord(glowInfo.left, glowInfo.right, glowInfo.top, glowInfo.bottom);
		self.moonBar:SetAlpha(0);
		self.darkSun:SetAlpha(0);
		self.sunBar:SetAlpha(1);
		self.darkMoon:SetAlpha(1);
		self.glow:SetAlpha(1);
		self.glow.pulse:Play();
	else
		self.sunBar:SetAlpha(0);
		self.moonBar:SetAlpha(0);
		self.darkSun:SetAlpha(0);
		self.darkMoon:SetAlpha(0);
		self.glow:SetAlpha(0);
	end

	self.hasLunarEclipse = hasLunarEclipse;
	self.hasSolarEclipse = hasSolarEclipse;

	StatusBars2_EclipseBar_OnUpdate(self);
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateRuneBar
--
--  Description:    Create a rune bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateRuneBar( name, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateBar( name, "player", "StatusBars2_RuneFrameTemplate", displayName, key, kRune );

    -- Create the rune table
    bar.runes = {};

    -- Initialize the rune buttons
    local i;
    for i = 1, 6 do
        local rune = _G[ name .. '_RuneButton' .. i ];
        rune.parentBar = bar;
        RuneButton_Update( rune, i, true );
    end

    -- Set the event handlers
    bar.OnEvent = StatusBars2_RuneBar_OnEvent;
    bar.OnEnable = StatusBars2_RuneBar_OnEnable;
    bar.IsDefault = StatusBars2_RuneBar_IsDefault;

    -- Register for events
    bar:RegisterEvent( "RUNE_POWER_UPDATE" );
    bar:RegisterEvent( "RUNE_TYPE_UPDATE" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );
	bar:RegisterEvent( "PLAYER_ENTERING_WORLD" );

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_OnEvent
--
--  Description:    Rune bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneBar_OnEvent( self, event, ... )

    -- Entering combat
    if( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;

	-- Player entering world
	elseif( event == "PLAYER_ENTERING_WORLD" ) then
		StatusBars2_RuneBar_UpdateAllRunes( self );

	-- Rune power update
	elseif( event == "RUNE_POWER_UPDATE" ) then
		local runeIndex, isEnergize = ...;
		if runeIndex and runeIndex >= 1 and runeIndex <= kMaxRunes then
			local runeButton = _G[ self:GetName( ) .. '_RuneButton' .. runeIndex ];
			local cooldown = _G[runeButton:GetName().."Cooldown"];

			local start, duration, runeReady = GetRuneCooldown(runeIndex);

			if not runeReady  then
				if start then
					CooldownFrame_SetTimer(cooldown, start, duration, 1);
				end
				runeButton.energize:Stop();
			else
				cooldown:Hide();
				runeButton.shine:SetVertexColor(1, 1, 1);
				RuneButton_ShineFadeIn(runeButton.shine)
			end

			if isEnergize  then
				runeButton.energize:Play();
			end
		else
			assert(false, "Bad rune index")
		end

	-- Rune type update
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local runeIndex = ...;
		if ( runeIndex and runeIndex >= 1 and runeIndex <= kMaxRunes ) then
			RuneButton_Update(_G[ self:GetName( ) .. '_RuneButton' .. runeIndex ], runeIndex);
		end
	end

    -- Update the bar visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_OnEnable
--
--  Description:    Rune bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneBar_OnEnable( self )

    -- Enable or disable moving
    local i;
    for i = 1, 6 do

        -- Get the rune button
        local rune = _G[ self:GetName( ) .. '_RuneButton' .. i ];

        -- If not grouped or locked enable the mouse for moving
        if( StatusBars2_Settings.grouped ~= true and StatusBars2_Settings.locked ~= true ) then
            rune:EnableMouse( true );
            rune:SetScript( "OnMouseDown", StatusBars2_RuneButton_OnMouseDown );
            rune:SetScript( "OnMouseUp", StatusBars2_RuneButton_OnMouseUp );
            rune:SetScript( "OnHide", StatusBars2_RuneButton_OnHide );
        else
            rune:EnableMouse( false );
        end
    end

	-- Update the runes
	StatusBars2_RuneBar_UpdateAllRunes( self );

    -- Call the base method
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_UpdateAllRunes
--
--  Description:    Update all runes
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneBar_UpdateAllRunes( self )

	for i=1,kMaxRunes do
		local runeButton = _G[ self:GetName( ) .. '_RuneButton' .. i ];
		if runeButton then
			RuneButton_Update( runeButton, i, true );
		end
	end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneButton_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneButton_OnMouseDown( self, button )

    StatusBars2_StatusBar_OnMouseDown( self.parentBar, button );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneButton_OnMouseUp
--
--  Description:    Called when the mouse goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneButton_OnMouseUp( self, button )

    StatusBars2_StatusBar_OnMouseUp( self.parentBar, button );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneButton_OnHide
--
--  Description:    Called when the frame is hidden
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneButton_OnHide( self )

    StatusBars2_StatusBar_OnHide( self.parentBar );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_IsDefault
--
--  Description:    Determine if a rune bar is at its default state
--a
-------------------------------------------------------------------------------
--
function StatusBars2_RuneBar_IsDefault( self )

    local isDefault = true;

    -- Look for a rune that is not ready
    local i;
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown( i );
        if( runeReady ~= true ) then
            isDefault = false;
            break;
        end
    end

    return isDefault;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateAuraStackBar
--
--  Description:    Create bar to track the stack size of a buff or debuff
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateAuraStackBar( name, aura, auraType, unit, count, r, g, b, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( name, unit, count, r, g, b, displayName, key, kAuraStack );

    -- Save the aura name and unit
    bar.aura = aura;
    bar.auraType = auraType;
    bar.unit = unit;

    -- Set the event handlers
    bar.OnEvent = StatusBars2_AuraStackBar_OnEvent;
    bar.IsDefault = StatusBars2_AuraStackBar_IsDefault;

    -- Default the bar to never visible
    bar.defaultEnabled = "Never";

    -- Register for events
    bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );
    bar:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraStackBar_OnEvent
--
--  Description:    Aura stack bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraStackBar_OnEvent( self, event, ... )

    -- Target changed
    if( event == "PLAYER_TARGET_CHANGED" and self.unit == "target" ) then
        StatusBars2_UpdateDiscreteBar( self, StatusBars2_GetAuraStack( self.unit, self.aura, self.auraType ) );

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;

    -- Combat log event
    elseif( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then

        -- Get the event type and flags
        local eventType = select( 2, ... );
        local destName = select( 9, ... );
        local flags = select( 10, ... );

        -- Only care about events for the unit we are tracking
        if( ( self.unit == "target" and bit.band( flags, COMBATLOG_OBJECT_TARGET ) == COMBATLOG_OBJECT_TARGET ) or ( self.unit == "player" and destName == UnitName( "player" ) ) ) then

            -- Look for spell aura events
            if( eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_APPLIED_DOSE" or eventType == "SPELL_AURA_REMOVED_DOSE" ) then

                -- Look for the aura
                local spellName = select( 13, ... );
                if( string.find( spellName, self.aura ) == 1 ) then

                    -- Applied
                    if( eventType == "SPELL_AURA_APPLIED" ) then
                        StatusBars2_UpdateDiscreteBar( self, 1 );

                    -- Removed
                    elseif( eventType == "SPELL_AURA_REMOVED" ) then
                        StatusBars2_UpdateDiscreteBar( self, 0 );

                    -- Dose changed
                    else
                        local amount = select( 16, ... );
                        StatusBars2_UpdateDiscreteBar( self, amount );
                    end
                end
            end
        end
    end

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraStackBar_IsDefault
--
--  Description:    Determine if an aura stack bar is in its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraStackBar_IsDefault( self )

    return StatusBars2_GetAuraStack( self.unit, self.aura, self.auraType ) == 0;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateAuraBar
--
--  Description:    Create a bar to display the auras on a unit
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateAuraBar( name, unit, displayName, key )

    -- Create the bar
    local bar = StatusBars2_CreateBar( name, unit, "StatusBars2_AuraBarTemplate", displayName, key, kAura );

    -- Set the options template
    bar.optionsTemplate = "StatusBars2_AuraBarOptionsTemplate";

    -- Initialize the button array
    bar.buttons = {};

    -- Set the event handlers
    bar.OnEvent = StatusBars2_AuraBar_OnEvent;
    bar.OnEnable = StatusBars2_AuraBar_OnEnable;
    bar.BarIsVisible = StatusBars2_AuraBar_IsVisible;
    bar.IsDefault = StatusBars2_AuraBar_IsDefault;
    bar.SetBarScale = StatusBars2_AuraBar_SetScale;
    bar.SetBarPosition = StatusBars2_AuraBar_SetPosition;
    bar.GetBarHeight = StatusBars2_AuraBar_GetHeight;

    -- Register for events
    bar:RegisterEvent( "UNIT_AURA" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );
    if( unit == "target" ) then
        bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
	elseif( unit == "focus" ) then
		bar:RegisterEvent( "PLAYER_FOCUS_CHANGED" );
    end

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_OnEvent
--
--  Description:    Aura bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_OnEvent( self, event, ... )

    -- Aurea changed
    if( event == "UNIT_AURA" ) then
        local arg1 = ...;
        if( arg1 == self.unit ) then
            StatusBars2_UpdateAuraBar( self );
        end

    -- Target changed
    elseif( event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" ) then
        if( self:BarIsVisible( ) == true ) then
            StatusBars2_UpdateAuraBar( self );
        end

    -- Entering combat
    elseif( event == 'PLAYER_REGEN_DISABLED' ) then
        self.inCombat = true;

    -- Exiting combat
    elseif( event == 'PLAYER_REGEN_ENABLED' ) then
        self.inCombat = false;
    end;

    -- Update visibility
    if( self:BarIsVisible( ) == true ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_OnEnable
--
--  Description:    Aura bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_OnEnable( self )

    StatusBars2_UpdateAuraBar( self );
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_IsVisible
--
--  Description:    Determine if an aura bar is visible
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_IsVisible( self )

    return StatusBars2_StatusBar_IsVisible( self ) and UnitExists( self.unit ) == 1 and UnitIsDeadOrGhost( self.unit ) == nil;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_IsDefault
--
--  Description:    Determine if a bar is in its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_IsDefault( self )

    -- No need to check, if there are no auras the bar will be empty anyway
    return false;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_SetScale
--
--  Description:    Set the bar scale
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_SetScale( self, scale )

    self:SetHeight( StatusBars2_GetAuraSize( self ) );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_SetPosition
--
--  Description:    Set the bar position
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_SetPosition( self, x, y )

    -- If the bar has a saved position call the default method
    if( StatusBars2_Settings.bars[ self.key ].position ~= nil ) then
        StatusBars2_StatusBar_SetPosition( self, x, y );

    -- Otherwise set the bar position
    else
        self:ClearAllPoints( );
        self:SetPoint( "TOPLEFT", StatusBars2, "TOPLEFT", x, y );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_GetHeight
--
--  Description:    Get the bar height
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_GetHeight( self )

    return self:GetHeight( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateAuraBar
--
--  Description:    Update an aura bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateAuraBar( self )

    -- If dragging have to cancel before hiding the buttons
    if( self.isMoving == true ) then
        StatusBars2_StatusBar_OnMouseUp( self, "LeftButton" );
    end

    -- Button offset
    local offset = 2;

    -- Hide all the buttons
    for name, button in pairs( self.buttons ) do
        button:Hide( );
    end

    -- Buffs
    if( StatusBars2_Settings.bars[ self.key ].showBuffs == true ) then
        offset = StatusBars2_ShowAuraButtons( self, "Buff", UnitBuff, MAX_TARGET_BUFFS, StatusBars2_Settings.bars[ self.key ].onlyShowSelf, offset );
    end

    -- Add a space between the buffs and the debuffs
    if( offset > 2 ) then
        offset = offset + StatusBars2_GetAuraSize( self );
    end

    -- Debuffs
    if( StatusBars2_Settings.bars[ self.key ].showDebuffs == true ) then
        offset = StatusBars2_ShowAuraButtons( self, "Debuff", UnitDebuff, MAX_TARGET_DEBUFFS, StatusBars2_Settings.bars[ self.key ].onlyShowSelf, offset );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ShowAuraButtons
--
--  Description:    Show buff or debuff buttons
--
-------------------------------------------------------------------------------
--
function StatusBars2_ShowAuraButtons( self, auraType, getAuraFunction, maxAuras, mineOnly, offset )

    -- Iterate over the unit auras
    for i = 1, maxAuras do

        -- Get the aura
        local name, rank, icon, count, debuffType, duration, expirationTime, caster = getAuraFunction( self.unit, i );

        -- If the aura exists show it
        if( icon ~= nil ) then

            -- Determine if the button should be shown
            if( ( caster == "player" or mineOnly == false ) and ( duration > 0 or StatusBars2_Settings.bars[ self.key ].onlyShowTimed == false ) ) then

                -- Get the button
                local buttonName = self:GetName( ) .. "_" .. auraType .. "Button" .. i;
                local button = StatusBars2_GetAuraButton( self, i, buttonName, "Target" .. auraType .. "FrameTemplate", name, rank, icon, count, debuffType, duration, expirationTime, offset );

                -- Update the offset
                offset = offset + button:GetWidth( ) + 2;

                -- Show the button
                button:Show( );
            end
        else
            break;
        end
    end

    return offset;
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetAuraButton
--
--  Description:    Get an aura button for this bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetAuraButton( self, id, buttonName, template, auraName, auraRank, auraIcon, auraCount, debuffType, auraDuration, auraExpirationTime, offset )

    -- If the button does not exist create it
    if( self.buttons[ buttonName ] == nil ) then
        self.buttons[ buttonName ] = CreateFrame( "Button", buttonName, self, template );
        self.buttons[ buttonName ]:SetScript( "OnMouseDown", StatusBars2_AuraButton_OnMouseDown );
        self.buttons[ buttonName ]:SetScript( "OnMouseUp", StatusBars2_AuraButton_OnMouseUp );
    end

    -- Get the button
    local button = self.buttons[ buttonName ];

    -- Set the ID
    button:SetID( id );

    -- Set the unit
    button.unit = self.unit;

    -- Set the icon
    local buttonIcon = _G[ buttonName .. "Icon" ];
    buttonIcon:SetTexture( auraIcon );

    -- Set the cooldown
    local buttonCooldown = _G[ buttonName .. "Cooldown" ];
    if( auraDuration > 0 ) then
        buttonCooldown:Show( );
        CooldownFrame_SetTimer( buttonCooldown, auraExpirationTime - auraDuration, auraDuration, 1 );
    else
        buttonCooldown:Hide( );
    end

    -- Set the count
    buttonCount = _G[ buttonName .."Count" ];
    if( auraCount > 1 ) then
        buttonCount:SetText( auraCount );
        buttonCount:Show( );
    else
        buttonCount:Hide( );
    end

    -- Set the position
    button:SetPoint( "TOPLEFT", self, "TOPLEFT", offset, -2 );

    -- Set the size
    local auraSize = StatusBars2_GetAuraSize( self );
    button:SetWidth( auraSize );
    button:SetHeight( auraSize );

    -- Set the parent bar
    button.parentBar = self;

    -- If its a debuff set the border size and color
    if( template == "TargetDebuffFrameTemplate" ) then

        -- Get debuff type color
        local color = DebuffTypeColor[ "none" ];
        if( debuffType ) then
            color = DebuffTypeColor[ debuffType ];
        end

        -- Get the border
        local border = _G[ buttonName .. "Border" ];

        -- Set its size and color
        border:SetWidth( auraSize + 2 );
        border:SetHeight( auraSize + 2 );
        border:SetVertexColor(color.r, color.g, color.b);
    end

    return button;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraButton_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraButton_OnMouseDown( self, button )

    if( StatusBars2_Settings.locked ~= true or StatusBars2_Options.moveBars == true ) then
        StatusBars2_StatusBar_OnMouseDown( self.parentBar, button );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraButton_OnMouseUp
--
--  Description:    Called when the mouse goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraButton_OnMouseUp( self, button )

    if( StatusBars2_Settings.locked ~= true ) then
        StatusBars2_StatusBar_OnMouseUp( self.parentBar, button );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetAuraSize
--
--  Description:    Get the size of an aura button
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetAuraSize( self )

    return 16 * StatusBars2_Settings.bars[ self.key ].scale;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateContinuousBar
--
--  Description:    Create a bar to display a range of values
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateContinuousBar( name, unit, r, g, b, displayName, key, barType )

    -- Create the bar
    local bar = StatusBars2_CreateBar( name, unit, "StatusBars2_ContinuousBarTemplate", displayName, key, barType );

    -- Set the options template
    bar.optionsTemplate = "StatusBars2_ContinuousBarOptionsTemplate";

    -- Set the background color
    bar:SetBackdropColor( 0, 0, 0, 0.35 );

    -- Get the status and text frames
    bar.status = _G[ name .. "_Status" ];
    bar.text = _G[ name .. "_Text" ];
    bar.percentText = _G[ name .. "_PercentText" ];
    bar.spark = _G[ name .. "_Spark" ];
    bar.flash = _G[ name .. "_FlashOverlay" ];

    -- Set the visible handler
    bar.BarIsVisible = StatusBars2_ContinuousBar_IsVisible;

    -- Set the status bar color
    bar.status:SetStatusBarColor( r, g, b );

    -- Set the text color
    bar.text:SetTextColor( 1, 1, 1 );

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

    -- If the should not be visible, hide it
    if( self:BarIsVisible( ) == false ) then
        StatusBars2_HideBar( self );

    -- Otherwise update the bar
    else

        -- Show the bar
        StatusBars2_ShowBar( self );

        -- Set the bar current and max values
        self.status:SetMinMaxValues( 0, max );
        self.status:SetValue( current );

        -- Set the text
        self.text:SetText( current .. ' / ' .. max );

        -- Set the percent text
        self.percentText:SetText( StatusBars2_Round( current / max * 100 ) .. "%" );

        -- If below the flash threshold start the bar flashing, otherwise end flashing
        if( StatusBars2_Settings.bars[ self.key ].flash == true and current / max <= StatusBars2_Settings.bars[ self.key ].flashThreshold ) then
            StatusBars2_StartFlash( self );
        else
            StatusBars2_EndFlash( self );
        end
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

    return StatusBars2_StatusBar_IsVisible( self ) and UnitExists( self.unit ) == 1 and UnitIsDeadOrGhost( self.unit ) == nil;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateDiscreteBar
--
--  Description:    Create a bar to track a discrete number of values.
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateDiscreteBar( name, unit, count, r, g, b, displayName, key, barType )

    -- Create the bar
    local bar = StatusBars2_CreateBar( name, unit, "StatusBars2_DiscreteBarTemplate_" .. count, displayName, key, barType );

    -- Save the box count
    bar.boxCount = count;

    -- Initialize the boxes
    local i;
    for i = 1, count do
        local boxName = name .. '_Box' .. i;
        local statusName = name .. '_Box' .. i .. '_Status';
        local box = _G[ boxName ];
        local status = _G[ statusName ];
        box:SetBackdropColor( 0, 0, 0, 0.0 );
        status:SetStatusBarColor( r, g, b );
        status:SetValue( 0 );
    end

    return bar;

end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateDiscreteBar
--
--  Description:    Update a discrete bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateDiscreteBar( self, current )

    -- Update the boxes
    for i = 1, self.boxCount do

        -- Get the status bar
        local statusName = self:GetName( ) .. '_Box' .. i .. '_Status';
        local status = _G[ statusName ];

        -- If the point exists show it
        if i <= current then
            status:SetValue( 1 );
        else
            status:SetValue( 0 );
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateBar
--
--  Description:    Create a status bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateBar( name, unit, template, displayName, key, barType )

    -- Create the bar
    local bar = CreateFrame( "Frame", name, StatusBars2, template );
    bar:Hide( );

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

    -- Store bar settings
    bar.unit = unit;
    bar.displayName = displayName;
    bar.key = key;
    bar.type = barType;
	bar.inCombat = false;

    -- Default the bar to Auto enabled
    bar.defaultEnabled = "Auto";

    -- Initialize flashing variables
    bar.flashing = false;

    -- Set the default options template
    bar.optionsTemplate = "StatusBars2_BarOptionsTemplate";

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

    if( self:BarIsVisible( ) == true ) then
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
        if( StatusBars2_Settings.grouped == true ) then
            StatusBars2_OnMouseDown( StatusBars2, button );

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

        -- If grouped move the main frame
        if( StatusBars2_Settings.grouped == true ) then
            StatusBars2_OnMouseUp( StatusBars2, button );

        -- Otherwise move this bar
        elseif( self.isMoving ) then

            -- End moving
            self:StopMovingOrSizing( );
            self.isMoving = false;

            -- Get the scaled position
            local left = self:GetLeft( ) * self:GetScale( );
            local top = self:GetTop( ) * self:GetScale( );

            -- Get the offsets relative to the main frame
            local xOffset = left - StatusBars2:GetLeft( );
            local yOffset = top - StatusBars2:GetTop( );

            -- Save the position in the settings
            StatusBars2_Settings.bars[ self.key ].position = {};
            StatusBars2_Settings.bars[ self.key ].position.x = xOffset;
            StatusBars2_Settings.bars[ self.key ].position.y = yOffset;

            -- Moving the bar de-anchored it from the main frame and anchored it to the screen.
            -- We don't want that, so re-anchor the bar to the main parent frame
            self:ClearAllPoints( );
            self:SetPoint( "TOPLEFT", StatusBars2, "TOPLEFT", xOffset * ( 1 / self:GetScale( ) ), yOffset * ( 1 / self:GetScale( ) ) );

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
    self:SetPoint( "TOPLEFT", StatusBars2, "TOPLEFT", xOffset, yOffset );

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

    -- Auto
    local visible = false;
    if( enabled == "Auto" ) then
        visible = self.inCombat or self:IsDefault( ) == false;

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

    -- print("StatusBars2_OnMouseDown "..self:GetName().." x "..self:GetLeft().." y "..self:GetTop());

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

        -- print("frame x = "..self:GetLeft( ).." frame y = "..self:GetTop( ).." scale = "..self:GetScale( ));
        -- print("xOffset = "..xOffset.." yOffset = "..yOffset);
        -- print("parent width = "..self:GetParent( ):GetWidth( ).." parent height = "..self:GetParent( ):GetHeight( ));
        -- print("x = "..StatusBars2_Settings.position.x.." y = "..StatusBars2_Settings.position.y);
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
    if( self.flashing == true ) then

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

    if( self.flashing ~= true ) then
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

    if( self.flashing == true ) then
        self.flashing = false;
        self.flash:Hide( );
        self:SetBackdropColor( 0, 0, 0, 0 );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_LoadSettings
--
--  Description:    Load settings
--
-------------------------------------------------------------------------------
--
function StatusBars2_LoadSettings( )

    -- Initialize the bar settings
    StatusBars2_InitializeSettings( );

    -- Import old settings
    StatusBars2_ImportSettings( );

    -- Set default settings
    StatusBars2_SetDefaultSettings( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_InitializeSettings
--
--  Description:    Initialize the settings object
--
-------------------------------------------------------------------------------
--
function StatusBars2_InitializeSettings( )

    -- If the bar array does not exist create it
    if( StatusBars2_Settings.bars == nil ) then
        StatusBars2_Settings.bars = {};
    end

    -- Create a structure for each bar type
    for i, bar in ipairs( bars ) do
        if( StatusBars2_Settings.bars[ bar.key ] == nil ) then
            StatusBars2_Settings.bars[ bar.key ] = {};
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
function StatusBars2_ImportSettings( )

    -- Import old bar enable settings
    StatusBars2_ImportEnableSetting( "ShowPlayerHealth", "playerHealth" );
    StatusBars2_ImportEnableSetting( "ShowPlayerPower", "playerPower" );
    StatusBars2_ImportEnableSetting( "ShowDruidMana", "druidMana" );
    StatusBars2_ImportEnableSetting( "ShowTargetHealth", "targetHealth" );
    StatusBars2_ImportEnableSetting( "ShowTargetPower", "targetPower" );
    StatusBars2_ImportEnableSetting( "ShowPetHealth", "petHealth" );
    StatusBars2_ImportEnableSetting( "ShowPetPower", "petPower" );
    StatusBars2_ImportEnableSetting( "ShowComboPoints", "combo" );
    StatusBars2_ImportEnableSetting( "ShowRunes", "rune" );
    StatusBars2_ImportEnableSetting( "ShowDeadlyPoison", "deadlyPoison" );
    StatusBars2_ImportEnableSetting( "ShowSunderArmor", "sunder" );
    StatusBars2_ImportEnableSetting( "ShowMaelstromWeapon", "maelstromWeapon" );

    -- Player buffs
    if( StatusBars2_Settings.ShowPlayerBuffs ~= nil ) then
        StatusBars2_Settings.bars.playerAura.showBuffs = StatusBars2_Settings.ShowPlayerBuffs;
        StatusBars2_Settings.ShowPlayerBuffs = nil;
    end

    -- Player debuffs
    if( StatusBars2_Settings.ShowPlayerDebuffs ~= nil ) then
        StatusBars2_Settings.bars.playerAura.showDebuffs = StatusBars2_Settings.ShowPlayerDebuffs;
        StatusBars2_Settings.ShowPlayerDebuffs = nil;
    end

    -- Target buffs
    if( StatusBars2_Settings.ShowTargetBuffs ~= nil ) then
        StatusBars2_Settings.bars.targetAura.showBuffs = StatusBars2_Settings.ShowTargetBuffs;
        StatusBars2_Settings.ShowTargetBuffs = nil
    end

    -- Target debuffs
    if( StatusBars2_Settings.ShowTargetDebuffs ~= nil ) then
        StatusBars2_Settings.bars.targetAura.showDebuffs = StatusBars2_Settings.ShowTargetDebuffs;
        StatusBars2_Settings.ShowTargetDebuffs = nil
    end

    -- Pet buffs
    if( StatusBars2_Settings.ShowPetBuffs ~= nil ) then
        StatusBars2_Settings.bars.petAura.showBuffs = StatusBars2_Settings.ShowPetBuffs;
        StatusBars2_Settings.ShowPetBuffs = nil;
    end

    -- Pet debuffs
    if( StatusBars2_Settings.ShowPetDebuffs ~= nil ) then
        StatusBars2_Settings.bars.petAura.showDebuffs = StatusBars2_Settings.ShowPetDebuffs;
        StatusBars2_Settings.ShowPetDebuffs = nil;
    end

    -- Only show self auras
    if( StatusBars2_Settings.OnlyShowSelfAuras ~= nil ) then
        StatusBars2_Settings.OnlyShowSelfAuras = nil;
    end

    -- Only show auras with a duration
    if( StatusBars2_Settings.OnlyShowAurasWithDuration ~= nil ) then
        StatusBars2_Settings.OnlyShowAurasWithDuration = nil;
    end

    -- Only show in combat
    if( StatusBars2_Settings.OnlyShowInCombat ~= nil ) then
        StatusBars2_Settings.OnlyShowInCombat = nil;
    end

    -- Always show target
    if( StatusBars2_Settings.AlwaysShowTarget ~= nil ) then
        StatusBars2_Settings.AlwaysShowTarget = nil;
    end

    -- Target spell
    if( StatusBars2_Settings.ShowTargetSpell ~= nil ) then
        StatusBars2_Settings.bars.playerPower.showSpell = StatusBars2_Settings.ShowTargetSpell;
        StatusBars2_Settings.ShowTargetSpell = nil;
    end

    -- Locked
    if( StatusBars2_Settings.Locked ~= nil ) then
        StatusBars2_Settings.locked = StatusBars2_Settings.Locked;
        StatusBars2_Settings.Locked = nil;
    end

    -- Scale
    if( StatusBars2_Settings.Scale ~= nil ) then
        StatusBars2_Settings.scale = StatusBars2_Settings.Scale;
        StatusBars2_Settings.Scale = nil;
    end

    -- Aura size
    if( StatusBars2_Settings.AuraSize ~= nil ) then
        StatusBars2_Settings.AuraSize = nil;
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
function StatusBars2_ImportEnableSetting( old, new )

    if( StatusBars2_Settings[ old ] ~= nil ) then
        if( StatusBars2_Settings[ old ] == true ) then
            StatusBars2_Settings.bars[ new ].enabled = "Auto"
        else
            StatusBars2_Settings.bars[ new ].enabled = "Never"
        end
        StatusBars2_Settings[ old ] = nil;
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
function StatusBars2_SetDefaultSettings( )

    -- Set defaults for the bars
    for i, bar in ipairs( bars ) do

	-- print("Bar "..i);

	-- if( bar.displayName == nil ) then
	--	print(" Name <unknown>");
	-- else
	--	print(" Name "..bar.displayName);
	-- end

	-- print(" Key "..bar.key);
	-- print(" Unit "..bar.unit);
	-- print(" Type "..bar.type);

        -- Enable all bars by default
        if( StatusBars2_Settings.bars[ bar.key ].enabled == nil ) then
            StatusBars2_Settings.bars[ bar.key ].enabled = bar.defaultEnabled;
        end

        -- Flash player and pet health and mana bars
        if( StatusBars2_Settings.bars[ bar.key ].flash == nil and ( bar.optionsTemplate == "StatusBars2_ContinuousBarOptionsTemplate" or bar.optionsTemplate == "StatusBars2_DruidManaBarOptionsTemplate" ) ) then
            if( ( bar.unit == "player" or bar.unit == "pet" ) and bar.type == kHealth ) then
                StatusBars2_Settings.bars[ bar.key ].flash = true;
            elseif( ( bar.unit == "player" or bar.unit == "pet" ) and bar.type == kPower ) then
                local localizedClass, englishClass = UnitClass( "player" );
                StatusBars2_Settings.bars[ bar.key ].flash = ( bar.unit == "player" and englishClass ~= "ROGUE" and englishClass ~= "WARRIOR" and englishClass ~= "DEATHKNIGHT" and englishClass ~= "DRUID" ) or ( bar.unit == "pet" and englishClass == "WARLOCK" );
            elseif( bar.type == kDruidMana ) then
                StatusBars2_Settings.bars[ bar.key ].flash = true;
            else
                StatusBars2_Settings.bars[ bar.key ].flash = false;
            end
        end

        -- Place continuous bar percent text on the right side
        if( StatusBars2_Settings.bars[ bar.key ].percentText == nil and ( bar.optionsTemplate == "StatusBars2_ContinuousBarOptionsTemplate" or bar.optionsTemplate == "StatusBars2_DruidManaBarOptionsTemplate" or bar.optionsTemplate == "StatusBars2_TargetPowerBarOptionsTemplate" ) ) then
            StatusBars2_Settings.bars[ bar.key ].percentText = "Right";
        end

        -- Set flash threshold to 40%
        if( StatusBars2_Settings.bars[ bar.key ].flashThreshold == nil ) then
            StatusBars2_Settings.bars[ bar.key ].flashThreshold = 0.40;
        end

        -- Enable buffs
        if( StatusBars2_Settings.bars[ bar.key ].showBuffs == nil and bar.type == kAura ) then
            StatusBars2_Settings.bars[ bar.key ].showBuffs = true;
        end

        -- Enable debuffs
        if( StatusBars2_Settings.bars[ bar.key ].showDebuffs == nil and bar.type == kAura ) then
            StatusBars2_Settings.bars[ bar.key ].showDebuffs = true;
        end

        -- Show all auras
        if( StatusBars2_Settings.bars[ bar.key ].onlyShowSelf == nil and bar.type == kAura ) then
            StatusBars2_Settings.bars[ bar.key ].onlyShowSelf = false;
        end

        -- Show all auras
        if( StatusBars2_Settings.bars[ bar.key ].onlyShowTimed == nil and bar.type == kAura ) then
            StatusBars2_Settings.bars[ bar.key ].onlyShowTimed = false;
        end

        -- Set scale to 1.0
        if( StatusBars2_Settings.bars[ bar.key ].scale == nil or StatusBars2_Settings.bars[ bar.key ].scale <= 0 ) then
            StatusBars2_Settings.bars[ bar.key ].scale = 1.0;
        end

        -- Show target spell
        if( bar.type == kPower and bar.unit == "target" and StatusBars2_Settings.bars[ bar.key ].showSpell == nil ) then
            StatusBars2_Settings.bars[ bar.key ].showSpell = true;
        end

        -- Show in all forms
        if( bar.type == kDruidMana and StatusBars2_Settings.bars[ bar.key ].showInAllForms == nil ) then
            StatusBars2_Settings.bars[ bar.key ].showInAllForms = true;
        end

    end

    -- Fade
    if( StatusBars2_Settings.fade == nil ) then
        StatusBars2_Settings.fade = true;
    end

    -- Locked
    if( StatusBars2_Settings.locked == nil ) then
        StatusBars2_Settings.locked = false;
    end

    -- Grouped
    if( StatusBars2_Settings.grouped == nil ) then
        StatusBars2_Settings.grouped = true;
    end

    -- Scale
    if( StatusBars2_Settings.scale == nil or StatusBars2_Settings.scale <= 0 ) then
        StatusBars2_Settings.scale = 1.0;
    end

    -- Main Frame Position
    if( StatusBars2_Settings.position == nil ) then
        StatusBars2_Settings.position = {};
		StatusBars2_Settings.position.x = 0;
        StatusBars2_Settings.position.y = -100;
    end

end;

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
    self.name = "StatusBars 2";
    self.okay = StatusBars2_Options_OnOK;
    self.cancel = StatusBars2_Options_OnCancel;
    InterfaceOptions_AddCategory( self );

    -- Add a category for each bar
    for i, bar in ipairs( bars ) do

        -- Create the option frame
        local frame = CreateFrame( "Frame", bar:GetName( ) .. "_OptionFrame", self, bar.optionsTemplate );

        -- Initialize the frame
        frame.name = bar.displayName;
        frame.parent = "StatusBars 2";
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
    if( StatusBars2_Options.resetBarPositions == true ) then

		StatusBars2_Settings.position.x = 0;
		StatusBars2_Settings.position.y = -100;

        for i, bar in ipairs( bars ) do
            StatusBars2_Settings.bars[ bar.key ].position = nil;
        end
    end

    -- Update the bar visibility and location
    StatusBars2_UpdateBars( );

    -- Reset the position flag
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
--  Name:           StatusBars2_BarEnabledMenu_Initialize
--
--  Description:    Initialize the enabled drop down menu
--
-------------------------------------------------------------------------------
--
function StatusBars2_BarEnabledMenu_Initialize( self )

    -- Button info
    local info = {};
    info.func = StatusBars2_BarEnabledMenu_OnClick;
    info.arg1 = self;

    -- Auto
    local auto = {};
    auto.func = StatusBars2_BarEnabledMenu_OnClick;
    auto.arg1 = self;
    auto.text = "Auto";
    UIDropDownMenu_AddButton( auto );

    -- Combat
    local combat = {};
    combat.func = StatusBars2_BarEnabledMenu_OnClick;
    combat.arg1 = self;
    combat.text = "Combat";
    UIDropDownMenu_AddButton( combat );

    -- Always
    local always = {};
    always.func = StatusBars2_BarEnabledMenu_OnClick;
    always.arg1 = self;
    always.text = "Always";
    UIDropDownMenu_AddButton( always );

    -- Never
    local never = {};
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
    local left = {};
    left.func = StatusBars2_PercentTextMenu_OnClick;
    left.arg1 = self;
    left.text = "Left";
    UIDropDownMenu_AddButton( left );

    -- Right
    local right = {};
    right.func = StatusBars2_PercentTextMenu_OnClick;
    right.arg1 = self;
    right.text = "Right";
    UIDropDownMenu_AddButton( right );

    -- Hide
    local hide = {};
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
    local flashButton = _G[ frame:GetName( ) .. "_FlashButton" ];
    local flashThresholdSlider = _G[ frame:GetName( ) .. "_FlashThresholdSlider" ];
    local showBuffsButton = _G[ frame:GetName( ) .. "_ShowBuffsButton" ];
    local showDebuffsButton = _G[ frame:GetName( ) .. "_ShowDebuffsButton" ];
    local onlyShowSelfAurasButton = _G[ frame:GetName( ) .. "_OnlyShowSelfAurasButton" ];
    local onlyShowTimedAurasButton = _G[ frame:GetName( ) .. "_OnlyShowTimedAurasButton" ];
    local showSpellButton = _G[ frame:GetName( ) .. "_ShowSpellButton" ];
    local showInAllFormsButton = _G[ frame:GetName( ) .. "_ShowInAllForms" ];
    local percentTextMenu = _G[ frame:GetName( ) .. "_PercentTextMenu" ];

    -- Exchange data
    if( save == true ) then
        StatusBars2_Settings.bars[ frame.bar.key ].enabled = UIDropDownMenu_GetSelectedName( enabledMenu );
        StatusBars2_Settings.bars[ frame.bar.key ].scale = StatusBars2_Round( scaleSlider:GetValue( ), 2 );
        if( flashButton ~= nil ) then
            StatusBars2_Settings.bars[ frame.bar.key ].flash = flashButton:GetChecked( ) == 1;
            StatusBars2_Settings.bars[ frame.bar.key ].flashThreshold = StatusBars2_Round( flashThresholdSlider:GetValue( ), 2 );
        end
        if( showBuffsButton ~= nil ) then
            StatusBars2_Settings.bars[ frame.bar.key ].showBuffs = showBuffsButton:GetChecked( ) == 1;
        end
        if( showDebuffsButton ~= nil ) then
            StatusBars2_Settings.bars[ frame.bar.key ].showDebuffs = showDebuffsButton:GetChecked( ) == 1;
        end
        if( onlyShowSelfAurasButton ~= nil ) then
            StatusBars2_Settings.bars[ frame.bar.key ].onlyShowSelf = onlyShowSelfAurasButton:GetChecked( ) == 1;
        end
        if( onlyShowTimedAurasButton ~= nil ) then
            StatusBars2_Settings.bars[ frame.bar.key ].onlyShowTimed = onlyShowTimedAurasButton:GetChecked( ) == 1;
        end
        if( showSpellButton ~= nil ) then
            StatusBars2_Settings.bars[ frame.bar.key ].showSpell = showSpellButton:GetChecked( ) == 1;
        end
        if( showInAllFormsButton ~= nil ) then
            StatusBars2_Settings.bars[ frame.bar.key ].showInAllForms = showInAllFormsButton:GetChecked( ) == 1;
        end
        if( percentTextMenu ~= nil ) then
            StatusBars2_Settings.bars[ frame.bar.key ].percentText = UIDropDownMenu_GetSelectedName( percentTextMenu );
        end
    else
        UIDropDownMenu_SetSelectedName( enabledMenu, StatusBars2_Settings.bars[ frame.bar.key ].enabled );
        UIDropDownMenu_SetText( enabledMenu, StatusBars2_Settings.bars[ frame.bar.key ].enabled );
        scaleSlider:SetValue( StatusBars2_Settings.bars[ frame.bar.key ].scale );
        if( flashButton ~= nil ) then
            flashButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].flash );
            flashThresholdSlider:SetValue( StatusBars2_Settings.bars[ frame.bar.key ].flashThreshold );
        end
        if( showBuffsButton ~= nil ) then
            showBuffsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showBuffs );
        end
        if( showDebuffsButton ~= nil ) then
            showDebuffsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showDebuffs );
        end
        if( onlyShowSelfAurasButton ~= nil ) then
            onlyShowSelfAurasButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].onlyShowSelf );
        end
        if( onlyShowTimedAurasButton ~= nil ) then
            onlyShowTimedAurasButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].onlyShowTimed );
        end
        if( showSpellButton ~= nil ) then
            showSpellButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showSpell );
        end
        if( showInAllFormsButton ~= nil ) then
            showInAllFormsButton:SetChecked( StatusBars2_Settings.bars[ frame.bar.key ].showInAllForms );
        end
        if( percentTextMenu ~= nil ) then
            UIDropDownMenu_SetSelectedName( percentTextMenu, StatusBars2_Settings.bars[ frame.bar.key ].percentText );
            UIDropDownMenu_SetText( percentTextMenu, StatusBars2_Settings.bars[ frame.bar.key ].percentText );
        end
    end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Options_ResetBarPositionButton_OnClick
--
--  Description:    Called when the reset bar position button is clicked
--
-------------------------------------------------------------------------------
--
function StatusBars2_Options_ResetBarPositionButton_OnClick( self )

    -- Set a flag and reset the positions if the OK button is clicked
    StatusBars2_Options.resetBarPositions = true;

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

    -- Set a flag and reset the positions if the OK button is clicked
	if(StatusBars2_Options.moveBars == nil or StatusBars2_Options.moveBars == false) then
        StatusBars2_Options.moveBars = true;
        StatusBars2_Options.saveLocked = StatusBars2_Settings.locked;
        StatusBars2_Settings.locked = false;
	else
        StatusBars2_Options.moveBars = false;
        StatusBars2_Settings.locked = StatusBars2_Options.saveLocked;
	end

    StatusBars2_UpdateBars( );

    -- print("moveBars = "..printBool( StatusBars2_Options.moveBars ).." locked = "..printBool( StatusBars2_Settings.locked ));
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

    -- Exchange bar data
    for i, bar in ipairs( bars ) do
        local frame = _G[ bar:GetName( ) .. "_OptionFrame" ];
        StatusBars2_BarOptions_DoDataExchange( save, frame );
    end

    -- Exchange options data
    if( save == true ) then
        StatusBars2_Settings.fade = StatusBars2_Options_FadeButton:GetChecked( ) == 1;
        StatusBars2_Settings.locked = StatusBars2_Options_LockedButton:GetChecked( ) == 1;
        StatusBars2_Settings.grouped = StatusBars2_Options_GroupedButton:GetChecked( ) == 1;
        StatusBars2_Settings.scale = StatusBars2_Options_ScaleSlider:GetValue( );
    else
        StatusBars2_Options_FadeButton:SetChecked( StatusBars2_Settings.fade );
        StatusBars2_Options_LockedButton:SetChecked( StatusBars2_Settings.locked );
        StatusBars2_Options_GroupedButton:SetChecked( StatusBars2_Settings.grouped );
        StatusBars2_Options_ScaleSlider:SetValue( StatusBars2_Settings.scale );
    end
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
		elseif( string.find( name, aura ) == 1 ) then
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
