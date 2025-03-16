--[[
    Script Setup:
        - Requirements:
            - An executor (duh)
            - Be injected into roblox using said executor (brain blown)
        
        - Steps:
            - 1. Choose ur destired options within the "env.Settings" table, the comments are there to EASILY tell u what to put.
            - 2. Execute the script bruh and it's that easy.
]]--

local env = getgenv()

env.Settings = {
    ["MessageToSend"] = "", -- PUT THE EXACT CHAT MESSAGE YOU WANT TO SEND HERE, MUST COMPLY WITH ROBLOX FILTER! >:(    (because i'm not making a free chat bypasser yallah...)
    ["AmountOfMessages"] = 3, -- PUT THE AMOUNT OF MESSAGES YOU WISH TO SEND HERE (NUMBER ONLY!!!)
    ["TimeBetweenMessage"] = 5, -- PUT THE TIME (SECONDS) YOU WANT TO WAIT IN BETWEEN EACH MESSAGE HERE (NUMBER ONLY!!!)
}

if not (queue_on_teleport) then game.Players.LocalPlayer:Kick("Executor unsupported: (queue_on_teleport) not found.") end
if not (http_request or request or env.http_request or env.request) then game.Players.LocalPlayer:Kick("Executor unsupported: (request) not found.") end

local httprequest = http_request or request
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")

queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/sulfu3r/Newer-Pentest-Projects/refs/heads/main/Requests/Advertiser.luau'))()")

for i = 1, env.Settings["AmountOfMessages"] do
    local new_strng = env.Settings["MessageToSend"] .. "\r\n"

    TextChatService.TextChannels.RBXGeneral:SendAsync(new_strng)
    task.wait(env.Settings["TimeBetweenMessage"])
end

-- FULL CREDIT TO INFINITE YIELD SOURCE FOR THIS FUNCTION BELOW
-- SCRIPT CAN BE FOUND HERE: https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source

if request then
    local FoundServers = {}
    local Request = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", game.PlaceId)})
    local Body = HttpService:JSONDecode(Request.Body)

    if Body and Body.data then
        for i, v in next, Body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(FoundServers, 1, v.id)
            end
        end
    end

    if #FoundServers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, FoundServers[math.random(1, #FoundServers)], game.Players.LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId)
    end
end
