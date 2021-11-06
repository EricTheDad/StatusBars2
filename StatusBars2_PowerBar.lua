-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad
local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


local groups = addonTable.groups;
local bars = addonTable.bars;

-- Bar types
local kHealth = addonTable.barTypes.kHealth;
local kPower = addonTable.barTypes.kPower;
local kAura = addonTable.barTypes.kAura;
local kAuraStack = addonTable.barTypes.kAuraStack;
local kRune = addonTable.barTypes.kRune;
local kDruidMana = addonTable.barTypes.kDruidMana;
local kUnitPower = addonTable.barTypes.kUnitPower;
local kAlternateMana = addonTable.barTypes.kAlternateMana;


-- PowerTypes
local SPELL_POWER_MANA = Enum.PowerType.Mana;
local SPELL_POWER_RAGE = Enum.PowerType.Rage;
local SPELL_POWER_FOCUS = Enum.PowerType.Focus;
local SPELL_POWER_ENERGY = Enum.PowerType.Energy;
local SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints;
local SPELL_POWER_RUNES = Enum.PowerType.Runes;
local SPELL_POWER_RUNIC_POWER = Enum.PowerType.RunicPower;
local SPELL_POWER_SOUL_SHARDS = Enum.PowerType.SoulShards;
local SPELL_POWER_LUNAR_POWER = Enum.PowerType.LunarPower;
local SPELL_POWER_HOLY_POWER = Enum.PowerType.HolyPower;
local SPELL_POWER_ALTERNATE_POWER = Enum.PowerType.Alternate;
local SPELL_POWER_MAELSTROM = Enum.PowerType.Maelstrom;
local SPELL_POWER_CHI = Enum.PowerType.Chi;
local SPELL_POWER_INSANITY = Enum.PowerType.Insanity;
local SPELL_POWER_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges;
local SPELL_POWER_FURY = Enum.PowerType.Fury;
local SPELL_POWER_PAIN = Enum.PowerType.Pain;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdatePowerBar
--
--  Description:    Update a power bar
--
-------------------------------------------------------------------------------
--
local function StatusBars2_UpdatePowerBar(self)
    
    -- Update the bar with current and max power
    self:ContinuousBar_Update(self:GetPower(), self:GetPowerMax());
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetPowerBarColor
--
--  Description:    Set the color of a power bar
--
-------------------------------------------------------------------------------
--
local function StatusBars2_SetPowerBarColor(self)
    
    local powerType = self:GetPowerType();
    self.status:SetStatusBarColor(self:GetColor(powerType));

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_StartCasting
--
--  Description:    Start spell casting
--
-------------------------------------------------------------------------------
--
local function StatusBars2_PowerBar_StartCasting(self)
    
    -- Get spell info
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unit);
    
    -- If that failed try getting channeling info
    channeling = false;
    if (name == nil) then
        name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(self.unit);
        channeling = true;
    end
    
    -- If the unit is casting a spell update the power bar
    if (name ~= nil) then
        
        -- Get the current and max values
        if (not channeling) then
            self.value = GetTime() - (startTime / 1000);
            self.maxValue = (endTime - startTime) / 1000;
            self.castID = castID;
        else
            self.value = ((endTime / 1000) - GetTime());
            self.maxValue = (endTime - startTime) / 1000;
        end
        
        -- Set the bar min, max and current values
        self.status:SetMinMaxValues(0, self.maxValue);
        self.status:SetValue(self.value);
        
        -- Set the text
        self.text:SetText(name);
        
        -- Show the bar spark
        self.spark:Show();
        
        -- Set the bar color
        if (notInterruptible) then
            self.status:SetStatusBarColor(1.0, 0.0, 0.0);
        elseif (channeling) then
            self.status:SetStatusBarColor(1.0, 0.7, 0.0);
        else
            self.status:SetStatusBarColor(0.0, 1.0, 0.0);
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
local function StatusBars2_PowerBar_EndCasting(self)
    
    -- Exit casting mode
    self.casting = false;
    self.channeling = false;
    self.castID = nil;
    
    -- Reset the min and max values
    self.status:SetMinMaxValues(0, self:GetPowerMax());
    
    -- Hide the bar spark
    self.spark:Hide();
    
    -- Reset the color
    StatusBars2_SetPowerBarColor(self);
    
    -- Update the bar
    StatusBars2_UpdatePowerBar(self);

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_OnEvent
--
--  Description:    Power bar event handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_PowerBar_OnEvent(self, event, ...)
    
    -- Target changed
    if (event == "PLAYER_TARGET_CHANGED") then
        
        -- Bar is visible
        if (self:BarIsVisible()) then
            
            -- Update the casting bar if applicable
            StatusBars2_PowerBar_StartCasting(self);
            
            -- If not in casting mode update as normal
            if (not self.casting and not self.channeling) then
                StatusBars2_SetPowerBarColor(self);
                self.status:SetMinMaxValues(0, self:GetPowerMax());
            end
            
            -- Show the bar and update the layout
            StatusBars2_ShowBar(self);
            StatusBars2_UpdateLayout();
        
        -- Bar is not visible
        else
            local unitExists = UnitExists(self.unit);
            StatusBars2_HideBar(self, unitExists);
            if (unitExists) then
                StatusBars2_UpdateLayout();
            end
        end
    
    -- Show the bar when power ticks
    elseif (event == "UNIT_POWER_UPDATE") then
        
        if (self:BarIsVisible() and not self.visible) then
            StatusBars2_SetPowerBarColor(self);
            StatusBars2_ShowBar(self);
            StatusBars2_UpdateLayout();
        elseif (self.powerToken == "STAGGER") then
            StatusBars2_SetPowerBarColor(self);
        end
    
    -- Update max power
    elseif (event == "UNIT_MAXPOWER" and not self.casting and not self.channeling) then
        self.status:SetMinMaxValues(0, self:GetPowerMax());
    
    -- Show when entering combat
    elseif (event == 'PLAYER_REGEN_DISABLED') then
        self.inCombat = true;
        if (self:BarIsVisible() and not self.visible) then
            StatusBars2_SetPowerBarColor(self);
            StatusBars2_ShowBar(self);
            StatusBars2_UpdateLayout();
        end
    
    -- Exiting combat
    elseif (event == 'PLAYER_REGEN_ENABLED') then
        self.inCombat = false;
    
    -- Pet changed
    elseif (event == "UNIT_PET" or event == "PLAYER_FOCUS_CHANGED") then
        if (self:BarIsVisible()) then
            StatusBars2_SetPowerBarColor(self);
            StatusBars2_ShowBar(self);
            StatusBars2_UpdatePowerBar(self);
            StatusBars2_UpdateLayout();
        -- Bar is not visible
        else
            local unitExists = UnitExists(self.unit);
            StatusBars2_HideBar(self, unitExists);
            if (unitExists) then
                StatusBars2_UpdateLayout();
            end
        end
    
    -- Unit shapeshifted
    elseif (event == "UNIT_DISPLAYPOWER" and select(1, ...) == self.unit) then
        StatusBars2_SetPowerBarColor(self);
        StatusBars2_UpdatePowerBar(self);
    
    -- Casting started
    elseif (select(1, ...) == self.unit and (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE") and self.showSpell) then
        
        -- Set to casting mode
        StatusBars2_PowerBar_StartCasting(self);
        
        -- If the bar is currently hidden show it and update the layout
        if not self.visible then
            StatusBars2_ShowBar(self);
            StatusBars2_UpdateLayout();
        end
    
    -- Casting ended
    elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
        
        if (select(1, ...) == self.unit and (event == "UNIT_SPELLCAST_CHANNEL_STOP" or select(4, ...) == self.castID)) then
            
            -- End casting mode
            StatusBars2_PowerBar_EndCasting(self);
            
            -- If the bar should no longer be visible hide it and update the layout
            if (not self:BarIsVisible()) then
                self:Hide();
                self.visible = false;
                StatusBars2_UpdateLayout();
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
local function StatusBars2_PowerBar_OnUpdate(self, elapsed)
    
    -- Casting mode
    if (self.casting or self.channeling) then
        
        -- Update the current value
        if (self.casting) then
            self.value = self.value + elapsed;
        else
            self.value = self.value - elapsed;
        end
        
        -- Casting finished
        if ((self.casting and self.value >= self.maxValue) or (self.value <= 0)) then
            StatusBars2_PowerBar_EndCasting(self);
        
        -- Casting continuing
        else
            self.status:SetValue(self.value);
            self.spark:SetPoint("CENTER", self.status, "LEFT", (self.value / self.maxValue) * self.status:GetWidth(), 0);
            self.percentText:SetText(StatusBars2_Round(self.value / self.maxValue * 100) .. "%");
        end
    
    -- Normal mode
    else
        StatusBars2_UpdatePowerBar(self);
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_OnEnable
--
--  Description:    Power bar enable handler
--
-------------------------------------------------------------------------------
--
local function StatusBars2_PowerBar_OnEnable(self)
    
    if (StatusBars2.configMode) then
        -- Hide the casting bar in case there was a spell being cast when we switched to config mode
        StatusBars2_PowerBar_EndCasting(self);
        
        -- Leave the color for the player and pet
        if (self.unit == "player" or self.unit == "pet") then
            StatusBars2_SetPowerBarColor(self);
        else
            self.status:SetStatusBarColor(addonTable.kDefaultPowerBarColor);
        end
    else
        local powerType = self:GetPowerType()
        
        if (powerType == SPELL_POWER_RAGE
            or powerType == SPELL_POWER_RUNIC_POWER
            or powerType == SPELL_POWER_INSANITY
            or powerType == SPELL_POWER_MAELSTROM
            or powerType == SPELL_POWER_FURY
            or powerType == SPELL_POWER_PAIN) then
            self.defaultPower = 0;
        else
            self.defaultPower = nil
        end
        
        -- Set the color
        StatusBars2_SetPowerBarColor(self);
        
        -- Update
        StatusBars2_UpdatePowerBar(self);
    end
    
    -- Call the base method
    self:ContinuousBar_OnEnable();

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_IsVisible
--
--  Description:    Determine if a power bar should be visible
--
-------------------------------------------------------------------------------
--
local function StatusBars2_PowerBar_IsVisible(self)
    
    return self:ContinuousBar_BarIsVisible() and (self:GetPowerMax() > 0 or self.casting or self.channeling);

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_PowerBar_IsDefault
--
--  Description:    Determine if a power bar is at its default level
--
-------------------------------------------------------------------------------
--
local function StatusBars2_PowerBar_IsDefault(self)
    
    local isDefault = true;
    
    -- If casting the bar is not at the default level
    if self.casting or self.channeling then
        isDefault = false
    
    -- Otherwise check the power level
    else
        -- Get the current power
        local power = self:GetPower();
        
        -- Determine if power is at it's default state
        -- Compare against the default power value if it exists, otherwise the max power
        isDefault = (power == (self.defaultPower or self:GetPowerMax()));
    end
    
    return isDefault;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreatePowerBar
--
--  Description:    Create a power bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreatePowerBar(group, index, removeWhenHidden, key, unit, barType, powerType, defaultColor)
    
    if (not barType) then barType = kPower end
    
    local displayName = StatusBars2_ConstructDisplayName(unit, barType);
    
    -- Create the power bar
    local bar = StatusBars2_CreateContinuousBar(group, index, removeWhenHidden, key, unit, displayName, barType, 1, 1, 0);
    
    -- If its the druid mana bar use a special options template
    if (barType == kDruidMana) then
        bar.optionsPanelKey = "druidManaBarConfigTabPage";
    -- If its a target power bar use a special options template
    elseif (bar.unit == "target") then
        bar.optionsPanelKey = "targetPowerBarConfigTabPage";
    end
    
    bar.powerType = powerType;
    bar.defaultColor = defaultColor
    
    bar.GetPowerType = function(self)
        return self.powerType or UnitPowerType(self.unit)
    end
    
    bar.GetPower = function(self, returnFractionalCharges)
        return UnitPower(self.unit, self:GetPowerType(), returnFractionalCharges)
    end
    
    bar.GetPowerMax = function(self, returnFractionalCharges)
        return UnitPowerMax(self.unit, self:GetPowerType(), returnFractionalCharges)
    end
    
    -- Set the event handlers
    bar.OnEvent = StatusBars2_PowerBar_OnEvent;
    bar.OnEnable = StatusBars2_PowerBar_OnEnable;
    bar.OnUpdate = StatusBars2_PowerBar_OnUpdate;
    bar.BarIsVisible = StatusBars2_PowerBar_IsVisible;
    bar.IsDefault = StatusBars2_PowerBar_IsDefault;
    
    -- Events to register for on enable
    bar.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    bar.eventsToRegister["UNIT_POWER_UPDATE"] = true;
    bar.eventsToRegister["UNIT_MAXPOWER"] = true;
    
    if (bar.unit == "target") then
        bar.eventsToRegister["PLAYER_TARGET_CHANGED"] = true;
        bar.eventsToRegister["UNIT_SPELLCAST_START"] = true;
        bar.eventsToRegister["UNIT_SPELLCAST_STOP"] = true;
        bar.eventsToRegister["UNIT_SPELLCAST_FAILED"] = true;
        bar.eventsToRegister["UNIT_SPELLCAST_INTERRUPTED"] = true;
        bar.eventsToRegister["UNIT_SPELLCAST_DELAYED"] = true;
        bar.eventsToRegister["UNIT_SPELLCAST_CHANNEL_START"] = true;
        bar.eventsToRegister["UNIT_SPELLCAST_CHANNEL_UPDATE"] = true;
        bar.eventsToRegister["UNIT_SPELLCAST_CHANNEL_STOP"] = true;
    elseif (bar.unit == "focus") then
        bar.eventsToRegister["PLAYER_FOCUS_CHANGED"] = true;
    elseif (bar.unit == "pet") then
        bar.eventsToRegister["UNIT_PET"] = true;
    end
    
    if (bar.powerType == nil) then
        bar.eventsToRegister["UNIT_DISPLAYPOWER"] = true;
    -- Not sure how this could even happen
    elseif (bar:IsEventRegistered("UNIT_DISPLAYPOWER") or bar.eventsToRegister["UNIT_DISPLAYPOWER"]) then
        bar.eventsToRegister["UNIT_DISPLAYPOWER"] = nil;
        bar:UnregisterEvent("UNIT_DISPLAYPOWER");
    end
    
    return bar;

end
