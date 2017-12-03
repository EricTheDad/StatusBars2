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

	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdateRunes(true);
	elseif ( event == "RUNE_POWER_UPDATE") then
		self:UpdateRunes();
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
	for index, runeIndex in ipairs(self.runeIndexes) do
        local start, duration, runeReady = GetRuneCooldown( runeIndex );
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
	for i = 1, #self.Runes do

        -- Get the rune button
        local rune = self.Runes[i];

        -- If not grouped or locked enable the mouse for moving
        if( not StatusBars2.locked ) then
            rune:EnableMouse( true );
        else
            rune:EnableMouse( false );
        end
    end

    -- Update the runes
    self:UpdateRunes();

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
    local self = StatusBars2_CreateBar( group, index, removeWhenHidden, "rune", "StatusBars2_RuneFrameTemplate", "player", RUNES, kRune );
    local name = self:GetName( );

    -- Create the rune table
	self.runeIndexes = {};

    -- Initialize the rune buttons
	for i = 1, #self.Runes do
		tinsert(self.runeIndexes, i); 
	end
	
	self.runesOnCooldown = {};
	self.spentAnimsActive = 0;

    -- Set the event handlers
    self.OnEvent = StatusBars2_RuneBar_OnEvent;
    self.OnEnable = StatusBars2_RuneBar_OnEnable;
    self.IsDefault = StatusBars2_RuneBar_IsDefault;

    -- Events to register for on enable
    self.eventsToRegister["RUNE_POWER_UPDATE"] = true;
    self.eventsToRegister["PLAYER_SPECIALIZATION_CHANGED"] = true;
    self.eventsToRegister["PLAYER_ENTERING_WORLD"] = true;

    self.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    self.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;

    return self;

end
