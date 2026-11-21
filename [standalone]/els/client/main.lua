local IndicatorL = false
local IndicatorR = false
local IndicatorHazard = false
local insideValidVehicle = false
local vehicleModelName = ""
CreateThread(function()
    if not kjxmlData then -- Request ELS Vehicle Data (venInit.lua) & assign to kjxmlData variable.
        TriggerServerEvent("kjELS:requestELSInformation")
        while not kjxmlData do
            Wait(0)
        end
    end
end)


RegisterNetEvent("QBCore:Client:EnteredVehicle", function(data)
    insideValidVehicle = getCarHash(data.vehicle)
    vehicleModelName = GetDisplayNameFromVehicleModel(GetEntityModel(data.vehicle))
    local driverSeat = GetPedInVehicleSeat(data.vehicle, -1)
    if insideValidVehicle and data.vehicle and kjxmlData then -- If the car player is in exists, then...
        CreateThread(function()
            local ped = PlayerPedId()
            while IsPedInAnyVehicle(ped) do
                if setContains(kjxmlData, vehicleModelName) then --
                    --[[ Disable conflicting controls ]] DisableControlAction(0, 83, true)
                    DisableControlAction(0, 73, true)
                    DisableControlAction(0, 81, true)
                    DisableControlAction(0, 84, true)
                    DisableControlAction(0, 83, true)
                    DisableControlAction(0, 82, true)
                    DisableControlAction(0, 85, true)
                    DisableControlAction(0, 58, true)
                    DisableControlAction(0, 80, true)
                    DisableControlAction(0, 86, true)
                    SetVehRadioStation(vehicle, "OFF")
                    SetVehicleRadioEnabled(vehicle, false)      
                    if (IsDisabledControlJustPressed(0, 86)) then
                        if GetPedInVehicleSeat(vehicle, -1) == ped then
                            TriggerServerEvent("kjELS:toggleHorn", 1)
                        end
                    end
                    if (IsDisabledControlJustReleased(0, 86)) then
                        if GetPedInVehicleSeat(vehicle, -1) == ped then
                            TriggerServerEvent("kjELS:toggleHorn", 0)
                        end
                    end
                end
                if GetLastInputMethod(0) then -- If on keyboard --
                    --[[ Primary Lights ]] if IsDisabledControlJustReleased(1, Config.KeyBinds["PrimaryLights"]) then
                        if IsPedInAnyVehicle(ped, false) then
                            if GetPedInVehicleSeat(vehicle, -1) == ped then
                                if setContains(kjxmlData, vehicleModelName) then
                                    if kjEnabledVehicles[vehicle] == nil then
                                        addVehicleToTable(vehicle)
                                    end
    
                                    if kjEnabledVehicles[vehicle]["primary"] then
                                        TriggerServerEvent("kjELS:updateStatus", "primary", false)
                                        SetVehicleSiren(vehicle, false)
                                        TriggerServerEvent("kjELS:setSirenState", 0)
                                    else
                                        TriggerServerEvent("kjELS:updateStatus", "primary", true)
                                        SetVehicleSiren(vehicle, true)
                                        TriggerServerEvent("kjELS:setSirenState", 0)
    
                                        if kjxmlData[getCarHash(vehicle)].sounds["nineMode"] then
                                            SendNUIMessage(
                                                {
                                                    transactionType = "playSound",
                                                    transactionFile = "999mode",
                                                    transactionVolume = 0.025
                                                }
                                            )
                                        end
                                    end
                                --PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1, 1, 1)
                                end
                            end
                        end
                    elseif IsDisabledControlJustPressed(1, Config.KeyBinds["SecondaryLights"]) then
                        if IsPedInAnyVehicle(ped, false) then
                            if driverSeat == ped then -- If player is driver
                                if kjEnabledVehicles[vehicle] == nil then
                                    addVehicleToTable(vehicle)
                                end
    
                                if kjEnabledVehicles[vehicle]["secondary"] then -- If secondary lighting is on, then...
                                    TriggerServerEvent("kjELS:updateStatus", "secondary", false) -- Turn them off
                                else
                                    TriggerServerEvent("kjELS:updateStatus", "secondary", true) -- if not, turn them on!
                                end
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    elseif IsDisabledControlJustPressed(1, Config.KeyBinds["MiscLights"]) then
                        if IsPedInAnyVehicle(ped, false) then
                            if driverSeat == ped then
                                if kjEnabledVehicles[vehicle] == nil then
                                    addVehicleToTable(vehicle)
                                end
    
                                if kjEnabledVehicles[vehicle]["warning"] then
                                    TriggerServerEvent("kjELS:updateStatus", "warning", false)
                                else
                                    TriggerServerEvent("kjELS:updateStatus", "warning", true)
                                end
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    elseif IsDisabledControlJustReleased(1, Config.KeyBinds["ActivateSiren"]) then
                        if driverSeat == ped then
                            if kjEnabledVehicles[vehicle] == nil then
                                addVehicleToTable(vehicle)
                            end
    
                            if kjEnabledVehicles[vehicle].primary == true then
                                if kjEnabledVehicles[vehicle] ~= nil and kjEnabledVehicles[vehicle].siren ~= 0 then
                                    TriggerServerEvent("kjELS:setSirenState", 0)
                                    if Config.HornBlip then
                                        Wait(100)
                                        SoundVehicleHornThisFrame(vehicle)
                                        Wait(100)
                                        SoundVehicleHornThisFrame(vehicle)
                                    end
                                else
                                    TriggerServerEvent("kjELS:setSirenState", 1)
                                    if Config.HornBlip then
                                        SoundVehicleHornThisFrame(vehicle)
                                    end
                                end
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    elseif IsDisabledControlJustReleased(1, Config.KeyBinds["NextSiren"]) then
                        if driverSeat == ped then
                            if kjEnabledVehicles[vehicle] == nil then
                                addVehicleToTable(vehicle)
                            end
    
                            local siren
    
                            if kjEnabledVehicles[vehicle].primary == true then
                                if kjEnabledVehicles[vehicle].siren >= 4 then
                                    siren = 1
                                else
                                    siren = kjEnabledVehicles[vehicle].siren + 1
                                end
    
                                TriggerServerEvent("kjELS:setSirenState", siren)
                                SoundVehicleHornThisFrame(vehicle)
    
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    end
                    --
    
                    --[[ Siren Toggles ]] if IsDisabledControlJustReleased(1, Config.KeyBinds["Siren1"]) then -- Siren One
                        if driverSeat == ped then
                            if kjEnabledVehicles[vehicle] == nil then
                                addVehicleToTable(vehicle)
                            end
    
                            if kjEnabledVehicles[vehicle].primary == true then
                                TriggerServerEvent("kjELS:setSirenState", 1)
                                SoundVehicleHornThisFrame(vehicle)
    
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    elseif IsDisabledControlJustReleased(1, Config.KeyBinds["Siren2"]) then -- Siren Two
                      
                        if driverSeat == ped then
                            if kjEnabledVehicles[vehicle] == nil then
                                addVehicleToTable(vehicle)
                            end
    
                            if kjEnabledVehicles[vehicle].primary == true then
                                TriggerServerEvent("kjELS:setSirenState", 2)
                                SoundVehicleHornThisFrame(vehicle)
    
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    elseif IsDisabledControlJustReleased(1, Config.KeyBinds["Siren3"]) then -- Siren Three
                       
                        if driverSeat == ped then
                            if kjEnabledVehicles[vehicle] == nil then
                                addVehicleToTable(vehicle)
                            end
    
                            if kjEnabledVehicles[vehicle].primary == true then
                                TriggerServerEvent("kjELS:setSirenState", 3)
                                SoundVehicleHornThisFrame(vehicle)
    
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    elseif IsDisabledControlJustReleased(1, Config.KeyBinds["Siren4"]) then -- Siren Four
                       
                        if driverSeat == ped then
                            if kjEnabledVehicles[vehicle] == nil then
                                addVehicleToTable(vehicle)
                            end
    
                            if kjEnabledVehicles[vehicle].primary == true then
                                TriggerServerEvent("kjELS:setSirenState", 4)
                                SoundVehicleHornThisFrame(vehicle)
    
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    end
                    --
    
                    --[[ Indicators ]] if Config.Indicators then
                        if IsControlJustPressed(1, 174) then -- left
                            if IsPedInAnyVehicle(ped, true) then
                                if driverSeat == ped then
                                    IndicatorL = not IndicatorL
                                    TriggerServerEvent("kjELS:sv_Indicator", "left", IndicatorL)
                                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                end
                            end
                        end
    
                        if IsControlJustPressed(1, 175) then --right
                            if IsPedInAnyVehicle(ped, true) then
                                if driverSeat == ped then
                                    IndicatorR = not IndicatorR
                                    TriggerServerEvent("kjELS:sv_Indicator", "right", IndicatorR)
                                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                end
                            end
                        end
    
                        if IsControlJustPressed(1, 173) then -- Hazards
                            if IsPedInAnyVehicle(ped, true) then
                                if driverSeat == ped then
                                    IndicatorHazard = not IndicatorHazard
                                    TriggerServerEvent("kjELS:sv_Indicator", "hazard", IndicatorHazard)
                                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                end
                            end
                        end
                    end
                else -- If on controller --
                    --[[ Primary Lights ]] if IsDisabledControlJustReleased(1, 85) then
                        if IsPedInAnyVehicle(ped, false) then
                       
                            if driverSeat == ped then
                                if kjEnabledVehicles[vehicle] == nil then
                                    addVehicleToTable(vehicle)
                                end
    
                                if kjEnabledVehicles[vehicle]["primary"] then
                                    TriggerServerEvent("kjELS:updateStatus", "primary", false)
                                    SetVehicleSiren(vehicle, false)
                                    TriggerServerEvent("kjELS:setSirenState", 0)
                                else
                                    TriggerServerEvent("kjELS:updateStatus", "primary", true)
                                    SetVehicleSiren(vehicle, true)
                                    TriggerServerEvent("kjELS:setSirenState", 0)
                                end
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    elseif IsDisabledControlJustReleased(1, 173) then
              
                        if driverSeat == ped then
                            if kjEnabledVehicles[vehicle] == nil then
                                addVehicleToTable(vehicle)
                            end
    
                            if kjEnabledVehicles[vehicle].primary == true then
                                if kjEnabledVehicles[vehicle] ~= nil and kjEnabledVehicles[vehicle].siren ~= 0 then
                                    TriggerServerEvent("kjELS:setSirenState", 0)
                                    if Config.HornBlip then
                                        Wait(100)
                                        SoundVehicleHornThisFrame(vehicle)
                                        Wait(100)
                                        SoundVehicleHornThisFrame(vehicle)
                                    end
                                else
                                    TriggerServerEvent("kjELS:setSirenState", 1)
                                    if Config.HornBlip then
                                        SoundVehicleHornThisFrame(vehicle)
                                    end
                                end
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    elseif IsDisabledControlJustReleased(1, 170) then
                        if driverSeat == ped then
                            if kjEnabledVehicles[vehicle] == nil then
                                addVehicleToTable(vehicle)
                            end
    
                            local siren
    
                            if kjEnabledVehicles[vehicle].primary == true then
                                if kjEnabledVehicles[vehicle].siren >= 4 then
                                    siren = 1
                                else
                                    siren = kjEnabledVehicles[vehicle].siren + 1
                                end
    
                                TriggerServerEvent("kjELS:setSirenState", siren)
                                SoundVehicleHornThisFrame(vehicle)
    
                                --PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                                if Config.Beeps then
                                    SendNUIMessage(
                                        {
                                            transactionType = "playSound",
                                            transactionFile = "Beep",
                                            transactionVolume = 0.025
                                        }
                                    )
                                end
                            end
                        end
                    end
                end
                Wait(5)
            end
        end)
        
    end
end)


RegisterNetEvent("updateIndicators")
AddEventHandler(
    "updateIndicators",
    function(PID, dir, toggle)
        if GetPlayerFromServerId(PID) == -1 or GetPlayerFromServerId(PID) == nil then
            return
        end
        local Veh = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(PID)), false)
        if dir == "left" then
            SetVehicleIndicatorLights(Veh, 1, false)
            SetVehicleIndicatorLights(Veh, 0, false)
            SetVehicleIndicatorLights(Veh, 1, toggle)
        elseif dir == "right" then
            SetVehicleIndicatorLights(Veh, 1, false)
            SetVehicleIndicatorLights(Veh, 0, false)
            SetVehicleIndicatorLights(Veh, 0, toggle)
        elseif dir == "hazard" then
            SetVehicleIndicatorLights(Veh, 1, false)
            SetVehicleIndicatorLights(Veh, 0, false)
            SetVehicleIndicatorLights(Veh, 0, toggle)
            SetVehicleIndicatorLights(Veh, 1, toggle)
        end
    end
)
