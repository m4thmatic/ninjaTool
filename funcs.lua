local consts = require("constants")

local funcs = T{};

local spellIdx = 1;

--------------------------------------------------------------------
funcs.getCurrentSpell = function()
    return spellIdx;
end

--------------------------------------------------------------------
funcs.castNextSpell = function(spellType, targetModifier)
    local spellToCast = consts.ninEleSpells[spellIdx].spellName .. ": "

    if (spellType == nil) then
        print(chat.header(addon.name):append(chat.message('No spell type specified.')));
        return
    end
    spellType = string.lower(spellType)

    if (spellType == "ni") or (spellType == "ichi") or (spellType == "san") then
        spellToCast = spellToCast .. spellType;
    else
        print(chat.header(addon.name):append(chat.message('No spell type:' .. spellType)));
        return
    end

    if (targetModifier == nil) then
        targetModifier = "<t>";
    end

    command = '/ma "' .. spellToCast .. '" ' .. targetModifier;
    AshitaCore:GetChatManager():QueueCommand(1, command);
end

--------------------------------------------------------------------
funcs.isNinjutsu = function(spellId)
    for idx, spell in pairs(consts.ninEleSpells) do
        if (spellId == spell.spellId) or 
           (spellId == spell.spellId+1) or
           (spellId == spell.spellId+2) then
            return true;
        end
    end

    return false;
end

--------------------------------------------------------------------
funcs.nextSpell = function()
    spellIdx = 1 + (spellIdx % 6);
end

--------------------------------------------------------------------
funcs.prevSpell = function()
    spellIdx = spellIdx - 1;
    if (spellIdx < 1) then
        spellIdx = 6;
    end
end

--------------------------------------------------------------------
funcs.resetSpellIdx = function(config)
    spellIdx = config.settings.components.firstSpellIdx;
end

--------------------------------------------------------------------
funcs.ninjaToolsRemaining = function(itemId)
    local inventory = AshitaCore:GetMemoryManager():GetInventory();
    local resources = AshitaCore:GetResourceManager();

    local itemCount = 0;

    for invSlot = 0,inventory:GetContainerCountMax(0) do
        local item = inventory:GetContainerItem(0, invSlot);
        if ((item ~= nil) and (item.Id == itemId)) then
            itemCount = itemCount + item.Count;
        end
    end

    return itemCount;
end

--------------------------------------------------------------------
funcs.GetShadowCount = function()
    local me = AshitaCore:GetMemoryManager():GetPlayer()
    local buffs = me:GetBuffs()

    for _, buff in pairs(buffs) do
        if buff == 66 or buff == 67 then
          return "1";
        elseif buff == 444 then
          return "2";
        elseif buff == 445 then
          return "3";
        elseif buff == 446 then
          return "4";
        end
    end
    return "0";
end

--------------------------------------------------------------------
funcs.hexToRBG = function(hexVal)
	local alpha = bit.band(bit.rshift(hexVal, 24), 0xff)/0xff;
	local red   = bit.band(bit.rshift(hexVal, 16), 0xff)/0xff;
	local green = bit.band(bit.rshift(hexVal,  8), 0xff)/0xff;
	local blue  = bit.band(bit.rshift(hexVal,  0), 0xff)/0xff;

	--return alpha, red, green, blue;
	return red, green, blue;
end

--------------------------------------------------------------------
funcs.argbToHex = function(alpha, red, green, blue)
	return	math.floor(alpha * 0xff) * 0x1000000 + 
			bit.lshift(red   * 0xff, 16) +
			bit.lshift(green * 0xff,  8) +
			bit.lshift(blue  * 0xff,  0);
end

--- Gets the name of the top-most menu element. (credit to/copied from XITools)
funcs.GetMenuName = function()
    local menuBase = ashita.memory.find('FFXiMain.dll', 0, '8B480C85C974??8B510885D274??3B05', 16, 0);
    local subPointer = ashita.memory.read_uint32(menuBase);
    local subValue = ashita.memory.read_uint32(subPointer);
    if (subValue == 0) then
        return '';
    end
    local menuHeader = ashita.memory.read_uint32(subValue + 4);
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16);
    return string.gsub(menuName, '\x00', '');
end


return funcs;