local function loadModel(model)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then
        return 0
    end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(50)
    end
    return hash
end

local function foundVehicleInBdd(model)
    local selectedVeh = 0
    for idx, veh in pairs(garage.Vehicles) do
        if model == veh.model then
            selectedVeh = veh
            break
        end
    end
    return selectedVeh
end

local function foundVehicleIdInBdd(vehIdsBdd, vehId)
    for idx, vehIdBdd in pairs(vehIdsBdd) do
        if vehIdBdd == vehId then
            return index
        end
    end
end

local function isVehicleOut(veh)
    return (veh <= 0)
end

local function getSpawnPoint(garage, model)
    if IsThisModelACar(model) then
        return garage.SpawnCarPoint
    elseif IsThisModelAHeli(model) then
        return garage.SpawnHeliPoint
    end
    return 0
end

local function spawnVehicle(garage, veh)
    local hash = loadModel(veh.model)
    local spawnpoint = getSpawnPoint(garage, veh.model)
    if not spawnpoint then
        return false
    end
    local spawnedVeh = CreateVehicle(hash, spawnpoint.x, spawnpoint.y, spawnpoint.z, spawnpoint.w, true, true)
    SetEntityAsMissionEntity(spawnedVeh, true, true)
    table.insert(veh.vehId, spawnedVeh)
end

local function getOutVehicle(garage, model)
    local veh = foundVehicleInBdd(model)
    if not veh then
        return veh
    end
    if isVehicleOut(veh) then
        print("Vehicle already out!")
    end
    spawnVehicle(garage, veh)
    veh.nb = veh.nb - 1
end

RegisterCommand("garage", function(_, args)
    if #args == 0 or #args > 2 then
        return
    end
    local garage = Config.Garages[args[1]]
    local model = args[2]
    getOutVehicle(garage, model)
end)

RegisterCommand("delgarage", function(_, args)
    if #args == 0 or #args > 1 then
        return
    end
    local garage = Config.Garages[args[1]]
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        return
    end
    local vehModel = GetEntityModel(veh)
    local vehBdd = foundVehicleInBdd(vehModel)

    local index = foundVehicleIdInBdd(vehBdd.vehId, veh)
    table.remove(vehBdd.vehId, index)
    DeleteEntity(veh)
    vehBdd.nb = vehBdd.nb + 1
end)
