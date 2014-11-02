-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally

-- Group ids
local kPlayerGroup              = addonTable.groupIDs.kPlayerGroup;
local kTargetGroup              = addonTable.groupIDs.kTargetGroup;
local kFocusGroup               = addonTable.groupIDs.kFocusGroup;
local kPetGroup                 = addonTable.groupIDs.kPetGroup;

local groups = addonTable.groups;
local bars = addonTable.bars;

local debugLayout = addonTable.debugLayout;

-------------------------------------------------------------------------------
--
--  Name:           NormalStatusBars2
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2_Group_OnEnable( self )

    StatusBars2_Movable_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateGroupFrame
--
--  Description:    Create a group to attach bars to
--
-------------------------------------------------------------------------------
--
local function StatusBars2_CreateGroupFrame( name, key )

    local groupFrame = CreateFrame( "Frame", "StatusBars2_"..name, StatusBars2, "StatusBars2_GroupFrameTemplate" );
    
    if debugLayout then
        local FontInfo = addonTable.fontInfo;
        StatusBars2_Frame_ShowBackdrop( groupFrame )
        groupFrame.text:SetFontObject(FontInfo[1].filename);
        groupFrame.text:SetTextColor( 1, 1, 1 );
        groupFrame.text:SetText( name );
        groupFrame.text:Show( );
    end
    
    -- Add mouse click handlers
    StatusBars2_MakeMovable( groupFrame, "group");

    groupFrame.OnEnable = StatusBars2_Group_OnEnable;
    groupFrame.key = key;

    -- Insert the group frame into the groups table for later reference.
    table.insert( groups, groupFrame );
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateGroups
--
--  Description:    Create frames for each bar group
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateGroups( )

    -- Create frames for the player, target, focus and pet groups.
    StatusBars2_CreateGroupFrame( "PlayerGroup", kPlayerGroup );
    StatusBars2_CreateGroupFrame( "TargetGroup", kTargetGroup );
    StatusBars2_CreateGroupFrame( "FocusGroup", kFocusGroup );
    StatusBars2_CreateGroupFrame( "PetGroup", kPetGroup );

end

