local item_frame_y_offset = 0
local item_list = {}
local max_item_index = 0

local function AddItem(main_win, item_id, item_index_str, start_price, winner, status)
	local item_info = Reunionloot_GetItemInfo(item_id)
	local retry = 5
	C_Timer.NewTicker(1, function ()
		if (item_info.texture ~= nil and item_list[item_index] == nil) then
			local item_index = tonumber(item_index_str)
			item_list[item_index] = {}
			item_list[item_index].item = item_info
			item_list[item_index].current_price = start_price
			item_list[item_index].current_winner = winner
			item_list[item_index].passed = false
			if status == "0" then
				item_list[item_index].status = "bidding"
			elseif status == "1" then
				item_list[item_index].status = "boughtin"
			elseif status == "2" then
				item_list[item_index].status = "deal"
			end
			Reunionloot_SetItemList(item_list)
		end
	end, retry)
end

local function OnEvent(self, event, prefix, msg, _, _, target, ...)
	if event == "CHAT_MSG_ADDON" then
		if prefix ~= REUNIONLOOT.prefix then return end
		--print("msg: ", msg);
		--print(event, ...);
		local actions = Reunionloot_split(msg, ";")

		if actions[1] == nil then return end
		-- Refresh the list
		if actions[1] == "NewItem" then
			max_item_index = tonumber(actions[2]) 
			local action_index = 3
			C_Timer.NewTicker(REUNIONLOOT.send_gap, function()
				local data = Reunionloot_split(actions[action_index], ",")
				item_index = data[1]
				item_id = data[2]
				start_price = data[3]
				winner = data[4]
				status = data[5]
				AddItem(REUNIONLOOT.client_win, item_id, item_index, start_price, winner, status)
				action_index = action_index + 1
			end, math.ceil(#actions - 2))
		elseif actions[1] == "PassedItem" then
			for action_index = 2, #actions do
				item_list[tonumber(actions[action_index])].passed = true
			end
			Reunionloot_SetItemList(item_list)
		elseif actions[1] == "BroadcastBid" then
			local bid_index = tonumber(actions[2])
			local bid_price = tonumber(actions[3])
			local winner = actions[4]
			local item_proto  = item_list[bid_index]
			item_proto.current_price = bid_price
			item_proto.current_winner = winner
			Reunionloot_UpdateItemPrice(bid_index, bid_price, winner)
		elseif actions[1] == "ConfirmPass" then
			local item_index = actions[2]
			Reunionloot_PassItem_Client(item_index)
		elseif actions[1] == "BroadcastSetPrice" then
			local bid_index = tonumber(actions[2])
			local bid_price = tonumber(actions[3])
			local winner = actions[4]
			local item_proto  = item_list[bid_index]
			item_proto.current_price = bid_price
			item_proto.current_winner = winner
			Reunionloot_UpdateItemPrice(bid_index, bid_price, winner)
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
		elseif actions[1] == "PubConfig" then
			REUNIONLOOT.client_win.filter_frame.share_panel:Show()
		elseif actions[1] == "BroadcastDelete" then
			local index = tonumber(actions[2])
			item_list[index] = nil
			Reunionloot_DeleteItem(index)
		elseif actions[1] == "BroadcastDeleteAllDeleteAll" then
			item_list = {}
			Reunionloot_DeleteAll()
		elseif actions[1] == "BroadcastNotify" then
			SendSystemMessage(actions[2])	
		elseif actions[1] == "BoughtIn" then
			local item_index = tonumber(actions[2])
			item_list[item_index].status = "boughtin"
			Reunionloot_BoughtInItem(item_index)
			SendSystemMessage(item_list[item_index].item.link.." Bought-In.")
		elseif actions[1] == "Deal" then
			local item_index = tonumber(actions[2])
			local item_info = item_list[item_index]
			item_info.status = "deal"
			Reunionloot_DealItem(item_index)
			SendSystemMessage(item_info.item.link.." Sold to "..item_info.current_winner..
				" at "..item_info.current_price.."g! Congratulations!")
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		--print("enterring the world");
	end
end

function Reunionloot_PassItem_Client(item_index)
	local index = tonumber(item_index)
	item_list[index].passed = true
	Reunionloot_PassItem(index)
end

function Reunionloot_Client_Window_Show()
	if REUNIONLOOT.client_win == nil then
		REUNIONLOOT.client_win = Reunionloot_Main_Window(false)
		REUNIONLOOT.client_win:SetScript("OnEvent", OnEvent);
	else
		REUNIONLOOT.client_win:Show()
	end
end