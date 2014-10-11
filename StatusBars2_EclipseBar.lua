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


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateEclipseBar
--
--  Description:    Create an eclipse bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateEclipseBar( )

    -- Create the bar
    local bar = StatusBars2_CreateBar( "eclipse", "StatusBars2_EclipseBarTemplate", "player", ECLIPSE, kEclipse );

    -- Set the event handlers
    bar.OnEvent = StatusBars2_EclipseBar_OnEvent;
    bar.OnEnable = StatusBars2_EclipseBar_OnEnable;
    bar.OnUpdate = StatusBars2_EclipseBar_OnUpdate;

    -- Events to register for on enable
    bar.eventsToRegister["UNIT_AURA"] = true;
    bar.eventsToRegister["ECLIPSE_DIRECTION_CHANGE"] = true;
    bar.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;

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

    if (event == "UNIT_AURA") then
        local arg1 = ...;
        if arg1 ==  PlayerFrame.unit then
            EclipseBar_CheckBuffs(self);
        end
    elseif (event == "ECLIPSE_DIRECTION_CHANGE") then
        local status = ...;
        if (status == "none") then
            self.Marker:SetAtlas("DruidEclipse-Diamond");
        else
            self.Marker:SetAtlas("DruidEclipse-Arrow");
            self.Marker:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS[status]));
        end

    -- Entering combat
    elseif( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;
    end

    -- Update visibility
    if( self:BarIsVisible( ) ) then
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
    self:Bar_OnEnable( );

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
    if (maxPower == 0) then
        return;--catch divide by zero
    end
     
    self.PowerText:SetText(abs(power));
     
    local xpos =  ECLIPSE_BAR_TRAVEL*(power/maxPower)
    self.Marker:SetPoint("CENTER", xpos, 0);
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
    if (not direction or direction == "none") then
        self.Marker:SetAtlas("DruidEclipse-Diamond");
    else
        self.Marker:SetAtlas("DruidEclipse-Arrow");
        self.Marker:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS[direction]));
    end
     
    local hasLunarEclipse = false;
    local hasSolarEclipse = false;
     
    local unit = PlayerFrame.unit;
    local j = 1;
    local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
    while name do
        if (spellID == ECLIPSE_BAR_SOLAR_BUFF_ID) then
            hasSolarEclipse = true;
        elseif (spellID == ECLIPSE_BAR_LUNAR_BUFF_ID) then
            hasLunarEclipse = true;
        end
        j=j+1;
        name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, j);
    end
     
    if (hasLunarEclipse) then
        EclipseBar_SetGlow(self, "moon");
        self.SunBar:SetAlpha(0);
        self.DarkMoon:SetAlpha(0);
        self.MoonBar:SetAlpha(1);
        self.DarkSun:SetAlpha(1);
        self.Glow:SetAlpha(1);
        self.SunCover:SetAlpha(1);
        if (IsPlayerSpell(EQUINOX_TALENT_SPELL_ID)) then
            self.SunCover:Show();
        end
        self.pulse:Play(); 
    elseif (hasSolarEclipse) then
        EclipseBar_SetGlow(self, "sun");
        self.MoonBar:SetAlpha(0);
        self.DarkSun:SetAlpha(0);
        self.SunBar:SetAlpha(1);
        self.DarkMoon:SetAlpha(1);
        self.Glow:SetAlpha(1);
        self.MoonCover:SetAlpha(1);
        if (IsPlayerSpell(EQUINOX_TALENT_SPELL_ID)) then
            self.MoonCover:Show();
        end
        self.pulse:Play();
    else
        self.SunBar:SetAlpha(0);
        self.MoonBar:SetAlpha(0);
        self.DarkSun:SetAlpha(0);
        self.DarkMoon:SetAlpha(0);
        self.Glow:SetAlpha(0);
    end
     
    self.hasLunarEclipse = hasLunarEclipse;
    self.hasSolarEclipse = hasSolarEclipse;
     
    StatusBars2_EclipseBar_OnUpdate(self);
end
