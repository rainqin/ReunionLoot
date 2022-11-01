local item_list = {}
local item_index = 1
local player_name = UnitName("player")
local bidding = false

local function AddItem(item, main_win)
	if item == nil then return end
	item_list[item_index] = {}
	item_list[item_index].item_index = item_index
	item_list[item_index].item = item
	item_list[item_index].current_price = "0"
	item_list[item_index].current_winner = "No one bid"
	item_list[item_index].passed = false
	item_list[item_index].status = "bidding"
	item_list[item_index].p_list = {}
	Reunionloot_SetItemList(item_list)
	item_index = item_index + 1
end

local function RegisterClickEvent(main_win)
	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick",function(self,button)
		if IsAltKeyDown() then
			local bag,slot=self:GetParent():GetID(),self:GetID();
			local item = Reunionloot_GetItem(bag, slot)
			AddItem(item, main_win)
		end
	end)
end

local function CheckItemPassStatus(item_index)
	local index = tonumber(item_index)
	local item_info = item_list[index]
	local p_list_len = Reunionloot_tablelength(item_info.p_list)
	if p_list_len == REUNIONLOOT.raid_size then
		Reunionloot_BroadCastBoughtIn(item_index)
	elseif p_list_len == REUNIONLOOT.raid_size - 1 and item_info.current_winner ~= "No one bid" then
		Reunionloot_BroadCastDeal(item_index)
	end
end

local function GetPListPerUser()
	local p_list_per_user = {}
	for index, item_info in pairs(item_list) do
		for user, _ in pairs(item_info.p_list) do
			if p_list_per_user[user] == nil then
				p_list_per_user[user] = {}
			end
			table.insert(p_list_per_user[user], index)
		end
	end
	return p_list_per_user
end

function Reunionloot_Master_Sendout_Items(item_list)
	Reunionloot_SendOutItemsMessage(item_list)
end

function Reunionloot_Master_Restore_P()
	local p_list_per_user = GetPListPerUser()
	for user, item_index_list in pairs(p_list_per_user) do
		Reunionloot_WhisperPListPerUser(user, item_index_list)
	end
end

function Reunionloot_Master_Bid(bid_index, bid_price)
	if not bidding then
		SendSystemMessage("Bidding not started yet, please wait.")
		return
	end
	local item_index = tonumber(bid_index)
	local item_proto = item_list[item_index]
	local bid_price = tonumber(bid_price)
	if bid_price >= item_proto.current_price + REUNIONLOOT.min_bid then
		item_proto.current_price = bid_price
		item_proto.current_winner = player_name
		Reunionloot_UpdateItemPrice(item_index, bid_price, player_name)
		Reunionloot_BroadCastBidMessage(item_index, bid_price, player_name)
		CheckItemPassStatus(item_index)
	end
end

function Reunionloot_Master_Set_Price(index, price)
	local item_index = tonumber(index)
	local item_proto = item_list[item_index]
	item_proto.current_price = tonumber(price)
	item_proto.current_winner = "No one bid"
	item_proto.status = "bidding"
	item_proto.passed = false
	item_proto.p_list = {}
	Reunionloot_UpdateItemPrice(item_index, item_proto.current_price, item_proto.current_winner)
	Reunionloot_BroadCastSetPriceMessage(item_index, price)
end

function Reunionloot_Master_DeleteAll()
	item_list = {}
	item_index = 1
	bidding = false
	Reunionloot_DeleteAll()
	Reunionloot_BroadCastDeleteAll()
end

function Reunionloot_Master_Delete(index)
	local index = tonumber(index)
	item_list[index].status = "deleted"
	Reunionloot_DeleteItem(index)
	Reunionloot_BroadCastDeleteMessage(index)
	item_list[index] = nil
end

function Reunionloot_Master_Start_Bidding()
	bidding = true
	Reunionloot_BroadCastNotifyMessage("Bidding Started!")
end

function Reunionloot_Master_Pause_Bidding()
	bidding = false
	Reunionloot_BroadCastNotifyMessage("Bidding Paused! Please wait.")
end

function Reunionloot_Master_End_Bidding()
	bidding = false
	Reunionloot_BroadCastNotifyMessage("Bidding Ended! Please wait.")
	Reunionloot_BroadcastEndBidMessage(item_list)
end

function Reunionloot_Master_GetPList(index)
	if item_list[index] == nil then return end
	return item_list[index].item.link, item_list[index].p_list
end

local function OnEvent(self, event, prefix, msg, _, _, target, ...)
	if event == "CHAT_MSG_ADDON" then
		if prefix ~= REUNIONLOOT.prefix then return end
		--print("msg: ", msg);
		--print(event, ...);
		local actions = Reunionloot_split(msg, ";")
		if actions[1] == nil then return end

		-- Receive bid from client
		if actions[1] == "BidFromClient" then
			if not bidding then
				Reunionloot_BroadCastNotifyMessage("Bidding not started yet, please wait.", target)
			else
				local bid_index = tonumber(actions[2])
				local bid_price = tonumber(actions[3])
				local winner = target
				local item_proto  = item_list[bid_index]
				if  item_proto.status ~= "bidding" then
					Reunionloot_BroadCastNotifyMessage(item_proto.item.link.."has finished bidding.",  target)
				end
				local current_price = tonumber(item_proto.current_price)
				if bid_price >= current_price + REUNIONLOOT.min_bid then
					item_proto.current_price = bid_price
					item_proto.current_winner = winner
					Reunionloot_UpdateItemPrice(bid_index, bid_price, winner)
					Reunionloot_BroadCastBidMessage(bid_index, bid_price, winner)
					CheckItemPassStatus(bid_index)
				end
			end
		elseif actions[1] == "SetConfig" then
			REUNIONLOOT.raid_size = tonumber(actions[2])
			REUNIONLOOT.cut_ratio.guild = tonumber(actions[3])
			REUNIONLOOT.cut_ratio.bonus1 = tonumber(actions[4])
			REUNIONLOOT.cut_ratio.people1 = tonumber(actions[5])
			REUNIONLOOT.cut_ratio.bonus2 = tonumber(actions[6])
			REUNIONLOOT.cut_ratio.people2 = tonumber(actions[7])
			REUNIONLOOT.cut_ratio.bonus3 = tonumber(actions[8])
			REUNIONLOOT.cut_ratio.people3 = tonumber(actions[9])
			REUNIONLOOT.cut_ratio.full_share = tonumber(actions[10])
			REUNIONLOOT.cut_ratio.half_share = tonumber(actions[11])
			Reunionloot_CalculateCut()
		elseif actions[1] == "BroadcastNotify" then
			SendSystemMessage(actions[2])
		elseif actions[1] == "PassFromClient" then
			if not bidding then
				Reunionloot_BroadCastNotifyMessage("Bidding not started yet, please wait.", target)
			else 
				local item_index = tonumber(actions[2])
				local player = target
				item_list[item_index].p_list[player] = true
				Reunionloot_ConfirmPass(item_index, player)
				CheckItemPassStatus(item_index)
			end
		elseif actions[1] == "BoughtIn" then
			for i = 2, #actions do
				local item_index = tonumber(actions[i])
				if item_list[item_index].status ~= "boughtin" then
					SendSystemMessage(item_list[item_index].item.link.." Bought-In.")
					item_list[item_index].status = "boughtin"
					Reunionloot_BoughtInItem(item_index)
				end
			end
		elseif actions[1] == "Deal" then
			for i = 2, #actions do
				local item_index = tonumber(actions[i])
				local item_info = item_list[item_index]
				if item_info.status ~= "deal" then
					SendSystemMessage(item_info.item.link.." Sold to "..item_info.current_winner..
					" at "..item_info.current_price.."g! Congratulations!")
					item_info.status = "deal"
					Reunionloot_DealItem(item_index)
				end
			end
		elseif actions[1] == "ConfirmPing" then
			local version = actions[2]
			local player = target
			Reunionloot_Master_Receive_Ping(version, player)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		--print("enterring the world");
	end
end

function Reunionloot_Master_Window()
	if REUNIONLOOT.master_win == nil then
		REUNIONLOOT.master_win = Reunionloot_Main_Window(true)
		RegisterClickEvent(REUNIONLOOT.master_win)
		REUNIONLOOT.master_win:SetScript("OnEvent", OnEvent);
	else
		REUNIONLOOT.master_win:Show()
	end
end

function Reunionloot_Monitor_Window()
	if REUNIONLOOT.monitor_win == nil then
		REUNIONLOOT.monitor_win = Reunionloot_Master_Monitor_Window()
	end
	REUNIONLOOT.monitor_win:Show()
end

function Reunionloot_PassItem_Master(item_index)
	if not bidding then
		SendSystemMessage("Bidding not started yet, please wait.")
		return
	end
	local index = tonumber(item_index)
	item_list[index].passed = true
	item_list[index].p_list[player_name] = "true"
	Reunionloot_PassItem(index)
	CheckItemPassStatus(item_index)
end