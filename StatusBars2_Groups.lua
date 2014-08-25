-- Group ids
local kPlayerGroup              = 1;
local kTargetGroup              = 2;
local kFocusGroup               = 3;
local kPetGroup                 = 4;


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

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateGroupFrame
--
--  Description:    Create a group to attach bars to
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateGroupFrame( name, key )

    local groupFrame = CreateFrame( "Frame", "StatusBars2_"..name, StatusBars2, "StatusBars2_GroupFrameTemplate" );
    
    -- local backdropInfo = { edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16 };
    -- groupFrame:SetBackdrop( backdropInfo );
    
    groupFrame.OnMouseDown = StatusBars2_Group_OnMouseDown;
    groupFrame.OnMouseUp = StatusBars2_Group_OnMouseUp;
    groupFrame.key = key;

    -- Insert the group frame into the groups table for later reference.
    -- print("Creating group "..key);
    table.insert( StatusBars2.groups, groupFrame );
    
end

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

        -- print("StatusBars2_Group_OnMouseDown "..self:GetName().." x "..self:GetLeft().." y "..self:GetTop().." parent "..self:GetParent():GetName());
        -- point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        -- print("Anchor "..relativePoint.." of "..relativeTo:GetName().." to "..point.." xoff "..xOfs.." yoff "..yOfs);

        -- If grouped move the main frame
        if( StatusBars2_Settings.groupsLocked == true ) then
            self:GetParent( ):OnMouseDown( button );

        -- Otherwise move this bar
        else
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

        -- If grouped move the main frame
        if( StatusBars2_Settings.groupsLocked == true ) then
            self:GetParent( ):OnMouseUp( button );
            -- StatusBars2_OnMouseUp( StatusBars2, button );

        -- Otherwise move this bar
        elseif( self.isMoving ) then

            -- End moving
            self:StopMovingOrSizing( );
            self.isMoving = false;

            -- Get the scaled position
            local left = ( self:GetLeft( ) + self:GetWidth( ) / 2 ) * self:GetScale( );
            local top = self:GetTop( ) * self:GetScale( );

            -- Get the offsets relative to the main frame
            local xOffset = left - StatusBars2:GetLeft( ) - StatusBars2:GetWidth( ) / 2;
            local yOffset = top - StatusBars2:GetTop( );

            -- Save the position in the settings
            StatusBars2_Settings.groups[ self.key ].position = {};
            StatusBars2_Settings.groups[ self.key ].position.x = xOffset;
            StatusBars2_Settings.groups[ self.key ].position.y = yOffset;

            -- Moving the bar de-anchored it from the main frame and anchored it to the screen.
            -- We don't want that, so re-anchor the bar to the main parent frame
            self:ClearAllPoints( );
            self:SetPoint( "TOP", StatusBars2, "TOP", xOffset, yOffset );

        end
    end
    
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Group_SetPosition
--
--  Description:    Set the group position
--
-------------------------------------------------------------------------------
--
function StatusBars2_Group_SetPosition( self, x, y )

    local xOffset;
    local yOffset;

    -- If the bar has a saved position use it
    if( StatusBars2_Settings.groups[ self.key ].position ~= nil ) then
        xOffset = StatusBars2_Settings.groups[ self.key ].position.x * ( 1 / self:GetScale( ) );
        yOffset = StatusBars2_Settings.groups[ self.key ].position.y * ( 1 / self:GetScale( ) );
        
    -- If using default positioning need to adjust for the scale
    else
        xOffset = x; -- ( 85 * ( 1 / StatusBars2_Settings.groups[ self.key ].scale ) ) + ( -self:GetWidth( ) / 2 );
        yOffset = y; -- * ( 1 / StatusBars2_Settings.groups[ self.key ].scale );
    end

    -- Set the bar position
    self:ClearAllPoints( );
    self:SetPoint( "TOP", StatusBars2, "TOP", xOffset, yOffset );

end

