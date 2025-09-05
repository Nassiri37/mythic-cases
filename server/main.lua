AddEventHandler("mythic-cases:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Fetch     = exports["mythic-base"]:FetchComponent("Fetch")
    Execute   = exports["mythic-base"]:FetchComponent("Execute")
    Callbacks = exports["mythic-base"]:FetchComponent("Callbacks")
    Inventory = exports["mythic-base"]:FetchComponent("Inventory")
end

AddEventHandler("Core:Shared:Ready", function()
    exports["mythic-base"]:RequestDependencies("mythic-cases", {
        "Fetch", "Utils", "Execute", "Inventory",
    }, function(error)
        if #error > 0 then
            exports["mythic-base"]:FetchComponent("Logger"):Critical("mythic-cases", "Failed To Load All Dependencies")
            return
        end
        RetrieveComponents()
        TriggerEvent("mythic-cases:Server:Startup")
    end)
end)


local ActiveCaseSessions = {}
local ROLL_DURATION_MS   = 9500

local function makeSessionId(src, caseName)
    return ("%s:%s:%d:%d"):format(tostring(src), tostring(caseName), os.time(), math.random(100000, 999999))
end

local function resolveAmount(entry, isWeapon)
    if isWeapon then return 1 end
    local a = entry and entry.amount
    if type(a) == "table" then
        local mn = tonumber(a[1]) or 1
        local mx = tonumber(a[2]) or mn
        if mx < mn then mx = mn end
        return math.random(math.floor(mn), math.floor(mx))
    end
    local n = tonumber(a)
    if n and n > 0 then
        return math.floor(n)
    end
    return 1
end


local function pick_random(pool)
    if not pool or #pool == 0 then return 1 end
    return math.random(1, #pool)
end


AddEventHandler("mythic-cases:Server:Startup", function()
    local _MysteryRewards = Config.Rewards

    for caseName, rewards in pairs(_MysteryRewards) do
        Inventory.Items:RegisterUse(caseName, "MysteryCase", function(source, slot, itemData)
            local char = Fetch:CharacterSource(source)
            if not char then return end

            local idx       = pick_random(rewards)
            local sessionId = makeSessionId(source, caseName)

            ActiveCaseSessions[sessionId] = {
                src       = source,
                caseName  = caseName,
                index     = idx,
                slot      = { Owner = slot.Owner, Name = slot.Name, Slot = slot.Slot, invType = slot.invType },
                startedAt = os.time(),
            }

            TriggerClientEvent("mystic-case:client:begin", source, {
                sessionId  = sessionId,
                case       = caseName,
                selected   = idx,
                rewards    = { [caseName] = rewards },
                durationMs = ROLL_DURATION_MS,
            })
        end)
    end
end)


RegisterNetEvent("mystic-case:server:finalize", function(sessionId)
    local src  = source
    local sess = ActiveCaseSessions[sessionId]
    if not sess or sess.src ~= src then return end
    ActiveCaseSessions[sessionId] = nil

    local char = Fetch:CharacterSource(src)
    if not char then return end
    local sid = char:GetData("SID")

    local caseName = sess.caseName
    local idx      = sess.index

    local rewards = Config.Rewards[caseName]
    local reward  = rewards and rewards[idx]
    if not reward or not reward.item then
        Execute:Client(src, "Notification", "Error", "Invalid reward.")
        return
    end

    local s       = sess.slot
    local removed = Inventory.Items:RemoveSlot(s.Owner, s.Name, 1, s.Slot, s.invType)
    if not removed then
        Execute:Client(src, "Notification", "Error", "Failed to consume the case. Try again.")
        return
    end
    local inv      = INVENTORY or Inventory
    local name     = reward.item
    local isWeapon = string.sub(name, 1, 6):lower() == "weapon"
    local added    = false

    if isWeapon then
        local keyUpper    = string.upper(name)            
        local keyNoPrefix = keyUpper:gsub("^WEAPON_", "") 
        local keyLower    = string.lower(name)            

        local meta = { ammo = 125, clip = 0, Scratched = true }
        added = inv:AddItem(sid, keyUpper,    1, meta, 1)
             or inv:AddItem(sid, keyNoPrefix, 1, meta, 1)
             or inv:AddItem(sid, keyLower,    1, meta, 1)

        if added then
            Execute:Client(src, "Notification", "Success",
                ("You won a %s!"):format(keyUpper))
        else
            Execute:Client(src, "Notification", "Error",
                ("Could not add %s to your inventory."):format(keyUpper))
            print(("^1[mythic-cases] AddItem failed for weapon variants: '%s' | '%s' | '%s' (sid=%s)^0")
                :format(keyUpper, keyNoPrefix, keyLower, tostring(sid)))
        end
    else
        local count = resolveAmount(reward, false)
        added = inv:AddItem(sid, name, count, {}, 1)
        if added then
            Execute:Client(src, "Notification", "Success",
                ("You won %sx %s!"):format(count, name))
        else
            Execute:Client(src, "Notification", "Error",
                ("Could not add %sx %s to your inventory."):format(count, name))
            print(("^1[mythic-cases] AddItem failed for item '%s' x%s (sid=%s)^0")
                :format(name, tostring(count), tostring(sid)))
        end
    end
    TriggerClientEvent("Inventory:Client:Refresh", src, sid, 1)
end)

RegisterNetEvent("mystic-case:server:cancel", function(sessionId)
    local src  = source
    local sess = ActiveCaseSessions[sessionId]
    if not sess or sess.src ~= src then return end

    ActiveCaseSessions[sessionId] = nil
    Execute:Client(src, "Notification", "Error", "Opening canceled.")
end)
