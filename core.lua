Doppler = LibStub("AceAddon-3.0"):NewAddon("Doppler")
GUI = LibStub("AceGUI-3.0")


function Doppler:OnInitialize()
    -- Called when the addon is loaded
    Doppler.dops = {}
    Doppler.InitGUI()
    Doppler.InitTick()
end

function Doppler:OnEnable()
    -- Called when the addon is enabled
end

function Doppler:OnDisable()
    -- Called when the addon is disabled
end

function Doppler:CreateDop(command , delay)
    local dop = {}
    dop["command"] = command
    dop["delay"] = delay

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
       Doppler.UpdateTick(self.elapsed)
       Doppler.tickCounter = Doppler.tickCounter % Doppler.TICK_PERIOD
    end
end

function Doppler.UpdateTick(curTime)
    print(curTime)
end

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

--[[
AceTest = LibStub("AceAddon-3.0"):NewAddon("AceTest", "AceConsole-3.0")
GUI = LibStub("AceGUI-3.0")

function AceTest:OnInitialize()
    -- Called when the addon is loaded
end

function AceTest:OnEnable()
    -- Called when the addon is enabled
end

function AceTest:OnDisable()
    -- Called when the addon is disabled
end

-- Create a container frame
local f = GUI:Create("Frame")
f:SetCallback("OnClose",function(widget) GUI:Release(widget) end)
f:SetTitle("Prosper Mk22")
--f:SetStatusText("Status Bar")
f:SetLayout("Fill")

local g = GUI:Create("SimpleGroup")
g:SetLayout("Fill")
f:AddChild(g)

scroll = GUI:Create("ScrollFrame")
scroll:SetLayout("Flow")
g:AddChild(scroll)

local btn = GUI:Create("Button")
btn:SetWidth(170)
btn:SetText("Button !")
btn:SetCallback("OnClick", function() print("Click!") end)
scroll:AddChild(btn)

local btn1 = GUI:Create("Button")
btn1:SetWidth(170)
btn1:SetText("Button !1")
btn1:SetCallback("OnClick", function() print("Click!1") end)
scroll:AddChild(btn1)
]]
