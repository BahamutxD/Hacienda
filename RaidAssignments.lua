RaidAssignments = CreateFrame("Button", "RaidAssignments", UIParent)
RaidAssignments.ToolTip = CreateFrame("Button", "ToolTip", UIParent)
RaidAssignments.HealToolTip = CreateFrame("Button", "HealToolTip", UIParent)
RaidAssignments.GeneralToolTip = CreateFrame("Button", "GeneralToolTip", UIParent)
RaidAssignments.MinimapButton = CreateFrame("Button", "RaidAssignmentsMinimapButton", Minimap)
RaidAssignments.GeneralAssignments = CreateFrame("Button", "GeneralAssignments", UIParent)

RaidAssignments_Settings = RaidAssignments_Settings or {}

RaidAssignments.RoleFilter = {
    TankPrimary = { Warrior = true, Druid = true, Paladin = true, Shaman = true },
    Healer = { Priest = true, Druid = true, Shaman = true, Paladin = true }
}

RaidAssignments_Settings = RaidAssignments_Settings or {}
RaidAssignments_Settings["useWhisper"] = RaidAssignments_Settings["useWhisper"] or false

RaidAssignments.Settings = {
	["MainFrame"] = false,
	["Animation"] = false,
	["MainFrameX"] = 950,
	["MainFrameY"] = 650,
	["SizeX"] = 0,
	["SizeY"] = 0,
	["active"] = "",
	["active_heal"] = "",
	["active_general"] = "",
	["MinimapPos"] = 0,
	["GeneralFrame"] = false,
	["GeneralAnimation"] = false,
	["GeneralFrameX"] = 700,
	["GeneralFrameY"] = 560, -- Increased by 60 to accommodate EditBox fields
	["GeneralSizeX"] = 0,
	["GeneralSizeY"] = 0,
}

RaidAssignments.Marks = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
}

RaidAssignments.RealMarks = {
	[1] = "Star",
	[2] = "Circle",
	[3] = "Diamond",
	[4] = "Triangle",
	[5] = "Moon",
	[6] = "Square",
	[7] = "Cross",
	[8] = "Skull",
}

RaidAssignments.HealMarks = {
	[1] = {nil, nil, nil, nil},
	[2] = {nil, nil, nil, nil},
	[3] = {nil, nil, nil, nil},
	[4] = {nil, nil, nil, nil},
	[5] = {nil, nil, nil, nil},
	[6] = {nil, nil, nil, nil},
	[7] = {nil, nil, nil, nil},
	[8] = {nil, nil, nil, nil},
	[9] = {nil, nil, nil, nil},
	[10] = {nil, nil, nil, nil},
	[11] = {nil, nil, nil, nil},
	[12] = {nil, nil, nil, nil},
}

RaidAssignments.HealRealMarks = {
	[1] = "D",
	[2] = "C",
	[3] = "B",
	[4] = "A",
	[5] = "4",
	[6] = "3",
	[7] = "2",
	[8] = "1",
	[9] = "South",
	[10] = "North",
	[11] = "Right",
	[12] = "Left",
}

RaidAssignments.GeneralMarks = {
[1] = {}, [2] = {}, [3] = {}, [4] = {},
[5] = {}, [6] = {}, [7] = {}, [8] = {},
[9] = {}, [10] = {}, -- new custom marks
}


RaidAssignments.GeneralRealMarks = {
[1] = "1: North",
[2] = "2: North East",
[3] = "3: East",
[4] = "4: South East",
[5] = "5: South",
[6] = "6: South West",
[7] = "7: West",
[8] = "8: North West",
[9] = "", -- editable
[10] = "", -- editable
}

RaidAssignments.Frames = {
	["ToolTip"] = {},
	["HealToolTip"] = {},
	["GeneralToolTip"] = {},
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
}

RaidAssignments.HealFrames = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
	[9] = {},
	[10] = {},
	[11] = {},
	[12] = {},
}

RaidAssignments.GeneralFrames = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
	[9] = {},
   [10] = {},
}

RaidAssignments.Classes = {
	[1] = "Warrior",
	[2] = "Warlock",
	[3] = "Rogue",
	[4] = "Priest",
	[5] = "Mage",
	[6] = "Hunter",
	[7] = "Druid",
	[8] = "Paladin",
	[9] = "Shaman",
}

RaidAssignments.ChanTable = {
	["s"] = "SAY",
	["y"] = "YELL",
	["e"] = "EMOTE",
	["g"] = "GUILD",
	["p"] = "PARTY",
	["r"] = "RAID",
	["1"] = {"CHANNEL", "1"},
	["2"] = {"CHANNEL", "2"},
	["3"] = {"CHANNEL", "3"},
	["4"] = {"CHANNEL", "4"},
	["5"] = {"CHANNEL", "5"},
	["6"] = {"CHANNEL", "6"},
	["7"] = {"CHANNEL", "7"},
	["8"] = {"CHANNEL", "8"},
	["9"] = {"CHANNEL", "9"},
}

-- Test mode variables
RaidAssignments.TestMode = false
RaidAssignments.TestRoster = {}

-- events
RaidAssignments:RegisterEvent("ADDON_LOADED")
RaidAssignments:RegisterEvent("RAID_ROSTER_UPDATE")
RaidAssignments:RegisterEvent("CHAT_MSG_WHISPER")
RaidAssignments:RegisterEvent("UNIT_PORTRAIT_UPDATE")
RaidAssignments:RegisterEvent("CHAT_MSG_ADDON") 
RaidAssignments:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

function RaidAssignments:OnEvent()
    if event == "ADDON_LOADED" and arg1 == "RaidAssignments" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: RaidAssignments 2.0 Loaded!")
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: /ta - open/close RaidAssignments")
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: /ta test - toggle test mode with 40 dummy players")
        RaidAssignments_Settings["usecolors"] = true
        RaidAssignments:ConfigMainFrame()
        RaidAssignments:ConfigGeneralFrame()
        RaidAssignments:UnregisterEvent("ADDON_LOADED")
    elseif event == "RAID_ROSTER_UPDATE" then 
        RaidAssignments:UpdateTanks()
        RaidAssignments:UpdateHeals()
        RaidAssignments:UpdateGeneral()
    elseif event == "UNIT_PORTRAIT_UPDATE" then
        RaidAssignments:UpdateTanks()
        RaidAssignments:UpdateHeals()
        RaidAssignments:UpdateGeneral()
    elseif event == "CHAT_MSG_ADDON" then
        if (arg1 == "TankAssignmentsMarks" or arg1 == "HealAssignmentsMarks" or arg1 == "RaidAssignmentsGeneralMarks" or arg1 == "RaidAssignmentsCustomLabels" or string.sub(arg1, 1, 15) == "RaidAssignments") and UnitName("player") ~= arg4 then
            if arg1 == "TankAssignmentsMarks" then
                RaidAssignments.Marks = {
                    [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {},
                }
                for text in string.gfind(arg2, "%d%a+") do
                    local mark = tonumber(string.sub(text, 1, 1))
                    table.insert(RaidAssignments.Marks[mark], string.sub(text, 2, string.len(text)))
                end
                RaidAssignments:UpdateTanks()
            elseif arg1 == "HealAssignmentsMarks" then
                RaidAssignments.HealMarks = {
                    [1] = {nil, nil, nil, nil}, [2] = {nil, nil, nil, nil}, [3] = {nil, nil, nil, nil},
                    [4] = {nil, nil, nil, nil}, [5] = {nil, nil, nil, nil}, [6] = {nil, nil, nil, nil},
                    [7] = {nil, nil, nil, nil}, [8] = {nil, nil, nil, nil}, [9] = {nil, nil, nil, nil},
                    [10] = {nil, nil, nil, nil}, [11] = {nil, nil, nil, nil}, [12] = {nil, nil, nil, nil},
                }
                -- Parse heal assignments with underscore separator
                local pos = 1
                while pos <= string.len(arg2) do
                    local markEnd = string.find(arg2, "_", pos)
                    if not markEnd then break end
                    local slotEnd = string.find(arg2, "_", markEnd + 1)
                    if not slotEnd then break end
                    local nameEnd = string.find(arg2, ",", slotEnd + 1)
                    if not nameEnd then nameEnd = string.len(arg2) + 1 end
                    
                    local mark = tonumber(string.sub(arg2, pos, markEnd - 1))
                    local slot = tonumber(string.sub(arg2, markEnd + 1, slotEnd - 1))
                    local name = string.sub(arg2, slotEnd + 1, nameEnd - 1)
                    
                    if mark and slot and slot <= 4 and name and name ~= "" then
                        RaidAssignments.HealMarks[mark][slot] = name
                    end
                    pos = nameEnd + 1
                end
                RaidAssignments:UpdateHeals()
            elseif arg1 == "RaidAssignmentsGeneralMarks" then
                -- Initialize ALL marks including custom ones
                for i = 1, 10 do
                    if not RaidAssignments.GeneralMarks[i] then
                        RaidAssignments.GeneralMarks[i] = {}
                    else
                        -- Clear existing assignments for this mark
                        RaidAssignments.GeneralMarks[i] = {}
                    end
                end
                
                -- Parse general assignments with underscore separator
                local pos = 1
                while pos <= string.len(arg2) do
                    local markEnd = string.find(arg2, "_", pos)
                    if not markEnd then break end
                    local slotEnd = string.find(arg2, "_", markEnd + 1)
                    if not slotEnd then break end
                    local nameEnd = string.find(arg2, ",", slotEnd + 1)
                    if not nameEnd then nameEnd = string.len(arg2) + 1 end
                    
                    local mark = tonumber(string.sub(arg2, pos, markEnd - 1))
                    local slot = tonumber(string.sub(arg2, markEnd + 1, slotEnd - 1))
                    local name = string.sub(arg2, slotEnd + 1, nameEnd - 1)
                    
                    if mark and slot and name and name ~= "" and mark >= 1 and mark <= 10 then
                        if not RaidAssignments.GeneralMarks[mark] then
                            RaidAssignments.GeneralMarks[mark] = {}
                        end
                        RaidAssignments.GeneralMarks[mark][slot] = name
                    end
                    pos = nameEnd + 1
                end
                RaidAssignments:UpdateGeneral()
            elseif arg1 == "RaidAssignmentsCustomLabels" then
    -- Parse custom mark labels with underscore separator
	local pos = 1
		while pos <= string.len(arg2) do
			local markEnd = string.find(arg2, "_", pos)
			if not markEnd then break end
			local labelEnd = string.find(arg2, ",", markEnd + 1)
			if not labelEnd then labelEnd = string.len(arg2) + 1 end
			
			local mark = tonumber(string.sub(arg2, pos, markEnd - 1))
			local label = string.sub(arg2, markEnd + 1, labelEnd - 1)
			
			if mark and (mark == 9 or mark == 10) and label ~= nil then  -- Changed: Allow empty string to clear
				RaidAssignments.GeneralRealMarks[mark] = label
				-- Update the EditBox if it exists
				local editBox = _G["G"..mark.."_Edit"]
				if editBox then
					editBox:SetText(label)
				end
			end
			pos = labelEnd + 1
		end
		RaidAssignments:UpdateGeneral()  -- Add this to refresh UI after label sync
	end
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        if UnitExists("mouseover") then
            if GetRaidTargetIndex("mouseover") then
                for i = 1, 8 do
                    if GetRaidTargetIndex("mouseover") == i and table.getn(RaidAssignments.Marks[i]) > 0 then
                        local names = ""
                        for k, v in pairs(RaidAssignments.Marks[i]) do
                            names = names .. " " .. v
                        end
                        GameTooltip:AddDoubleLine("RaidAssignments", names, 0.78, 0.61, 0.43, 1, 1, 1)
                    end
                end
            end
        end
    end
end

function RaidAssignments:ConfigMainFrame()
    RaidAssignments.Drag = {}
    function RaidAssignments.Drag:StartMoving()
        RaidAssignments:StartMoving()
        this.drag = true
    end
    
    function RaidAssignments.Drag:StopMovingOrSizing()
        RaidAssignments:StopMovingOrSizing()
        this.drag = false
    end
    
    local backdrop = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false,
        tileSize = 16,
        edgeSize = 2,
        insets = {
            left = 1,
            right = 1,
            top = 1,
            bottom = 1
        }
    }
    
    self:SetFrameStrata("BACKGROUND")
    self:SetWidth(RaidAssignments.Settings["MainFrameX"]) 
    self:SetHeight(RaidAssignments.Settings["MainFrameY"]) 
    self:SetPoint("CENTER",0,100)
    self:SetMovable(true)
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetBackdrop(backdrop)
    self:SetBackdropColor(0,0,0,1)
    self:SetBackdropBorderColor(1,1,1,0.5)

    self:SetScript("OnUpdate", function()
        local updfreq = math.floor(GetFramerate()) * 0.3
        if RaidAssignments:IsVisible() then
            if not RaidAssignments.Settings["MainFrame"] then
                if RaidAssignments.Settings["SizeX"] >= RaidAssignments.Settings["MainFrameX"] and RaidAssignments.Settings["SizeY"] >= RaidAssignments.Settings["MainFrameY"] then
                    RaidAssignments.Settings["MainFrame"] = true
                    RaidAssignments:SetWidth(RaidAssignments.Settings["MainFrameX"])
                    RaidAssignments:SetHeight(RaidAssignments.Settings["MainFrameY"])
                    RaidAssignments.bg:Show()
                    RaidAssignments:UpdateTanks()
                    RaidAssignments:UpdateHeals()
                else
                    if RaidAssignments.Settings["SizeX"] < RaidAssignments.Settings["MainFrameX"] then
                        RaidAssignments.Settings["SizeX"] = RaidAssignments.Settings["SizeX"] + (RaidAssignments.Settings["MainFrameX"] / updfreq)
                        RaidAssignments:SetWidth(RaidAssignments.Settings["SizeX"])
                    end
                    if RaidAssignments.Settings["SizeY"] < RaidAssignments.Settings["MainFrameY"] then
                        RaidAssignments.Settings["SizeY"] = RaidAssignments.Settings["SizeY"] + (RaidAssignments.Settings["MainFrameY"] / updfreq)
                        RaidAssignments:SetHeight(RaidAssignments.Settings["SizeY"])
                    end
                end
            else
                if RaidAssignments.Settings["Animation"] then
                    RaidAssignments.bg:Hide()
                    if RaidAssignments.Settings["SizeX"] <= 0 and RaidAssignments.Settings["SizeY"] <= 0 then
                        RaidAssignments.Settings["MainFrame"] = false
                        RaidAssignments.Settings["Animation"] = false
                        RaidAssignments.bg:Hide()
                        RaidAssignments:Hide()
                    else
                        if RaidAssignments.Settings["SizeY"] >= 0 then
                            RaidAssignments.Settings["SizeY"] = RaidAssignments.Settings["SizeY"] - (RaidAssignments.Settings["MainFrameY"] / updfreq)
                            RaidAssignments:SetHeight(RaidAssignments.Settings["SizeY"])
                        end
                        if RaidAssignments.Settings["SizeY"] < RaidAssignments.Settings["MainFrameY"] / 4 then
                            RaidAssignments.Settings["SizeX"] = RaidAssignments.Settings["SizeX"] - (RaidAssignments.Settings["MainFrameX"] / updfreq)
                            RaidAssignments:SetWidth(RaidAssignments.Settings["SizeX"])
                        end    
                    end
                end
            end
        end
    end)    

    self.bg = CreateFrame("Button", "bg", RaidAssignments)
    self.bg:SetWidth(self:GetWidth()) 
    self.bg:SetHeight(self:GetHeight()) 
    self.bg:SetPoint("TOPLEFT",0,0)    
    self.bg:SetBackdropColor(0,0,0,1)
    self.bg:EnableMouse(true)
    self.bg:SetMovable(true)
    self.bg:RegisterForDrag("LeftButton")
    self.bg:SetScript("OnDragStart", RaidAssignments.Drag.StartMoving)
    self.bg:SetScript("OnDragStop", RaidAssignments.Drag.StopMovingOrSizing)
    self.bg:SetScript("OnEnter", function()
        RaidAssignments.ToolTip:Hide()
        RaidAssignments.HealToolTip:Hide()
    end)
    
    self.text = self.bg:CreateFontString(nil, "OVERLAY")
    self.text:SetPoint("TOP", self.bg, "TOP", 0, -20)
    self.text:SetFont("Interface\\AddOns\\RaidAssignments\\assets\\BalooBhaina.ttf", 25)
    local r,g,b = RaidAssignments:GetClassColors("Warrior","class")
    self.text:SetTextColor(r,g,b, 1)
    self.text:SetShadowOffset(2,-2)
    self.text:SetText("Raid Assignments")
    
    local classIconStartX = 50
    local classIconY = -25
    local i = 1
    for n, class in pairs(RaidAssignments.Classes) do	
        local r, l, t, b = RaidAssignments:ClassPos(class)
        local classframe = CreateFrame("Button", class, self.bg)
        classframe:SetWidth(22)
        classframe:SetHeight(22)
        classframe:SetBackdropColor(0,0,0,1)
        classframe:SetPoint("TOPLEFT", classIconStartX + (i*25), classIconY)
        classframe:SetFrameStrata("MEDIUM")
        classframe.Icon = classframe:CreateTexture(nil, "ARTWORK")
        classframe.Icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        classframe.Icon:SetTexCoord(r, l, t, b)
        classframe.Icon:SetPoint("TOPRIGHT", -1, -1)
        classframe.Icon:SetWidth(22)
        classframe.Icon:SetHeight(22)
        classframe:SetScript("OnEnter", function() 
            local r,g,b = RaidAssignments:GetClassColors(this:GetName(),"class")
            GameTooltip:SetOwner(classframe, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText("|cffFFFFFFShow|r "..this:GetName(), r,g,b)
            GameTooltip:Show()
        end)
        classframe:SetScript("OnLeave", function() GameTooltip:Hide() end)
        classframe:SetScript("OnMouseDown", function()
            if arg1 == "LeftButton" then
                if RaidAssignments_Settings[this:GetName()] == 1 then
                    RaidAssignments_Settings[this:GetName()] = 0
                    classframe.Icon:SetVertexColor(0.5, 0.5, 0.5)
                else
                    RaidAssignments_Settings[this:GetName()] = 1
                    classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)
                end
            end
        end)
        i = i + 1
        if RaidAssignments_Settings[class] == nil then
            RaidAssignments_Settings[class] = 1
            classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)			
        else
            if RaidAssignments_Settings[class] == 1 then
                classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)
            else
                classframe.Icon:SetVertexColor(0.5, 0.5, 0.5)
            end			
        end
    end

    local padding = 5
    for i = 8, 1, -1 do
        local r, l, t, b = RaidAssignments:GetMarkPos(i)
        local icon = CreateFrame("Frame", "T"..i, self.bg) 
        icon:SetWidth(35)
        icon:SetHeight(35) 
        icon:SetPoint("TOPLEFT", 50, 85 - ((35 + padding) * (12 - i)))
        icon:SetFrameStrata("MEDIUM")
        icon:EnableMouse(true)
        icon:SetScript("OnEnter", function()
            RaidAssignments:OpenToolTip(this:GetName())
        end)
        icon:SetScript("OnLeave", function() end)   
        
        icon.Icon = icon:CreateTexture(nil, "ARTWORK")
        icon.Icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        icon.Icon:SetTexCoord(r, l, t, b)
        icon.Icon:SetPoint("CENTER", 0,0)
        icon.Icon:SetWidth(35)
        icon.Icon:SetHeight(35)
    end
    
    local newHealOrder = {"D", "C", "B", "A", "4", "3", "2", "1", "South", "North", "Right", "Left"}
    local padding = 5
    for i = 12, 1, -1 do
        local icon = CreateFrame("Frame", "H"..i, self.bg) 
        icon:SetWidth(35)
        icon:SetHeight(35) 
        icon:SetPoint("TOPLEFT", 450, -75 - ((35 + padding) * (12 - i)))
        icon:SetFrameStrata("MEDIUM")
        icon:EnableMouse(true)
        icon:SetScript("OnEnter", function()
            RaidAssignments:OpenHealToolTip(this:GetName())
        end)
        icon:SetScript("OnLeave", function() end)   
        
        icon.Icon = icon:CreateTexture(nil, "ARTWORK")
        icon.Icon:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\" .. newHealOrder[i] .. ".tga")
        icon.Icon:SetPoint("CENTER", 0,0)
        icon.Icon:SetWidth(35)
        icon.Icon:SetHeight(35)
    end  
   
    self.CloseButton = CreateFrame("Button", nil, self.bg, "UIPanelCloseButton")
    self.CloseButton:SetPoint("TOPLEFT", self:GetWidth()-23, 2)
    self.CloseButton:SetWidth(24)
    self.CloseButton:SetHeight(24)
    self.CloseButton:SetFrameStrata("MEDIUM")
    self.CloseButton:SetScript("OnClick", function() 
        PlaySound("igMainMenuOptionCheckBoxOn")
        RaidAssignments.ToolTip:Hide()
        RaidAssignments.HealToolTip:Hide()
        RaidAssignments.Settings["Animation"] = true
        RaidAssignments.Settings["MainFrame"] = false
    end)
	
    -- In the ConfigMainFrame() function, replace the existing KT and 4H button code with this:

    -- KT Image Button
    self.ktButton = CreateFrame("Button", nil, self.bg, "UIPanelButtonTemplate")
    self.ktButton:SetPoint("BOTTOM", -440, 10) -- Moved further left
    self.ktButton:SetWidth(60)  -- Reduced from 72 to 60
    self.ktButton:SetHeight(24)
    self.ktButton:SetText("KT Image")
    self.ktButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        if not RaidAssignments.KTFrame then
            RaidAssignments.KTFrame = CreateFrame("Frame", "RaidAssignmentsKTFrame", UIParent)
            RaidAssignments.KTFrame:SetFrameStrata("DIALOG")
            RaidAssignments.KTFrame:SetWidth(512)
            RaidAssignments.KTFrame:SetHeight(512)
            RaidAssignments.KTFrame:SetPoint("CENTER", 0, 0)
            RaidAssignments.KTFrame:EnableMouse(true)
            RaidAssignments.KTFrame:SetMovable(true)
            RaidAssignments.KTFrame:RegisterForDrag("LeftButton")
            RaidAssignments.KTFrame:SetScript("OnDragStart", function() this:StartMoving() end)
            RaidAssignments.KTFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

            -- Image
            RaidAssignments.KTFrame.texture = RaidAssignments.KTFrame:CreateTexture(nil, "ARTWORK")
            RaidAssignments.KTFrame.texture:SetAllPoints(RaidAssignments.KTFrame)
            RaidAssignments.KTFrame.texture:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\KT.tga")

            -- Close Button
            RaidAssignments.KTFrame.close = CreateFrame("Button", nil, RaidAssignments.KTFrame, "UIPanelCloseButton")
            RaidAssignments.KTFrame.close:SetPoint("TOPRIGHT", RaidAssignments.KTFrame, "TOPRIGHT")
            RaidAssignments.KTFrame.close:SetScript("OnClick", function()
                RaidAssignments.KTFrame:Hide()
            end)
        end

        if RaidAssignments.KTFrame:IsShown() then
            RaidAssignments.KTFrame:Hide()
        else
            RaidAssignments.KTFrame:Show()
        end
    end)

    -- 4H Image Button
    self.fourhButton = CreateFrame("Button", nil, self.bg, "UIPanelButtonTemplate")
    self.fourhButton:SetPoint("LEFT", self.ktButton, "RIGHT", 5, 0) -- Reduced spacing from 10 to 5
    self.fourhButton:SetWidth(60)  -- Reduced from 72 to 60
    self.fourhButton:SetHeight(24)
    self.fourhButton:SetText("4H Image")
    self.fourhButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        if not RaidAssignments.FourHFrame then
            RaidAssignments.FourHFrame = CreateFrame("Frame", "RaidAssignmentsFourHFrame", UIParent)
            RaidAssignments.FourHFrame:SetFrameStrata("DIALOG")
            RaidAssignments.FourHFrame:SetWidth(512)
            RaidAssignments.FourHFrame:SetHeight(512)
            RaidAssignments.FourHFrame:SetPoint("CENTER", 0, 0)
            RaidAssignments.FourHFrame:EnableMouse(true)
            RaidAssignments.FourHFrame:SetMovable(true)
            RaidAssignments.FourHFrame:RegisterForDrag("LeftButton")
            RaidAssignments.FourHFrame:SetScript("OnDragStart", function() this:StartMoving() end)
            RaidAssignments.FourHFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

            -- Image
            RaidAssignments.FourHFrame.texture = RaidAssignments.FourHFrame:CreateTexture(nil, "ARTWORK")
            RaidAssignments.FourHFrame.texture:SetAllPoints(RaidAssignments.FourHFrame)
            RaidAssignments.FourHFrame.texture:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\4H.tga")

            -- Close Button
            RaidAssignments.FourHFrame.close = CreateFrame("Button", nil, RaidAssignments.FourHFrame, "UIPanelCloseButton")
            RaidAssignments.FourHFrame.close:SetPoint("TOPRIGHT", RaidAssignments.FourHFrame, "TOPRIGHT")
            RaidAssignments.FourHFrame.close:SetScript("OnClick", function()
                RaidAssignments.FourHFrame:Hide()
            end)
        end

        if RaidAssignments.FourHFrame:IsShown() then
            RaidAssignments.FourHFrame:Hide()
        else
            RaidAssignments.FourHFrame:Show()
        end
    end)

    -- Cthun Image Button
    self.cthunButton = CreateFrame("Button", nil, self.bg, "UIPanelButtonTemplate")
    self.cthunButton:SetPoint("LEFT", self.fourhButton, "RIGHT", 5, 0) -- Right next to 4H button
    self.cthunButton:SetWidth(60)  -- Same size as others
    self.cthunButton:SetHeight(24)
    self.cthunButton:SetText("Cthun Image")
    self.cthunButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        if not RaidAssignments.CthunFrame then
            RaidAssignments.CthunFrame = CreateFrame("Frame", "RaidAssignmentsCthunFrame", UIParent)
            RaidAssignments.CthunFrame:SetFrameStrata("DIALOG")
            RaidAssignments.CthunFrame:SetWidth(512)
            RaidAssignments.CthunFrame:SetHeight(512)
            RaidAssignments.CthunFrame:SetPoint("CENTER", 0, 0)
            RaidAssignments.CthunFrame:EnableMouse(true)
            RaidAssignments.CthunFrame:SetMovable(true)
            RaidAssignments.CthunFrame:RegisterForDrag("LeftButton")
            RaidAssignments.CthunFrame:SetScript("OnDragStart", function() this:StartMoving() end)
            RaidAssignments.CthunFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

            -- Image
            RaidAssignments.CthunFrame.texture = RaidAssignments.CthunFrame:CreateTexture(nil, "ARTWORK")
            RaidAssignments.CthunFrame.texture:SetAllPoints(RaidAssignments.CthunFrame)
            RaidAssignments.CthunFrame.texture:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\CThun.tga")

            -- Close Button
            RaidAssignments.CthunFrame.close = CreateFrame("Button", nil, RaidAssignments.CthunFrame, "UIPanelCloseButton")
            RaidAssignments.CthunFrame.close:SetPoint("TOPRIGHT", RaidAssignments.CthunFrame, "TOPRIGHT")
            RaidAssignments.CthunFrame.close:SetScript("OnClick", function()
                RaidAssignments.CthunFrame:Hide()
            end)
        end

        if RaidAssignments.CthunFrame:IsShown() then
            RaidAssignments.CthunFrame:Hide()
        else
            RaidAssignments.CthunFrame:Show()
        end
    end)


    
    -- Post Tank Assignments Button
    self.tankButton = CreateFrame("Button", nil, self.bg, "UIPanelButtonTemplate")
    self.tankButton:SetPoint("BOTTOM", -200, 10)
    self.tankButton:SetFrameStrata("MEDIUM")
    self.tankButton:SetWidth(145)
    self.tankButton:SetHeight(24)
    self.tankButton:SetText("Post Tank Assignments")
    self.tankButton:SetScript("OnClick", function() 
        if IsRaidOfficer("player") then
            PlaySound("igMainMenuOptionCheckBoxOn")
            RaidAssignments:PostRaidAssignments() 
        end
    end)
    
    -- Post Heal Assignments Button
    self.healButton = CreateFrame("Button", nil, self.bg, "UIPanelButtonTemplate")
    self.healButton:SetPoint("BOTTOM", -50, 10)
    self.healButton:SetFrameStrata("MEDIUM")
    self.healButton:SetWidth(145)
    self.healButton:SetHeight(24)
    self.healButton:SetText("Post Heal Assignments")
    self.healButton:SetScript("OnClick", function() 
        if IsRaidOfficer("player") then
            PlaySound("igMainMenuOptionCheckBoxOn")
            RaidAssignments:PostHealAssignments() 
        end
    end)
    
    -- Post All Assignments Button
    self.dbutton = CreateFrame("Button", nil, self.bg, "UIPanelButtonTemplate")
    self.dbutton:SetPoint("BOTTOM", 100, 10)
    self.dbutton:SetFrameStrata("MEDIUM")
    self.dbutton:SetWidth(145)
    self.dbutton:SetHeight(24)
    self.dbutton:SetText("Post All Assignments")
    self.dbutton:SetScript("OnClick", function() 
        if IsRaidOfficer("player") then
            PlaySound("igMainMenuOptionCheckBoxOn")
            RaidAssignments:PostAssignments() 
        end
    end)
    
    -- Whisper Button
    self.whisperButton = CreateFrame("Button", nil, self.bg, "UIPanelButtonTemplate")
    self.whisperButton:SetPoint("BOTTOM", 250, 10)
    self.whisperButton:SetWidth(145)
    self.whisperButton:SetHeight(24)
    self.whisperButton:SetText("Whisper Assignments")
    self.whisperButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        RaidAssignments:WhisperAssignments()
    end)
    
    -- New Button for General Assignments
    self.generalButton = CreateFrame("Button", nil, self.bg, "UIPanelButtonTemplate")
    self.generalButton:SetPoint("BOTTOM", 400, 10)
    self.generalButton:SetWidth(145)
    self.generalButton:SetHeight(24)
    self.generalButton:SetText("General Assignments")
    self.generalButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        RaidAssignments.ToolTip:Hide()
        RaidAssignments.HealToolTip:Hide()
        RaidAssignments.Settings["Animation"] = true
        RaidAssignments.Settings["MainFrame"] = false
        RaidAssignments.Settings["GeneralAnimation"] = false
        RaidAssignments.Settings["GeneralFrame"] = false
        RaidAssignments.Settings["GeneralSizeX"] = 0
        RaidAssignments.Settings["GeneralSizeY"] = 0
        RaidAssignments.GeneralAssignments:Show()
    end)
    
    -- Minimap Button Setup
    self.MinimapButton:SetWidth(31)
    self.MinimapButton:SetHeight(31)
    self.MinimapButton:SetFrameStrata("LOW")
    self.MinimapButton:SetPoint("CENTER", Minimap, "CENTER")
    self.MinimapButton:SetMovable(true)
    self.MinimapButton:EnableMouse(true)
    self.MinimapButton:RegisterForDrag("LeftButton")
    
    -- Minimap Button Texture
    self.MinimapButton.texture = self.MinimapButton:CreateTexture(nil, "BACKGROUND")
    self.MinimapButton.texture:SetWidth(25)
    self.MinimapButton.texture:SetHeight(25)
    self.MinimapButton.texture:SetPoint("CENTER", -3, 2)
    self.MinimapButton.texture:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\Icon")
    
    -- Minimap Button Dragging
    self.MinimapButton:SetScript("OnDragStart", function()
        this:LockHighlight()
        this:SetScript("OnUpdate", function()
            local xpos, ypos = GetCursorPosition()
            local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
            xpos = xmin - xpos / Minimap:GetEffectiveScale() + 70
            ypos = ypos / Minimap:GetEffectiveScale() - ymin - 70
            RaidAssignments.Settings["MinimapPos"] = math.deg(math.atan2(ypos, xpos))
            RaidAssignments:UpdateMinimapPosition()
        end)
    end)
    
    self.MinimapButton:SetScript("OnDragStop", function()
        this:UnlockHighlight()
        this:SetScript("OnUpdate", nil)
    end)
    
    -- Minimap Button Click to Toggle Main Frame
    self.MinimapButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        if RaidAssignments:IsVisible() then
            RaidAssignments.ToolTip:Hide()
            RaidAssignments.HealToolTip:Hide()
            RaidAssignments.Settings["Animation"] = true
            RaidAssignments.Settings["MainFrame"] = false
        else
            RaidAssignments.Settings["Animation"] = false
            RaidAssignments.Settings["MainFrame"] = false
            RaidAssignments.Settings["SizeX"] = 0
            RaidAssignments.Settings["SizeY"] = 0
            RaidAssignments:Show()
        end
    end)
    
    -- Minimap Button Tooltip
    self.MinimapButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("RaidAssignments 3.0")
        GameTooltip:AddLine("Click to toggle Raid Assignments", 1, 1, 1)
        GameTooltip:Show()
    end)
    
    self.MinimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Update Minimap Position
    self:UpdateMinimapPosition()
    
    self.bg:Hide()
    self:Hide()
    RaidAssignments.Settings["MainFrame"] = false
    RaidAssignments.Settings["SizeX"] = 0
    RaidAssignments.Settings["SizeY"] = 0    
end

function RaidAssignments:ConfigGeneralFrame()
    RaidAssignments.GeneralDrag = {}
    function RaidAssignments.GeneralDrag:StartMoving()
        RaidAssignments.GeneralAssignments:StartMoving()
        this.drag = true
    end
    
    function RaidAssignments.GeneralDrag:StopMovingOrSizing()
        RaidAssignments.GeneralAssignments:StopMovingOrSizing()
        this.drag = false
    end
    
    local backdrop = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false,
        tileSize = 16,
        edgeSize = 2,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    
    RaidAssignments.GeneralAssignments:SetFrameStrata("BACKGROUND")
    RaidAssignments.GeneralAssignments:SetWidth(RaidAssignments.Settings["GeneralFrameX"])
	RaidAssignments.GeneralAssignments:SetHeight(RaidAssignments.Settings["GeneralFrameY"] + 60) -- Increased by 60 to accommodate EditBox fields
    RaidAssignments.GeneralAssignments:SetPoint("CENTER",0,100)
    RaidAssignments.GeneralAssignments:SetMovable(true)
    RaidAssignments.GeneralAssignments:EnableMouse(true)
    RaidAssignments.GeneralAssignments:RegisterForDrag("LeftButton")
    RaidAssignments.GeneralAssignments:SetBackdrop(backdrop)
    RaidAssignments.GeneralAssignments:SetBackdropColor(0,0,0,1)
    RaidAssignments.GeneralAssignments:SetBackdropBorderColor(1,1,1,0.5)

    RaidAssignments.GeneralAssignments:SetScript("OnUpdate", function()
        local updfreq = math.floor(GetFramerate()) * 0.3
        if RaidAssignments.GeneralAssignments:IsVisible() then
            if not RaidAssignments.Settings["GeneralFrame"] then
                if RaidAssignments.Settings["GeneralSizeX"] >= RaidAssignments.Settings["GeneralFrameX"] and RaidAssignments.Settings["GeneralSizeY"] >= RaidAssignments.Settings["GeneralFrameY"] then
                    RaidAssignments.Settings["GeneralFrame"] = true
                    RaidAssignments.GeneralAssignments:SetWidth(RaidAssignments.Settings["GeneralFrameX"])
                    RaidAssignments.GeneralAssignments:SetHeight(RaidAssignments.Settings["GeneralFrameY"])
                    RaidAssignments.generalBg:Show()
                    RaidAssignments:UpdateGeneral()
                else
                    if RaidAssignments.Settings["GeneralSizeX"] < RaidAssignments.Settings["GeneralFrameX"] then
                        RaidAssignments.Settings["GeneralSizeX"] = RaidAssignments.Settings["GeneralSizeX"] + (RaidAssignments.Settings["GeneralFrameX"] / updfreq)
                        RaidAssignments.GeneralAssignments:SetWidth(RaidAssignments.Settings["GeneralSizeX"])
                    end
                    if RaidAssignments.Settings["GeneralSizeY"] < RaidAssignments.Settings["GeneralFrameY"] then
                        RaidAssignments.Settings["GeneralSizeY"] = RaidAssignments.Settings["GeneralSizeY"] + (RaidAssignments.Settings["GeneralFrameY"] / updfreq)
                        RaidAssignments.GeneralAssignments:SetHeight(RaidAssignments.Settings["GeneralSizeY"])
                    end
                end
            else
                if RaidAssignments.Settings["GeneralAnimation"] then
                    RaidAssignments.generalBg:Hide()
                    if RaidAssignments.Settings["GeneralSizeX"] <= 0 and RaidAssignments.Settings["GeneralSizeY"] <= 0 then
                        RaidAssignments.Settings["GeneralFrame"] = false
                        RaidAssignments.Settings["GeneralAnimation"] = false
                        RaidAssignments.generalBg:Hide()
                        RaidAssignments.GeneralAssignments:Hide()
                    else
                        if RaidAssignments.Settings["GeneralSizeY"] >= 0 then
                            RaidAssignments.Settings["GeneralSizeY"] = RaidAssignments.Settings["GeneralSizeY"] - (RaidAssignments.Settings["GeneralFrameY"] / updfreq)
                            RaidAssignments.GeneralAssignments:SetHeight(RaidAssignments.Settings["GeneralSizeY"])
                        end
                        if RaidAssignments.Settings["GeneralSizeY"] < RaidAssignments.Settings["GeneralFrameY"] / 4 then
                            RaidAssignments.Settings["GeneralSizeX"] = RaidAssignments.Settings["GeneralSizeX"] - (RaidAssignments.Settings["GeneralFrameX"] / updfreq)
                            RaidAssignments.GeneralAssignments:SetWidth(RaidAssignments.Settings["GeneralSizeX"])
                        end    
                    end
                end
            end
        end
    end)

    self.generalBg = CreateFrame("Button", "generalBg", RaidAssignments.GeneralAssignments)
    self.generalBg:SetWidth(RaidAssignments.GeneralAssignments:GetWidth())
    self.generalBg:SetHeight(RaidAssignments.GeneralAssignments:GetHeight())
    self.generalBg:SetPoint("TOPLEFT",0,0)
    self.generalBg:SetBackdropColor(0,0,0,1)
    self.generalBg:EnableMouse(true)
    self.generalBg:SetMovable(true)
    self.generalBg:RegisterForDrag("LeftButton")
    self.generalBg:SetScript("OnDragStart", RaidAssignments.GeneralDrag.StartMoving)
    self.generalBg:SetScript("OnDragStop", RaidAssignments.GeneralDrag.StopMovingOrSizing)
    self.generalBg:SetScript("OnEnter", function() RaidAssignments.GeneralToolTip:Hide() end)

    self.generalText = self.generalBg:CreateFontString(nil, "OVERLAY")
    self.generalText:SetPoint("TOP", self.generalBg, "TOP", 0, -20)
    self.generalText:SetFont("Interface\\AddOns\\RaidAssignments\\assets\\BalooBhaina.ttf", 25)
    local r,g,b = RaidAssignments:GetClassColors("Warrior","class")
    self.generalText:SetTextColor(r,g,b, 1)
    self.generalText:SetShadowOffset(2,-2)
    self.generalText:SetText("General Assignments")

    local classIconStartX, classIconY, i = 50, -45, 1
    for n, class in pairs(RaidAssignments.Classes) do
        local r, l, t, b = RaidAssignments:ClassPos(class)
        local classframe = CreateFrame("Button", class, self.generalBg)
        classframe:SetWidth(22) classframe:SetHeight(22)
        classframe:SetBackdropColor(0,0,0,1)
        classframe:SetPoint("TOPLEFT", classIconStartX + (i*25), classIconY)
        classframe:SetFrameStrata("MEDIUM")
        classframe.Icon = classframe:CreateTexture(nil, "ARTWORK")
        classframe.Icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        classframe.Icon:SetTexCoord(r, l, t, b)
        classframe.Icon:SetPoint("TOPRIGHT", -1, -1)
        classframe.Icon:SetWidth(22) classframe.Icon:SetHeight(22)
        classframe:SetScript("OnEnter", function() 
            local r,g,b = RaidAssignments:GetClassColors(this:GetName(),"class")
            GameTooltip:SetOwner(classframe, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText("|cffFFFFFFShow|r "..this:GetName(), r,g,b)
            GameTooltip:Show()
        end)
        classframe:SetScript("OnLeave", function() GameTooltip:Hide() end)
        classframe:SetScript("OnMouseDown", function()
            if arg1 == "LeftButton" then
                if RaidAssignments_Settings[this:GetName()] == 1 then
                    RaidAssignments_Settings[this:GetName()] = 0
                    classframe.Icon:SetVertexColor(0.5, 0.5, 0.5)
                else
                    RaidAssignments_Settings[this:GetName()] = 1
                    classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)
                end
            end
        end)
        i = i + 1
        if RaidAssignments_Settings[class] == nil then
            RaidAssignments_Settings[class] = 1
            classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)			
        else
            if RaidAssignments_Settings[class] == 1 then
                classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)
            else
                classframe.Icon:SetVertexColor(0.5, 0.5, 0.5)
            end			
        end
    end

-- General marks 1-8 using UI-RaidTargetingIcons
local padding = 5
for i = 1, 8 do
    local icon = CreateFrame("Frame", "G"..i, self.generalBg)
    icon:SetWidth(35)
    icon:SetHeight(35)
    icon:SetPoint("TOPLEFT", 50, -75 - ((35 + padding) * (i - 1)))
    icon:SetFrameStrata("MEDIUM")
    icon:EnableMouse(true)
    icon:SetScript("OnEnter", function() RaidAssignments:OpenGeneralToolTip(this:GetName()) end)
    icon:SetScript("OnLeave", function() end)
    icon.Icon = icon:CreateTexture(nil, "ARTWORK")
    icon.Icon:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\" .. i .. ".tga")
    icon.Icon:SetPoint("CENTER", 0, 0)
    icon.Icon:SetWidth(35)
    icon.Icon:SetHeight(35)
end

-- Add custom marks 9 and 10 with EditBox below the icon
for i = 9, 10 do
    local icon = CreateFrame("Frame", "G"..i, self.generalBg)
    icon:SetWidth(35)
    icon:SetHeight(35)
    -- Adjust position to account for extra space needed for EditBox below
    icon:SetPoint("TOPLEFT", 50, -75 - ((35 + padding) * (i - 1) + (i - 9) * 30)) -- Extra 30 pixels per custom mark for EditBox
    icon:SetFrameStrata("MEDIUM")
    icon:EnableMouse(true)
    icon:SetScript("OnEnter", function()
        RaidAssignments:OpenGeneralToolTip(this:GetName())
    end)
    icon:SetScript("OnLeave", function() end)

    -- Use custom mark texture
    icon.Icon = icon:CreateTexture(nil, "ARTWORK")
    icon.Icon:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\Custom.tga")
    icon.Icon:SetPoint("CENTER", 0, 0)
    icon.Icon:SetWidth(35)
    icon.Icon:SetHeight(35)

    -- Add an EditBox *below the icon* to edit the label for reporting
    local editBox = CreateFrame("EditBox", "G"..i.."_Edit", self.generalBg, "InputBoxTemplate")
    editBox:SetWidth(90)
    editBox:SetHeight(25)
    editBox:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", -20, -5) -- Position below the icon with 5-pixel gap
    editBox:SetAutoFocus(false)

    if RaidAssignments.GeneralRealMarks[i] ~= "" then
        editBox:SetText(RaidAssignments.GeneralRealMarks[i])
    else
        editBox:SetText("Custom Mark " .. (i-8))
    end

    local markIndex = i  -- Capture the value of i for this iteration
    editBox:SetScript("OnEnterPressed", function()
        local text = (this and this:GetText()) or ""
        RaidAssignments.GeneralRealMarks[markIndex] = text
        RaidAssignments:UpdateGeneral()
        RaidAssignments:SendGeneral()
        RaidAssignments:SendCustomMarkLabels()  -- Sync labels
        this:ClearFocus()
    end)
    editBox:SetScript("OnEscapePressed", function()
        if this then this:ClearFocus() end
    end)
end

    self.generalCloseButton = CreateFrame("Button", nil, self.generalBg, "UIPanelCloseButton")
    self.generalCloseButton:SetPoint("TOPLEFT", RaidAssignments.GeneralAssignments:GetWidth()-23, 2)
    self.generalCloseButton:SetWidth(24) self.generalCloseButton:SetHeight(24)
    self.generalCloseButton:SetFrameStrata("MEDIUM")
    self.generalCloseButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        RaidAssignments.GeneralToolTip:Hide()
        RaidAssignments.Settings["GeneralAnimation"] = true
        RaidAssignments.Settings["GeneralFrame"] = false
    end)

    -- Button to open Raid Assignments window
    self.openRaidAssignmentsButton = CreateFrame("Button", nil, self.generalBg, "UIPanelButtonTemplate")
    self.openRaidAssignmentsButton:SetPoint("BOTTOM", 75, 65) -- Position to the left of Post Marks button
    self.openRaidAssignmentsButton:SetWidth(145)
    self.openRaidAssignmentsButton:SetHeight(24)
    self.openRaidAssignmentsButton:SetText("Raid Assignments")
    self.openRaidAssignmentsButton:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        RaidAssignments.GeneralToolTip:Hide()
        RaidAssignments.Settings["GeneralAnimation"] = true
        RaidAssignments.Settings["GeneralFrame"] = false
        
        -- Open Raid Assignments window
        RaidAssignments.Settings["Animation"] = false
        RaidAssignments.Settings["MainFrame"] = false
        RaidAssignments.Settings["SizeX"] = 0
        RaidAssignments.Settings["SizeY"] = 0
        RaidAssignments:Show()
    end)

    self.postGeneralButton = CreateFrame("Button", nil, self.generalBg, "UIPanelButtonTemplate")
    self.postGeneralButton:SetPoint("BOTTOM", -75, 65)
    self.postGeneralButton:SetWidth(145) self.postGeneralButton:SetHeight(24)
    self.postGeneralButton:SetText("Post Marks")
    self.postGeneralButton:SetScript("OnClick", function()
        if IsRaidOfficer("player") then
            PlaySound("igMainMenuOptionCheckBoxOn")
            RaidAssignments:PostGeneralAssignments()
        end
    end)

    self.generalBg:Hide()
    RaidAssignments.GeneralAssignments:Hide()
    RaidAssignments.Settings["GeneralFrame"] = false
    RaidAssignments.Settings["GeneralSizeX"] = 0
    RaidAssignments.Settings["GeneralSizeY"] = 0
end

function RaidAssignments:UpdateGeneral()
    if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
        -- Initialize GeneralFrames for all marks if not already done
        for i = 1, 10 do
            if not RaidAssignments.GeneralFrames[i] then
                RaidAssignments.GeneralFrames[i] = {}
            end
        end

        -- Process each mark (1-10)
        for i = 1, 10 do
            -- Get the mark icon frame (G1 to G10)
            local iconFrame = _G["G" .. i]
            if iconFrame then
                iconFrame:Show()  -- Always show the icon, regardless of assignments
            end

            -- Hide all player frames for this mark first
            for k, v in pairs(RaidAssignments.GeneralFrames[i]) do
                if v:IsVisible() then
                    v:Hide()
                end
            end

            -- Remove players no longer in raid
            for k = 1, 5 do
                local v = RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][k]
                if v and not RaidAssignments:IsInRaid(v) then
                    RaidAssignments.GeneralMarks[i][k] = nil
                end
            end

            -- Show frames for assigned players in correct slots
            for slot = 1, 5 do
                local v = RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][slot]
                if v then
                    -- Create frame if it doesn't exist
                    if not RaidAssignments.GeneralFrames[i][v] then
                        RaidAssignments.GeneralFrames[i][v] = RaidAssignments:AddGeneralFrame(v, i)
                    end
                    local frame = RaidAssignments.GeneralFrames[i][v]
                    frame:SetPoint("RIGHT", 10 + (105 * slot), 0)
                    frame.texture:SetWidth(frame:GetWidth() - 4)
                    frame.texture:SetVertexColor(RaidAssignments:GetClassColors(v, "rgb"))
                    frame:Show()
                end
            end
        end
    else
        -- Hide all frames and clear marks if not in raid
        for i = 1, 10 do
            local iconFrame = _G["G" .. i]
            if iconFrame then
                iconFrame:Show()
            end
            for k, v in pairs(RaidAssignments.GeneralFrames[i]) do
                if v:IsVisible() then
                    v:Hide()
                end
            end
            RaidAssignments.GeneralMarks[i] = {}
        end
    end
end
function RaidAssignments:WhisperAssignments()
    if not IsRaidOfficer("player") then
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: You must be a raid officer to whisper assignments")
        return
    end
    for i = 1, 8 do
        for k, v in pairs(RaidAssignments.Marks[i]) do
            if RaidAssignments:IsInRaid(v) then
                local text = "You are assigned to tank " .. RaidAssignments.RealMarks[i] .. " (slot " .. k .. ")"
                SendChatMessage(text, "WHISPER", nil, v)
            end
        end
    end
    for i = 1, 12 do
        for k = 1, 4 do
            local v = RaidAssignments.HealMarks[i][k]
            if v and RaidAssignments:IsInRaid(v) then
                local text = "You are assigned to heal " .. RaidAssignments.HealRealMarks[i] .. " (slot " .. k .. ")"
                SendChatMessage(text, "WHISPER", nil, v)
            end
        end
    end
    for i = 1, 8 do
        for k, v in pairs(RaidAssignments.GeneralMarks[i]) do
            if RaidAssignments:IsInRaid(v) then
                local text = "You are assigned to " .. RaidAssignments.GeneralRealMarks[i] .. " (slot " .. k .. ")"
                SendChatMessage(text, "WHISPER", nil, v)
            end
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: Whispered assignments to players")
end

function RaidAssignments:UpdateMinimapPosition()
    local angle = math.rad(RaidAssignments.Settings["MinimapPos"])
    local x, y = math.cos(angle) * 80, math.sin(angle) * 80
    self.MinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function RaidAssignments:SetTankChannelString()
	local channelChar = self.TankChannelEditBox:GetText()
	if channelChar == "s" or channelChar == "S" then
		self.TankChannelSelectedFontString:SetText("Say")
	elseif channelChar == "r" or channelChar == "R" then
		self.TankChannelSelectedFontString:SetText("Raid")
	elseif channelChar == "p" or channelChar == "P" then
		self.TankChannelSelectedFontString:SetText("Group")
	elseif channelChar == "g" or channelChar == "G" then
		self.TankChannelSelectedFontString:SetText("Guild")
	elseif channelChar == "e" or channelChar == "E" then
		self.TankChannelSelectedFontString:SetText("Emote")
	elseif channelChar == "rw" or channelChar == "RW" then
		self.TankChannelSelectedFontString:SetText("Raid Warning")
	else
		local id, name = GetChannelName(channelChar)
		self.TankChannelSelectedFontString:SetText(name or "Unknown")
	end
end

function RaidAssignments:GetSendChannel(chanName)
	if not chanName or chanName == "" or chanName == " " then
		return nil,nil
	end
	chanName = string.lower(chanName)
	if RaidAssignments.ChanTable[chanName] then
		if type(RaidAssignments.ChanTable[chanName]) == "table" then
			local chan = RaidAssignments.ChanTable[chanName][1]
			local bla = RaidAssignments.ChanTable[chanName][2]
			return chan,bla
		else
			local chan = RaidAssignments.ChanTable[chanName]
			return chan,chanName
		end
	end
	return "WHISPER",chanName
end

function RaidAssignments:GetMarkPos(mark)
	if mark == 1 then return 0, 0.25, 0, 0.25 end
	if mark == 2 then return 0.25, 0.5, 0, 0.25 end
	if mark == 3 then return 0.5, 0.75, 0, 0.25 end
	if mark == 4 then return 0.75, 1, 0, 0.25 end
	if mark == 5 then return 0, 0.25, 0.25, 0.5 end
	if mark == 6 then return 0.25, 0.5, 0.25, 0.5 end
	if mark == 7 then return 0.5, 0.75, 0.25, 0.5 end
	if mark == 8 then return 0.75, 1, 0.25, 0.5 end
	return 0, 0.25, 0.5, 0.75 -- Returns empty next one, so blank
end

function RaidAssignments:ClassPos(class)
	if class == "Warrior" then return 0, 0.25, 0, 0.25 end
	if class == "Mage" then return 0.25, 0.5, 0, 0.25 end
	if class == "Rogue" then return 0.5, 0.75, 0, 0.25 end
	if class == "Druid" then return 0.75, 1, 0, 0.25 end
	if class == "Hunter" then return 0, 0.25, 0.25, 0.5 end
	if class == "Shaman" then return 0.25, 0.5, 0.25, 0.5 end
	if class == "Priest" then return 0.5, 0.75, 0.25, 0.5 end
	if class == "Warlock" then return 0.75, 1, 0.25, 0.5 end
	if class == "Paladin" then return 0, 0.25, 0.5, 0.75 end
end

function RaidAssignments:GetClassColors(name, color)
	if color == "rgb" then
		if name == UnitName("player") then
			if UnitClass("player") == "Warrior" then return 0.78, 0.61, 0.43,1
			elseif UnitClass("player") == "Hunter" then return 0.67, 0.83, 0.45,1
			elseif UnitClass("player") == "Mage" then return 0.41, 0.80, 0.94,1
			elseif UnitClass("player") == "Rogue" then return 1.00, 0.96, 0.41,1
			elseif UnitClass("player") == "Warlock" then return 0.58, 0.51, 0.79,1
			elseif UnitClass("player") == "Druid" then return 1, 0.49, 0.04,1
			elseif UnitClass("player") == "Shaman" then return 0.0, 0.44, 0.87,1
			elseif UnitClass("player") == "Priest" then return 1.00, 1.00, 1.00,1
			elseif UnitClass("player") == "Paladin" then return 0.96, 0.55, 0.73,1
			end
		end
		if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
			local roster = RaidAssignments.TestMode and RaidAssignments.TestRoster or {}
			local numMembers = RaidAssignments.TestMode and table.getn(RaidAssignments.TestRoster) or GetNumRaidMembers()
			for i=1,numMembers do
				local unitName, unitClass
				if RaidAssignments.TestMode then
					unitName = roster[i].name
					unitClass = roster[i].class
				else
					unitName = UnitName("raid"..i)
					unitClass = UnitClass("raid"..i)
				end
				if unitName == name then
					if unitClass == "Warrior" then return 0.78, 0.61, 0.43,1
					elseif unitClass == "Hunter" then return 0.67, 0.83, 0.45,1
					elseif unitClass == "Mage" then return 0.41, 0.80, 0.94,1
					elseif unitClass == "Rogue" then return 1.00, 0.96, 0.41,1
					elseif unitClass == "Warlock" then return 0.58, 0.51, 0.79,1
					elseif unitClass == "Druid" then return 1, 0.49, 0.04,1
					elseif unitClass == "Shaman" then return 0.0, 0.44, 0.87,1	
					elseif unitClass == "Priest" then return 1.00, 1.00, 1.00,1
					elseif unitClass == "Paladin" then return 0.96, 0.55, 0.73,1
					end
				end
			end
		elseif GetNumPartyMembers() > 0 then
			for i=1,GetNumPartyMembers() do
				if UnitName("party"..i) == name then
					if UnitClass("party"..i) == "Warrior" then return 0.78, 0.61, 0.43,1
					elseif UnitClass("party"..i) == "Hunter" then return 0.67, 0.83, 0.45,1
					elseif UnitClass("party"..i) == "Mage" then return 0.41, 0.80, 0.94,1
					elseif UnitClass("party"..i) == "Rogue" then return 1.00, 0.96, 0.41,1
					elseif UnitClass("party"..i) == "Warlock" then return 0.58, 0.51, 0.79,1
					elseif UnitClass("party"..i) == "Druid" then return 1, 0.49, 0.04,1
					elseif UnitClass("party"..i) == "Shaman" then return 0.0, 0.44, 0.87,1	
					elseif UnitClass("party"..i) == "Priest" then return 1.00, 1.00, 1.00,1
					elseif UnitClass("party"..i) == "Paladin" then return 0.96, 0.55, 0.73,1
					end
				end
			end	
			if UnitName("player") == name then
				if UnitClass("player") == "Warrior" then return 0.78, 0.61, 0.43,1
				elseif UnitClass("player") == "Hunter" then return 0.67, 0.83, 0.45,1
				elseif UnitClass("player") == "Mage" then return 0.41, 0.80, 0.94,1
				elseif UnitClass("player") == "Rogue" then return 1.00, 0.96, 0.41,1
				elseif UnitClass("player") == "Warlock" then return 0.58, 0.51, 0.79,1
				elseif UnitClass("player") == "Druid" then return 1, 0.49, 0.04,1
				elseif UnitClass("player") == "Shaman" then return 0.0, 0.44, 0.87,1
				elseif UnitClass("player") == "Priest" then return 1.00, 1.00, 1.00,1
				elseif UnitClass("player") == "Paladin" then return 0.96, 0.55, 0.73,1
				end
			end
		else
			if UnitName("player") == name then
				if UnitClass("player") == "Warrior" then return 0.78, 0.61, 0.43,1
				elseif UnitClass("player") == "Hunter" then return 0.67, 0.83, 0.45,1
				elseif UnitClass("player") == "Mage" then return 0.41, 0.80, 0.94,1
				elseif UnitClass("player") == "Rogue" then return 1.00, 0.96, 0.41,1
				elseif UnitClass("player") == "Warlock" then return 0.58, 0.51, 0.79,1
				elseif UnitClass("player") == "Druid" then return 1, 0.49, 0.04,1
				elseif UnitClass("player") == "Shaman" then return 0.0, 0.44, 0.87,1
				elseif UnitClass("player") == "Priest" then return 1.00, 1.00, 1.00,1
				elseif UnitClass("player") == "Paladin" then return 0.96, 0.55, 0.73,1
				end
			end
		end
	elseif color == "cff" then
		if name == UnitName("player") then
			if UnitClass("player") == "Warrior" then return "|cffC79C6E"..name.."|r"
			elseif UnitClass("player") == "Hunter" then return "|cffABD473"..name.."|r"
			elseif UnitClass("player") == "Mage" then return "|cff69CCF0"..name.."|r"
			elseif UnitClass("player") == "Rogue" then return "|cffFFF569"..name.."|r"
			elseif UnitClass("player") == "Warlock" then return "|cff9482C9"..name.."|r"
			elseif UnitClass("player") == "Druid" then return "|cffFF7D0A"..name.."|r"
			elseif UnitClass("player") == "Shaman" then return "|cff0070DE"..name.."|r"
			elseif UnitClass("player") == "Priest" then return "|cffFFFFFF"..name.."|r"
			elseif UnitClass("player") == "Paladin" then return "|cffF58CBA"..name.."|r"
			end
		end
		if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
			local roster = RaidAssignments.TestMode and RaidAssignments.TestRoster or {}
			local numMembers = RaidAssignments.TestMode and table.getn(RaidAssignments.TestRoster) or GetNumRaidMembers()
			for i=1,numMembers do
				local unitName, unitClass
				if RaidAssignments.TestMode then
					unitName = roster[i].name
					unitClass = roster[i].class
				else
					unitName = UnitName("raid"..i)
					unitClass = UnitClass("raid"..i)
				end
				if unitName == name then
					if unitClass == "Warrior" then return "|cffC79C6E"..name.."|r"
					elseif unitClass == "Hunter" then return "|cffABD473"..name.."|r"
					elseif unitClass == "Mage" then return "|cff69CCF0"..name.."|r"
					elseif unitClass == "Rogue" then return "|cffFFF569"..name.."|r"
					elseif unitClass == "Warlock" then return "|cff9482C9"..name.."|r"
					elseif unitClass == "Druid" then return "|cffFF7D0A"..name.."|r"
					elseif unitClass == "Shaman" then return "|cff0070DE"..name.."|r"
					elseif unitClass == "Priest" then return "|cffFFFFFF"..name.."|r"
					elseif unitClass == "Paladin" then return "|cffF58CBA"..name.."|r"
					end
				end
			end
		else
			for i=1,GetNumPartyMembers() do
				if UnitName("party"..i) == name then
					if UnitClass("party"..i) == "Warrior" then return "|cffC79C6E"..name.."|r"
					elseif UnitClass("party"..i) == "Hunter" then return "|cffABD473"..name.."|r"
					elseif UnitClass("party"..i) == "Mage" then return "|cff69CCF0"..name.."|r"
					elseif UnitClass("party"..i) == "Rogue" then return "|cffFFF569"..name.."|r"
					elseif UnitClass("party"..i) == "Warlock" then return "|cff9482C9"..name.."|r"
					elseif UnitClass("party"..i) == "Druid" then return "|cffFF7D0A"..name.."|r"
					elseif UnitClass("party"..i) == "Shaman" then return "|cff0070DE"..name.."|r"
					elseif UnitClass("party"..i) == "Priest" then return "|cffFFFFFF"..name.."|r"
					elseif UnitClass("party"..i) == "Paladin" then return "|cffF58CBA"..name.."|r"
					end
				end
			end
			if UnitName("player") == name then
				if UnitClass("player") == "Warrior" then return "|cffC79C6E"..name.."|r"
				elseif UnitClass("player") == "Hunter" then return "|cffABD473"..name.."|r"
				elseif UnitClass("player") == "Mage" then return "|cff69CCF0"..name.."|r"
				elseif UnitClass("player") == "Rogue" then return "|cffFFF569"..name.."|r"
				elseif UnitClass("player") == "Warlock" then return "|cff9482C9"..name.."|r"
				elseif UnitClass("player") == "Druid" then return "|cffFF7D0A"..name.."|r"
				elseif UnitClass("player") == "Shaman" then return "|cff0070DE"..name.."|r"
				elseif UnitClass("player") == "Priest" then return "|cffFFFFFF"..name.."|r"
				elseif UnitClass("player") == "Paladin" then return "|cffF58CBA"..name.."|r"
				end
			end
		end
	elseif color == "class" then
		if (name == "Warrior") then 
			return 0.78, 0.61, 0.43
		end
		if(name=="Mage") then
			return 0.41, 0.80, 0.94
		end
		if(name=="Rogue") then 
			return 1.00, 0.96, 0.41
		end
		if(name=="Druid") then 
			return 1, 0.49, 0.04
		end
		if(name=="Hunter") then 
			return 0.67, 0.83, 0.45 
		end
		if(name=="Shaman") then 
			return 0.0, 0.44, 0.87
		end
		if(name=="Priest") then 
			return 1.00, 1.00, 1.00 
		end
		if(name=="Warlock") then 
			return 0.58, 0.51, 0.79
		end
		if(name=="Paladin") then 
			return 0.96, 0.55, 0.73
		end
	elseif color == "mark" then
		if name == "Skull" then return "|cffFFFFFF"..name.."|r" end
		if name == "Cross" then return "|cffFF0000"..name.."|r" end
		if name == "Square" then return "|cff00B4FF"..name.."|r" end
		if name == "Moon" then return "|cffCEECF5"..name.."|r" end
		if name == "Triangle" then return "|cff66FF00"..name.."|r" end
		if name == "Diamond" then return "|cffCC00FF"..name.."|r" end
		if name == "Circle" then return "|cffFF9900"..name.."|r" end
		if name == "Star" then return "|cffFFFF00"..name.."|r" end
	end
end

function RaidAssignments:IsInRaid(name)
	if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
		local roster = RaidAssignments.TestMode and RaidAssignments.TestRoster or {}
		local numMembers = RaidAssignments.TestMode and table.getn(RaidAssignments.TestRoster) or GetNumRaidMembers()
		for i=1,numMembers do
			local unitName
			if RaidAssignments.TestMode then
				unitName = roster[i].name
			else
				unitName = UnitName("raid"..i)
			end
			if unitName == name then
				return true
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i=1,GetNumPartyMembers() do 
			if UnitName("party"..i) == name then
				return true
			end
		end	
		if UnitName("player") == name then
			return true
		end
	else
		if UnitName("player") == name then
			return true
		end
	end
	return false
end

function RaidAssignments:GetRaidID(name)
	if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
		local roster = RaidAssignments.TestMode and RaidAssignments.TestRoster or {}
		local numMembers = RaidAssignments.TestMode and table.getn(RaidAssignments.TestRoster) or GetNumRaidMembers()
		for i=1,numMembers do
			local unitName
			if RaidAssignments.TestMode then
				unitName = roster[i].name
			else
				unitName = UnitName("raid"..i)
			end
			if unitName == name then
				return "raid"..i
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i=1,GetNumPartyMembers() do 
			if UnitName("party"..i) == name then
				return "party"..i
			end
		end	
		if UnitName("player") == name then
			return "player"
		end
	else
		if UnitName("player") == name then
			return "player"
		end
	end
	return nil
end

function RaidAssignments:UpdateTanks()
    if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
        for i=1,8 do
            -- Hide old frames
            for k,v in pairs(RaidAssignments.Frames[i]) do
                v:Hide()
            end
            -- Remove players not in raid anymore
            for k,v in pairs(RaidAssignments.Marks[i]) do
                if not RaidAssignments:IsInRaid(v) then    
                    table.remove(RaidAssignments.Marks[i],k)
                    table.sort(RaidAssignments.Marks[i])    
                end
            end
            -- Show frames for tanks
            local index = 0
            for k,v in pairs(RaidAssignments.Marks[i]) do
                index = index + 1
                RaidAssignments.Frames[i][v] = RaidAssignments.Frames[i][v] or RaidAssignments:AddTankFrame(v,i)
                local frame = RaidAssignments.Frames[i][v]
                frame:SetPoint("RIGHT", 10 + (105 * index), 0)

                -- Always full width
                frame.texture:SetWidth(frame:GetWidth() - 4)

                frame.texture:SetVertexColor(RaidAssignments:GetClassColors(v, "rgb"))
                frame:Show()
            end
        end
    else
        for i=1,8 do
            for k,v in pairs(RaidAssignments.Frames[i]) do
                if v:IsVisible() then
                    v:Hide()
                end
            end
            RaidAssignments.Marks[i] = {}
        end
    end
end

function RaidAssignments:UpdateHeals()
    if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
        -- Hide old frames
        for i=1,12 do
            for k,v in pairs(RaidAssignments.HealFrames[i]) do
                v:Hide()
            end
        end
        -- Show healers
        for i=1,12 do
            for k=1,4 do
                local name = RaidAssignments.HealMarks[i][k]
                if name then
                    RaidAssignments.HealFrames[i][name] = RaidAssignments.HealFrames[i][name] or RaidAssignments:AddHealFrame(name, i)
                    local frame = RaidAssignments.HealFrames[i][name]
                    frame:SetPoint("RIGHT", 10 + (105 * k), 0)

                    -- Always full width
                    frame.texture:SetWidth(frame:GetWidth() - 4)

                    frame.texture:SetVertexColor(RaidAssignments:GetClassColors(name, "rgb"))
                    frame:Show()
                end
            end
        end
    end
end

function RaidAssignments:SendTanks()
    if IsRaidOfficer("player") then
        local sendstring = ""
        for mark=1,8 do
            for k,v in pairs(RaidAssignments.Marks[mark]) do
                sendstring = sendstring .. mark .. v
            end
        end
        -- always send, even if empty
        SendAddonMessage("TankAssignmentsMarks", sendstring, "RAID")
    end
end


function RaidAssignments:SendHeals()
    if IsRaidOfficer("player") then
        local sendstring = ""
        for mark = 1, 12 do
            for slot = 1, 4 do
                local v = RaidAssignments.HealMarks[mark][slot]
                if v then
                    -- Use underscore separators
                    sendstring = sendstring .. mark .. "_" .. slot .. "_" .. v .. ","
                end
            end
        end
        SendAddonMessage("HealAssignmentsMarks", sendstring, "RAID")
    end
end
	
function RaidAssignments:SanitizeName(name)
    if not name then return "" end
    -- Replace non-ASCII characters with their closest ASCII equivalent or remove them
    local sanitized = string.gsub(name, "[^%w%s%-]", "")
    return sanitized
end

function RaidAssignments:SendGeneral()
    if IsRaidOfficer("player") then
        local sendstring = ""
        for mark = 1, 10 do
            if RaidAssignments.GeneralMarks[mark] then
                for slot, v in pairs(RaidAssignments.GeneralMarks[mark]) do
                    if v and type(slot) == "number" then
                        -- Use simple concatenation without special characters
                        sendstring = sendstring .. mark .. "_" .. slot .. "_" .. v .. ","
                    end
                end
            end
        end
        -- always send, even if empty
        SendAddonMessage("RaidAssignmentsGeneralMarks", sendstring, "RAID")
    end
end

function RaidAssignments:OpenToolTip(frameName)
    if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
        for k, v in pairs(RaidAssignments.Frames["ToolTip"]) do
            v:Hide()
        end
        local index = 0
        local n = tonumber(string.sub(frameName, 2))
        local assignedCount = table.getn(RaidAssignments.Marks[n])
        local roster = RaidAssignments.TestMode and RaidAssignments.TestRoster or {}
        local numMembers = RaidAssignments.TestMode and table.getn(RaidAssignments.TestRoster) or GetNumRaidMembers()
        for i = 1, numMembers do
            local name, class
            if RaidAssignments.TestMode then
                name = roster[i] and roster[i].name
                class = roster[i] and roster[i].class
            else
                name = UnitName("raid"..i)
                class = UnitClass("raid"..i)
            end
            if name and class then
                local f = false
                -- Check if player is already assigned to ANY tank mark (1-8)
                for j = 1, 8 do
                    for k, v in pairs(RaidAssignments.Marks[j]) do
                        if name == v then
                            f = true
                            break
                        end
                    end
                    if f then break end
                end
                if not f then
                    if (assignedCount == 0 and RaidAssignments.RoleFilter.TankPrimary[class] or assignedCount > 0) and RaidAssignments_Settings[class] == 1 then
                        index = index + 1
                        RaidAssignments.Frames["ToolTip"][name] = RaidAssignments.Frames["ToolTip"][name] or RaidAssignments:AddToolTipFrame(name, RaidAssignments.ToolTip)
                        local frame = RaidAssignments.Frames["ToolTip"][name]
                        frame:SetPoint("TOPLEFT", RaidAssignments.ToolTip, "TOPLEFT", 2, 25 + (-25 * index))
                        frame.texture:SetVertexColor(RaidAssignments:GetClassColors(name, "rgb"))
                        frame:Show()
                    end
                end
            end
        end
        RaidAssignments.Settings["active"] = n
        RaidAssignments.ToolTip:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
        RaidAssignments.ToolTip:SetBackdropColor(0, 0, 0, 1)
        RaidAssignments.ToolTip:SetWidth(102)
        RaidAssignments.ToolTip:SetHeight(25 * index)
        RaidAssignments.ToolTip:SetPoint("TOPLEFT", frameName, "TOPLEFT", -100, 0)
        RaidAssignments.ToolTip:EnableMouse(true)
        RaidAssignments.ToolTip:SetScript("OnLeave", function()
            RaidAssignments.ToolTip:Hide()
        end)
        RaidAssignments.ToolTip:SetFrameStrata("HIGH")
        RaidAssignments.ToolTip:Show()
    end
end

function RaidAssignments:OpenHealToolTip(frameName)
    if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
        for k, v in pairs(RaidAssignments.Frames["HealToolTip"]) do
            v:Hide()
        end
        local index = 0
        local n = tonumber(string.sub(frameName, 2))
        local roster = RaidAssignments.TestMode and RaidAssignments.TestRoster or {}
        local numMembers = RaidAssignments.TestMode and table.getn(RaidAssignments.TestRoster) or GetNumRaidMembers()
        for i = 1, numMembers do
            local name, class
            if RaidAssignments.TestMode then
                name = roster[i] and roster[i].name
                class = roster[i] and roster[i].class
            else
                name = UnitName("raid"..i)
                class = UnitClass("raid"..i)
            end
            if name and class then
                local f = false
                -- Check if player is already assigned to ANY heal mark (1-12)
                for j = 1, 12 do
                    for k, v in ipairs(RaidAssignments.HealMarks[j]) do
                        if name == v then
                            f = true
                            break
                        end
                    end
                    if f then break end
                end
                if not f and RaidAssignments.RoleFilter.Healer[class] then
                    index = index + 1
                    RaidAssignments.Frames["HealToolTip"][name] = RaidAssignments.Frames["HealToolTip"][name] or RaidAssignments:AddToolTipFrame(name, RaidAssignments.HealToolTip)
                    local frame = RaidAssignments.Frames["HealToolTip"][name]
                    frame:SetPoint("TOPLEFT", RaidAssignments.HealToolTip, "TOPLEFT", 2, 25 + (-25 * index))
                    frame.texture:SetVertexColor(RaidAssignments:GetClassColors(name, "rgb"))
                    frame:Show()
                end
            end
        end
        RaidAssignments.Settings["active_heal"] = n
        RaidAssignments.HealToolTip:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
        RaidAssignments.HealToolTip:SetBackdropColor(0, 0, 0, 1)
        RaidAssignments.HealToolTip:SetWidth(102)
        RaidAssignments.HealToolTip:SetHeight(25 * index)
        RaidAssignments.HealToolTip:SetPoint("TOPLEFT", frameName, "TOPLEFT", -100, 0)
        RaidAssignments.HealToolTip:EnableMouse(true)
        RaidAssignments.HealToolTip:SetScript("OnLeave", function()
            RaidAssignments.HealToolTip:Hide()
        end)
        RaidAssignments.HealToolTip:SetFrameStrata("HIGH")
        RaidAssignments.HealToolTip:Show()
    end
end

function RaidAssignments:OpenGeneralToolTip(frameName)
    if GetRaidRosterInfo(1) or RaidAssignments.TestMode then
        for k, v in pairs(RaidAssignments.Frames["GeneralToolTip"]) do
            v:Hide()
        end
        local index = 0
        local n = tonumber(string.sub(frameName, 2))
        local roster = RaidAssignments.TestMode and RaidAssignments.TestRoster or {}
        local numMembers = RaidAssignments.TestMode and table.getn(RaidAssignments.TestRoster) or GetNumRaidMembers()
        for i = 1, numMembers do
            local name, class
            if RaidAssignments.TestMode then
                name = roster[i] and roster[i].name
                class = roster[i] and roster[i].class
            else
                name = UnitName("raid"..i)
                class = UnitClass("raid"..i)
            end
            if name and class then
                local f = false
                -- Check if player is already assigned to ANY general mark (1-10)
                for j = 1, 10 do
                    for k, v in pairs(RaidAssignments.GeneralMarks[j]) do
                        if name == v then
                            f = true
                            break
                        end
                    end
                    if f then break end
                end
                if not f and RaidAssignments_Settings[class] == 1 then
                    index = index + 1
                    RaidAssignments.Frames["GeneralToolTip"][name] = RaidAssignments.Frames["GeneralToolTip"][name] or RaidAssignments:AddToolTipFrame(name, RaidAssignments.GeneralToolTip)
                    local frame = RaidAssignments.Frames["GeneralToolTip"][name]
                    frame:SetPoint("TOPLEFT", RaidAssignments.GeneralToolTip, "TOPLEFT", 2, 25 + (-25 * index))
                    frame.texture:SetVertexColor(RaidAssignments:GetClassColors(name, "rgb"))
                    frame:Show()
                end
            end
        end
        RaidAssignments.Settings["active_general"] = n
        RaidAssignments.GeneralToolTip:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
        RaidAssignments.GeneralToolTip:SetBackdropColor(0, 0, 0, 1)
        RaidAssignments.GeneralToolTip:SetWidth(102)
        RaidAssignments.GeneralToolTip:SetHeight(25 * index)
        RaidAssignments.GeneralToolTip:SetPoint("TOPLEFT", frameName, "TOPLEFT", -100, 0)
        RaidAssignments.GeneralToolTip:EnableMouse(true)
        RaidAssignments.GeneralToolTip:SetScript("OnLeave", function()
            RaidAssignments.GeneralToolTip:Hide()
        end)
        RaidAssignments.GeneralToolTip:SetFrameStrata("HIGH")
        RaidAssignments.GeneralToolTip:Show()
    end
end

function RaidAssignments:AddTank(name, mark)
    mark = tonumber(mark)

    -- Prevent assigning the same player to ANY other tank mark (1-8)
    for i = 1, 8 do
        if RaidAssignments.Marks[i] then
            for _, v in pairs(RaidAssignments.Marks[i]) do
                if v == name then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: " .. name .. " is already assigned to tank " .. (RaidAssignments.RealMarks[i] or "a mark"))
                    return
                end
            end
        end
    end

    if not RaidAssignments.Marks[mark] then
        RaidAssignments.Marks[mark] = {}
    end
    local index = table.getn(RaidAssignments.Marks[mark]) + 1
    if index < 4 then
        local unit = RaidAssignments:GetRaidID(name)
        local class = RaidAssignments.TestMode and RaidAssignments:GetTestClass(name) or UnitClass(unit)
        -- Restrict first slot to primary tank classes
        if index == 1 and not RaidAssignments.RoleFilter.TankPrimary[class] then
            DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: Only Warrior, Druid, Paladin, or Shaman can be assigned as primary tank for mark " .. RaidAssignments.RealMarks[mark])
            return
        end
        RaidAssignments.Frames[mark][name] = RaidAssignments.Frames[mark][name] or RaidAssignments:AddTankFrame(name, mark)
        local frame = RaidAssignments.Frames[mark][name]
        frame:SetPoint("RIGHT", 10 + (105 * index), 0)
        frame.texture:SetVertexColor(RaidAssignments:GetClassColors(name, "rgb"))
        frame:Show()
        table.insert(RaidAssignments.Marks[mark], name)
    end
end


function RaidAssignments:AddHeal(name, mark)
    mark = tonumber(mark)

    -- Prevent assigning the same healer twice in the same mark
    for i = 1, 4 do
        if RaidAssignments.HealMarks[mark][i] == name then
            DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: " .. name .. " is already assigned to heal " .. RaidAssignments.HealRealMarks[mark])
            return
        end
    end

    local slot = nil
    -- Find first empty slot
    for i = 1, 4 do
        if not RaidAssignments.HealMarks[mark][i] then
            slot = i
            break
        end
    end

    if slot then
        RaidAssignments.HealFrames[mark][name] = RaidAssignments.HealFrames[mark][name] or RaidAssignments:AddHealFrame(name, mark)
        local frame = RaidAssignments.HealFrames[mark][name]
        local unit = RaidAssignments:GetRaidID(name)
        frame:SetPoint("RIGHT", 10 + (105 * slot), 0)
        frame.texture:SetVertexColor(RaidAssignments:GetClassColors(name, "rgb"))
        frame:Show()
        RaidAssignments.HealMarks[mark][slot] = name
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: All slots are already filled for " .. RaidAssignments.HealRealMarks[mark])
    end
end

function RaidAssignments:AddGeneral(name, mark)
    mark = tonumber(mark)
    
    -- Ensure the mark exists in the table
    if not RaidAssignments.GeneralMarks[mark] then
        RaidAssignments.GeneralMarks[mark] = {}
    end

    -- Prevent assigning the same player to ANY general mark (1-10)
    for i = 1, 10 do
        if RaidAssignments.GeneralMarks[i] then
            for _, v in pairs(RaidAssignments.GeneralMarks[i]) do
                if v == name then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: " .. name .. " is already assigned to " .. (RaidAssignments.GeneralRealMarks[i] or "a mark"))
                    return
                end
            end
        end
    end

    -- Find the first available slot
    local slot = nil
    for i = 1, 5 do
        if not RaidAssignments.GeneralMarks[mark][i] then
            slot = i
            break
        end
    end

    if slot then
        RaidAssignments.GeneralFrames[mark][name] = RaidAssignments.GeneralFrames[mark][name] or RaidAssignments:AddGeneralFrame(name, mark)
        local frame = RaidAssignments.GeneralFrames[mark][name]
        frame:SetPoint("RIGHT", 10 + (105 * slot), 0)
        frame.texture:SetVertexColor(RaidAssignments:GetClassColors(name, "rgb"))
        frame:Show()
        RaidAssignments.GeneralMarks[mark][slot] = name
        
        -- Send updates
        RaidAssignments:SendGeneral()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: All slots are already filled for " .. (RaidAssignments.GeneralRealMarks[mark] or "this mark"))
    end
end

function RaidAssignments:AddToolTipFrame(name, tooltip)
    local unit = RaidAssignments:GetRaidID(name)
    local frame = CreateFrame("Button", name, tooltip)
    local backdrop = {
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = false,
        tileSize = 8,
        edgeSize = 4,
        insets = { left = 2, right = 2, top = 0, bottom = 0 }
    }
    
    frame:SetWidth(100)
    frame:SetHeight(25)
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0) -- Transparent background
    
    frame.texture = frame:CreateTexture(nil, "ARTWORK")
    frame.texture:SetWidth(frame:GetWidth() - 4)
    frame.texture:SetHeight(24)
    frame.texture:SetPoint("TOPLEFT", 2, -1)
    frame.texture:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\LiteStep")
    frame.texture:SetGradientAlpha("VERTICAL", 1, 1, 1, 0, 1, 1, 1, 1)
    
    frame.name = frame:CreateFontString(nil, "OVERLAY")
    frame.name:SetPoint("CENTER", 0, 0)
    frame.name:SetFont("Interface\\AddOns\\RaidAssignments\\assets\\BalooBhaina.ttf", 12)
    frame.name:SetTextColor(1, 1, 1, 1)
    frame.name:SetShadowOffset(1, -1)
    frame.name:SetText(name)
    
    -- In the AddToolTipFrame function, update the OnClick script:
	frame:SetScript("OnClick", function()
		if IsRaidOfficer("player") then
			this:Hide()
			if tooltip == RaidAssignments.ToolTip then
				RaidAssignments:AddTank(this:GetName(), RaidAssignments.Settings["active"])
				RaidAssignments:OpenToolTip("T"..RaidAssignments.Settings["active"])
				RaidAssignments:SendTanks()
			elseif tooltip == RaidAssignments.HealToolTip then
				RaidAssignments:AddHeal(this:GetName(), RaidAssignments.Settings["active_heal"])
				RaidAssignments:OpenHealToolTip("H"..RaidAssignments.Settings["active_heal"])
				RaidAssignments:SendHeals()
			elseif tooltip == RaidAssignments.GeneralToolTip then
				RaidAssignments:AddGeneral(this:GetName(), RaidAssignments.Settings["active_general"])
				RaidAssignments:OpenGeneralToolTip("G"..RaidAssignments.Settings["active_general"])
				RaidAssignments:SendGeneral()
			end
		end
	end)
    frame.unit = unit
    frame:SetScript("OnEnter", UnitFrame_OnEnter)
    frame:SetScript("OnLeave", UnitFrame_OnLeave)
    return frame
end

function RaidAssignments:AddTankFrame(name, mark)
    local unit = RaidAssignments:GetRaidID(name)
    local frame = CreateFrame("Button", mark..name, RaidAssignments.bg)
    local backdrop = {
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = false,
        tileSize = 8,
        edgeSize = 4,
        insets = { left = 2, right = 2, top = 0, bottom = 0 }
    }
    frame:SetParent("T"..mark)
    frame:SetWidth(100)
    frame:SetHeight(25)    
    
    -- hpbar without portrait gap
    frame.hpbar = CreateFrame("Button", nil, frame)
    frame.hpbar:SetWidth(frame:GetWidth() - 4)
    frame.hpbar:SetHeight(24)
    frame.hpbar:SetPoint("TOPLEFT", 2, -1)
    frame.hpbar:SetFrameLevel(1)
    
    frame.texture = frame.hpbar:CreateTexture(nil, "ARTWORK")
    frame.texture:SetWidth(frame:GetWidth() - 4)
    frame.texture:SetHeight(24)
    frame.texture:SetPoint("TOPLEFT", 0, 0)
    frame.texture:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\LiteStep")
    frame.texture:SetGradientAlpha("VERTICAL", 1, 1, 1, 0, 1, 1, 1, 1)
    
    frame.name = frame.hpbar:CreateFontString(nil, "OVERLAY")
    frame.name:SetPoint("CENTER", 0, 0)
    frame.name:SetFont("Interface\\AddOns\\RaidAssignments\\assets\\BalooBhaina.ttf", 12)
    frame.name:SetTextColor(1, 1, 1, 1)
    frame.name:SetShadowOffset(1, -1)
    frame.name:SetText(name)

    if frame.portrait then
        frame.portrait:Hide()
    end

    frame:SetScript("OnClick", function()
        if IsRaidOfficer("player") then
            -- Remove from tank assignments
            for k, v in pairs(RaidAssignments.Marks[mark]) do
                if v == name then
                    table.remove(RaidAssignments.Marks[mark], k)
                    this:Hide()
                    RaidAssignments.Frames[mark][name] = nil -- clear cached frame
                    RaidAssignments:UpdateTanks()
                    RaidAssignments:SendTanks()
                    break
                end
            end
        end
    end)
    frame.unit = unit
    frame:SetScript("OnEnter", UnitFrame_OnEnter)
    frame:SetScript("OnLeave", UnitFrame_OnLeave)
    return frame
end

function RaidAssignments:AddHealFrame(name, mark)
    local unit = RaidAssignments:GetRaidID(name)
    local frame = CreateFrame("Button", "H"..mark..name, RaidAssignments.bg)
    local backdrop = {
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = false,
        tileSize = 8,
        edgeSize = 4,
        insets = { left = 2, right = 2, top = 0, bottom = 0 }
    }
    frame:SetParent("H"..mark)
    frame:SetWidth(100)
    frame:SetHeight(25)    
    
    frame.hpbar = CreateFrame("Button", nil, frame)
    frame.hpbar:SetWidth(frame:GetWidth() - 4)
    frame.hpbar:SetHeight(24)
    frame.hpbar:SetPoint("TOPLEFT", 2, -1)
    frame.hpbar:SetFrameLevel(1)
    
    frame.texture = frame.hpbar:CreateTexture(nil, "ARTWORK")
    frame.texture:SetWidth(frame:GetWidth() - 4)
    frame.texture:SetHeight(24)
    frame.texture:SetPoint("TOPLEFT", 0, 0)
    frame.texture:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\LiteStep")
    frame.texture:SetGradientAlpha("VERTICAL", 1, 1, 1, 0, 1, 1, 1, 1)
    
    frame.name = frame.hpbar:CreateFontString(nil, "OVERLAY")
    frame.name:SetPoint("CENTER", 0, 0)
    frame.name:SetFont("Interface\\AddOns\\RaidAssignments\\assets\\BalooBhaina.ttf", 12)
    frame.name:SetTextColor(1, 1, 1, 1)
    frame.name:SetShadowOffset(1, -1)
    frame.name:SetText(name)

    if frame.portrait then
        frame.portrait:Hide()
    end

    frame:SetScript("OnClick", function()
        if IsRaidOfficer("player") then
            for k = 1, 4 do
                if RaidAssignments.HealMarks[mark][k] == name then
                    RaidAssignments.HealMarks[mark][k] = nil
                    this:Hide()
                    RaidAssignments.HealFrames[mark][name] = nil -- clear cached frame
                    RaidAssignments:UpdateHeals()
                    break
                end
            end
            RaidAssignments:SendHeals()
        end
    end)

    frame.unit = unit
    frame:SetScript("OnEnter", UnitFrame_OnEnter)
    frame:SetScript("OnLeave", UnitFrame_OnLeave)
    return frame
end

function RaidAssignments:AddGeneralFrame(name, mark)
    local unit = RaidAssignments:GetRaidID(name)
    local frame = CreateFrame("Button", mark..name, RaidAssignments.generalBg)
    local backdrop = {
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = false,
        tileSize = 8,
        edgeSize = 4,
        insets = { left = 2, right = 2, top = 0, bottom = 0 }
    }
    frame:SetParent("G"..mark)
    frame:SetWidth(100)
    frame:SetHeight(25)    
    
    -- hpbar without portrait gap
    frame.hpbar = CreateFrame("Button", nil, frame)
    frame.hpbar:SetWidth(frame:GetWidth() - 4)
    frame.hpbar:SetHeight(24)
    frame.hpbar:SetPoint("TOPLEFT", 2, -1)
    frame.hpbar:SetFrameLevel(1)
    
    frame.texture = frame.hpbar:CreateTexture(nil, "ARTWORK")
    frame.texture:SetWidth(frame:GetWidth() - 4)
    frame.texture:SetHeight(24)
    frame.texture:SetPoint("TOPLEFT", 0, 0)
    frame.texture:SetTexture("Interface\\AddOns\\RaidAssignments\\assets\\LiteStep")
    frame.texture:SetGradientAlpha("VERTICAL", 1, 1, 1, 0, 1, 1, 1, 1)
    
    frame.name = frame.hpbar:CreateFontString(nil, "OVERLAY")
    frame.name:SetPoint("CENTER", 0, 0)
    frame.name:SetFont("Interface\\AddOns\\RaidAssignments\\assets\\BalooBhaina.ttf", 12)
    frame.name:SetTextColor(1, 1, 1, 1)
    frame.name:SetShadowOffset(1, -1)
    frame.name:SetText(name)

    if frame.portrait then
        frame.portrait:Hide()
    end

    frame:SetScript("OnClick", function()
        if IsRaidOfficer("player") then
            for slot = 1, 5 do
                if RaidAssignments.GeneralMarks[mark] and RaidAssignments.GeneralMarks[mark][slot] == name then
                    RaidAssignments.GeneralMarks[mark][slot] = nil
                    this:Hide()
                    RaidAssignments.GeneralFrames[mark][name] = nil -- clear cached frame
                    RaidAssignments:UpdateGeneral()
                    RaidAssignments:SendGeneral() -- Broadcast the updated GeneralMarks
                    break
                end
            end
        end
    end)
    frame.unit = unit
    frame:SetScript("OnEnter", UnitFrame_OnEnter)
    frame:SetScript("OnLeave", UnitFrame_OnLeave)
    return frame
end
function RaidAssignments:PostAssignments()
    local chan = "RAID" -- Default to RAID channel
    local chanNum = nil
    local n = false

    if RaidAssignments_Settings["usecolors"] then
        -- Tanks
        for i = 1, 8 do
            if RaidAssignments.Marks[i] ~= nil and table.getn(RaidAssignments.Marks[i]) ~= 0 then
                n = true
            end
        end
        if n then
            SendChatMessage("-- Tank Assignments --", chan, nil, chanNum)
            local i = 8
            while i > 0 do
                local text = RaidAssignments:GetClassColors(RaidAssignments.RealMarks[i], "mark")
                if table.getn(RaidAssignments.Marks[i]) ~= 0 then
                    for k, v in pairs(RaidAssignments.Marks[i]) do
                        if k == 1 then
                            text = text .. ": " .. RaidAssignments:GetClassColors(v, "cff")
                        else
                            text = text .. ", " .. RaidAssignments:GetClassColors(v, "cff")
                        end
                        if k == table.getn(RaidAssignments.Marks[i]) then
                            text = text .. "."
                        end
                    end
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i - 1
            end
        end

        -- Heals
        n = false
        for i = 1, 12 do
            for k = 1, 4 do
                if RaidAssignments.HealMarks[i][k] then
                    n = true
                    break
                end
            end
        end
        if n then
            SendChatMessage("-- Heal Assignments --", chan, nil, chanNum)
            local i = 12
            while i > 0 do
                local text = RaidAssignments.HealRealMarks[i]
                local hasHealers = false
                for k = 1, 4 do
                    if RaidAssignments.HealMarks[i][k] then
                        hasHealers = true
                        break
                    end
                end
                if hasHealers then
                    text = text .. ": "
                    for k = 1, 4 do
                        local v = RaidAssignments.HealMarks[i][k]
                        if v then
                            text = text .. "(" .. k .. ") " .. RaidAssignments:GetClassColors(v, "cff")
                            local hasMore = false
                            for m = k + 1, 4 do
                                if RaidAssignments.HealMarks[i][m] then
                                    hasMore = true
                                    break
                                end
                            end
                            if hasMore then
                                text = text .. ", "
                            else
                                text = text .. "."
                            end
                        end
                    end
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i - 1
            end
        end

    else
        -- Tanks (no colors)
        for i = 1, 8 do
            if RaidAssignments.Marks[i] ~= nil and table.getn(RaidAssignments.Marks[i]) ~= 0 then
                n = true
            end
        end
        if n then
            SendChatMessage("-- Tank Assignments --", chan, nil, chanNum)
            local i = 8
            while i > 0 do
                local text = RaidAssignments.RealMarks[i]
                if table.getn(RaidAssignments.Marks[i]) ~= 0 then
                    for k, v in pairs(RaidAssignments.Marks[i]) do
                        if k == 1 then
                            text = text .. ": " .. v
                        else
                            text = text .. ", " .. v
                        end
                        if k == table.getn(RaidAssignments.Marks[i]) then
                            text = text .. "."
                        end
                    end
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i - 1
            end
        end

        -- Heals (no colors)
        n = false
        for i = 1, 12 do
            for k = 1, 4 do
                if RaidAssignments.HealMarks[i][k] then
                    n = true
                    break
                end
            end
        end
        if n then
            SendChatMessage("-- Heal Assignments --", chan, nil, chanNum)
            local i = 12
            while i > 0 do
                local text = RaidAssignments.HealRealMarks[i]
                local hasHealers = false
                for k = 1, 4 do
                    if RaidAssignments.HealMarks[i][k] then
                        hasHealers = true
                        break
                    end
                end
                if hasHealers then
                    text = text .. ": "
                    for k = 1, 4 do
                        local v = RaidAssignments.HealMarks[i][k]
                        if v then
                            text = text .. "(" .. k .. ") " .. v
                            local hasMore = false
                            for m = k + 1, 4 do
                                if RaidAssignments.HealMarks[i][m] then
                                    hasMore = true
                                    break
                                end
                            end
                            if hasMore then
                                text = text .. ", "
                            else
                                text = text .. "."
                            end
                        end
                    end
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i - 1
            end
        end
    end
    if RaidAssignments_Settings["useWhisper"] then
        self:WhisperAssignments()
    end
end

function RaidAssignments:GenerateTestRoster()
    RaidAssignments.TestRoster = {}
    local classes = {"Warrior", "Warlock", "Rogue", "Priest", "Mage", "Hunter", "Druid", "Paladin", "Shaman"}
    local names = {
        "Abelius", "Arboldemango", "Azzer", "Bestigor", "Bigbron", "Bombardero", "Calogero", "Catu",
        "Culin", "Dardork", "Darez", "Dragovar", "Durotavich", "Edeax", "Elcucho", "Eisla",
        "Gulolio", "Hecryp", "Hezpar", "Hoplite", "Kukarda", "Lokyu", "Ndree", "Neneta",
        "Neralone", "Ocuspocuss", "Onrul", "Palawhite", "Pandamonium", "Pimienta", "Pokker", "Fionna",
        "Selner", "Sinnergia", "Tankita", "Teletubbiei", "Uburrka", "Xanty", "Xposed", "Zeroxkg"
    }
    for i = 1, 40 do
        local class = classes[math.mod(i - 1, 9) + 1] -- Distribute classes evenly
        local name = names[i] -- Use name from the pool
        table.insert(RaidAssignments.TestRoster, {
            name = name,
            class = class
        })
    end
end

function RaidAssignments:GetTestClass(name)
    for _, unit in pairs(RaidAssignments.TestRoster) do
        if unit.name == name then
            return unit.class
        end
    end
    return nil
end

function RaidAssignments:ToggleTestMode()
    if not RaidAssignments.TestMode then
        RaidAssignments.TestMode = true
        RaidAssignments:GenerateTestRoster()
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: Test mode enabled with 40 dummy players")
    else
        RaidAssignments.TestMode = false
        RaidAssignments.TestRoster = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: Test mode disabled")
    end
    RaidAssignments:UpdateTanks()
    RaidAssignments:UpdateHeals()
    RaidAssignments:UpdateGeneral()
end

function RaidAssignments:Slash(arg1)
	if arg1 == nil or arg1 == "" then
		if RaidAssignments:IsVisible() then
			RaidAssignments.ToolTip:Hide()
			RaidAssignments.HealToolTip:Hide()
			RaidAssignments.Settings["Animation"] = true
			RaidAssignments.Settings["MainFrame"] = false
		else
			RaidAssignments.Settings["Animation"] = false
			RaidAssignments.Settings["MainFrame"] = false
			RaidAssignments.Settings["SizeX"] = 0
			RaidAssignments.Settings["SizeY"] = 0
			RaidAssignments:Show()
		end
	elseif arg1 == "test" then
		RaidAssignments:ToggleTestMode()
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: Unknown command. Use /ta, or /ta test")
	end
end

SLASH_TA1, SLASH_TA2 = "/ta", "/tanksassignments"
function SlashCmdList.TA(msg, editbox)
	RaidAssignments:Slash(msg)
end

RaidAssignments:SetScript("OnEvent", RaidAssignments.OnEvent)

function RaidAssignments:Debug()
	for k, v in pairs(RaidAssignments.Marks) do
		for i, name in pairs(RaidAssignments.Marks[k]) do
			DEFAULT_CHAT_FRAME:AddMessage(k..": "..i.." - "..name)
		end
	end
end

function RaidAssignments:PostRaidAssignments()
    local chan = "RAID"
    local chanNum = nil
    local n = false

    if RaidAssignments_Settings["usecolors"] then
        -- Tanks
        for i = 1, 8 do
            if RaidAssignments.Marks[i] ~= nil and table.getn(RaidAssignments.Marks[i]) ~= 0 then
                n = true
            end
        end
        if n then
            SendChatMessage("-- Tank Assignments --", chan, nil, chanNum)
            local i = 8
            while i > 0 do
                local text = RaidAssignments:GetClassColors(RaidAssignments.RealMarks[i], "mark")
                if table.getn(RaidAssignments.Marks[i]) ~= 0 then
                    for k, v in pairs(RaidAssignments.Marks[i]) do
                        if k == 1 then
                            text = text .. ": " .. RaidAssignments:GetClassColors(v, "cff")
                        else
                            text = text .. ", " .. RaidAssignments:GetClassColors(v, "cff")
                        end
                        if k == table.getn(RaidAssignments.Marks[i]) then
                            text = text .. "."
                        end
                    end
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i - 1
            end
        end
    else
        -- Tanks (no colors)
        for i = 1, 8 do
            if RaidAssignments.Marks[i] ~= nil and table.getn(RaidAssignments.Marks[i]) ~= 0 then
                n = true
            end
        end
        if n then
            SendChatMessage("-- Tank Assignments --", chan, nil, chanNum)
            local i = 8
            while i > 0 do
                local text = RaidAssignments.RealMarks[i]
                if table.getn(RaidAssignments.Marks[i]) ~= 0 then
                    for k, v in pairs(RaidAssignments.Marks[i]) do
                        if k == 1 then
                            text = text .. ": " .. v
                        else
                            text = text .. ", " .. v
                        end
                        if k == table.getn(RaidAssignments.Marks[i]) then
                            text = text .. "."
                        end
                    end
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i - 1
            end
        end
    end
    if RaidAssignments_Settings["useWhisper"] then
        for i = 1, 8 do
            for k, v in pairs(RaidAssignments.Marks[i]) do
                if RaidAssignments:IsInRaid(v) then
                    local text = "You are assigned to tank " .. RaidAssignments.RealMarks[i] .. " (slot " .. k .. ")"
                    SendChatMessage(text, "WHISPER", nil, v)
                end
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: Whispered tank assignments to players")
    end
end

function RaidAssignments:PostHealAssignments()
    local chan = "RAID"
    local chanNum = nil
    local n = false

    if RaidAssignments_Settings["usecolors"] then
        -- Heals
        for i = 1, 12 do
            for k = 1, 4 do
                if RaidAssignments.HealMarks[i][k] then
                    n = true
                    break
                end
            end
        end
        if n then
            SendChatMessage("-- Heal Assignments --", chan, nil, chanNum)
            local i = 12
            while i > 0 do
                local text = RaidAssignments.HealRealMarks[i]
                local hasHealers = false
                for k = 1, 4 do
                    if RaidAssignments.HealMarks[i][k] then
                        hasHealers = true
                        break
                    end
                end
                if hasHealers then
                    text = text .. ": "
                    for k = 1, 4 do
                        local v = RaidAssignments.HealMarks[i][k]
                        if v then
                            text = text .. "(" .. k .. ") " .. RaidAssignments:GetClassColors(v, "cff")
                            local hasMore = false
                            for m = k + 1, 4 do
                                if RaidAssignments.HealMarks[i][m] then
                                    hasMore = true
                                    break
                                end
                            end
                            if hasMore then
                                text = text .. ", "
                            else
                                text = text .. "."
                            end
                        end
                    end
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i - 1
            end
        end
    else
        -- Heals (no colors)
        for i = 1, 12 do
            for k = 1, 4 do
                if RaidAssignments.HealMarks[i][k] then
                    n = true
                    break
                end
            end
        end
        if n then
            SendChatMessage("-- Heal Assignments --", chan, nil, chanNum)
            local i = 12
            while i > 0 do
                local text = RaidAssignments.HealRealMarks[i]
                local hasHealers = false
                for k = 1, 4 do
                    if RaidAssignments.HealMarks[i][k] then
                        hasHealers = true
                        break
                    end
                end
                if hasHealers then
                    text = text .. ": "
                    for k = 1, 4 do
                        local v = RaidAssignments.HealMarks[i][k]
                        if v then
                            text = text .. "(" .. k .. ") " .. v
                            local hasMore = false
                            for m = k + 1, 4 do
                                if RaidAssignments.HealMarks[i][m] then
                                    hasMore = true
                                    break
                                end
                            end
                            if hasMore then
                                text = text .. ", "
                            else
                                text = text .. "."
                            end
                        end
                    end
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i - 1
            end
        end
    end
    if RaidAssignments_Settings["useWhisper"] then
        for i = 1, 12 do
            for k = 1, 4 do
                local v = RaidAssignments.HealMarks[i][k]
                if v and RaidAssignments:IsInRaid(v) then
                    local text = "You are assigned to heal " .. RaidAssignments.HealRealMarks[i] .. " (slot " .. k .. ")"
                    SendChatMessage(text, "WHISPER", nil, v)
                end
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: Whispered heal assignments to players")
    end
end

function RaidAssignments:PostGeneralAssignments()
    local chan = "RAID"
    local chanNum = nil
    local n = false

    if RaidAssignments_Settings["usecolors"] then
        for i = 1, 10 do -- Changed from 8 to 10 to include custom marks
            if RaidAssignments.GeneralMarks[i] ~= nil then
                local hasAssignments = false
                for k = 1, 5 do
                    if RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][k] then
                        hasAssignments = true
                        n = true
                        break
                    end
                end
            end
        end
        if n then
            SendChatMessage("-- General Assignments --", chan, nil, chanNum)
            local i = 1
            while i <= 10 do -- Changed from 8 to 10
                local hasAssignments = false
                for k = 1, 5 do
                    if RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][k] then
                        hasAssignments = true
                        break
                    end
                end
                
                if hasAssignments then
                    -- Get the mark text from the input box for custom marks, or use predefined names
                    local markText = RaidAssignments.GeneralRealMarks[i]
                    if i >= 9 then
                        -- For custom marks 9 and 10, get the text from the EditBox
                        local editBox = _G["G"..i.."_Edit"]
                        if editBox then
                            local editText = editBox:GetText()
                            if editText and editText ~= "" then
                                markText = editText
                            else
                                markText = "Custom Mark " .. (i - 8)
                            end
                        else
                            markText = "Custom Mark " .. (i - 8)
                        end
                    end
                    
                    local text = markText .. ": "
                    local first = true
                    for k = 1, 5 do
                        local v = RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][k]
                        if v then
                            if not first then
                                text = text .. ", "
                            end
                            text = text .. RaidAssignments:GetClassColors(v, "cff")
                            first = false
                        end
                    end
                    text = text .. "."
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i + 1
            end
        end
    else
        for i = 1, 10 do -- Changed from 8 to 10
            if RaidAssignments.GeneralMarks[i] ~= nil then
                local hasAssignments = false
                for k = 1, 5 do
                    if RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][k] then
                        hasAssignments = true
                        n = true
                        break
                    end
                end
            end
        end
        if n then
            SendChatMessage("-- General Assignments --", chan, nil, chanNum)
            local i = 1
            while i <= 10 do -- Changed from 8 to 10
                local hasAssignments = false
                for k = 1, 5 do
                    if RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][k] then
                        hasAssignments = true
                        break
                    end
                end
                
                if hasAssignments then
                    -- Get the mark text from the input box for custom marks, or use predefined names
                    local markText = RaidAssignments.GeneralRealMarks[i]
                    if i >= 9 then
                        -- For custom marks 9 and 10, get the text from the EditBox
                        local editBox = _G["G"..i.."_Edit"]
                        if editBox then
                            local editText = editBox:GetText()
                            if editText and editText ~= "" then
                                markText = editText
                            else
                                markText = "Custom Mark " .. (i - 8)
                            end
                        else
                            markText = "Custom Mark " .. (i - 8)
                        end
                    end
                    
                    local text = markText .. ": "
                    local first = true
                    for k = 1, 5 do
                        local v = RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][k]
                        if v then
                            if not first then
                                text = text .. ", "
                            end
                            text = text .. v
                            first = false
                        end
                    end
                    text = text .. "."
                    SendChatMessage(text, chan, nil, chanNum)
                end
                i = i + 1
            end
        end
    end
    if RaidAssignments_Settings["useWhisper"] then
        for i = 1, 10 do -- Changed from 8 to 10
            for k = 1, 5 do
                local v = RaidAssignments.GeneralMarks[i] and RaidAssignments.GeneralMarks[i][k]
                if v and RaidAssignments:IsInRaid(v) then
                    -- Get the mark text from the input box for custom marks, or use predefined names
                    local markText = RaidAssignments.GeneralRealMarks[i]
                    if i >= 9 then
                        -- For custom marks 9 and 10, get the text from the EditBox
                        local editBox = _G["G"..i.."_Edit"]
                        if editBox then
                            local editText = editBox:GetText()
                            if editText and editText ~= "" then
                                markText = editText
                            else
                                markText = "Custom Mark " .. (i - 8)
                            end
                        else
                            markText = "Custom Mark " .. (i - 8)
                        end
                    end
                    local text = "You are assigned to " .. markText .. " (slot " .. k .. ")"
                    SendChatMessage(text, "WHISPER", nil, v)
                end
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffC79C6E RaidAssignments 2.0|r: Whispered general assignments to players")
    end
end

function RaidAssignments:SendCustomMarkLabels()
    if IsRaidOfficer("player") then
        local sendstring = ""
        for i = 9, 10 do
            local label = RaidAssignments.GeneralRealMarks[i] or ""
            -- Use simple format without pipe characters
            sendstring = sendstring .. i .. "_" .. label .. ","
        end
        SendAddonMessage("RaidAssignmentsCustomLabels", sendstring, "RAID")
    end
end