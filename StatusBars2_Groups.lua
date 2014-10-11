-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally

-- Group ids
local kPlayerGroup              = 1;
local kTargetGroup              = 2;
local kFocusGroup               = 3;
local kPetGroup                 = 4;

local groups = addonTable.groups;
local bars = addonTable.bars;

local debugLayout = addonTable.debugLayout;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Group_OnMouseDown
--
--  Description:    Handle "OnMouseDown" event coming from one of the attached bars
--
-------------------------------------------------------------------------------
--
function StatusBars2_Group_OnMouseDown( self, button )

    -- Move on left button down
    if( button == 'LeftButton' ) then

        -- If grouped move the main frame
        if( self:ShouldPassClickToParent( ) ) then
            self:GetParent( ):OnMouseDown( button );

        -- Otherwise move this bar
        elseif( self:ShouldProcessClick( ) ) then
            self:StartMoving( );
            self.isMoving = true;
        end

    end
   
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Group_OnMouseUp
--
--  Description:    Handle "OnMouseUp" event coming from one of the attached bars
--
-------------------------------------------------------------------------------
--
function StatusBars2_Group_OnMouseUp( self, button )

    -- Move with left button
    if( button == 'LeftButton' ) then
        local parentFrame = self:GetParent( );

        -- If the parent frame is the one that was put into motion, call it's handler
        if( parentFrame.isMoving ) then
            parentFrame:OnMouseUp( button );

        -- Otherwise move this bar
        elseif( self.isMoving ) then
            -- End moving
            self:StopMovingOrSizing( );
            self.isMoving = false;

            -- Moving the frame clears the points and attaches it to the UIParent frame
            -- This will re-attach it to it's group frame
            local x, y = self:GetCenter( );
            y = self:GetTop( );
            StatusBars2_StatusBar_SetPosition( self, x * self:GetScale( ), y * self:GetScale( ), true );
        end
    end
    
end

-------------------------------------------------------------------------------
--
--  Name:           ConfigShouldPassClickToParent
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function ConfigShouldPassClickToParent( )
    return not IsControlKeyDown( ) and IsAltKeyDown( );
end

-------------------------------------------------------------------------------
--
--  Name:           NormalShouldPassClickToParent
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function NormalShouldPassClickToParent( )
    return not IsControlKeyDown( ) and ( StatusBars2.groupsLocked or IsAltKeyDown( ) );
end

-------------------------------------------------------------------------------
--
--  Name:           ConfigShouldProcessClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function ConfigShouldProcessClick( )
    return IsControlKeyDown( );
end

-------------------------------------------------------------------------------
--
--  Name:           NormalShouldProcessClick
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function NormalShouldProcessClick( )
    return IsControlKeyDown( ) or not StatusBars2.locked;
end

-------------------------------------------------------------------------------
--
--  Name:           NormalStatusBars2
--
--  Description:    
--
-------------------------------------------------------------------------------
--
local function StatusBars2_Group_OnEnable( self )

    if( StatusBars2.configMode ) then
        self.ShouldPassClickToParent = ConfigShouldPassClickToParent;
        self.ShouldProcessClick = ConfigShouldProcessClick;
    else
        self.ShouldPassClickToParent = NormalShouldPassClickToParent;
        self.ShouldProcessClick = NormalShouldProcessClick;
    end

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
        Bar_ShowBackdrop( groupFrame )
        groupFrame.text:SetFontObject(FontInfo[1].filename);
        groupFrame.text:SetTextColor( 1, 1, 1 );
        groupFrame.text:SetText( name );
        groupFrame.text:Show( );
    end
    
    groupFrame.OnEnable = StatusBars2_Group_OnEnable;
    groupFrame.OnMouseDown = StatusBars2_Group_OnMouseDown;
    groupFrame.OnMouseUp = StatusBars2_Group_OnMouseUp;
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

