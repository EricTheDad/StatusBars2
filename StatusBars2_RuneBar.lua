-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad
-- The inner workings here are more or less lifted directly from the Blizzard rune frame and adapeted to StatusBars2.

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


-- Bar types
local kHealth = addonTable.barTypes.kHealth;
local kPower = addonTable.barTypes.kPower;
local kAura = addonTable.barTypes.kAura;
local kAuraStack = addonTable.barTypes.kAuraStack;
local kRune = addonTable.barTypes.kRune;
local kDruidMana = addonTable.barTypes.kDruidMana;
local kUnitPower = addonTable.barTypes.kUnitPower;
local kEclipse = addonTable.barTypes.kEclipse;
local kDemonicFury = addonTable.barTypes.kDemonicFury;

-- Number of runes
local CURRENT_MAX_RUNES;
local MAX_RUNE_CAPACITY = 7;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneFrame_RunePowerUpdate
--
--  Description:    Update an individual rune
--
-------------------------------------------------------------------------------
--
local function StatusBars2_RuneFrame_RunePowerUpdate(runeButton, runeIndex, isEnergize)
	if runeIndex and runeIndex >= 1 and runeIndex <= CURRENT_MAX_RUNES  then
		local cooldown = runeButton.Cooldown;
		local start, duration, runeReady = GetRuneCooldown(runeIndex);

		if not runeReady  then
			if start then
				CooldownFrame_Set(cooldown, start, duration, true, true);
			end
			runeButton.energize:Stop();
		else
			cooldown:Hide();
			if (not isEnergize and not runeButton.energize:IsPlaying()) then
				runeButton.shine:SetVertexColor(1, 1, 1);
				RuneButton_ShineFadeIn(runeButton.shine)
			end
		end

		if isEnergize  then
			runeButton.energize:Play();
		end
	else
		assert(false, "Bad rune index")
	end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_UpdateAllRunes
--
--  Description:    Update all runes
--
-------------------------------------------------------------------------------
--
local function StatusBars2_RuneBar_UpdateAllRunes( self )

	CURRENT_MAX_RUNES = UnitPowerMax(RuneFrame:GetParent().unit, SPELL_POWER_RUNES);
	for i=1, MAX_RUNE_CAPACITY do
		local runeButton = _G[self:GetName( ).."_RuneButtonIndividual"..i];

		-- Shrink the runes sizes if you have all 7
		if (CURRENT_MAX_RUNES == MAX_RUNE_CAPACITY) then
			runeButton.Border:SetSize(21, 21);
			runeButton.rune:SetSize(21, 21);
			runeButton.Textures.Shine:SetSize(52, 31);
			runeButton.energize.RingScale:SetFromScale(0.6, 0.7);
			runeButton.energize.RingScale:SetToScale(0.7, 0.7);
			runeButton:SetSize(15, 15);
		else
			runeButton.Border:SetSize(24, 24);
			runeButton.rune:SetSize(24, 24);
			runeButton.Textures.Shine:SetSize(60, 35);
			runeButton.energize.RingScale:SetFromScale(0.7, 0.8);
			runeButton.energize.RingScale:SetToScale(0.8, 0.8);
			runeButton:SetSize(18, 18);
		end

		if(i <= CURRENT_MAX_RUNES) then
			runeButton:Show();
            StatusBars2_RuneFrame_RunePowerUpdate( runeButton, i, true );
		else
			runeButton:Hide();
		end
	end
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_OnEvent
--
--  Description:    Rune bar event handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_RuneBar_OnEvent( self, event, ... )

    -- Entering combat
    if( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;

	elseif ( event == "UNIT_MAXPOWER") then
		RuneFrame_UpdateNumberOfShownRunes();

	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		RuneFrame_UpdateNumberOfShownRunes();
		for i=1, CURRENT_MAX_RUNES do
			local runeButton = _G[self:GetName( ).."_RuneButtonIndividual"..i];
			StatusBars2_RuneFrame_RunePowerUpdate(runeButton, i, false);
		end

	elseif ( event == "RUNE_POWER_UPDATE") then
		local runeIndex, isEnergize = ...;
		local runeButton = _G[self:GetName( ).."_RuneButtonIndividual"..runeIndex];
		StatusBars2_RuneFrame_RunePowerUpdate(runeButton, runeIndex, isEnergize);

	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local runeIndex = ...;
		if ( runeIndex and runeIndex >= 1 and runeIndex <= CURRENT_MAX_RUNES ) then
			local runeButton = _G[self:GetName( ).."_RuneButtonIndividual"..runeIndex];
			RuneButton_Flash(runeButton);
		end
	end

    -- Update the bar visibility
    if( self:BarIsVisible( ) ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_IsDefault
--
--  Description:    Determine if a rune bar is at its default state
--
-------------------------------------------------------------------------------
--
local function StatusBars2_RuneBar_IsDefault( self )

    local isDefault = true;

    -- Look for a rune that is not ready
    local i;
    for i = 1, CURRENT_MAX_RUNES do
        local start, duration, runeReady = GetRuneCooldown( i );
        if( not runeReady ) then
            isDefault = false;
            break;
        end
    end

    return isDefault;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_OnEnable
--
--  Description:    Rune bar enable handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_RuneBar_OnEnable( self )

    -- Enable or disable moving
    local i;
    for i = 1, MAX_RUNE_CAPACITY do

        -- Get the rune button
        local rune = _G[self:GetName( ).."_RuneButtonIndividual"..i];

        -- If not grouped or locked enable the mouse for moving
        if( not StatusBars2.locked ) then
            rune:EnableMouse( true );
        else
            rune:EnableMouse( false );
        end
    end

    -- Update the runes
    StatusBars2_RuneBar_UpdateAllRunes( self );

    -- Call the base method
    self:BaseBar_OnEnable( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneButton_OnHide
--
--  Description:    Called when the frame is hidden
--
-------------------------------------------------------------------------------
--
local function StatusBars2_RuneButton_OnHide( self )

    local OnHideScript = self.parentBar:GetScript( "OnHide" );
    OnHideScript( self.parentBar );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateRuneBar
--
--  Description:    Create a rune bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateRuneBar( group, index, removeWhenHidden )

    -- Create the bar
    local bar = StatusBars2_CreateBar( group, index, removeWhenHidden, "rune", "StatusBars2_RuneFrameTemplate", "player", RUNES, kRune );
    local name = bar:GetName( );

    -- Create the rune table
    bar.runes = {};

    -- Initialize the rune buttons
    local i;
    for i = 1, MAX_RUNE_CAPACITY do
        local rune = _G[bar:GetName( ).."_RuneButtonIndividual"..i];
        rune.parentBar = bar;
        rune:SetScript( "OnMouseDown", StatusBars2_ChildButton_OnMouseDown );
        rune:SetScript( "OnMouseUp", StatusBars2_ChildButton_OnMouseUp );
        rune:SetScript( "OnHide", StatusBars2_RuneButton_OnHide );
    end

    -- Set the event handlers
    bar.OnEvent = StatusBars2_RuneBar_OnEvent;
    bar.OnEnable = StatusBars2_RuneBar_OnEnable;
    bar.IsDefault = StatusBars2_RuneBar_IsDefault;

    -- Events to register for on enable
    bar.eventsToRegister["RUNE_POWER_UPDATE"] = true;
    bar.eventsToRegister["RUNE_TYPE_UPDATE"] = true;
    bar.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;
    bar.eventsToRegister["PLAYER_ENTERING_WORLD"] = true;

    return bar;

end