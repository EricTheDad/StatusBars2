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
--  Name:           StatusBars2_GetAuraStack
--
--  Description:    Get the stack size of the specified aura
--
-------------------------------------------------------------------------------
--
local function StatusBars2_GetAuraStack( unit, aura, auraType )

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
--  Name:           StatusBars2_CreateAuraStackBar
--
--  Description:    Create bar to track the stack size of a buff or debuff
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateAuraStackBar( key, unit, spellID, auraType, count, auraID )

    -- The player has a spell that is the pre-condition for the aura stack
    -- We can match on the same name as the spell, but if we know it, the auraID is more efficient and reliable
    local auraName = GetSpellInfo( auraID or spellID );
     
    -- For the interface, we'll display the name of the aura if we have it, otherwise the name of the triggering spell
    local displayName = GetSpellInfo( auraID or spellID );
    
    -- Create the bar
    local bar = StatusBars2_CreateDiscreteBar( key, unit, displayName, kAuraStack, count );

    -- Save the aura name and unit
    bar.spellID = spellID;
    bar.auraID = auraID;
    bar.aura = auraName;
    bar.auraType = auraType;

    -- Set the event handlers
    bar.OnEvent = StatusBars2_AuraStackBar_OnEvent;
    bar.IsDefault = StatusBars2_AuraStackBar_IsDefault;

    -- Default the bar to never visible
    bar.defaultEnabled = "Never";

    -- Events to register for on enable
    bar.eventsToRegister["PLAYER_TARGET_CHANGED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;

    bar.eventsToRegister["UNIT_AURA"] = true;
    --bar.eventsToRegister["COMBAT_LOG_EVENT_UNFILTERED"] = true;

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

    elseif( event == "UNIT_AURA" ) then
        local arg1 = ...;
        if( arg1 == self.unit ) then

            -- UnitAura doesn't seem to be returning debuffs right now
            local _,_,_,amount = UnitAura( self.unit, self.aura );

            if not amount then
                _,_,_,amount = UnitDebuff( self.unit, self.aura );
            end

            StatusBars2_UpdateDiscreteBar( self, amount or 0 );
        end

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
                local spellID = select( 12, ... );
                local spellName = select( 13, ... );
                local found = false;

                -- If we have the auraID, check that as it's faster and more reliable
                if( self.auraID ) then
                    if( self.auraID == spellID ) then 
                        found = true; 
                    end
                -- Otherwise, see if the name matches
                elseif( string.find( spellName, self.aura, 1, true )) then 
                    found = true; 
                end
                
                if( found ) then

                    -- Applied
                    if( eventType == "SPELL_AURA_APPLIED" ) then
                        local _,_,_,amount = UnitAura( self.unit, spellName );

                        if not amount then
                            _,_,_,amount = UnitDebuff( self.unit, spellName );
                        end

                        StatusBars2_UpdateDiscreteBar( self, amount );

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
    if( self:BarIsVisible( ) ) then
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
