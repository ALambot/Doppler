--[[

    Structure of a dop :
        - ID        : unique identifier
        - command   : command or text to run/print at a given interval
        - delay     : the given interval
        - running   : true if the dop is running, false if stopped
        - exist     : false if the dop has been deleted
        - current   : a timer, when it reaches the "delay" value it the "command" will be run
        - frame     : reference to the UI frame of that dop

  ]]

Doppler = LibStub("AceAddon-3.0"):NewAddon("Doppler")
GUI = LibStub("AceGUI-3.0")


function Doppler:OnInitialize()
    -- Called when the addon is loaded
    Doppler.dopHolder = {}
    Doppler.dopHolder["count"] = 0
    Doppler.dopHolder["dops"] = {}
end

function Doppler:OnEnable()
    -- Called when the addon is enabled
    Doppler.InitGUI()
    Doppler.InitTick()
end

function Doppler:OnDisable()
    -- Called when the addon is disabled
end

-----

function Doppler:CreateDop(command, delay)

    local dop = {}
    dop["command"] = command
    dop["delay"] = delay

    dop["current"] = 0
    dop["running"] = false
    dop["exist"] = true

    local gui = GUI.mainScroll

    local labelCmd = GUI:Create("Label")
    labelCmd:SetText(command)
    local labelDelay = GUI:Create("Label")
    labelDelay:SetText(delay)

    gui:AddChild(labelCmd)
    gui:AddChild(labelDelay)

    dop["frame"] = gui

    return dop
end

function Doppler:AddDop(dop)
    local dH = Doppler.dopHolder
    local dops = dH["dops"]
    dop["ID"] = dh["count"]
    dops[dH["count"]] = dop
    dH["count"] = dh["count"] + 1
end

function Doppler:RemoveDop(dop)
    dop["exist"] == false
    dop["running"] == false
    -- hide frame
end

-----

function Doppler.InitTick()
    Doppler.TICK_PERIOD = 3

    Doppler.tickCounter = 0
    Doppler.LoopFrame = CreateFrame("Frame")
    Doppler.LoopFrame.elapsed = 0
    Doppler.LoopFrame:SetScript("OnUpdate", Doppler.OnUpdate)
end

function Doppler.OnUpdate(self, elapsed)
    self.elapsed = self.elapsed+elapsed
    Doppler.tickCounter = Doppler.tickCounter + elapsed
    if Doppler.tickCounter > Doppler.TICK_PERIOD then
       Doppler.UpdateTick(elapsed)
       Doppler.tickCounter = Doppler.tickCounter % Doppler.TICK_PERIOD
    end
end

function Doppler.UpdateTick(elapsed)
    local dH = Doppler.dopHolder
    local dops = dh["dops"]
    for i = 0,dh["count"]-1,1 do
        local dop = dops[i]
        if dop["exist"] and dop["running"] then
            dop["current"] = dop["current"] + elapsed
            if dop["current"] > dop["delay"] then
                SendChatMessage(dop["command"],"GUILD")
                dop["current"] = dop["current"]%dop["delay"]
            end
        end
    end
end

-----

function Doppler.InitGUI()

    GUI.mainFrame = GUI:Create("Frame")
    GUI.mainFrame:SetCallback("OnClose",function(widget) GUI:Release(widget) end)
    GUI.mainFrame:SetTitle("Doppler")
    GUI.mainFrame:SetLayout("Flow")
    GUI.mainFrame:SetWidth(200)
    GUI.mainFrame:SetHeight(500)

    GUI.mainScroll = GUI:Create("ScrollFrame")
    GUI.mainScroll:SetFullHeight(true)
    GUI.mainScroll:SetLayout("Flow")
    GUI.mainFrame:AddChild(GUI.mainScroll)

    GUI.but = GUI:Create("Button")
    GUI.but:SetCallback("OnClick", function() Doppler:CreateDop("kek","keke") end)
    GUI.mainScroll:AddChild(GUI.but)

end
