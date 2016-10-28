BT.InterfaceOptions = { Listeners = {}, Data = { Channels = {TradeChat = false, GeneralChat = false, BGChat = false, RaidChat = false, PartyChat = false }, ShowInfoFrame = false } };

function BT.InterfaceOptions:OnChanged()
	for k,v in ipairs(self.Listeners) do
		v();
	end
end

function BT.InterfaceOptions:AddListener(Listen_Func)
	for k,v in ipairs(self.Listeners) do if v == Listen_Func then return end end
	self.Listeners[#self.Listeners+1] = Listen_Func;
	--table.insert(self.Listeners, Listen_Func);
end

-- NOTE: only supports a depth of 2.
-- Usage: BT.InterfaceOptions:Set("Channels.TradeChat", true);
-- Usage: BT.InterfaceOptions:Set("ShowInfoFrame", false);
function BT.InterfaceOptions:Set(option, value)
	for k,v in pairs(self.Data) do
		if (k == option) then
			self.Data[k] = value;
			self:OnChanged();
			break;
		elseif (type(v) == "table") then
			local token = tostring(k);
			for k1,v1 in pairs(v) do
				if ((token .. "." .. tostring(k1)) == option) then
					self.Data[k][k1] = value;
					self:OnChanged();
					break;
				end
			end
		end
	end
end


local function OnRefresh()
	BT.InterfaceOptions.Frame.cboxInfoFrameEnabled:SetChecked(BT.InterfaceOptions.Data.ShowInfoFrame);
end

local function cbox_OnClick(cbox, event, arg1)
	-- this whole function is janky but it's better than having 5 anonymous functions
	local name = cbox:GetName();
	local checkState = cbox:GetChecked();
	if (name == "cboxInfoFrameEnabled") then
		BT.InterfaceOptions:Set("ShowInfoFrame", checkState);
	elseif (name == "cboxTradeChatEnabled") then
		BT.InterfaceOptions:Set("Channels.TradeChat", checkState);
	elseif (name == "cboxGeneralChatEnabled") then
		BT.InterfaceOptions:Set("Channels.GeneralChat", checkState);
	elseif (name == "cboxBattlegroundChatEnabled") then
		BT.InterfaceOptions:Set("Channels.BGChat", checkState);
	elseif (name == "cboxRaidChatEnabled") then
		BT.InterfaceOptions:Set("Channels.RaidChat", checkState);
	elseif (name == "cboxPartyChatEnabled") then
		BT.InterfaceOptions:Set("Channels.PartyChat", checkState);
	end
end

local function CreateCheckbox(name, parent, posX, posY, text, onClickHandler)
	local newCBox = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate");
	newCBox:SetPoint("TOPLEFT", parent, posX, posY);
	newCBox.text = _G[name .."Text"];
	newCBox.text:SetText(text);
	newCBox:SetScript("OnClick", onClickHandler);
	return newCBox;
end

function BT.InterfaceOptions:Initialize()
	self.Listeners = {};
	
	self.Frame = CreateFrame("Frame", "BaitedConfig", UIParent);
	self.Frame.Title = self.Frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge2");
	self.Frame.Title:SetPoint("TOPLEFT", 10, -10);
	self.Frame.Title:SetText("Baited");
	
	self.Frame.cboxInfoFrameEnabled = CreateCheckbox("cboxInfoFrameEnabled", self.Frame, 10, -35, "Show Info Frame", cbox_OnClick);
	
	self.Frame.ChannelsHeader = self.Frame:CreateFontString(nil,"ARTWORK","GameFontHighlightMedium");
	self.Frame.ChannelsHeader:SetPoint("TOPLEFT", 10, -60);
	self.Frame.ChannelsHeader:SetTextColor(1,0.8,0);
	self.Frame.ChannelsHeader:SetText("Channels");
	
	self.Frame.cboxTradeChatEnabled = CreateCheckbox("cboxTradeChatEnabled", self.Frame, 10, -75, "Trade", cbox_OnClick);
	self.Frame.cboxGeneralChatEnabled = CreateCheckbox("cboxGeneralChatEnabled", self.Frame, 10, -105, "General", cbox_OnClick);
	self.Frame.cboxBattlegroundChatEnabled = CreateCheckbox("cboxBattlegroundChatEnabled", self.Frame, 10, -135, "Battleground", cbox_OnClick);
	self.Frame.cboxRaidChatEnabled = CreateCheckbox("cboxRaidChatEnabled", self.Frame, 260, -75, "Raid", cbox_OnClick);
	self.Frame.cboxPartyChatEnabled = CreateCheckbox("cboxPartyChatEnabled", self.Frame, 260, -105, "Party", cbox_OnClick);
	
	self.Frame.name = "Baited";
	self.Frame.refresh = OnRefresh;
	-- finally, register it with the addon options
	InterfaceOptions_AddCategory(self.Frame);
end