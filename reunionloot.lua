SLASH_REUNIONLOOT1 = "/reunionloot"
SLASH_REUNIONLOOTMASTER1 = "/reunionlootmaster"
SLASH_REUNIONLOOTMONITOR1 = "/reunionlootmonitor"

REUNIONLOOT = {}
REUNIONLOOT.prefix = "ReunionLoot"
REUNIONLOOT.min_bid = 100
REUNIONLOOT.version = "1.2.0"
REUNIONLOOT.item_per_page = 11
REUNIONLOOT.raid_size = 10
REUNIONLOOT.send_gap = 0.5
REUNIONLOOT.cut_ratio = {}
REUNIONLOOT.cut_ratio.guild = 7
REUNIONLOOT.cut_ratio.bonus1 = 1
REUNIONLOOT.cut_ratio.people1 = 4
REUNIONLOOT.cut_ratio.bonus2 = 0.8
REUNIONLOOT.cut_ratio.people2 = 2
REUNIONLOOT.cut_ratio.bonus3 = 0.5
REUNIONLOOT.cut_ratio.people3 = 7
REUNIONLOOT.cut_ratio.full_share = 1
REUNIONLOOT.cut_ratio.half_share = 0

local player_name = UnitName("player")

local function SendOutItem(start_index, item_list, batch_num)
	local msg = "NewItem;"
	local batch_index = 1
	local list_index = start_index
	while (list_index <= #item_list and batch_index <= batch_num) do
		local item_info = item_list[list_index]
		if item_info ~= nil then
			msg = msg..item_info.item_index..","..item_info.item.id..","..item_info.current_price..","..item_info.current_winner..";"
			batch_index = batch_index + 1
		end
		list_index = list_index + 1
	end
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID")
	SendSystemMessage("Item "..start_index.." to "..(list_index - 1).." has been sent.")
	return list_index
end

local function SendOutItemIgnoreSkips(start_index, item_list, batch_num)
	local msg = "NewItem;"..#item_list..";"
	local batch_index = 1
	local list_index = start_index
	while (list_index <= #item_list and list_index < start_index + batch_num) do
		local item_info = item_list[list_index]
		if item_info ~= nil then
			local status = item_info.status
			local encode_status = 0
			if status == "bidding" then
				encode_status = 0
			elseif status == "boughtin" then
				encode_status = 1
			elseif status == "deal" then
				encode_status = 2
			end
			msg = msg..item_info.item_index..","..item_info.item.id..","..item_info.current_price..","
				..item_info.current_winner..","..encode_status..";"
		end
		list_index = list_index + 1
	end
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID")
	SendSystemMessage("Item "..start_index.." to "..(list_index - 1).." has been sent.")
end

function Reunionloot_SendOutItemsMessage(item_list)
	local batch_num = 5
	local index = 1
	C_Timer.NewTicker(REUNIONLOOT.send_gap * batch_num, function()
		SendOutItemIgnoreSkips(index, item_list, batch_num)
		index = index + batch_num
	end, math.ceil(#item_list / batch_num))
end

function  Reunionloot_WhisperPListPerUser(user, passed_item_index)
	local msg = "PassedItem;"
	for _, item_index in pairs(passed_item_index) do
		msg = msg..item_index..";"
	end
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "WHISPER", user)
end

function Reunionloot_ReportBidMessage(item_index, price)
	local msg = "BidFromClient;"..item_index..";"..price
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_BroadcastEndBidMessage(item_list)
	local boughtin_msg = "BoughtIn;"
	local deal_msg = "Deal;"
	for index, item_info in pairs(item_list) do
		if item_info.current_winner == "No one bid" then
			boughtin_msg = boughtin_msg..index..";"
		else
			deal_msg = deal_msg..index..";"
		end
	end
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, boughtin_msg, "RAID");
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, deal_msg, "RAID");
end

function Reunionloot_BroadcastPing()
	local msg = "Ping;"
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_ClientResponsePing(name)
	local msg = "ConfirmPing;"..REUNIONLOOT.version
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "WHISPER", name);
end

function Reunionloot_BroadCastBidMessage(item_index, price, winner)
	local msg = "BroadcastBid;"..item_index..";"..price..";"..winner
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_BroadCastSetPriceMessage(item_index, price)
	local msg = "BroadcastSetPrice;"..item_index..";"..price..";".."No one bid"
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_BroadCastDeleteMessage(item_index)
	local msg = "BroadcastDelete;"..item_index
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_BroadCastDeleteAll()
	local msg = "BroadcastDeleteAllDeleteAll;"
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_BroadCastNotifyMessage(message, target)
	local msg = "BroadcastNotify;"..message
	if target == nil then
		C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID")
	else 
		C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "WHISPER", target)
	end
end

function Reunionloot_BroadcastSetConfig(config)
	local msg = "SetConfig;"
	for k, v in pairs(config) do
		msg = msg..v..";"
	end
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID")
end

function Reunionloot_BroadcastPublishConfig()
	local msg = "PubConfig;"
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID")
end

function Reunionloot_BroadCastBoughtIn(item_index)
	local msg = "BoughtIn;"..item_index
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_BroadCastDeal(item_index)
	local msg = "Deal;"..item_index
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_ReportPass(item_index)
	local msg = "PassFromClient;"..item_index
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_ConfirmPass(item_index, target)
	local msg = "ConfirmPass;"..item_index
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "WHISPER", target);
end

function Reunionloot_BroadCastStartClient()
	local msg = "ClientStart;"
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

local function OnStandbyEvent(self, event, prefix, msg, _, _, target, ...)
	if event == "CHAT_MSG_ADDON" then
		if prefix ~= REUNIONLOOT.prefix then return end
		local actions = Reunionloot_split(msg, ";")

		if actions[1] == nil then return end
		-- Refresh the list
		if actions[1] == "ClientStart" then
			if REUNIONLOOT.master_win == nil then
				Reunionloot_Client_Window_Show()
			end
		end
	end
end

local function Client_Start()
	SendSystemMessage("Reunionloot V"..REUNIONLOOT.version.." registered")
	REUNIONLOOT.client_standby = REUNIONLOOT.client_standby or CreateFrame("Frame", nil, UIParent)
	REUNIONLOOT.client_standby:SetScript("OnEvent", OnStandbyEvent)
	REUNIONLOOT.client_standby:RegisterEvent("CHAT_MSG_ADDON");
end

C_ChatInfo.RegisterAddonMessagePrefix(REUNIONLOOT.prefix);
Client_Start()
SlashCmdList["REUNIONLOOT"] = Reunionloot_Client_Window_Show;
SlashCmdList["REUNIONLOOTMASTER"] = Reunionloot_Master_Window;
SlashCmdList["REUNIONLOOTMONITOR"] = Reunionloot_Monitor_Window;