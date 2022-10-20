SLASH_REUNIONLOOT1 = "/reunionloot"
SLASH_REUNIONLOOTMASTER1 = "/reunionlootmaster"

REUNIONLOOT = {}
REUNIONLOOT.prefix = "ReunionLoot"
REUNIONLOOT.min_bid = 100
REUNIONLOOT.version = "0.1.0"
local player_name = UnitName("player")

function Reunionloot_SendOutItemsMessage(item_list)
	local msg = "Refresh;"
	for k, v in pairs(item_list) do
		if v ~= nil then
			msg = msg..k..","..v.item.id..","..v.data.current_price:GetText()..","..v.data.current_winner:GetText()..";"
		end
	end
	--print("Send out msg: ", msg)
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
end

function Reunionloot_ReportBidMessage(item_index, price)
	local msg = "BidFromClient;"..item_index..";"..price..";"
	C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID");
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

function Reunionloot_BroadCastNotifyMessage(message, target)
	local msg = "BroadcastNotify;"..message
	if target == nil then
		C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "RAID")
	else 
		C_ChatInfo.SendAddonMessage(REUNIONLOOT.prefix, msg, "WHISPER", target)
	end
end

C_ChatInfo.RegisterAddonMessagePrefix(REUNIONLOOT.prefix);
SlashCmdList["REUNIONLOOT"] = Reunionloot_Client_Window;
SlashCmdList["REUNIONLOOTMASTER"] = Reunionloot_Master_Window;