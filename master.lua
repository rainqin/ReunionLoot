local item_list = {}
local item_index = 1
local item_frame_y_offset = 0
local player_name = UnitName("player")
local bidding = false

local function AddItem(item, main_win)
	local item_frames, item_data = Reunionloot_CreateItemFrame_Master(main_win.scrollchild, item_frame_y_offset, item.texture, item.link, item_index)
	local item_proto = {
		item = item,
		frames = item_frames,
		data = item_data
	}
	item_list[item_index] = item_proto

	item_index = item_index + 1
	item_frame_y_offset = item_frame_y_offset - 55
	main_win.scrollchild:SetSize(main_win.scrollframe:GetWidth(), -item_frame_y_offset + 55);
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

function Reunionloot_Master_Sendout_Items()
	Reunionloot_SendOutItemsMessage(item_list)
end

function Reunionloot_Master_Bid(bid_index)
	if not bidding then
		SendSystemMessage("Bidding not started yet, please wait.")
		return
	end
	local item_proto = item_list[tonumber(bid_index)]
	local current_price = tonumber(item_proto.data.current_price:GetText())
	local bid_price = tonumber(item_proto.data.input_price:GetText())
	if bid_price >= current_price + REUNIONLOOT.min_bid then
		item_proto.data.current_price:SetText(bid_price)
		item_proto.data.current_winner:SetText(player_name)
		Reunionloot_BroadCastBidMessage(bid_index, bid_price, player_name)
	end
end

function Reunionloot_Master_Set_Price(index)
	local item_proto = item_list[tonumber(index)]
	local current_price = tonumber(item_proto.data.current_price:GetText())
	item_proto.data.current_winner:SetText("No one bid")
	Reunionloot_BroadCastSetPriceMessage(index, current_price)
end

function Reunionloot_Master_Delete(index)
	local index = tonumber(index)
	Reunion_Clear_Master_Item(item_list[index].frames)
	item_list[index] = nil
	item_frame_y_offset = 0
	for i = 0, item_index - 1 do
		if item_list[i] ~= nil then
			local item_root = item_list[i].frames.item_root
			local _, _, point, x_offset, y_offset = item_root:GetPoint()
			item_root:SetPoint(point, x_offset, item_frame_y_offset)
			item_frame_y_offset = item_frame_y_offset - 55
		end
	end
	REUNIONLOOT.master_win.scrollchild:SetHeight(REUNIONLOOT.master_win.scrollchild:GetHeight() - 55);
	Reunionloot_BroadCastDeleteMessage(index)
end

function Reunionloot_Master_Start_Bidding()
	bidding = true
	Reunionloot_BroadCastNotifyMessage("Bidding Started!")
end

function Reunionloot_Master_End_Bidding()
	bidding = false
	Reunionloot_BroadCastNotifyMessage("Bidding Paused! Please wait.")
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

				local current_price = tonumber(item_proto.data.current_price:GetText())
				if bid_price >= current_price + REUNIONLOOT.min_bid then
					item_proto.data.current_price:SetText(bid_price)
					item_proto.data.current_winner:SetText(winner)
					Reunionloot_BroadCastBidMessage(bid_index, bid_price, winner)
				end
			end
		elseif actions[1] == "BroadcastNotify" then
			SendSystemMessage(actions[2])
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		--print("enterring the world");
	end
end

function Reunionloot_Master_Window()
	if REUNIONLOOT.master_win == nil then
		REUNIONLOOT.master_win = Reunionloot_Main_Window(true)
		Reunionloot_AddScrollFrame(REUNIONLOOT.master_win, "master")
		RegisterClickEvent(REUNIONLOOT.master_win)

	else
		REUNIONLOOT.master_win:Show()
	end
	REUNIONLOOT.master_win:SetScript("OnEvent", OnEvent);
end