local triggers = {"ping doppler", "ping prosper"}
local channel = "xtensionxtooltip2"
local answer = "Doppler"

JoinChannelByName(channel,nil,nil,nil)
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:SetScript("OnEvent", function(self, event, ...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg11, arg12 = ...
    if arg9 == channel then
        local msg = string.lower(arg1)
        local flag = false
        for k,v in pairs(triggers) do
            flag = (v == msg) or flag
        end
        if flag then
            local channelIndex = GetChannelName(channel)
            if channelIndex ~= nil then
                SendChatMessage(answer, "CHANNEL", nil, channelIndex)
            end
        end
    end
end)
