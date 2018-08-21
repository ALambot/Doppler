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

print("HELLO")

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


    local Group = GUI:Create("InlineGroup")
    Group:SetFullWidth(true)
    Group:SetLayout("Flow")

    local labelCmd = GUI:Create("Label")
    labelCmd:SetText(command)
    labelCmd:SetRelativeWidth(0.5)
    local labelDelay = GUI:Create("Label")
    labelDelay:SetText(delay)
    labelCmd:SetRelativeWidth(0.2)
    local buttonRun = GUI:Create("Button")
    buttonRun:SetRelativeWidth(0.14)
    local buttonDel = GUI:Create("Button")
    buttonDel:SetRelativeWidth(0.14)

    Group:AddChild(labelCmd)
    Group:AddChild(labelDelay)
    Group:AddChild(buttonRun)
    Group:AddChild(buttonDel)

    GUI.Scroll:AddChild(Group)

    dop["frame"] = gui

    return dop
end

function Doppler:AddDop(dop)
    local dH = Doppler.dopHolder
    local dops = dH["dops"]
    dop["ID"] = dH["count"]
    dops[dH["count"]] = dop
    dH["count"] = dH["count"] + 1
end

function Doppler:RemoveDop(dop)
    dop["exist"] = false
    dop["running"] = false
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
    print("TICK")
    local dH = Doppler.dopHolder
    local dops = dH["dops"]
    for i = 0,dH["count"]-1,1 do
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

    GUI.mainFrame = GUI:Create("MainFrame")
    GUI.mainFrame:SetCallback("OnClose",function(widget) GUI:Release(widget) end)
    GUI.mainFrame:SetTitle("Doppler")
    GUI.mainFrame:SetLayout("Flow")
    GUI.mainFrame:SetWidth(200)
    GUI.mainFrame:SetHeight(500)

    GUI.Header = GUI:Create("InlineGroup")
    GUI.Header:SetFullWidth(true)
    GUI.Header:SetLayout("Flow")

    GUI.HeaderCommand = GUI:Create("EditBox")
    GUI.HeaderCommand:SetLabel("Commande")
    GUI.HeaderCommand:SetRelativeWidth(0.8)

    GUI.HeaderDelay = GUI:Create("EditBox")
    GUI.HeaderDelay:SetLabel("Délai")
    GUI.HeaderDelay:SetRelativeWidth(0.19)

    GUI.HeaderButton = GUI:Create("Button")
    GUI.HeaderButton:SetFullWidth(true)
    GUI.HeaderButton:SetCallback("OnClick", function()
        local dop = Doppler:CreateDop(GUI.HeaderCommand:GetText(),GUI.HeaderDelay:GetText())
        Doppler:AddDop(dop)
    end)

    GUI.Header:AddChild(GUI.HeaderCommand)
    GUI.Header:AddChild(GUI.HeaderDelay)
    GUI.Header:AddChild(GUI.HeaderButton)

    GUI.ScrollContainer = GUI:Create("InlineGroup")
    GUI.ScrollContainer:SetFullWidth(true)
    GUI.ScrollContainer:SetFullHeight(true)
    GUI.ScrollContainer:SetLayout("Fill")

    GUI.Scroll = GUI:Create("ScrollFrame")
    GUI.Scroll:SetFullHeight(true)
    GUI.Scroll:SetFullWidth(true)
    GUI.Scroll:SetLayout("List")
    GUI.ScrollContainer:AddChild(GUI.Scroll)

    GUI.mainFrame:AddChild(GUI.Header)
    GUI.mainFrame:AddChild(GUI.ScrollContainer)

end
