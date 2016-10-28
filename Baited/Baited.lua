-- can't think of anything clever to do with this yet
local _, BT_DATA = ...;

-- https://github.com/punchmonster/baited_v6

-- the main object
BT = CreateFrame("Frame");
BT.Events = {};
-- assigning globals to locals for optimization
local rand = math.random;
local strmatch = string.match;
local strgmatch = string.gmatch;
local strformat = string.format;
-- this will be assigned to BT.InterfaceOptions.Data when everything is initialized
local Options = {};
-- constants
local THROTTLE_TIME = 10; -- the time required to pass (in seconds) before responding to another message
local TOUPPER_SYMBOL = string.byte("^"); -- because we store responses in an array we must use a symbol to know if a response should be in all uppercase
local NOFORMAT_SYMBOL = string.byte("$");
local RESPONSE_ILEVEL_CHANCE = 85;
local RESPONSE_PROFANITY_CHANCE = 95;
-- vars
local lastUpdate = 0;
local timeSinceStartup = 0;
local lastMessageTime = -36;
local totalResponses = 0;

local function Options_OnChanged()
	if ((Options.Channels.TradeChat == true) or (Options.Channels.GeneralChat == true)) then
		BT:RegisterEvent("CHAT_MSG_CHANNEL");
	else
		-- this is (dangerously) assuming that it was previously registered or that calling UnregisterEvent w/ an event that the frame isn't currently registered for won't bug out
		BT:UnregisterEvent("CHAT_MSG_CHANNEL");
	end
	if (Options.Channels.BGChat == true) then
		-- don't know which event this uses
	end
	if (Options.Channels.RaidChat == true) then
		BT:RegisterEvent("CHAT_MSG_RAID");
	else
		BT:UnregisterEvent("CHAT_MSG_RAID");
	end
	if (Options.Channels.PartyChat == true) then
		BT:RegisterEvent("CHAT_MSG_PARTY");
	else
		BT:UnregisterEvent("CHAT_MSG_PARTY");
	end
end

local function OnAddonLoaded(name)
	if (name == "Baited") then
		print("<Baited> loaded");
		if (BAITED_DB == nil) then
			BAITED_DB = BT.InterfaceOptions.Data;
		else
			BT.InterfaceOptions.Data = BAITED_DB;
		end
		BT.InterfaceOptions:Initialize();
		Options = BT.InterfaceOptions.Data;
		BT.QuickInfo:Initialize();
		if ((Options.Channels.TradeChat == true) or (Options.Channels.GeneralChat == true)) then
			BT:RegisterEvent("CHAT_MSG_CHANNEL");
		end
		if (Options.Channels.BGChat == true) then
			-- don't know which event this uses
		end
		if (Options.Channels.RaidChat == true) then
			BT:RegisterEvent("CHAT_MSG_RAID");
		end
		if (Options.Channels.PartyChat == true) then
			BT:RegisterEvent("CHAT_MSG_PARTY");
		end
		BT.InterfaceOptions:AddListener(Options_OnChanged);
	end
end

local function GetResponse(sender, bItemLevel)
	if (bItemLevel == true) then
		if (rand(100) <= RESPONSE_ILEVEL_CHANCE) then
			local response = BT.Responses.ItemLvl[rand(#BT.Responses.ItemLvl)];
			if (response:byte(1) == TOUPPER_SYMBOL) then
				response = response:sub(2);
				response = response:upper();
			end
			if (response:byte(1) == NOFORMAT_SYMBOL) then
				response = response:sub(2);
				return response;
			end
			return strformat(response, sender);
		end
	else
		if (rand(100) <= RESPONSE_PROFANITY_CHANCE) then
			local response = BT.Responses.Profanity[rand(#BT.Responses.Profanity)];
			if (response:byte(1) == TOUPPER_SYMBOL) then
				response = response:sub(2);
				response = response:upper();
			end
			if (response:byte(1) == NOFORMAT_SYMBOL) then
				response = response:sub(2);
				return response;
			end
			return strformat(response, sender);
		end
	end
end

local function SendMsg(msg, originalEvent, opt_chatArg)
	if (originalEvent == "CHAT_MSG_CHANNEL") then
		SendChatMessage(msg, "CHANNEL", nil, opt_chatArg);
	elseif (originalEvent == "CHAT_MSG_GUILD") then
		SendChatMessage(msg, "GUILD", nil, nil);
	elseif (originalEvent == "CHAT_MSG_PARTY") then
		SendChatMessage(msg, "PARTY", nil, nil);
	elseif (originalEvent == "CHAT_MSG_RAID") then
		SendChatMessage(msg, "RAID", nil, nil);
	end
end

local function IsGuildMemberOrFriend(name)
	-- can cache friends / guild roster for improved performance, but would require subscribing to GUILD_ROSTER_UPDATE and FRIENDLIST_UPDATE events
	for i=1,GetNumFriends() do
		if GetFriendInfo(i) == name then
			return true
		end
	end
	for i=1, GetNumGuildMembers() do
		if GetGuildRosterInfo(i) == name then
			return true
		end
	end
end

local function OnChatMsgReceived(event, message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknownTwo, counter)
	if ((timeSinceStartup - lastMessageTime) < THROTTLE_TIME) then return end
	--splits the server name off of character name
	local playerName = (sender:find("-") == nil and sender or strsplit("-", sender, 2));
	--print("Player name: " .. tostring(playerName));
	-- sloppy, quick addition
	if ((IsGuildMemberOrFriend(playerName)) and (event == "CHAT_MSG_CHANNEL")) then return end
	
	
	-- this works but has some limitations. i really wish lua supported n-digit repetition. [0-9]{3}\+ would be so much easier.
	if (strmatch(message, "%D%d%d%d%+") ~= nil) then
		local response = GetResponse(playerName, true);
		if (response ~= nil) then
			print(response);
			--SendMsg(response, event, channelNumber);
			totalResponses = totalResponses + 1;
		end
		lastMessageTime = timeSinceStartup;
	else
		local profane = false;
		for word in strgmatch(message, "%w+") do
			-- hopefully this is more CPU efficient than manually iterating the table
			-- we add some memory by using a named-key table instead of a simple array, but it's well worth the trade imo (assuming it is lighter on the CPU)
			if (BT.BadWords[word:lower()] ~= nil) then
				profane = true;
				break;
			end
		end
		if (profane == true) then
			local response = GetResponse(playerName, false);
			if (response ~= nil) then
				print(response);
				--SendMsg(response, event, channelNumber);
				totalResponses = totalResponses + 1;
			end
			lastMessageTime = timeSinceStartup;
		end
	end
end

local function OnUpdate(self, elapsed)
	timeSinceStartup = timeSinceStartup + elapsed;
	lastUpdate = lastUpdate + elapsed;
	if (lastUpdate > 1) then
		lastUpdate = 0;
		-- sloppy, quick addition
		BT.QuickInfo:OnUpdate((THROTTLE_TIME - (timeSinceStartup - lastMessageTime)), totalResponses);
	end
end


BT:SetScript("OnEvent", function(self, event, ...)
	if (event == "ADDON_LOADED") then
		local name = ...;
		OnAddonLoaded(name);
	end
	if (event == "CHAT_MSG_CHANNEL") then
		OnChatMsgReceived("CHAT_MSG_CHANNEL", ...);
	elseif (event == "CHAT_MSG_GUILD") then
		OnChatMsgReceived("CHAT_MSG_GUILD", ...);
	elseif ((event == "CHAT_MSG_PARTY") and (Options.Channels.PartyChat == true)) then
		OnChatMsgReceived("CHAT_MSG_PARTY", ...);
	elseif ((event == "CHAT_MSG_RAID") and ((Options.Channels.RaidChat == true) or (Options.Channels.BGChat == true))) then
		OnChatMsgReceived("CHAT_MSG_RAID", ...);
	end
end);

BT:RegisterEvent("ADDON_LOADED");
BT:SetScript("OnUpdate", OnUpdate);


local function HandleSlashCommand(msg, remaining)
	local command, param1 = msg:match("^(%S*)%s*(.-)$");
	if (command == "show") then
		BT.InterfaceOptions:Set("ShowInfoFrame", true);
	elseif (command == "hide") then
		BT.InterfaceOptions:Set("ShowInfoFrame", false);
	elseif (command == "") then
		-- default command (eg; "/baited") brings up the interface options
		InterfaceOptionsFrame_OpenToCategory(BT.InterfaceOptions.Frame);
	end
end

SLASH_BAITED1 = "/baited"
SlashCmdList["BAITED"] = HandleSlashCommand;