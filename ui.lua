
local backdrop_pool = CreateFramePool("Frame", nil, "BackdropTemplate")
local blank_pool = CreateFramePool("Frame")
local item_link_pool = CreateFramePool("Frame")
local current_price_pool = CreateFramePool("Frame")
local current_winner_pool = CreateFramePool("Frame")
local number_input_pool = CreateFramePool("EditBox")
local button_pool = CreateFramePool("Button", nil, "UIPanelButtonTemplate")
local item_list = {}
local page_number = 1
local max_page_number = 1
local Window = {}
local carry_on_total_gold = 0

local current_filter = Reunionloot_FilterNotPassed

function Reunionloot_CreateItemFrame_Client(parent, y_offset)
	local item_root = backdrop_pool:Acquire()
	item_root:SetParent(parent)
	item_root:SetPoint("TOP", 0, y_offset)
	item_root:SetSize(530, 40)
	item_root:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})

	local item_index = blank_pool:Acquire()
	item_index:SetParent(item_root)
	item_index:SetPoint("LEFT", -10, 0)
	item_index:SetSize(30, 30)
	item_index.text = item_index:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	item_index:Hide()

	local item_texture = backdrop_pool:Acquire()
	item_texture:SetParent(item_root)
	item_texture:SetPoint("LEFT", 10, 0)
	item_texture:SetSize(30, 30)
	item_texture:Show()

	local item_link = item_link_pool:Acquire()
	item_link:SetParent(item_root)
	item_link:SetPoint("LEFT", 53, 0)
	item_link:SetSize(120, 30)
	item_link.text = item_link.text or item_link:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	item_link.text:SetPoint("LEFT")
	item_link:Show()

	item_texture:HookScript("OnEnter", function()
	  if (item_link and item_link.text:GetText() ~= nil) then
	    GameTooltip:SetOwner(item_texture, "ANCHOR_BOTTOMLEFT")
	    GameTooltip:SetHyperlink(item_link.text:GetText())
	  end
	end)
	item_texture:HookScript("OnLeave", function()
	  GameTooltip:Hide()
	end)

	local current_price = blank_pool:Acquire()
	current_price:SetParent(item_root)
	current_price:SetPoint("LEFT", 200, 0)
	current_price:SetSize(80, 30)
	current_price.text = current_price.text or current_price:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	current_price.text:SetPoint("LEFT")
	current_price.text:SetText("0")
	current_price:Show()

	local current_winner = blank_pool:Acquire()
	current_winner:SetParent(item_root)
	current_winner:SetPoint("LEFT", 280, 0)
	current_winner:SetSize(80, 30)
	current_winner.text = current_winner.text or current_winner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	current_winner.text:SetPoint("LEFT")
	current_winner.text:SetText("No one bid")
	current_winner:Show()

	local input_price_border = backdrop_pool:Acquire()
	input_price_border:SetParent(item_root)
	input_price_border:SetPoint("LEFT", 365, 0)
	input_price_border:SetSize(80, 26)
	input_price_border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	input_price_border:Show()

	local input_price = number_input_pool:Acquire()
	input_price:SetParent(item_root)
	input_price:SetPoint("LEFT", 370, 0)
	input_price:SetSize(70, 30)
	input_price:SetMultiLine(false)
    input_price:SetAutoFocus(false)
    input_price:SetFontObject("ChatFontNormal")
    input_price:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	input_price:SetNumeric(true)
	input_price:SetText("0")
	input_price:Show()

	local bid_button = button_pool:Acquire()
	bid_button:SetParent(item_root)
	bid_button:SetPoint("LEFT", 445, 0)
	bid_button:SetSize(50, 30)
	bid_button:SetText("Bid")
	bid_button:SetScript("OnClick", function(self)
		local bid_price = tonumber(input_price:GetText())
		local min_price = tonumber(current_price.text:GetText()) + REUNIONLOOT.min_bid
		if (bid_price < min_price) then
			SendSystemMessage("Bid price must be at least "..min_price)
		else
			Reunionloot_ReportBidMessage(item_index.text:GetText(), bid_price)
		end
	end)
	bid_button:Show()

	local pass_button = button_pool:Acquire()
	pass_button:SetParent(item_root)
	pass_button:SetPoint("LEFT", 495, 0)
	pass_button:SetSize(30, 30)
	pass_button:SetText("P")
	pass_button:SetScript("OnClick", function(self)
		Reunionloot_ReportPass(item_index.text:GetText())
	end)
	pass_button:Show()

	return {item_root = item_root, item_index = item_index.text, item_texture = item_texture, item_link = item_link.text,
		current_price = current_price.text, current_winner = current_winner.text, input_price = input_price, bid_buttons = {bid = bid_button, pass = pass_button}}
end

local function Reunionloot_CreateItemFrame_Master(parent, y_offset)
	local item_root = backdrop_pool:Acquire()
	item_root:SetParent(parent)
	item_root:SetPoint("TOP", 0, y_offset)
	item_root:SetSize(610, 40)
	item_root:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})

	local item_index = blank_pool:Acquire()
	item_index:SetParent(item_root)
	item_index:SetPoint("LEFT", -10, 0)
	item_index:SetSize(30, 30)
	item_index.text = item_index:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	item_index:Hide()

	local item_texture = backdrop_pool:Acquire()
	item_texture:SetParent(item_root)
	item_texture:SetPoint("LEFT", 10, 0)
	item_texture:SetSize(30, 30)
	item_texture:Show()

	local item_link = item_link_pool:Acquire()
	item_link:SetParent(item_root)
	item_link:SetPoint("LEFT", 53, 0)
	item_link:SetSize(120, 30)
	item_link.text = item_link.text or item_link:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	item_link.text:SetPoint("LEFT")
	item_link:Show()

	item_texture:HookScript("OnEnter", function()
	  if (item_link and item_link.text:GetText() ~= nil) then
	    GameTooltip:SetOwner(item_texture, "ANCHOR_BOTTOMLEFT")
	    GameTooltip:SetHyperlink(item_link.text:GetText())
	  end
	end)
	item_texture:HookScript("OnLeave", function()
	  GameTooltip:Hide()
	end)

	local current_price_border = backdrop_pool:Acquire()
	current_price_border:SetParent(item_root)
	current_price_border:SetPoint("LEFT", 195, 0)
	current_price_border:SetSize(80, 26)
	current_price_border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	current_price_border:Show()

	local current_price = number_input_pool:Acquire()
	current_price:SetParent(item_root)
	current_price:SetPoint("LEFT", 200, 0)
	current_price:SetSize(70, 30)
	current_price:SetMultiLine(false)
    current_price:SetAutoFocus(false)
    current_price:SetFontObject("ChatFontNormal")
    current_price:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	current_price:SetNumeric(true)
	current_price:SetText("0")
	current_price:Show()

	local current_winner = blank_pool:Acquire()
	current_winner:SetParent(item_root)
	current_winner:SetPoint("LEFT", 280, 0)
	current_winner:SetSize(80, 30)
	current_winner.text = current_winner.text or current_winner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	current_winner.text:SetPoint("LEFT")
	current_winner.text:SetMaxLines(2)
	current_winner.text:SetWordWrap(true)
	current_winner.text:SetNonSpaceWrap(true)
	current_winner.text:SetText("No one bid")
	current_winner:Show()

	local input_price_border = backdrop_pool:Acquire()
	input_price_border:SetParent(item_root)
	input_price_border:SetPoint("LEFT", 365, 0)
	input_price_border:SetSize(80, 26)
	input_price_border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	input_price_border:Show()

	local input_price = number_input_pool:Acquire()
	input_price:SetParent(item_root)
	input_price:SetPoint("LEFT", 370, 0)
	input_price:SetSize(70, 30)
	input_price:SetMultiLine(false)
    input_price:SetAutoFocus(false)
    input_price:SetFontObject("ChatFontNormal")
    input_price:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	input_price:SetNumeric(true)
	input_price:SetText("0")
	input_price:Show()

	local bid_button = button_pool:Acquire()
	bid_button:SetParent(item_root)
	bid_button:SetPoint("LEFT", 445, 0)
	bid_button:SetSize(50, 30)
	bid_button:SetText("Bid")
	bid_button:SetScript("OnClick", function(self)
		if (tonumber(input_price:GetText()) < tonumber(current_price:GetText())) then
			SendSystemMessage("lower than current price")
		else
			Reunionloot_Master_Bid(item_index.text:GetText(), input_price:GetText())
		end
	end)
	bid_button:Show()

	local pass_button = button_pool:Acquire()
	pass_button:SetParent(item_root)
	pass_button:SetPoint("LEFT", 495, 0)
	pass_button:SetSize(30, 30)
	pass_button:SetText("P")
	pass_button:SetScript("OnClick", function(self)
		Reunionloot_PassItem_Master(item_index.text:GetText())
	end)
	pass_button:Show()

	local set_current_price_button = button_pool:Acquire()
	set_current_price_button:SetParent(item_root)
	set_current_price_button:SetPoint("LEFT", 525, 0)
	set_current_price_button:SetSize(50, 30)
	set_current_price_button:SetText("Set")
	set_current_price_button:SetScript("OnClick", function(self)
		Reunionloot_Master_Set_Price(item_index.text:GetText(), current_price:GetText())
	end)
	set_current_price_button:Show()

	local delete_button = button_pool:Acquire()
	delete_button:SetParent(item_root)
	delete_button:SetPoint("LEFT", 575, 0)
	delete_button:SetSize(30, 30)
	delete_button:SetText("X")
	delete_button:SetScript("OnClick", function(self)
		Reunionloot_Master_Delete(item_index.text:GetText())
	end)
	delete_button:Show()

	return {item_root = item_root, item_index = item_index.text, item_texture = item_texture, item_link = item_link.text,
		current_price = current_price, current_winner = current_winner.text, input_price = input_price, bid_buttons = {bid = bid_button, pass = pass_button}}
end

local function UpdatePageButton()
	if page_number == 1 then
		Window.win.bid_frame.prev_page_button:Disable()
	else
		Window.win.bid_frame.prev_page_button:Enable()
	end
	if page_number == max_page_number then
		Window.win.bid_frame.next_page_button:Disable()
	else
		Window.win.bid_frame.next_page_button:Enable()
	end
	Window.win.bid_frame.page_label.text:SetText(page_number)
end

local function Master_Config_Item(parent, y_offset, name, value)
	local config_item_root = blank_pool:Acquire()
	parent.config_item_root = config_item_root
	config_item_root:SetParent(parent)
	config_item_root:SetPoint("TOP", 0, y_offset)
	config_item_root:SetSize(160, 30)
	config_item_root:Show()

	config_item_root.item_label = blank_pool:Acquire()
	config_item_root.item_label:SetParent(config_item_root)
	config_item_root.item_label:SetPoint("LEFT", 10, 0)
	config_item_root.item_label:SetSize(100, 30)
	config_item_root.item_label.text = config_item_root.item_label:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	config_item_root.item_label.text:SetPoint("LEFT")
	config_item_root.item_label.text:SetText(name)
	config_item_root.item_label:Show()

	local config_item_border = backdrop_pool:Acquire()
	config_item_root.border = config_item_border
	config_item_border:SetParent(config_item_root)
	config_item_border:SetPoint("RIGHT", -3, 0)
	config_item_border:SetSize(50, 30)
	config_item_border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	config_item_border:Show()

	local input = number_input_pool:Acquire()
	config_item_root.value = input
	input:SetParent(config_item_border)
	input:SetPoint("CENTER", 0, 0)
	input:SetSize(36, 30)
	input:SetFontObject("ChatFontNormal")
	input:SetNumeric(false)
	input:SetText(value)
    input:SetAutoFocus(false)
	input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	input:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	input:Show()
	return config_item_root
end

local function Reunionloot_Master_Config(parent)
	local root = backdrop_pool:Acquire()
	parent.config_frame = root
	root:SetParent(parent)
	root:SetPoint("TOPLEFT", 5, -25)
	root:SetSize(160, 450)
	root:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	root:Show()

	root.config_label = blank_pool:Acquire()
	root.config_label:SetParent(root)
	root.config_label:SetPoint("TOP", 0, 0)
	root.config_label:SetSize(50, 30)
	root.config_label.text = root.config_label:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	root.config_label.text:SetPoint("CENTER")
	root.config_label.text:SetText("Config")
	root.config_label:Show()

	root.raid_size = Master_Config_Item(root, -32, "Raid Size", REUNIONLOOT.raid_size)
	root.guild_cut = Master_Config_Item(root, -64, "Guild Cut %", REUNIONLOOT.cut_ratio.guild)
	root.bonus_1_ratio = Master_Config_Item(root, -96, "Bonus 1 %", REUNIONLOOT.cut_ratio.bonus1)
	root.bonus_1_num = Master_Config_Item(root, -128, "Bonus 1 num", REUNIONLOOT.cut_ratio.people1)
	root.bonus_2_ratio = Master_Config_Item(root, -160, "Bonus 2 %", REUNIONLOOT.cut_ratio.bonus2)
	root.bonus_2_num = Master_Config_Item(root, -192, "Bonus 2 num", REUNIONLOOT.cut_ratio.people2)
	root.bonus_3_ratio = Master_Config_Item(root, -224, "Bonus 3 %", REUNIONLOOT.cut_ratio.bonus3)
	root.bonus_3_num = Master_Config_Item(root, -256, "Bonus 3 num", REUNIONLOOT.cut_ratio.people3)
	root.full_share = Master_Config_Item(root, -288, "Full Share num", REUNIONLOOT.cut_ratio.full_share)
	root.half_share = Master_Config_Item(root, -320, "Half Share num", REUNIONLOOT.cut_ratio.half_share)

	local set_config_button = button_pool:Acquire()
	set_config_button:SetParent(root)
	set_config_button:SetPoint("BOTTOMLEFT", 0, 5)
	set_config_button:SetSize(80, 30)
	set_config_button:SetText("Set")
	set_config_button:SetScript("OnClick", function(self)
		SendSystemMessage("New config is set.")
		Reunionloot_BroadcastSetConfig({root.raid_size.value:GetText(),
										root.guild_cut.value:GetText(), 
										root.bonus_1_ratio.value:GetText(),
										root.bonus_1_num.value:GetText(), 
										root.bonus_2_ratio.value:GetText(), 
										root.bonus_2_num.value:GetText(), 
										root.bonus_3_ratio.value:GetText(), 
										root.bonus_3_num.value:GetText(), 
										root.full_share.value:GetText(), 
										root.half_share.value:GetText()})
	end)
	set_config_button:Show()

	local pub_config_button = button_pool:Acquire()
	pub_config_button:SetParent(root)
	pub_config_button:SetPoint("BOTTOMRIGHT", 0, 5)
	pub_config_button:SetSize(80, 30)
	pub_config_button:SetText("Publish")
	pub_config_button:SetScript("OnClick", function(self)
		Reunionloot_BroadcastPublishConfig()
	end)
	pub_config_button:Show()
end

local function Master_Readonly_Item(parent, name, value)
	local root = blank_pool:Acquire()
	root:SetParent(parent)
	root:SetSize(140, 30)
	root:Show()

	root.name = blank_pool:Acquire()
	root.name:SetParent(root)
	root.name:SetPoint("LEFT", 0, 0)
	root.name:SetSize(100, 30)
	root.name.text = root.name:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	root.name.text:SetPoint("LEFT")
	root.name.text:SetText(name)
	root.name:Show()

	root.value = blank_pool:Acquire()
	root.value:SetParent(root)
	root.value:SetPoint("RIGHT", 5, 0)
	root.value:SetSize(100, 30)
	root.value.text = root.value:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	root.value.text:SetPoint("RIGHT")
	root.value.text:SetText(value)
	root.value:Show()
	return root
end


local function Reunionloot_FilterFrame(parent)
	parent.filter_frame = backdrop_pool:Acquire()
	parent.filter_frame:SetParent(parent)
	parent.filter_frame:SetPoint("TOPLEFT", 5, -25)
	parent.filter_frame:SetSize(160, 450)
	parent.filter_frame:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	parent.filter_frame:Show()

	local filter_all_button = button_pool:Acquire()
	filter_all_button:SetParent(parent.filter_frame)
	filter_all_button:SetPoint("TOPRIGHT", -5, -5)
	filter_all_button:SetSize(150, 30)
	filter_all_button:SetText("All Items")
	filter_all_button:SetScript("OnClick", function(self)
		current_filter = Reunionloot_FilterAll
		page_number = 1
		Window:RefreshItemList(page_number)
		UpdatePageButton()
	end)
	filter_all_button:Show()

	local filter_not_passed_button = button_pool:Acquire()
	filter_not_passed_button:SetParent(parent.filter_frame)
	filter_not_passed_button:SetPoint("TOPRIGHT", -5, -35)
	filter_not_passed_button:SetSize(150, 30)
	filter_not_passed_button:SetText("Not Passed Items")
	filter_not_passed_button:SetScript("OnClick", function(self)
		current_filter = Reunionloot_FilterNotPassed
		page_number = 1
		Window:RefreshItemList(page_number)
		UpdatePageButton()
	end)
	filter_not_passed_button:Show()

	local filter_bought_in_button = button_pool:Acquire()
	filter_bought_in_button:SetParent(parent.filter_frame)
	filter_bought_in_button:SetPoint("TOPRIGHT", -5, -65)
	filter_bought_in_button:SetSize(150, 30)
	filter_bought_in_button:SetText("Bought-in Items")
	filter_bought_in_button:SetScript("OnClick", function(self)
		current_filter = Reunionloot_FilterBoughtIn
		page_number = 1
		Window:RefreshItemList(page_number)
		UpdatePageButton()
	end)
	filter_bought_in_button:Show()

	local filter_deal_button = button_pool:Acquire()
	filter_deal_button:SetParent(parent.filter_frame)
	filter_deal_button:SetPoint("TOPRIGHT", -5, -95)
	filter_deal_button:SetSize(150, 30)
	filter_deal_button:SetText("Deal Items")
	filter_deal_button:SetScript("OnClick", function(self)
		current_filter = Reunionloot_FilterDeal
		page_number = 1
		Window:RefreshItemList(page_number)
		UpdatePageButton()
	end)
	filter_deal_button:Show()

	parent.filter_frame.total_gold = Master_Readonly_Item(parent.filter_frame, "Total Gold", 0)
	parent.filter_frame.total_gold:SetPoint("BOTTOM", 0, 165)
	parent.filter_frame.guild_cut = Master_Readonly_Item(parent.filter_frame, "Guild Cut", 0)
	parent.filter_frame.guild_cut:SetPoint("BOTTOM", 0, 145)
	parent.filter_frame.bonus_1 = Master_Readonly_Item(parent.filter_frame, "Bonus 1", 0)
	parent.filter_frame.bonus_1:SetPoint("BOTTOM", 0, 125)
	parent.filter_frame.bonus_2 = Master_Readonly_Item(parent.filter_frame, "Bonus 2", 0)
	parent.filter_frame.bonus_2:SetPoint("BOTTOM", 0, 105)
	parent.filter_frame.bonus_3 = Master_Readonly_Item(parent.filter_frame, "Bonus 3", 0)
	parent.filter_frame.bonus_3:SetPoint("BOTTOM", 0, 85)

	parent.filter_frame.share_panel = blank_pool:Acquire()
	parent.filter_frame.share_panel:SetParent(parent.filter_frame)
	parent.filter_frame.share_panel:SetPoint("BOTTOM", 0, 0)
	parent.filter_frame.share_panel:SetSize(160, 80)
	parent.filter_frame.share_panel:Hide()

	parent.filter_frame.full_share = Master_Readonly_Item(parent.filter_frame.share_panel, "Full Share", 0)
	parent.filter_frame.full_share:SetPoint("BOTTOM", 0, 65)
	parent.filter_frame.half_share = Master_Readonly_Item(parent.filter_frame.share_panel, "Half Share", 0)
	parent.filter_frame.half_share:SetPoint("BOTTOM", 0, 45)
	parent.filter_frame.share_5 = Master_Readonly_Item(parent.filter_frame.share_panel, "5 Shares", 0)
	parent.filter_frame.share_5:SetPoint("BOTTOM", 0, 25)
	parent.filter_frame.share_4 = Master_Readonly_Item(parent.filter_frame.share_panel, "4 Shares", 0)
	parent.filter_frame.share_4:SetPoint("BOTTOM", 0, 5)
end

local function Reunionloot_BidFrame(parent, is_master)
	parent.bid_frame = backdrop_pool:Acquire()
	parent.bid_frame:SetParent(parent)
	parent.bid_frame:SetPoint("TOPRIGHT", -5, -25)
	if is_master then
		parent.bid_frame:SetSize(620, 450)
	else 
		parent.bid_frame:SetSize(535, 450)
	end
	parent.bid_frame:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	parent.bid_frame:Show()

	parent.bid_frame.item_slot = {}
	local y_offset = -5;
	for i = 1, REUNIONLOOT.item_per_page do
		if (is_master) then
			parent.bid_frame.item_slot[i] = Reunionloot_CreateItemFrame_Master(parent.bid_frame, y_offset)
		else 
			parent.bid_frame.item_slot[i] = Reunionloot_CreateItemFrame_Client(parent.bid_frame, y_offset)
		end
		y_offset = y_offset - 40
	end

	local bottom_frame = blank_pool:Acquire()
	bottom_frame:SetParent(parent.bid_frame)
	bottom_frame:SetSize(200, 30)
	bottom_frame:SetPoint("BOTTOM", 0, -30)
	bottom_frame:Show()

	parent.bid_frame.prev_page_button = CreateFrame("Button", nil, bottom_frame)
	parent.bid_frame.prev_page_button:SetSize(30, 30)
	parent.bid_frame.prev_page_button:SetPoint("LEFT", 0, 0)
	parent.bid_frame.prev_page_button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	parent.bid_frame.prev_page_button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	parent.bid_frame.prev_page_button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	parent.bid_frame.prev_page_button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

	parent.bid_frame.page_label = blank_pool:Acquire()
	parent.bid_frame.page_label:SetParent(bottom_frame)
	parent.bid_frame.page_label:SetPoint("CENTER", 0, 0)
	parent.bid_frame.page_label:SetSize(100, 30)
	parent.bid_frame.page_label.text = parent.bid_frame.page_label.text or parent.bid_frame.page_label:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	parent.bid_frame.page_label.text:SetPoint("CENTER")
	parent.bid_frame.page_label.text:SetText("1")
	parent.bid_frame.page_label:Show()

	parent.bid_frame.next_page_button = CreateFrame("Button", nil, bottom_frame)
	parent.bid_frame.next_page_button:SetSize(30, 30)
	parent.bid_frame.next_page_button:SetPoint("RIGHT", 0, 0)
	parent.bid_frame.next_page_button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	parent.bid_frame.next_page_button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	parent.bid_frame.next_page_button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	parent.bid_frame.next_page_button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

	parent.bid_frame.prev_page_button:SetScript("OnClick", function(self)
		page_number = page_number - 1
		Window:RefreshItemList(page_number)
		UpdatePageButton()
	end)
	parent.bid_frame.next_page_button:SetScript("OnClick", function(self)
		page_number = page_number + 1
		Window:RefreshItemList(page_number)
		UpdatePageButton()
	end)
end

function Reunionloot_AddScrollFrame(win, scroll_name)
	win.scrollzone = win.scrollzone or CreateFrame("Frame", nil, win);
	win.scrollzone:SetPoint("TOP", 0, -30)
	win.scrollzone:SetSize(win:GetWidth(), 500)
	-- now create the template Scroll Frame (this frame must be given a name so that it can be looked up via the _G function (you'll see why later on in the code)
	win.scrollframe = win.scrollframe or CreateFrame("ScrollFrame", scroll_name, win.scrollzone, "UIPanelScrollFrameTemplate");
	win.scrollframe:SetPoint("TOP", 0, 200);
	-- create the standard frame which will eventually become the Scroll Frame's scrollchild
	-- importantly, each Scroll Frame can have only ONE scrollchild
	win.scrollchild = win.scrollchild or CreateFrame("Frame"); -- not sure what happens if you do, but to be safe, don't parent this yet (or do anything with it)
	 
	-- define the scrollframe's objects/elements:
	local scrollbarName = win.scrollframe:GetName()
	win.scrollbar = _G[scrollbarName.."ScrollBar"];
	win.scrollupbutton = _G[scrollbarName.."ScrollBarScrollUpButton"];
	win.scrolldownbutton = _G[scrollbarName.."ScrollBarScrollDownButton"];
	 
	-- all of these objects will need to be re-anchored (if not, they appear outside the frame and about 30 pixels too "high")
	win.scrollupbutton:ClearAllPoints();
	win.scrollupbutton:SetPoint("TOPRIGHT", win.scrollframe, "TOPRIGHT", -5, 0);
 
	win.scrolldownbutton:ClearAllPoints();
	win.scrolldownbutton:SetPoint("BOTTOMRIGHT", win.scrollframe, "BOTTOMRIGHT", -5, 2);
	 
	win.scrollbar:ClearAllPoints();
	win.scrollbar:SetPoint("TOP", win.scrollupbutton, "BOTTOM", 0, -2);
	win.scrollbar:SetPoint("BOTTOM", win.scrolldownbutton, "TOP", 0, 2);
	 
	-- now officially set the scrollchild as your Scroll Frame's scrollchild (this also parents win.scrollchild to win.scrollframe)
	-- IT IS IMPORTANT TO ENSURE THAT YOU SET THE SCROLLCHILD'S SIZE AFTER REGISTERING IT AS A SCROLLCHILD:
	win.scrollframe:SetScrollChild(win.scrollchild);
	win.scrollchild:SetPoint("TOP", 0, -200);
	 
	-- set win.scrollframe points to the first frame that you created (in this case, win)
	win.scrollframe:SetAllPoints(win.scrollzone);
end

function Reunionloot_Main_Window(is_master)
	local win = Window.win or CreateFrame("Frame","Reunion Loot",UIParent, "BasicFrameTemplateWithInset");
	win:SetFrameStrata("BACKGROUND")
	win:SetMovable(true)
	win:EnableMouse(true)
	win:RegisterForDrag("LeftButton")
	win:SetScript("OnDragStart", win.StartMoving)
	win:SetFrameStrata("HIGH")
	win:SetScript("OnDragStop", win.StopMovingOrSizing)
	
	-- Create the title	
	win.title = win.title or CreateFrame("Frame")
	win.title:SetParent(win)
	win.title:SetPoint("TOP", 0, 10)
	win.title:SetSize(100, 40)
	local text = win.title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("CENTER")
	text:SetText("Reunion Loot - V"..REUNIONLOOT.version)
	win.title:Show()

	win:RegisterEvent("CHAT_MSG_ADDON");
	win:RegisterEvent("PLAYER_ENTERING_WORLD");

	if is_master then
		win:SetSize(950, 600)
		Reunionloot_Master_Config(win)
	else
		win:SetSize(700, 520)
	end
	Reunionloot_BidFrame(win, is_master)
	Reunionloot_FilterFrame(win)
	win:SetPoint("CENTER", UIParent, "CENTER");

	if is_master then
		win.filter_frame:SetPoint("TOPLEFT", 165, -25)
		win.filter_frame.share_panel:Show()

		local send_out_list_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		send_out_list_button:SetPoint("BOTTOM", -200, 20)
		send_out_list_button:SetSize(100, 40)
		send_out_list_button:SetText("Open Client")
		send_out_list_button:SetScript("OnClick", function(self)
			Reunionloot_BroadCastStartClient()
		end)
		send_out_list_button:Show()
		local send_out_list_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		send_out_list_button:SetPoint("BOTTOM", -100, 20)
		send_out_list_button:SetSize(100, 40)
		send_out_list_button:SetText("Send Out")
		send_out_list_button:SetScript("OnClick", function(self)
			Reunionloot_Master_Sendout_Items(item_list)
		end)
		send_out_list_button:Show()
		local restore_p_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		restore_p_button:SetPoint("BOTTOM", 0, 20)
		restore_p_button:SetSize(100, 40)
		restore_p_button:SetText("Restore P")
		restore_p_button:SetScript("OnClick", function(self)
			Reunionloot_Master_Restore_P()
		end)
		restore_p_button:Show()
		local start_bid_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		start_bid_button:SetPoint("BOTTOM", 100, 20)
		start_bid_button:SetSize(100, 40)
		start_bid_button:SetText("Start Bid")
		start_bid_button:SetScript("OnClick", function(self)
			Reunionloot_Master_Start_Bidding()
		end)
		start_bid_button:Show()
		local end_bid_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		end_bid_button:SetPoint("BOTTOM", 200, 20)
		end_bid_button:SetSize(100, 40)
		end_bid_button:SetText("End Bid")
		end_bid_button:SetScript("OnClick", function(self)
			Reunionloot_Master_End_Bidding()
		end)
		end_bid_button:Show()
		local end_bid_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		end_bid_button:SetPoint("BOTTOM", 300, 20)
		end_bid_button:SetSize(100, 40)
		end_bid_button:SetText("Clear All")
		end_bid_button:SetScript("OnClick", function(self)
			Reunionloot_Master_DeleteAll()
		end)
		end_bid_button:Show()
	end
	Window.win = win
	UpdatePageButton()
	return win;
end

function Window:RenderSlot(slot, item_list_index, item_info)
	slot.item_index:SetText(item_list_index)
	slot.item_texture:SetBackdrop({bgFile = item_info.item.texture}) 
	slot.item_link:SetText(item_info.item.link)
	slot.current_price:SetText(item_info.current_price)
	slot.current_winner:SetText(item_info.current_winner)
	if item_info.passed or item_info.status == "boughtin" or item_info.status == "deal" then
		slot.bid_buttons.bid:Disable()
		slot.bid_buttons.pass:Disable()
	else
		slot.bid_buttons.bid:Enable()
		slot.bid_buttons.pass:Enable()
	end
	slot.item_root:Show()
end

function Window:RefreshItemList(page_number)
	for i = 1, REUNIONLOOT.item_per_page do
		Window.win.bid_frame.item_slot[i].item_root:Hide()
		Window.win.bid_frame.item_slot[i].input_price:SetText(0)
	end
	max_page_number = 1
	local slot_index = 1
	local item_list_index = 1
	local total_gold = carry_on_total_gold
	while (item_list_index <= Reunionloot_tablelength(item_list)) do
		local item_info = item_list[item_list_index]
		if current_filter(item_info) then
			local page = math.ceil(slot_index / REUNIONLOOT.item_per_page)
			max_page_number = math.max(page, max_page_number)
			if page_number == page then
				local slot_in_page_index = slot_index % REUNIONLOOT.item_per_page
				if slot_in_page_index == 0 then slot_in_page_index = REUNIONLOOT.item_per_page end
				local slot = Window.win.bid_frame.item_slot[slot_in_page_index]
				Window:RenderSlot(slot, item_list_index, item_info)
			end
			slot_index = slot_index + 1
		end
		if item_info ~= nil then
			total_gold = total_gold + tonumber(item_info.current_price)
		end
		item_list_index = item_list_index + 1
	end
	Window.win.filter_frame.total_gold.value.text:SetText(total_gold)	
	Reunionloot_CalculateCut()
end

function Reunionloot_CalculateCut( )
	local total_gold = tonumber(Window.win.filter_frame.total_gold.value.text:GetText())
	local guild_cut = total_gold * REUNIONLOOT.cut_ratio.guild * 0.01
	local bonus_1 = total_gold * REUNIONLOOT.cut_ratio.bonus1 * 0.01
	local bonus_2 = total_gold * REUNIONLOOT.cut_ratio.bonus2 * 0.01
	local bonus_3 = total_gold * REUNIONLOOT.cut_ratio.bonus3 * 0.01
	Window.win.filter_frame.guild_cut.value.text:SetText(math.floor(guild_cut))
	Window.win.filter_frame.bonus_1.value.text:SetText(math.floor(bonus_1))
	Window.win.filter_frame.bonus_2.value.text:SetText(math.floor(bonus_2))
	Window.win.filter_frame.bonus_3.value.text:SetText(math.floor(bonus_3))
	local sharable_gold = total_gold - guild_cut - bonus_1 - bonus_2 - bonus_3
	local full_share = math.floor(sharable_gold / (REUNIONLOOT.cut_ratio.full_share + 0.5 * REUNIONLOOT.cut_ratio.half_share))
	Window.win.filter_frame.full_share.value.text:SetText(full_share)
	Window.win.filter_frame.half_share.value.text:SetText(math.floor(full_share / 2))
	Window.win.filter_frame.share_5.value.text:SetText(full_share * 5)
	Window.win.filter_frame.share_4.value.text:SetText(full_share * 4)
end

function Reunionloot_SetItemList(input_item_list)
	item_list = input_item_list
	Window:RefreshItemList(page_number)
	UpdatePageButton()
end

function Reunionloot_UpdateItemPrice(item_index, price, winner)
	item_list[item_index].current_price = price
	item_list[item_index].current_winner = winner
	Window:RefreshItemList(page_number)
end

function Reunionloot_DeleteAll()
	carry_on_total_gold = tonumber(Window.win.filter_frame.total_gold.value.text:GetText())
	item_list = {}
	page_number = 1
	Window:RefreshItemList(page_number)
	UpdatePageButton()
end

function Reunionloot_DeleteItem(item_index)
	item_list[item_index] = nil
	Window:RefreshItemList(page_number)
	if page_number > max_page_number then
		page_number = max_page_number
		Window:RefreshItemList(page_number)
	end
	UpdatePageButton()
end

function Reunionloot_PassItem(item_index)
	item_list[item_index].passed = true
	Window:RefreshItemList(page_number)
	if page_number > max_page_number then
		page_number = max_page_number
		Window:RefreshItemList(page_number)
	end
	UpdatePageButton()
end

function Reunionloot_BoughtInItem(item_index)
	item_list[item_index].status = "boughtin"
	Window:RefreshItemList(page_number)
	if page_number > max_page_number then
		page_number = max_page_number
		Window:RefreshItemList(page_number)
	end
	UpdatePageButton()
end

function Reunionloot_DealItem(item_index)
	item_list[item_index].status = "deal"
	Window:RefreshItemList(page_number)
	if page_number > max_page_number then
		page_number = max_page_number
		Window:RefreshItemList(page_number)
	end
	UpdatePageButton()
end
