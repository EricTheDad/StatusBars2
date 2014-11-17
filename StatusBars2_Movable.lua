-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


local groups = addonTable.groups;
local bars = addonTable.bars;

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

local FontInfo = addonTable.fontInfo;


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Movable_StartMoving
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetMoveMode( self )

    local moveMode;

    if( IsControlKeyDown( ) ) then
        moveMode = "group";
    end

    if( IsAltKeyDown( ) ) then
        if( moveMode == "group" ) then
            moveMode = "all";
        else
            moveMode = "bar";
        end
    end

    -- layoutType "Background" is never locked to a group or all, so it always returns modeMode "bar"
    if( moveMode and self.layoutType == "Background" ) then
        moveMode = "bar";
    end

    return moveMode;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Movable_StartMoving
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_Movable_StartMoving( self )

    if( self.movableType and StatusBars2.moveMode == self.movableType ) then
        self:StartMoving( );
        self.isMoving = true;
        local x, y = self:GetCenter( );
        self.startX = x;
        self.startY = y;

    elseif( StatusBars2.moveMode ) then
        StatusBars2_Movable_StartMoving( self:GetParent( ) );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Movable_StopMoving
--
--  Description:    Called when the mouse button goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_Movable_StopMoving( self )

    local parentFrame = self:GetParent( );

    -- Save this frame's position
    if( self.isMoving ) then
        -- End moving
        self:StopMovingOrSizing( );
        self.isMoving = false;

        -- Moving the frame clears the points and attaches it to the UIParent frame
        -- This will re-attach it to it's group frame
        local x, y = self:GetCenter( );
        local rnd = StatusBars2_Round;

        -- Don't count it if we didn't move the bar more than a pixel
        if( rnd( math.abs( x - self.startX ) ) > 0.1 or rnd( math.abs( y - self.startY ) ) > 0.1 ) then
            y = self:GetTop( );
            StatusBars2_Movable_SetPosition( self, x * self:GetScale( ), y * self:GetScale( ), true );

            -- Update the layout so if we moved something that changed the groups' autolayout that that changes, too.
            StatusBars2_UpdateFullLayout( );
        end

    elseif( self ~= StatusBars2 ) then
        -- if this bar isn't moving, then pass the event through to the parent unless we are already at the top parent frame of this addon
        StatusBars2_Movable_StopMoving( self:GetParent( ) );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           Normal_Movable_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
local function Normal_Movable_OnMouseDown( self, button )

    -- Move on left button down
    if( button == 'LeftButton' ) then
        StatusBars2.moveMode = StatusBars2_GetMoveMode( self );
        StatusBars2_Movable_StartMoving( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           Normal_Movable_OnMouseUp
--
--  Description:    Called when the mouse button goes up in this frame
--
-------------------------------------------------------------------------------
--
local function Normal_Movable_OnMouseUp( self, button )

    -- Move with left button
    if( button == 'LeftButton' ) then
        StatusBars2_Movable_StopMoving( self )
    end

    -- Save the bar settings for the moved bars
    StatusBars2_Settings_Apply_Settings( StatusBars2_Settings, true );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ChildButton_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_ChildButton_OnMouseDown( self, button )

    local onMouseDown = self.parentBar:GetScript( "OnMouseDown" );
    onMouseDown( self.parentBar, button );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ChildButton_OnMouseUp
--
--  Description:    Called when the mouse goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_ChildButton_OnMouseUp( self, button )

    local onMouseUp = self.parentBar:GetScript( "OnMouseUp" );
    onMouseUp( self.parentBar, button );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Movable_OnEnable
--
--  Description:    Called when a movable element is enabled
--
-------------------------------------------------------------------------------
--
function StatusBars2_Movable_OnEnable( self )

    assert(self);
    local onMouseDown, onMouseUp;

    if( StatusBars2.configMode ) then

        -- Set the mouse event handlers
        self:SetScript( "OnMouseDown", addonTable.Config_Movable_OnMouseDown );
        self:SetScript( "OnMouseUp", addonTable.Config_Movable_OnMouseUp );

        -- In config mode, the mouse is always enabled for all bars
        self:EnableMouse( self.movableType == "bar" );

    else

        -- Set the mouse event handlers
        self:SetScript( "OnMouseDown", Normal_Movable_OnMouseDown );
        self:SetScript( "OnMouseUp", Normal_Movable_OnMouseUp );

        -- If not locked enable the mouse for moving
        -- Don't enable mouse on aura bars, we only want the mouse to be able to grab active icons
        self:EnableMouse( self.movableType == "bar" and self.type ~= kAura and not StatusBars2.locked and self.enabled and self.enabled ~= "Never" );

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
function StatusBars2_MakeMovable( frame, movableType )

    frame.movableType = movableType;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Movable_SetPosition
--
--  Description:    Set the bar position
--
-------------------------------------------------------------------------------
--
function StatusBars2_Movable_SetPosition( self, x, y, savePosition )

    local rnd = StatusBars2_Round;

    --local ux, uy = UIParent:GetSize();
    --print("ux:"..rnd(ux).." uy:"..rnd(uy));

    local parentFrame = (( self.layoutType ~= "Background" ) and self:GetParent( ) ) or UIParent;
    local px, py = parentFrame:GetCenter( );
    local relativeTo;

    if ( parentFrame == UIParent and self.layoutType ~= "Background" ) then 
        relativeTo = "CENTER";
    else
        py = parentFrame:GetTop( );
        relativeTo = "TOP";
    end

    local scale = self.scale;
    local inv_scale = 1 / scale;

    local nx = x;
    local ny = y;

    local dx = nx - px;
    local dy = ny - py;

    if savePosition then
        --print("Saving Position");
        self.position = self.position or {};
        self.position.x = dx;
        self.position.y = dy;
    end

    local invScale = 1 / self.scale;
    local xOffset = ( self.position and self.position.x or dx ) * invScale;
    local yOffset = ( self.position and self.position.y or dy ) * invScale;

    --[[
    if( self.key == "playerHealth" ) then
    --if true then
        print("StatusBars2_Movable_SetPosition");
        print((self.key or "Main"), " x:", rnd(x), " y:", rnd(y));

        print("Saving Position = ", savePosition);
        print("scale:", scale);

        if self.position then
            print("Saved Pos x:", rnd(self.position.x), " y:", rnd(self.position.y));
        else
            print("No saved pos");
        end

        print("nx: ", rnd(nx), " ny:", rnd(ny));
        print("px: ", rnd(px), " py:", rnd(py));
        print("dx: ", rnd(dx), " dy:", rnd(dy), "relTo:", relativeTo);
        print("xoff:", rnd(xOffset), " yoff:", rnd(yOffset));
    end
    --]]

    -- Set the bar position
    self:ClearAllPoints( );
    self:SetPoint( "TOP", parentFrame, relativeTo, xOffset, yOffset );
end

