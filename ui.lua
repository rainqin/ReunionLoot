
local backdrop_pool = CreateFramePool("Frame", nil, "BackdropTemplate")
local blank_pool = CreateFramePool("Frame")
local item_link_pool = CreateFramePool("Frame")
local current_price_pool = CreateFramePool("Frame")
local current_winner_pool = CreateFramePool("Frame")
local number_input_pool = CreateFramePool("EditBox")
local button_pool = CreateFramePool("Button", nil, "UIPanelButtonTemplate")

function Reunionloot_CreateItemFrame_Client(parent, y_offset, texture, link, item_index, start_price, winner)
	local item_root = backdrop_pool:Acquire()
	item_root:SetParent(parent)
	item_root:SetPoint("TOP", 0, y_offset)
	item_root:SetSize(610, 50)
	item_root:SetFrameStrata("LOW")
	item_root:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	item_root:Show()

	local item_texture = backdrop_pool:Acquire()
	item_texture:SetParent(item_root)
	item_texture:SetPoint("TOPLEFT", 10, -5)
	item_texture:SetSize(40, 40)
	item_texture:SetFrameStrata("HIGH")
	item_texture:SetBackdrop({
		bgFile = texture
	})
	item_texture:Show()

	local item_link = item_link_pool:Acquire()
	item_link:SetParent(item_root)
	item_link:SetPoint("TOPLEFT", 80, -5)
	item_link:SetSize(100, 40)
	item_link:SetFrameStrata("HIGH")
	item_link.text = item_link.text or item_link:CreateFontString(item_link, "OVERLAY", "GameFontNormal")
	item_link.text:ClearAllPoints()
	item_link.text:SetPoint("CENTER")
	item_link.text:SetText(link)
	item_link:HookScript("OnEnter", function()
	  if (item_link and item_link.text:GetText() ~= nil) then
	    GameTooltip:SetOwner(item_link, "ANCHOR_TOP")
	    GameTooltip:SetHyperlink(item_link.text:GetText())
	    GameTooltip:Show()
	  end
	end)
	item_link:HookScript("OnLeave", function()
	  GameTooltip:Hide()
	end)
	item_link:Show()

	local current_price = current_price_pool:Acquire()
	current_price:SetParent(item_root)
	current_price:SetPoint("TOPLEFT", 200, -5)
	current_price:SetSize(80, 40)
	current_price:SetFrameStrata("HIGH")
	current_price.text = current_price.text or current_price:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	current_price.text:ClearAllPoints()
	current_price.text:SetPoint("CENTER")
	current_price.text:SetText(start_price)
	current_price:Show()

	local current_winner = current_winner_pool:Acquire()
	current_winner:SetParent(item_root)
	current_winner:SetPoint("TOPLEFT", 300, -5)
	current_winner:SetSize(80, 40)
	current_winner:SetFrameStrata("HIGH")
	current_winner.text = current_winner.text or current_winner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	current_winner.text:ClearAllPoints()
	current_winner.text:SetPoint("CENTER")
	current_winner.text:SetText(winner)
	current_winner:Show()

	local input_price_border = backdrop_pool:Acquire()
	input_price_border:SetParent(item_root)
	input_price_border:SetPoint("TOPLEFT", 390, -7)
	input_price_border:SetSize(100, 36)
	input_price_border:SetFrameStrata("MEDIUM")
	input_price_border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	input_price_border:Show()

	local input_price = number_input_pool:Acquire()
	input_price:SetParent(item_root)
	input_price:SetPoint("TOPLEFT", 400, -5)
	input_price:SetSize(80, 40)
	input_price:SetFrameStrata("HIGH")
	input_price:SetMultiLine(false)
    input_price:SetAutoFocus(false)
    input_price:SetFontObject("ChatFontNormal")
    input_price:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	input_price:SetNumeric(true)
	input_price:SetText("0")
	input_price:Show()

	local bid_button = button_pool:Acquire()
	bid_button:SetParent(item_root)
	bid_button:SetPoint("TOPLEFT", 500, -5)
	bid_button:SetSize(100, 40)
	bid_button:SetFrameStrata("HIGH")
	bid_button:SetText("Bid")
	bid_button:SetScript("OnClick", function(self)
		local bid_price = tonumber(input_price:GetText())
		local min_price = tonumber(current_price.text:GetText()) + REUNIONLOOT.min_bid
		if (bid_price < min_price) then
			SendSystemMessage("Bid price must be at least "..min_price)
		else
			Reunionloot_ReportBidMessage(item_index, bid_price)
		end
	end)
	bid_button:Show()

	return {item_root = item_root, item_texture = item_texture, item_link = item_link, current_price = current_price, 
	current_winner = current_winner, input_price_border = input_price_border, input_price = input_price, bid_button = bid_button},
	{current_price = current_price.text, current_winner = current_winner.text, input_price = input_price}
end


function Reunionloot_CreateItemFrame_Master(parent, y_offset, texture, link, item_index)
	local item_root = backdrop_pool:Acquire()
	item_root:SetParent(parent)
	item_root:SetPoint("TOP", 0, y_offset)
	item_root:SetSize(810, 50)
	item_root:SetFrameStrata("LOW")
	item_root:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	item_root:Show()

	local item_texture = backdrop_pool:Acquire()
	item_texture:SetParent(item_root)
	item_texture:SetPoint("TOPLEFT", 10, -5)
	item_texture:SetSize(40, 40)
	item_texture:SetFrameStrata("HIGH")
	item_texture:SetBackdrop({
		bgFile = texture
	})
	item_texture:Show()

	local item_link = item_link_pool:Acquire()
	item_link:SetParent(item_root)
	item_link:SetPoint("TOPLEFT", 80, -5)
	item_link:SetSize(100, 40)
	item_link:SetFrameStrata("HIGH")
	item_link.text = item_link.text or item_link:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	item_link.text:SetPoint("CENTER")
	item_link.text:SetText(link)
	item_link:HookScript("OnEnter", function()
	  if (item_link and item_link.text:GetText() ~= nil) then
	    GameTooltip:SetOwner(item_link, "ANCHOR_TOP")
	    GameTooltip:SetHyperlink(item_link.text:GetText())
	    GameTooltip:Show()
	  end
	end)
	item_link:HookScript("OnLeave", function()
	  GameTooltip:Hide()
	end)
	item_link:Show()

	local current_price_border = backdrop_pool:Acquire()
	current_price_border:SetParent(item_root)
	current_price_border:SetPoint("TOPLEFT", 190, -7)
	current_price_border:SetSize(100, 36)
	current_price_border:SetFrameStrata("MEDIUM")
	current_price_border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	current_price_border:Show()

	local current_price = number_input_pool:Acquire()
	current_price:SetParent(item_root)
	current_price:SetPoint("TOPLEFT", 200, -5)
	current_price:SetSize(80, 40)
	current_price:SetFrameStrata("HIGH")
	current_price:SetMultiLine(false)
    current_price:SetAutoFocus(false)
    current_price:SetFontObject("ChatFontNormal")
    current_price:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	current_price:SetNumeric(true)
	current_price:SetText("0")
	current_price:Show()

	local current_winner = blank_pool:Acquire()
	current_winner:SetParent(item_root)
	current_winner:SetPoint("TOPLEFT", 300, -5)
	current_winner:SetSize(80, 40)
	current_winner:SetFrameStrata("HIGH")
	current_winner.text = current_winner.text or current_winner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	current_winner.text:SetPoint("CENTER")
	current_winner.text:SetText("No one bid")
	current_winner:Show()

	local input_price_border = backdrop_pool:Acquire()
	input_price_border:SetParent(item_root)
	input_price_border:SetPoint("TOPLEFT", 390, -7)
	input_price_border:SetSize(100, 36)
	input_price_border:SetFrameStrata("MEDIUM")
	input_price_border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 		tileEdge = true,
	 	edgeSize = 20,
	})
	input_price_border:Show()

	local input_price = number_input_pool:Acquire()
	input_price:SetParent(item_root)
	input_price:SetPoint("TOPLEFT", 400, -5)
	input_price:SetSize(80, 40)
	input_price:SetFrameStrata("HIGH")
	input_price:SetMultiLine(false)
    input_price:SetAutoFocus(false)
    input_price:SetFontObject("ChatFontNormal")
    input_price:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	input_price:SetNumeric(true)
	input_price:SetText("0")
	input_price:Show()

	local bid_button = button_pool:Acquire()
	bid_button:SetParent(item_root)
	bid_button:SetPoint("TOPLEFT", 500, -5)
	bid_button:SetSize(100, 40)
	bid_button:SetFrameStrata("HIGH")
	bid_button:SetText("Bid")
	bid_button:SetScript("OnClick", function(self)
		if (tonumber(input_price:GetText()) < tonumber(current_price:GetText())) then
			SendSystemMessage("lower than current price")
		else
			Reunionloot_Master_Bid(item_index)
		end
	end)
	bid_button:Show()

	local set_current_price_button = button_pool:Acquire()
	set_current_price_button:SetParent(item_root)
	set_current_price_button:SetPoint("TOPLEFT", 600, -5)
	set_current_price_button:SetSize(100, 40)
	set_current_price_button:SetFrameStrata("HIGH")
	set_current_price_button:SetText("Set Price")
	set_current_price_button:SetScript("OnClick", function(self)
		Reunionloot_Master_Set_Price(item_index)
	end)
	set_current_price_button:Show()

	local delete_button = button_pool:Acquire()
	delete_button:SetParent(item_root)
	delete_button:SetPoint("TOPLEFT", 700, -5)
	delete_button:SetSize(100, 40)
	delete_button:SetFrameStrata("HIGH")
	delete_button:SetText("Delete")
	delete_button:SetScript("OnClick", function(self)
		Reunionloot_Master_Delete(item_index)
	end)
	delete_button:Show()

	return {item_root = item_root, item_texture = item_texture, item_link = item_link, current_price_border = current_price_border, current_price = current_price, 
		current_winner = current_winner, input_price_border = input_price_border, input_price = input_price, bid_button = bid_button, set_current_price_button = set_current_price_button,
		delete_button = delete_button},
	{current_price = current_price, current_winner = current_winner.text, input_price = input_price}
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
	local win = CreateFrame("Frame","Reunion Loot",UIParent, "BasicFrameTemplateWithInset");
	win:SetFrameStrata("BACKGROUND")
	win:SetMovable(true)
	win:EnableMouse(true)
	win:RegisterForDrag("LeftButton")
	win:SetScript("OnDragStart", win.StartMoving)
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
		win:SetSize(900, 600)
	else
		win:SetSize(700, 600)
	end
	win:SetPoint("CENTER", UIParent, "CENTER");

	if is_master then
		local send_out_list_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		send_out_list_button:SetPoint("BOTTOM", -100, 20)
		send_out_list_button:SetSize(100, 40)
		send_out_list_button:SetText("Send Out")
		send_out_list_button:SetScript("OnClick", function(self)
			Reunionloot_Master_Sendout_Items()
		end)
		send_out_list_button:Show()
		local start_bid_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		start_bid_button:SetPoint("BOTTOM", 0, 20)
		start_bid_button:SetSize(100, 40)
		start_bid_button:SetText("Start Bid")
		start_bid_button:SetScript("OnClick", function(self)
			Reunionloot_Master_Start_Bidding()
		end)
		start_bid_button:Show()
		local end_bid_button = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
		end_bid_button:SetPoint("BOTTOM", 100, 20)
		end_bid_button:SetSize(100, 40)
		end_bid_button:SetText("End Bid")
		end_bid_button:SetScript("OnClick", function(self)
			Reunionloot_Master_End_Bidding()
		end)
		end_bid_button:Show()
	else
		win.notification = CreateFrame("Frame", nil, win)
		win.notification:SetPoint("CENTER", 0, 0)
		win.notification:SetSize(500, 40)
		local notification_text = win.notification:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		notification_text:SetPoint("CENTER")
		notification_text:SetText("Waiting for Loot Master sending out items...")
		win.notification:Show()
	end
	return win;
end

--item_root, item_texture, item_link, current_price, current_winner, input_price_border, input_price, bid_button
function Reunion_Clear_Client_Item(item_frame)
	backdrop_pool:Release(item_frame.item_root)
	backdrop_pool:Release(item_frame.item_texture)
	item_link_pool:Release(item_frame.item_link)
	current_price_pool:Release(item_frame.current_price)
	current_winner_pool:Release(item_frame.current_winner)
	backdrop_pool:Release(item_frame.input_price_border)
	number_input_pool:Release(item_frame.input_price)
	button_pool:Release(item_frame.bid_button)
end

--item_root, item_texture, item_link, current_price_border, current_price, current_winner, input_price_border, input_price, bid_button, set_current_price_button, delete_button
function Reunion_Clear_Master_Item(item_frame)
	backdrop_pool:Release(item_frame.item_root)
	backdrop_pool:Release(item_frame.item_texture)
	item_link_pool:Release(item_frame.item_link)
	backdrop_pool:Release(item_frame.current_price_border)
	number_input_pool:Release(item_frame.current_price)
	blank_pool:Release(item_frame.current_winner)
	backdrop_pool:Release(item_frame.input_price_border)
	number_input_pool:Release(item_frame.input_price)
	button_pool:Release(item_frame.bid_button)
	button_pool:Release(item_frame.set_current_price_button)
	button_pool:Release(item_frame.delete_button)
end

function Reunionloot_Clear_Items()
	backdrop_pool:ReleaseAll()
	blank_pool:ReleaseAll()
	item_link_pool:ReleaseAll()
	current_price_pool:ReleaseAll()
	current_winner_pool:ReleaseAll()
	number_input_pool:ReleaseAll()
	button_pool:ReleaseAll()
end