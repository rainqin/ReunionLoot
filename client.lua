local item_frame_y_offset = 0
local item_list = {}
local max_item_index = 0

local function AddItem(main_win, item_id, item_index, start_price)
	local item_info = Reunionloot_GetItemInfo(item_id)
	local item_frames, item_data = Reunionloot_CreateItemFrame_Client(main_win.scrollchild, item_frame_y_offset, item_info.texture, item_info.link, item_index, start_price, winner)
	local item_proto = {
		item = item_info,
		frames = item_frames,
		data = item_data
	}
	local index = tonumber(item_index)
	item_list[index] = item_proto
	if index > max_item_index then 
		max_item_index = index 
	end

	item_frame_y_offset = item_frame_y_offset - 55
	main_win.scrollchild:SetSize(main_win.scrollframe:GetWidth(), -item_frame_y_offset + 55);
end

local function OnEvent(self, event, prefix, msg, _, _, target, ...)
	if event == "CHAT_MSG_ADDON" then
		if prefix ~= REUNIONLOOT.prefix then return end
		--print("msg: ", msg);
		--print(event, ...);
		local actions = Reunionloot_split(msg, ";")

		if actions[1] == nil then return end
		-- Refresh the list
		if actions[1] == "Refresh" then
			REUNIONLOOT.client_win.notification:Hide()
			item_frame_y_offset = 0
			Reunionloot_Clear_Items()
			for i = 2, #actions do
				data = Reunionloot_split(actions[i], ",")
				item_index = data[1]
				item_id = data[2]
				start_price = data[3]
				winner = data[4]
				AddItem(REUNIONLOOT.client_win, item_id, item_index, start_price, winner)
			end
		elseif actions[1] == "BroadcastBid" then
			local bid_index = tonumber(actions[2])
			local bid_price = tonumber(actions[3])
			local winner = actions[4]
			local item_proto  = item_list[bid_index]
			item_proto.data.current_price:SetText(bid_price)
			item_proto.data.current_winner:SetText(winner)
		elseif actions[1] == "BroadcastSetPrice" then
			local bid_index = tonumber(actions[2])
			local bid_price = tonumber(actions[3])
			local winner = actions[4]
			local item_proto  = item_list[bid_index]
			item_proto.data.current_price:SetText(bid_price)
			item_proto.data.current_winner:SetText(winner)
		elseif actions[1] == "BroadcastDelete" then
			local index = tonumber(actions[2])
			Reunion_Clear_Client_Item(item_list[index].frames)
			item_list[index] = nil
			item_frame_y_offset = 0
			for i = 0, max_item_index - 1 do
				if item_list[i] ~= nil then
					local item_root = item_list[i].frames.item_root
					local _, _, point, x_offset, y_offset = item_root:GetPoint()
					item_root:SetPoint(point, x_offset, item_frame_y_offset)
					item_frame_y_offset = item_frame_y_offset - 55
				end
			end
			REUNIONLOOT.client_win.scrollchild:SetHeight(REUNIONLOOT.client_win.scrollchild:GetHeight() - 55);
		elseif actions[1] == "BroadcastNotify" then
			SendSystemMessage(actions[2])
		end

	elseif event == "PLAYER_ENTERING_WORLD" then
		--print("enterring the world");
	end
end

function Reunionloot_Client_Window()
	if REUNIONLOOT.client_win == nil then
		REUNIONLOOT.client_win = Reunionloot_Main_Window(false)
		Reunionloot_AddScrollFrame(REUNIONLOOT.client_win, "client")
	else
		REUNIONLOOT.client_win:Show()
	end
	REUNIONLOOT.client_win:SetScript("OnEvent", OnEvent);
end