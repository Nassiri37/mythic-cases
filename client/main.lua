local currentSession = nil

RegisterNetEvent("mystic-case:client:begin", function(data)
    currentSession = data.sessionId
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "load", rewards = data.rewards })  
    SendNUIMessage({
        type = "ui",
        status = true,
        case = data.case,
        selected = data.selected,
        durationMs = data.durationMs or 9500
    })
end)


RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "ui", status = false })
    local finished = data and data.finished
    local sess = currentSession
    currentSession = nil
    if sess then
        if finished then
            TriggerServerEvent("mystic-case:server:finalize", sess)
        else
            TriggerServerEvent("mystic-case:server:cancel", sess)
        end
    end
    cb("ok")
end)
