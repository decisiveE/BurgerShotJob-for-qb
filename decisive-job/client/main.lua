QBCore = nil

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
end)

isLoggedIn = true
PlayerJob = {}

local onDuty = false

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
        if PlayerData.job.onduty then
            if PlayerData.job.name == "burgershot" then
                TriggerServerEvent("QBCore:ToggleDuty")
            end
        end
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = PlayerJob.onduty
end)

RegisterNetEvent('QBCore:Client:SetDuty')
AddEventHandler('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
end)

Citizen.CreateThread(function()
    local c = Config.Locations["exit"]
    local Blip = AddBlipForCoord(c.x, c.y, c.z)

    SetBlipSprite (Blip, 446)
    SetBlipDisplay(Blip, 4)
    SetBlipScale  (Blip, 0.7)
    SetBlipAsShortRange(Blip, true)
    SetBlipColour(Blip, 0)
    SetBlipAlpha(Blip, 0.7)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Burgershot")
    EndTextCommandSetBlipName(Blip)
end)

Citizen.CreateThread(function()
    while true do
        local inRange = false

        if isLoggedIn then
            if PlayerJob.name == "burgershot" then
                local pos = GetEntityCoords(PlayerPedId())
                local StashDistance = #(pos - vector3(Config.Locations["stash"].x, Config.Locations["stash"].y, Config.Locations["stash"].z))
                local OnDutyDistance = #(pos - vector3(Config.Locations["duty"].x, Config.Locations["duty"].y, Config.Locations["duty"].z))
                local CheesbDistance = #(pos - vector3(Config.Locations["cheesb"].x, Config.Locations["cheesb"].y, Config.Locations["cheesb"].z))

                if onDuty then
                    if StashDistance < 20 then
                        inRange = true
                        DrawMarker(2, Config.Locations["stash"].x, Config.Locations["stash"].y, Config.Locations["stash"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)

                        if StashDistance < 1 then
                            DrawText3Ds(Config.Locations["stash"].x, Config.Locations["stash"].y, Config.Locations["stash"].z, "[E] Open Stash")
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent("inventory:client:SetCurrentStash", "burgerstash")
                                TriggerServerEvent("inventory:server:OpenInventory", "stash", "burgerstash", {
                                    maxweight = 4000000,
                                    slots = 500,
                                })
                            end
                        end
                    end
                end

                if onDuty then
                    if CheesbDistance < 20 then
                        inRange = true
                        DrawMarker(2, Config.Locations["cheesb"].x, Config.Locations["cheesb"].y, Config.Locations["cheesb"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)

                        if CheesbDistance < 1 then
                            DrawText3Ds(Config.Locations["cheesb"].x, Config.Locations["cheesb"].y, Config.Locations["cheesb"].z, "[E] To ")
                            if IsControlJustReleased(0, 38) then
                                 QBCore.Functions.Progressbar("pickup_sla", "Baking meat..", 20000, false, true, {
                                     disableMovement = true,
                                     disableCarMovement = false,
                                     disableMouse = false,
                                     disableCombat = false,
                                 })
                                Citizen.Wait(20000)
                                TriggerServerEvent('QBCore:Server:AddItem', "meat", 1)
                            end
                        end
                    end
                end

                if OnDutyDistance < 20 then
                    inRange = true
                    DrawMarker(2, Config.Locations["duty"].x, Config.Locations["duty"].y, Config.Locations["duty"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)

                    if OnDutyDistance < 1 then
                        if onDuty then
                            DrawText3Ds(Config.Locations["duty"].x, Config.Locations["duty"].y, Config.Locations["duty"].z, "[E] Off Duty")
                        else
                            DrawText3Ds(Config.Locations["duty"].x, Config.Locations["duty"].y, Config.Locations["duty"].z, "[E] On Duty")
                        end
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent("QBCore:ToggleDuty")
                        end
                    end
                end

                if not inRange then
                    Citizen.Wait(1500)
                end
            else
                Citizen.Wait(1500)
            end
        else
            Citizen.Wait(1500)
        end

        Citizen.Wait(3)
    end
end)


RegisterNetEvent("decisive:CheesBurger")
AddEventHandler("decisive:CheesBurger", function()
    QBCore.Functions.Progressbar("pickup_sla", "Building a chees burger..", 20000, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    })
   Citizen.Wait(20000)
   TriggerServerEvent('QBCore:Server:AddItem', "cheesb", 1)
end)

RegisterNetEvent("decisive:HamBurger")
AddEventHandler("decisive:HamBurger", function()
    QBCore.Functions.Progressbar("pickup_sla", "Building a ham burger..", 20000, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    })
   Citizen.Wait(20000)
   TriggerServerEvent('QBCore:Server:AddItem', "hamb", 1)
end)

RegisterNetEvent("decisive:Toast")
AddEventHandler("decisive:Toast", function()
    QBCore.Functions.Progressbar("pickup_sla", "Toasting a toast..", 20000, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    })
   Citizen.Wait(20000)
   TriggerServerEvent('QBCore:Server:AddItem', "toast", 1)
end)

RegisterNetEvent("decisive:Soda")
AddEventHandler("decisive:Soda", function()
    QBCore.Functions.Progressbar("pickup_sla", "Filling a cup..", 20000, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    })
   Citizen.Wait(20000)
   TriggerServerEvent('QBCore:Server:AddItem', "soda", 1)
end)

RegisterNetEvent("decisive:Fries")
AddEventHandler("decisive:Fries", function()
    QBCore.Functions.Progressbar("pickup_sla", "Frying the fries..", 20000, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    })
   Citizen.Wait(20000)
   TriggerServerEvent('QBCore:Server:AddItem', "fries", 1)
end)

RegisterNetEvent("decisive:DutyB")
AddEventHandler("decisive:DutyB", function()
    TriggerServerEvent("QBCore:ToggleDuty")
end)

RegisterNetEvent("decisive:Tray1")
AddEventHandler("decisive:Tray1", function()
    TriggerEvent("inventory:client:SetCurrentStash", "burgertray1")
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "burgertray1", {
        maxweight = 10000,
        slots = 6,
    })
end)

RegisterNetEvent("decisive:Tray2")
AddEventHandler("decisive:Tray2", function()
    TriggerEvent("inventory:client:SetCurrentStash", "burgertray2")
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "burgertray2", {
        maxweight = 10000,
        slots = 6,
    })
end)

RegisterNetEvent("decisive:Storage")
AddEventHandler("decisive:Storage", function()
    TriggerEvent("inventory:client:SetCurrentStash", "burgerstorage")
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "burgerstorage", {
        maxweight = 250000,
        slots = 40,
    })
end)
-- bt target -

Citizen.CreateThread(function()
    
    exports["bt-target"]:AddBoxZone("Sign", vector3(-1196.25, -902.87, 14.0), 0.5, 0.5, {
        name = "Sign",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                event = "decisive:DutyB",
                icon = "far fa-clipboard",
                label = "Sign",
            },
        },
        job = {"all"},
        distance = 1.5
    })
    
    exports["bt-target"]:AddBoxZone("Burgers", vector3(-1198.18, -897.6, 14.92), 1.5, 1.5, {
        name = "Burgers",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                event = "decisive:CheesBurger",
                icon = "fas fa-hamburger",
                label = "CheesBurger",
            },
            {
                event = "decisive:HamBurger",
                icon = "fas fa-hamburger",
                label = "HamBurger",
            },
            {
                event = "decisive:Toast",
                icon = "fas fa-hamburger",
                label = "Toast",
            },
        },
        job = {"all"},
        distance = 1.5
    })
    
    exports["bt-target"]:AddBoxZone("Sodas", vector3(-1199.21, -894.81, 14.0), 1, 1, {
        name = "Sodas",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                event = "decisive:Soda",
                icon = "fas fa-filter",
                label = "Soda",
            },
        },
        job = {"all"},
        distance = 1.5
    })
    
    exports["bt-target"]:AddBoxZone("Fries", vector3(-1201.08, -898.67, 14.0), 1.5, 1.5, {
        name = "Fries",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                event = "decisive:Fries",
                icon = "fas fa-box",
                label = "Fries",
            },
        },
        job = {"all"},
        distance = 1.5
    })

    
    exports["bt-target"]:AddBoxZone("Tray1", vector3(-1193.36, -893.77, 14.0), 1.7, 1.7, {
        name = "Tray1",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                event = "decisive:Tray1",
                icon = "fas fa-box",
                label = "Tray",
            },
        },
        job = {"all"},
        distance = 1.5
    })

    
    exports["bt-target"]:AddBoxZone("Tray2", vector3(-1194.64, -891.83, 14.0), 1.7, 1.7, {
        name = "Tray2",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                event = "decisive:Tray2",
                icon = "fas fa-box",
                label = "Tray",
            },
        },
        job = {"all"},
        distance = 1.5
    })

    
    exports["bt-target"]:AddBoxZone("Stash1", vector3(-1197.08, -893.88, 14.0), 1.25, 1.25, {
        name = "Stash1",
        heading = 0,
        debugPoly = false,
    }, {
        options = {
            {
                event = "decisive:Storage",
                icon = "fas fa-box",
                label = "Storage",
            },
        },
        job = {"all"},
        distance = 1.5
    })
end)