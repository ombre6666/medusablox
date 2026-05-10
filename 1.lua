local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer

local data = _G.SPOTIFY_SERVER_ID

if data and typeof(data) == "table" then
    local placeId = data[1]
    local jobId = data[2]

    if placeId and jobId then
        if game.PlaceId ~= placeId or game.JobId ~= jobId then
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        end
    end
end
