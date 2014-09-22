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
        local status = ...;
        self.marker:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS[status]));

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
    if self.showPercent then
        self.powerText:SetText(abs(power/maxPower*100).."%");
    else
        self.powerText:SetText(abs(power));
    end

    local xpos =  ECLIPSE_BAR_TRAVEL*(power/maxPower)
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
