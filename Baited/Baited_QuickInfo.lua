BT.QuickInfo = {};
-- this will be assigned to BT.InterfaceOptions.Data when everything is initialized
local Options = {};

function BT.QuickInfo:BuildQuickInfo()
	self.Frame.Title = self.Frame:CreateFontString(nil,"ARTWORK","GameFontHighlightMedium");
	self.Frame.Title:SetSize(self.Frame.Width,35);
	self.Frame.Title:SetPoint("TOP",self.Frame,"TOP", 0, -5);
	self.Frame.Title:SetJustifyH("CENTER"); 
	self.Frame.Title:SetJustifyV("TOP");
	self.Frame.Title:SetTextColor(1,0.8,0);
	self.Frame.Title:SetText("<Baited>\n[Info]");
	
	self.Frame.GlobalCooldown = self.Frame:CreateFontString(nil,"ARTWORK","GameFontWhite");
	self.Frame.GlobalCooldown:SetSize(self.Frame.Width-15,35);
	self.Frame.GlobalCooldown:SetPoint("TOPLEFT",self.Frame, 5, -30);
	self.Frame.GlobalCooldown:SetJustifyH("LEFT");
	self.Frame.GlobalCooldown:SetText("Global cooldown: ready");
	
	self.Frame.TotalResponses = self.Frame:CreateFontString(nil,"ARTWORK","GameFontWhite");
	self.Frame.TotalResponses:SetSize(self.Frame.Width-15,35);
	self.Frame.TotalResponses:SetPoint("TOPLEFT",self.Frame, 5, -50);
	self.Frame.TotalResponses:SetJustifyH("LEFT");
	self.Frame.TotalResponses:SetText("Total baits this session: 0");
	
	-- BUG: this fontstring appears closer to the above fontstring even though they're spaced evenly
	-- i believe it's either vertical justification or word wrap.
	-- adjusting its height seems to cover it up nicely, but not a perfect solution
	self.Frame.ActiveChannels = self.Frame:CreateFontString(nil,"ARTWORK","GameFontWhite");
	self.Frame.ActiveChannels:SetSize(self.Frame.Width-15,45);
	self.Frame.ActiveChannels:SetPoint("TOPLEFT",self.Frame, 5, -70);
	self.Frame.ActiveChannels:SetJustifyH("LEFT");
	local activeChannelsString = "";
	local firstIter = true;
	for k,v in pairs(Options.Channels) do
		if (v == true) then 
			activeChannelsString = activeChannelsString .. (firstIter and tostring(k) or ", " .. tostring(k));
			firstIter = false;
		end
	end
	self.Frame.ActiveChannels:SetText("Active Channels: " .. (activeChannelsString == "" and "none" or activeChannelsString));
	
	-- add more stuff
end

local function Options_OnChanged()
	if (Options.ShowInfoFrame == false) then
		BT.QuickInfo.Frame:Hide();
		return;
	else
		BT.QuickInfo.Frame:Show();
	end
	
	local activeChannelsString = "";
	local firstIter = true;
	for k,v in pairs(Options.Channels) do
		if (v == true) then
			activeChannelsString = activeChannelsString .. (firstIter and tostring(k) or ", " .. tostring(k));
			firstIter = false;
		end
	end
	BT.QuickInfo.Frame.ActiveChannels:SetText("Active Channels: " .. (activeChannelsString == "" and "none" or activeChannelsString));
end

function BT.QuickInfo:OnUpdate(cooldown, totalResponses)
	-- POTENTIAL BUG:
	-- if cooldown or totalResponses is NaN math.floor might throw an exception
	self.Frame.GlobalCooldown:SetText("Global cooldown: " .. (cooldown <= 0 and "ready" or tostring(math.floor(cooldown))));
	self.Frame.TotalResponses:SetText("Total baits this session: " .. tostring(math.floor(totalResponses)));
end

function BT.QuickInfo:Initialize()
	self.Frame = CreateFrame("Frame", "Baited_QuickInfo", UIParent);
	self.Frame.Width  = 250;
	self.Frame.Height = 115;
	self.Frame:SetFrameStrata("FULLSCREEN_DIALOG");
	self.Frame:SetSize(self.Frame.Width, self.Frame.Height);
	self.Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	self.Frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=16});
	self.Frame:SetBackdropColor(0, 0, 0, 1);
	self.Frame:EnableMouse(true);
	self.Frame:EnableMouseWheel(true);

	-- Make movable/resizable
	self.Frame:SetMovable(true);
	self.Frame:RegisterForDrag("LeftButton");
	self.Frame:SetScript("OnDragStart", self.Frame.StartMoving);
	self.Frame:SetScript("OnDragStop", self.Frame.StopMovingOrSizing);
	
	-- makes it so pressing Escape will close the window
	--tinsert(UISpecialFrames, "FarmStats_QuickInfo")
	Options = BT.InterfaceOptions.Data;
	self:BuildQuickInfo();
	BT.InterfaceOptions:AddListener(Options_OnChanged);
	if (Options.ShowInfoFrame == false) then self.Frame:Hide() end
end