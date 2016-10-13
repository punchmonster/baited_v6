--[[
Baited by Punchmonster

Based off the Reported! addon by iceweasel and the Trade Chat Champion addon.

Version 6.4

2009-2016
LAST UPDATED: 6:05 - 03/10/16

]]



-- Global variables
local ilvl = { "gearscore", "gear.score", "gerescoar", "gere.scoar", "gearescoar", "gearscoar", 
  "geare.scoar", "gear.scoar", "gee ess", "jee ess", "llvl", "ilevel", "ilvl", "ilevl", "ilvel", 
  "ilv", "i level", "i lvl", "i level", "835", "840", "845", "850", "855", "860", "item level", 
  "item lvl" 
}

local swears = { "fuck", "shit", "jizz", "sex", "nigg", "anal ", "bollocks", "fagg", " fag ", "fuk", 
  "pussy", "dick", "asshole", " ass ", " cum ", "slut", "cumdumpster", "bitch", "whore", "hooker", 
  "cock", "turd ", "penis", "wtf", "kike", "wetback", "scratchback", "chink", "nagger", "cuck", "towelhead", 
  "fgt", "sperg" 
}

local fakes = {	}
local time = floor(GetTime()); -- time count
local otime = floor(GetTime());
local stime = floor(GetTime());-- Swear time count
local globalcd = (math.random(35, 35));
local posttime = (math.random(3, 6));
local globaltime = floor(GetTime());
local ftime
local itime
local rilvl = 80; -- Roll chance ilvl responses
local rswears = 95; -- Roll chance swear responses
local togglecheck = 1;
local trigcount = 0; -- times addon has been triggered this session
local swearon = "|cff00ff00 enabled|r";
local ilvlon = "|cff00ff00 enabled|r";

local GSwindow_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)

function OnLoad_Message()
  DEFAULT_CHAT_FRAME:AddMessage("Welcome to|cff3399FF Baited|r: Master baiting for master baiters. Version|cff00ff00 6.0|r", 1.0, 1.0, 1.0);
end

--FUNCTION: handling of slash commands for addon control
  --message - chat message, unused
  --editbox - idk lol
SLASH_CONFIG1 = "/baited"
function SlashCmdList.CONFIG(message, editbox)
  if message == "show" then
    GSwindow_Cooldown:Show();
    BAITEDSHOW=true;
  elseif message == "hide" then
    GSwindow_Cooldown:Hide();
    BAITEDSHOW=false;
  elseif message == "ilvl" then
    if rilvl > 0 then
      rilvl=0;
      DEFAULT_CHAT_FRAME:AddMessage("|cff3399FFBaited|r: ilvl responses disabled", 1.0, 1.0, 1.0);
      ilvlon = "|cffff0000 disabled|r";
    else
      rilvl=80;
      DEFAULT_CHAT_FRAME:AddMessage("|cff3399FFBaited|r: ilvl responses enabled", 1.0, 1.0, 1.0);
      ilvlon = "|cff00ff00 enabled|r";
    end
  elseif message == "swears" then
    if rswears > 0 then
      rswears=0;
      DEFAULT_CHAT_FRAME:AddMessage("|cff3399FFBaited|r: swear responses disabled", 1.0, 1.0, 1.0);
      swearon = "|cffff0000 disabled|r";
    else
      rswears=95;
      DEFAULT_CHAT_FRAME:AddMessage("|cff3399FFBaited|r: swear responses enabled", 1.0, 1.0, 1.0);
      swearon = "|cff00ff00 enabled|r";
    end
  elseif message == "toggle" then
    if togglecheck == 1 then
      togglecheck=0;
      DEFAULT_CHAT_FRAME:AddMessage("|cff3399FFBaited|r: disabled", 1.0, 1.0, 1.0);
    else
      togglecheck=1;
      DEFAULT_CHAT_FRAME:AddMessage("|cff3399FFBaited|r: enabled", 1.0, 1.0, 1.0);
    end
  else
  DEFAULT_CHAT_FRAME:AddMessage(" ", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage("|cff3399FFBaited|r by Lewdtrapgirl of Bleeding Hollow.", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage("STATUS: swears " .. swearon .. " - ilvl " .. ilvlon .. " ", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /baited |r|cffCC3399 toggle |r - Turn addon on and off.", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /baited |r|cffCC3399 swears |r - Turn swear responses on and off.", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /baited |r|cffCC3399 ilvl |r - Turn ilvl responses on and off.", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /baited |r|cffCC3399 show |r - Show cooldown window.", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /baited |r|cffCC3399 hide |r - Hide cooldown window.", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /baited |r|cffCC3399 help |r - Show you this menu.", 1.0, 1.0, 1.0);
  DEFAULT_CHAT_FRAME:AddMessage(" ", 1.0, 1.0, 1.0);
  end
end

--FUNCTION: handling cooldown UI display, called every second
  --ARGUMENTS:
  --self    - idk lol
  --elapsed - time elapsed since last response
function GSwindow_OnUpdate(self, elapsed)

  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
  currenttime = floor(GetTime());
  finalilvl = stime - currenttime;
  finalee = otime - currenttime;
  finalgcd = globaltime - currenttime;

  if (self.TimeSinceLastUpdate > GSwindow_UpdateInterval) then

    --SWEAR
    if (finalilvl > 9) then
      GSwindow_CooldownSwear:SetText(finalilvl);
      GSwindow_CooldownSwear:SetTextColor(1.0, 1.0, 1.0, 0.5);
	  elseif (finalilvl > 0) then
      GSwindow_CooldownSwear:SetText(" " .. finalilvl);
      GSwindow_CooldownSwear:SetTextColor(1.0, 1.0, 1.0, 0.5);
  	else
      GSwindow_CooldownSwear:SetText("OK");
      GSwindow_CooldownSwear:SetTextColor(1.0, 1.0, 1.0, 0.5);
    end

    --GCD
  	if (finalgcd > 0) then
      GSwindow_CooldownGCD:SetText(" ");
      GSwindow_CooldownGCD:SetTextColor(1.0, 1.0, 1.0, 1.0);
    else
      GSwindow_CooldownGCD:SetText(" ");
      GSwindow_CooldownGCD:SetTextColor(0, 2.0, 0, 1.0);
    end

    self.TimeSinceLastUpdate = 0;

  end
end

--FUNCTION: called on chat event
  --ARGUMENTS:
  --message  - the chat message
  --sender   - character name and realm name of the message sender
  --chatType - regular or whisper
  --channel  - channel the message was in
local function CheckMsgMatch(message, sender, chatType, channel)

  local senderStripped

  if togglecheck == 1 then

    -- Cooldowns for triggers set
    local ilvlcooldown = (math.random(35, 50));

    local roll = (math.random(1, 100));

    --FUNCTION: checks if sender is on friendlist
      --ARGUMENTS:
      --sender - character name and realm name of the message sender
    local function IsFriend(sender)
      for i=1,GetNumFriends() do
        if GetFriendInfo(i) == sender then
          return true
        end
      end
    end

    --FUNCTION: checks if sender is in same guild
      --ARGUMENTS:
      --sender - character name and realm name of the message sender
    local function IsGuildMember(sender)
      for i=1, GetNumGuildMembers() do
        if GetGuildRosterInfo(i) == sender then
          return true
        end
      end
    end

    -- Splits the server name off of character name
    y = string.match(sender, "^.+%-")

    if y == nil then
      senderStripped = sender
    else
      senderStripped = y:sub(1, #y - 1)
    end
    
    --FUNCTION: response processing
      --ARGUMENTS:
      --type         - response type (ilvl, swears)
      --rolltype     - roll chance for response type
      --responsetype - returns the array with responses
    local function AddonAnouncements(type, rolltype, responsetype)
    -- ilvl
      for _, v in ipairs(type) do
        if strmatch(strlower(message), strlower(v))	then
          if not stime or GetTime() > stime then
            if globaltime <= GetTime() then
              if (IsFriend(sender) == true) then  --Check if the person is a Friend before replying.
                DEFAULT_CHAT_FRAME:AddMessage("["..sender.." (" .. strlower(v) .. ") is a Friend, skipping.]", 1.0, 1.0, 1.0);
                stime = floor(GetTime()) + 2
                return
              end
              if (IsGuildMember(sender) == true) then --Check if the person is a Guildmate before replying.
                DEFAULT_CHAT_FRAME:AddMessage("["..sender.." (|cffFF9933" .. strlower(v) .. "|r) is a Guildmate, skipping.]", 1.0, 1.0, 1.0);
                stime = floor(GetTime()) + 2
                return
              end
              if (roll <= rolltype) then
                trigcount = trigcount +1;
                SendChatMessage("" .. responsetype[math.random(getn(responsetype))] .. "",chatType, nil, channel)
                DEFAULT_CHAT_FRAME:AddMessage("[|cff3399FFBaited|r: triggered |cffFF9933" ..trigcount.. "|r times. (|cffFF9933" .. strlower(v) .. "|r) Your new cooldown is |cffFF9933" .. ilvlcooldown .. "|r seconds. You rolled " .. roll .. " out of a " ..rilvl.. "% chance to respond.]", 1.0, 1.0, 1.0);
                stime = floor(GetTime()) + ilvlcooldown
                globaltime = floor(GetTime()) + globalcd
                return
              end
              if (roll > rolltype) and (rolltype > 0) then
                DEFAULT_CHAT_FRAME:AddMessage("["..sender..": (" .. strlower(v) .. ") but roll was > " .. rolltype .. " (" .. roll .. ")]", 0.1, 0.9, 0.1);
                stime = floor(GetTime()) + 2
                return
              end
            end
          end
        end
      end
    end

    -- item level responses
    local ilvlresponses = {
      "SWEARING GETS YOU NO WHERE IN THIS SPORT " .. strupper(senderStripped) .. ". BOOM-SHAKA-LAKA! - JOHN MADDEN, NBA JAM 1993",
      "Typical whiteboy, cares about item level but not that #BlackLivesMatter",
      "While young black men get killed by cops in cold blood, all you can talk about is item level " .. senderStripped .. "... #BLM" ,
      "I AM PRESIDENT BERNIE SANDERS AND WE WILL NOT LET THE 1\% LIKE ".. strupper(senderStripped) .. " WHO HAVE BAD GEAR DECIDE WHO RUNS THIS EXPANSION",
      "Yo man I'm really happy for you and I'm gonna let you finish, but ".. senderStripped .. " has one of the worst item levels of all time... Of all time!",
        "I hope your mom comes home drunk and beats your dad to death for having too low of an item level ".. senderStripped .. ".",
        "'For fear not, the chosen messiah, Odors hath cometh to praise glory for all gentiles, for his excellence shines yonder beyond tiers of gears' -Book of Odors 4:20",
        "To Sunburth he said 'Because thou listened not to logic and reason, but to treachery and deceit, thine fruit hath been corrupted and your errors plenty'  -Book of Odors 4:17",
      "i think " .. senderStripped .. " is a pretty cool guy, eh asks for ilvl and doesnt afraid of anything...",
      "" .. senderStripped .. " is WTS skill, his item level is over 9000!",
      "HEY BOOBOO, " .. senderStripped .. "'s ilevel demands are spoiling my PICANIC BASKET - yogi 'the bear' bear",
      "'The world is a dangerous place to live " .. senderStripped .. "; not because of the people who demand item level, but because of the people who don't do anything about it.' -Einstein",
      "" .. senderStripped .. ", All the gearwhores and raid leaders will look up and shout 'Save us!'... and I'll look down and whisper 'No.'",
      " Britain not caring that BP caused the oilspill is not as bad as " .. senderStripped .. " still thinking item level = skill...",
      "www.myilevelmylife.com! The hot new matchup site for the overly geared! Sign up now and recieve special benefits such as filtering based on gear, gear and more gear! Hear our testimonials from people such as " .. senderStripped .. ": 'I didn't want to date a random scrub'",
      "In spite of his item level " .. senderStripped .. " dies in fire.",
      "Hey " .. senderStripped .. ", ilevel = skill",
      "" .. senderStripped .. "'s relentless demand for certain ilevels is almost as oppressive as the American patriarchy keeping the individual non-cis at the bottom.",
      "" .. strupper(senderStripped) .. " ISNT GETTIN AN INVITE CUZ HIS ILVL SUX LOL",
      "Analysts have concluded that " .. senderStripped .. "'s item level is only achieved through PvP gear.",
      "9/11 was an inside job but it was not nearly as bad as the terror caused by Blizzard and " .. senderStripped .. "'s gearscore abuse.",
      "Scientists have recently discovered after a series of tests that item level causes cancer. Enjoy your hairloss, mouth foaming and inevitable death " .. senderStripped .. ".",
      "Playing naked is probably not such a good idea if " .. senderStripped .. " keeps demanding item levels like that",
      "Jesus was crucified for " .. senderStripped .. "'s sins, yet here he is sinfully demanding item level.",
      "Hey " .. senderStripped .. " this is the trade channel, not the skill channel, item level discussion does not belong in here, type /join ilevel to join the skill discussion.",
      "'Daddy, I did it!' -Festergut after wiping " .. senderStripped .. "'s ilvl based raid.",
      "'Is the item level loved by the gods because it is pious, or is it pious because it is loved by the gods " .. senderStripped .. "?' -Socrates",
      "'One of the penalties for refusing to participate in item level is that you end up being governed by your inferiors like " .. senderStripped .. ".' -Plato",
      "'Who is also aware of the tremendous risk involved in ilevel pugging - when he nevertheless makes the leap of faith - this is subjectivity at its height.' -Soren Kierkegaard",
      "'ilevel is dead.' -Nietzsche",
      "Dobby is free! Free from " .. senderStripped .. "'s item level abuse!",
      "I liek mudkipz, not item levels " .. senderStripped .." ",
      "HAHAHAHAHAHAHAHAHA " .. strupper(senderStripped) .." STILL USES ITEM LEVEL XDDDD",
      "Yesterday, all my troubles seemed so far away, but now it looks like " .. senderStripped .."'s here to stay, oh I believe in yesterday",
      "'It is the mark of an educated mind to be able to entertain item level without accepting it " .. senderStripped .. ".' -Aristotle",
      "'I have never wished to cater to item level; for what I know they do not approve, and what they approve I do not know.' -Epicurus",
      "'" .. senderStripped .. ", I never considered a lower item level in raids, in heroics, in guilds, as cause for withdrawing from a group.' -Thomas Jefferson",
      "'Those who lack the skill will always find item level to justify it.' -Albert Camus",
      "'I have a dream that my four little children will one day live in a nation where they will not be judged by " .. senderStripped .. " for level of their gear, but by the skill at their character.' -Martin Luther King, Jr.",
      "I guess " .. senderStripped .. " was kicked out of the Garden of eden for sizing up God by using item level.",
      "Psalm 136:26 Give thanks to the God of heaven, for " .. senderStripped .. "'s steadfast item level forever.",
      "'If you were as bad as " .. senderStripped .. ", wouldn't you use ilevel too?' -Zach Braff",
      "'Item level? Isn't that the stuff that makes juice drinkable?' -Philip J. Fry",
      "WHAT?! How do you expect Kevinwillis to marry you " .. senderStripped .. " when Meanbeaver has a higher item level?",
      "" .. senderStripped .. " will have to repent for his sins for their item level isn't high enough for heaven!",
      "Hey " .. senderStripped .. ", Stop implanting an ilevel meter in your wife's mind like Leonardo Dicaprio implants ideas in his wife's mind",
      "'Now listen here " .. senderStripped .. ". What I'm sayin' to you is the honest truth. Let go of your item level and you'll be safe.' -Applejack",
      "Hey " .. senderStripped .. ", your ilvl based raid will probably go as well as your love life.",
      "'I..I want to c-come to " .. senderStripped .. "'s raid, b-but I'm not sure if my ilvl is high enough...' -Fluttershy",
      "'heh... expeliarmous of " .. senderStripped .. "'s item level requirements' - potter 2002",
      "'Raiding really isn't about ilevel or gear, it's about the skill to deliver your chops and your chops, " .. senderStripped .. ", are shit.' -Gary Oldman",
      "It's bad enough that you're playing WoW, do you have to make yourself look like more of a nerd by asking for ilvl requirements " .. senderStripped .. "?",
      "'Suffer " .. senderStripped .. ", as your pathetic item level betrays you!' -Deathwing",
      "Raleigh might have managed to go through the portal in Pacific rim to destroy the aliens and save the world, but " .. senderStripped .. " is trying to ruin the world again with their ilevel requirements.",
      "Oh dear what can I do, " .. senderStripped .. " asked for ilevel and I'm feeling blue",
      "Joining " .. senderStripped .. "'s ilvl based raid will be like running in the 2012 Boston marathon. You won't finish it.",
      "beiber is waaaaaaayyyyyyy cuiter then " .. senderStripped .. " lol and he dosnt ask for ilevel lol, loser ;P",
      "Settle down there " .. senderStripped .. ".  I don't want item level mentioned around my household, ok?",
      "Where'd you learn how to demand ilevel like that, " .. senderStripped .. "? I thought I raised you better than that, kiddo.",
      "republican dps, looking for group that doesn't demand ilevel like " .. senderStripped .. ",send me a pst",
      "lady gaga might have a bad romance but " .. senderStripped .. " really bad gear requirements!!",
      "Asking for ilevel? Should probably make sure the people coming have enough repair gold too " .. senderStripped .. ".",
      "I'm a sponsored girl gamer and I get by without ilevel requirements, why can't " .. senderStripped .. "?",
      "I'm on remote chat at the club and even I'm offended by " .. senderStripped .. "'s ilevel requirement",
      "What the fudge did " .. senderStripped .. " just frickin say about my gear, you little n00b? I'll have you know I'm a rank 1 challenger PVPer and have done raids on every 10 man heroic content. I also partner with reckful and have reflexes like fatal1ty. You are nothing to me but just an ilevel abuser. I will pwn the fudge out of you with Arcane Missiles the likes of which has never been seen before on Azeroth AND Outland, mark my frickin words.",
      "waterboarding isn't torture, but " .. senderStripped .. "'s itemlevel requirement sure is",
      "please stop talking about item level " .. senderStripped .. " ",
      "LF 1 TANK 2 HEALERS MSV 10 MAN 540ILEVEL MINIMUM! PST " .. strupper(senderStripped) .. "",
      "Razer sponsored me without asking for my ilvl so why does " .. senderStripped .. "'s random pug need to know it?",
      "No flasks, feasts, gems, enchants, achieves or skill needed for " .. senderStripped .. "'s group. Just bring the ilevel.",
      "Wiping all night and clearing a quarter of the raid is just fine for " .. senderStripped .. " as long as the pugs have a good ilevel.",
      "'Mama always said life was like a group of pugs. You never know what ilevel you're gonna get.' - Forrest Gump",
      "I-it's not like I need ilevel or anything " .. senderStripped .."-sama...",
      "Robb Stark and his mom may have died, but they died due to lack of skill, not low item level " .. senderStripped .. "",
      "King David tallied his nation's military ilvl, after God's prophet warned him not to, and God punished him. Moral of the story? Don't count ilvl, just win your battles " .. senderStripped .. ".",
      "Raids in WoW require ilvl and not skill " .. senderStripped .. "? Guess that's another reason Guild Wars 2 is the better MMO.",
      "Raids in WoW require ilvl and not skill " .. senderStripped .. "? Guess that's another reason Runescape is the better MMO.",
      "Raids in WoW require ilvl and not skill " .. senderStripped .. "? Guess that's another reason SWTOR is the better MMO.",
      "Raids in WoW require ilvl and not skill " .. senderStripped .. "? Guess that's another reason Wildstar is the better MMO.",
      "'Oh! It's my tail! It's my tail! It's a-twitch a-twitchin'! And " .. senderStripped .. ", you know what that means! The twitchin' means my Pinkie Sense is telling me your ilevel requirement is dumb!' -Pinkie Pie",
      "And verily I say unto " .. senderStripped .. ", it is easier for a camel to get through the eye of a needle than for a man with a high ilevel to get into Heaven",
      "'I don't understand why we keep wiping! Everyone had the required ilvl.' - " .. senderStripped .. ".",
      "Genesis 1:31: And God saw every thing that he had made, and, behold, it was very good. Except for " .. senderStripped .. "'s item level.",
      "" .. senderStripped .. "'s ilvl requirements have been holding back good players longer than this misogynistic country has been holding back strong womyn.",
      "Rita died in dexter cause " .. senderStripped .. " is still using ilevel, how many more victims does he need to claim?", 
      "<Reddit Gamer Girls>, the number 1 all female sponsored raiding guild does not approve " .. senderStripped .. "'s use of item level requirements. Please refrain from doing so, thank you.",
      "'item level is the best thing invented by Blizzard since they invented parry' -Ungroth, best warrior US",
      "Hey " .. senderStripped .. ", we don't mention item levels here.",
      "" .. senderStripped .. " could you please stop talking about item level?",
      "" .. senderStripped .. " I love you, but I can't be with someone who loves item level over me...",
      "Hey " .. senderStripped .. ", chill with the item level stuff."
    }

    -- swear responses
    local swearresponses = {
      "We're gonna build a wall between us and the swearers, and we're gonna make ".. senderStripped .. " pay for it",
      "If you don't stop swearing I'm gonna have to send you back ".. senderStripped .. " #MAGA #TRUMP2016",
      "Black lives don't matter, but what does matter is ".. senderStripped .. "'s swearing",
      "Not swearing like ".. senderStripped .. " is just as easy as being white #BLM",
      "Harambe is dead because " .. senderStripped .. " couldn't stop swearing",
      "2016, the year an unarmed black man get's shot to save " .. senderStripped .. "'s gorilla child. #RIPharambe",
      "please stop swearing " .. senderStripped .. ".",
      "no swearing in public chat " .. senderStripped .. "! I've reported you!",
      "reported " .. senderStripped .. " for swearing!",
      senderStripped .. " reported!",
      senderStripped .. ", reported for swearing",
      "If my mouth was as filthy as " .. senderStripped .. "'s I'd be a sailor.",
      "Do you talk to your mother that way, " .. senderStripped .. "?",
      "This isn't the army, " .. senderStripped .. ", watch your language.",
      "We are lucky the FCC doesn't regulate WoW, or else we would be in trouble with " .. senderStripped .. "'s potty mouth.",
      "I voted for Sarah Palin in 2008 so I would not have to hear garbage like " .. senderStripped .. " just said.",
      "Enabling the profanity filter does not give you free reign to speak with crude language " .. senderStripped .. ".",
      "That language is not acceptable in my kitchen, " .. senderStripped .. "! - Chef Gordon Ramsay ",
      "AFK a second, I need to put on my sunglasses, the swear word that " .. senderStripped .. " just said blinded me.",
      "Oh look at " .. senderStripped .. " using those big swear words again, if you keep it up, you might be able to wear big boy underwear soon!",
      "HEY EVERYONE LOOK! " .. senderStripped .. " is trying to mimic the big boys! Go and play, " .. senderStripped .. ", the sandbox is lonely without you!",
      "Player " .. senderStripped .. " has been reported for his/her vulgar language.",
      "I know " .. senderStripped .. " is trying to be a big boy gamer with that language, but they're just a fake gamer. Don't be fooled. Reported!",
      "Don't say words like that, " .. senderStripped .. ".  There are children playing.",
      "republican dps, looking for group that doesn't swear like " .. senderStripped .. ", send me a pst",
      "I reported you for swearing " .. senderStripped .. ".",
      "Yo man I'm really happy for you and I'm gonna let you finish, but ".. senderStripped .. " has one of the biggest pottymouths of all time... Of all time!",
      "Rita died in dexter cause " .. senderStripped .. " still cusses like a child, how many more victims does he need to claim?",
      "It's bad enough that you're playing Wildstar, do you have to make yourself look like more of a nerd by swearing " .. senderStripped .. "?",
      "watch your mouth " .. senderStripped .. "...",
      senderStripped .. ", swearing is for nerds!",
      "" .. senderStripped .. " I love you, but I can't be with someone who still swears like a 12 year old...",
      "What the fudge did you just swear " .. senderStripped .. ", you little n00b? I'll have you know I'm a rank 1 challenger PVPer and have done raids on every 10 man heroic content. I also partner with reckful and have reflexes like fatal1ty. You are nothing to me but just an abusive pottymouth. I will pwn the fudge out of you with Arcane Missiles the likes of which has never been seen before on Azeroth AND Outland, mark my frickin words.",
      "Hey " .. senderStripped .. ", I heard swearing is cool",
      "'Now listen here " .. senderStripped .. ". What I'm sayin' to you is the honest truth. stop swearing you'll be safe.' -Applejack",
      "Hey " .. senderStripped .. ", chill out with the swearing.",
      "Where'd you learn how to swear like that, " .. senderStripped .. "? I thought I raised you better than that, kiddo.",
      "" .. senderStripped .. "'s relentless swearing habits is almost as bad as the American patriarchy keeping the individual non-cis and womyn at the bottom.",
      "<Reddit Gamer Girls>, the number 1 all female sponsored raiding guild does not approve " .. senderStripped .. "'s use of bad words. Please refrain from doing so, thank you.",
      "'I have never wished to cater to potty mouthes like " .. senderStripped .. "; for what I know they do not approve, and what they approve I do not know.' -Epicurus",
      "beiber is waaaaaaayyyyyyy cuiter then " .. senderStripped .. " lol and he dosnt swear, loser ;P",
      "" .. senderStripped .. ", All the swearers and cursers will look up and shout 'Save us!'... and I'll look down and whisper 'No.'",
      "" .. senderStripped .. "'s swearing has been holding back good players longer than this misogynistic country has been holding back strong womyn.",
      "9/11 was an inside job but it was not nearly as bad as the terror caused by " .. senderStripped .. "'s swearing.",
      "waterboarding isn't torture, but " .. senderStripped .. "'s potty mouth sure is",
      "Oh dear what can I do, " .. senderStripped .. " swore and I'm feeling blue",
      "I-it's not like I need your swearing or anything " .. senderStripped .."-sama...",
      "Razer sponsored me because I don\'t swear " .. senderStripped .. ", why do you feel the need to do it?",
      "lady gaga might have a bad romance but " .. senderStripped .. " has a really bad mouth!!",
      "'Suffer " .. senderStripped .. ", as your pathetic potty mouth betrays you!' -Deathwing",
      "Genesis 1:31: And God saw every thing that he had made, and, behold, it was very good. Except for " .. senderStripped .. "'s dirty mouth.",
      "\"Put away from you crooked speech, and put devious talk far from you " .. senderStripped .. ".\" -Proverbs 4:24",
      "Please no swearing " .. senderStripped .. ".",
      senderStripped .."'s sharp tongue will be cut out like Robb Stark's unborn child on his wedding night.",
      "'heh... expeliarmous of " .. senderStripped .. "'s bad mouth' - potter 2002",
      "Do you kiss your mother with that mouth " ..senderStripped.."?",
      "i think " .. senderStripped .. " is a pretty cool guy, eh swears and doesnt afraid of anything...",
      "I'm on remote chat at the club and even I'm offended by " .. senderStripped .. "'s swearing",
      "Hey " .. senderStripped .. ", stop fucking swearing!",
      "'Oh! It's my tail! It's my tail! It's a-twitch a-twitchin'! And " .. senderStripped .. ", you know what that means! The twitchin' means my Pinkie Sense is telling me your swearing is dumb!' -Pinkie Pie",
      senderStripped .."'s potty mouth is almost as shocking as the time Ned Stark was beheaded for treason against the king.",
      senderStripped .. " 's words are giving me a crushing headache like Oberyn Martell often gets.",
      "Excuse me ".. senderStripped ..", was you sayin' somethin'? Uh uh, you can't tell me nothin'",
      "Hey " .. senderStripped .. ", real men don't swear.",
      senderStripped .. " keeps it 300, like the Romans. 300 swearwords, where\'s' the Trojans?",
      "Please no swearing.",
      "Can you please stop swearing " .. senderStripped .. "?",
      "\"" .. senderStripped .. ", you\'re a wizard so do me a favor and wizz those words away\" -Hagrid",
      "The plan was to drink until the pain over, but what's worse: ".. senderStripped .."\'s swearing or the hangover?",
      senderStripped .. " was a fookin' legend in Gin Alley, but here he's just another brick in the wall.",
      "-6 x 6 x 6 = 0, and swearing + bad at this game + 12 = " .. senderStripped .. "."
    }

    -- FAKES
    for _, v in ipairs(fakes) do
      if strmatch(strlower(message), strlower(v)) then
        if not ftime or GetTime() > ftime then
          DEFAULT_CHAT_FRAME:AddMessage("Fake? (" .. strlower(v) .. ").", 0.1, 0.9, 0.1);
          ftime = floor(GetTime()) + 2
        end

        return
      end
    end

    --calls announcement function
    AddonAnouncements(ilvl, rilvl, ilvlresponses)
    AddonAnouncements(swears, rswears, swearresponses)

    --CLOSURE
  end
end

-- Registering event hooks
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_CHANNEL")
f:RegisterEvent("CHAT_MSG_BATTLEGROUND")
f:RegisterEvent("CHAT_MSG_RAID")
f:RegisterEvent("CHAT_MSG_PARTY")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function (self, event, ...)
	local message, sender, _, _, _, _, _, channel, channelname = ...

	-- Check CD window
	if (event == "ADDON_LOADED") then
	  if BAITEDSHOW == true or BAITEDSHOW == nil then
		  GSwindow_Cooldown:Show();
	  else
		  GSwindow_Cooldown:Hide();
	  end
	end

	-- Trade Channel
	if (event == "CHAT_MSG_CHANNEL") and ((channelname == "Trade - City") or (channelname == "Trade")) then
	  CheckMsgMatch(message, sender, "CHANNEL", channel)
	end

	-- General Channel
	if (event == "CHAT_MSG_CHANNEL") and (string.find(channelname, "General")) then
		CheckMsgMatch(message, sender, "CHANNEL", channel)
	end

	-- Mod test channel.
	if (event == "CHAT_MSG_CHANNEL") and (channelname == "tcctest") then
		CheckMsgMatch(message, sender, "CHANNEL", channel)
	end

	-- Battleground Channel
	if (event == "CHAT_MSG_BATTLEGROUND") then
		CheckMsgMatch(message, sender, "BATTLEGROUND")
	end

	-- Raid Channel
	if (event == "CHAT_MSG_RAID") then
		CheckMsgMatch(message, sender, "RAID")
	end

	-- Party Channel
	if (event == "CHAT_MSG_PARTY") then
		CheckMsgMatch(message, sender, "PARTY")
	end
end)
