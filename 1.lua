local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer

local jobId = _G.SPOTIFY_SERVER_ID

if jobId and jobId ~= "" then
    TeleportService:TeleportToPlaceInstance(
        game.PlaceId, -- otomatis ambil dari game sekarang
        jobId,
        player
    )
end
