
function Reunionloot_FilterAll(item_info)
	return item_info ~= nil and item_info.status ~= "deleted"
end

function Reunionloot_FilterNotPassed(item_info)
	return item_info ~= nil and item_info.passed == false and item_info.status == "bidding"
end

function Reunionloot_FilterBoughtIn(item_info)
	return item_info ~= nil and item_info.status == "boughtin"
end

function Reunionloot_FilterDeal(item_info)
	return item_info ~= nil and item_info.status == "deal"
end