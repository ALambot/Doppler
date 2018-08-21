--------------------------------------------------------------
--
-- "THE BEERWARE LICENSE" (Revision 42):
-- Prosper wrote this code. As long as you retain this
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
--
--------------------------------------------------------------

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
-- Dop creation and removal
-----

function Doppler:CreateDop(command, delay)

    local dop = {}
    dop["command"] = command
    dop["delay"] = tonumber(delay)

    if dop["delay"] == nil then return nil end
    if dop["delay"] < 0.5 then dop["delay"] = 0.5 end
    if dop["delay"] > 1000 then dop["delay"] = 1000 end

    dop["current"] = dop["delay"]
    dop["running"] = false
    dop["exist"] = true

    local Group = Doppler:BuildDopFrame(dop, command, delay)
    GUI.Scroll:AddChild(Group)

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
    Doppler:RebuildScroll()
end

function Doppler:BuildDopFrame(dop)
    local command = dop["command"]
    local delay = dop["delay"]

    local Group = GUI:Create("DopplerInlineGroupProgress")
    Group:SetFullWidth(true)
    Group:SetHeight(15)
    Group:SetLayout("Flow")

    local labelCmd = GUI:Create("Label")
    labelCmd:SetText(command)
    labelCmd:SetFontObject(ChatFontNormal)
    labelCmd:SetRelativeWidth(0.8)
    local labelDelay = GUI:Create("Label")
    labelDelay:SetText(delay.." sec")
    labelDelay:SetFontObject(ChatFontNormal)
    labelDelay:SetColor(.8,.8,0)
    labelDelay:SetRelativeWidth(0.19)

    local buttonRun = GUI:Create("Button")
    buttonRun:SetRelativeWidth(0.6)
    buttonRun:SetText("Run")
    if dop["running"] then buttonRun:SetText("Stop") end
    buttonRun:SetCallback("OnClick", function()
        if not dop["running"] then
            dop["current"] = dop["delay"]
            dop["running"] = true
            buttonRun:SetText("Stop")
        else
            dop["current"] = 0
            dop["running"] = false
            dop["frame"]:SetProgress(0)
            buttonRun:SetText("Run")
        end
    end)
    local buttonDel = GUI:Create("Button")
    buttonDel:SetRelativeWidth(0.39)
    buttonDel:SetText("Del")
    buttonDel:SetCallback("OnClick", function()
        dop["frame"]:SetProgress(0)
        Doppler:RemoveDop(dop)
    end)

    Group:AddChild(labelCmd)
    Group:AddChild(labelDelay)
    Group:AddChild(buttonRun)
    Group:AddChild(buttonDel)

    dop["frame"] = Group

    return Group
end

function Doppler:RebuildScroll()
    local Scroll = GUI.Scroll
    Scroll:ReleaseChildren()
    local dH = Doppler.dopHolder
    local dops = dH["dops"]
    for i=0,dH["count"]-1,1 do
        local dop = dops[i]
        if dop["exist"] then
            local Group = Doppler:BuildDopFrame(dop)
            dop["frame"]:SetProgress(0)
            Scroll:AddChild(Group)
        end
    end
end

-----
-- Loop and Tick functions
-----

function Doppler.InitTick()
    Doppler.TICK_PERIOD = 0.25

    Doppler.oldCurTime = 0
    Doppler.tickCounter = 0
    Doppler.LoopFrame = CreateFrame("Frame")
    Doppler.LoopFrame.elapsed = 0
    Doppler.LoopFrame:SetScript("OnUpdate", Doppler.OnUpdate)
end

function Doppler.OnUpdate(self, elapsed)
    self.elapsed = self.elapsed+elapsed
    Doppler.tickCounter = Doppler.tickCounter + elapsed
    if Doppler.tickCounter > Doppler.TICK_PERIOD then
       Doppler.UpdateTick(self.elapsed)
       Doppler.tickCounter = Doppler.tickCounter % Doppler.TICK_PERIOD
    end
end

function Doppler.UpdateTick(curTime)
    local elapsed = curTime - Doppler.oldCurTime
    Doppler.oldCurTime = curTime

    --print("TICK "..elapsed)
    local dH = Doppler.dopHolder
    local dops = dH["dops"]
    for i = 0,dH["count"]-1,1 do
        local dop = dops[i]
        if dop["exist"] and dop["running"] then
            dop["current"] = dop["current"] + elapsed
            dop["frame"]:SetProgress(dop["current"]/dop["delay"])
            if dop["current"] > dop["delay"] then
                SendChatMessage(dop["command"],"GUILD")
                dop["current"] = dop["current"]%dop["delay"]
            end
        end
    end
end

-----
-- Main GUI
-----

function Doppler.InitGUI()

    GUI.mainFrame = GUI:Create("DopplerMainFrame")
    GUI.mainFrame:SetCallback("OnClose",function(widget) GUI:Release(widget) end)
    GUI.mainFrame:SetTitle("Doppler")
    GUI.mainFrame:SetLayout("Flow")
    GUI.mainFrame:SetWidth(200)
    GUI.mainFrame:SetHeight(50) -- minimized

    GUI.Header = GUI:Create("InlineGroup")
    GUI.Header:SetFullWidth(true)
    GUI.Header:SetLayout("Flow")

    GUI.HeaderCommand = GUI:Create("DopplerEditBox")
    GUI.HeaderCommand:SetLabel("Commande")
    GUI.HeaderCommand:SetRelativeWidth(0.8)

    GUI.HeaderDelay = GUI:Create("DopplerEditBox")
    GUI.HeaderDelay:SetLabel("Délai")
    GUI.HeaderDelay:SetRelativeWidth(0.19)

    GUI.HeaderButton = GUI:Create("Button")
    GUI.HeaderButton:SetFullWidth(true)
    GUI.HeaderButton:SetText("Create")
    GUI.HeaderButton:SetCallback("OnClick", function()
        local dop = Doppler:CreateDop(GUI.HeaderCommand:GetText(),GUI.HeaderDelay:GetText())
        if dop == nil then
            GUI.HeaderDelay:SetText("")
        else
            Doppler:AddDop(dop)
            GUI.HeaderCommand:SetText("")
            GUI.HeaderDelay:SetText("")
        end
    end)

    GUI.Header:AddChild(GUI.HeaderCommand)
    GUI.Header:AddChild(GUI.HeaderDelay)
    GUI.Header:AddChild(GUI.HeaderButton)

    GUI.ScrollContainer = GUI:Create("DopplerInlineGroup")
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
