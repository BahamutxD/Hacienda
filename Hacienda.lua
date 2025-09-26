Hacienda = {}
Hacienda.conversations = {}
Hacienda.settings = {}

Hacienda.contactFramePool = {}
Hacienda.activeContactFrames = {}
Hacienda.minimapButton = nil

function Hacienda:Trim(str)
    if not str then return "" end
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

-- Banco de la Guild Constants
local ACTION_DEPOSIT_MONEY = 5
local ACTION_WITHDRAW_MONEY = 4
local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD = 100
local GUILD_BANK_PREFIX = "TW_GUILDBANK"
local GUILD_BANK_CONTACT = "Banco de la Guild"
local PAID_OS_CONTACT = "OS Pagadas" -- New category for paid OS
local MAX_GUILDBANK_SLOTS_PER_TAB = MAX_GUILDBANK_SLOTS_PER_TAB or 52 -- Fallback if not defined

function Hacienda:OnLoad()
    if not HaciendaSavedData then
        HaciendaSavedData = {
            conversations = {},
            settings = {},
            paidConversations = {}, -- New storage for paid OS
            linkedChars = {} -- Storage for linked characters
        }
    end
    
    -- Initialize account-wide conversations if they don't exist
    if not HaciendaSavedData.conversations then
        HaciendaSavedData.conversations = {}
    end
    
    -- Initialize Banco de la Guild conversation if it doesn't exist
    if not HaciendaSavedData.conversations[GUILD_BANK_CONTACT] then
        HaciendaSavedData.conversations[GUILD_BANK_CONTACT] = {}
    end
    
    -- Initialize OS Pagadas conversation if it doesn't exist
    if not HaciendaSavedData.paidConversations then
        HaciendaSavedData.paidConversations = {}
    end
    
    -- Initialize linked characters if it doesn't exist
    if not HaciendaSavedData.linkedChars then
        HaciendaSavedData.linkedChars = {}
    end
    
    -- Per-character settings (like UI preferences)
    if not HaciendaCharacterSettings then
        HaciendaCharacterSettings = {
            unreadCounts = {},
            uiSettings = {}
        }
    end
    
    Hacienda.conversations = HaciendaSavedData.conversations
    Hacienda.paidConversations = HaciendaSavedData.paidConversations -- Reference to paid OS
    Hacienda.linkedChars = HaciendaSavedData.linkedChars -- Reference to linked characters
    Hacienda.accountSettings = HaciendaSavedData.settings
    Hacienda.characterSettings = HaciendaCharacterSettings
    
    this:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
    this:RegisterEvent("PLAYER_LOGIN")
    this:RegisterEvent("CHAT_MSG_SYSTEM")
    this:RegisterEvent("CHAT_MSG_ADDON") -- For guild bank messages
    this:RegisterEvent("GUILD_ROSTER_UPDATE") -- To track guild info
    this:RegisterEvent("GUILDBANKFRAME_OPENED") -- To update bank logs when opening guild bank

    SLASH_Hacienda1 = "/hacienda"
    SLASH_Hacienda2 = "/hc"
    SLASH_Hacienda3 = "/hconq"
    SlashCmdList["Hacienda"] = function(msg)
        Hacienda:ToggleFrame()
    end
    
    Hacienda:CreateMinimapButton()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r loaded! Use /hacienda, /hc, or /hconq to open.")
end

function Hacienda:OnEvent(event)
    -- Handle player login
    if event == "PLAYER_LOGIN" then
        Hacienda.transientMessages = {} -- Clear transient messages on login
        
        -- Initialize account-wide data structure if needed
        if not HaciendaSavedData then
            HaciendaSavedData = {
                conversations = {},
                paidConversations = {}, -- OS Pagadas storage
                linkedChars = {}, -- Linked characters storage
                settings = {
                    conversationsListCollapsed = false
                },
                pendingTotals = {} -- Initialize pending OS totals table
            }
        end
        
        -- Backwards compatibility - ensure pendingTotals exists
        if not HaciendaSavedData.pendingTotals then
            HaciendaSavedData.pendingTotals = {}
        end
        
        -- Backwards compatibility - ensure paidConversations exists
        if not HaciendaSavedData.paidConversations then
            HaciendaSavedData.paidConversations = {}
        end
        
        -- Backwards compatibility - ensure linkedChars exists
        if not HaciendaSavedData.linkedChars then
            HaciendaSavedData.linkedChars = {}
        end
        
        -- Initialize per-character settings if needed
        if not HaciendaCharacterSettings then
            HaciendaCharacterSettings = {
                unreadCounts = {}
            }
        end
        
        -- Set references to the data stores
        Hacienda.conversations = HaciendaSavedData.conversations
        Hacienda.paidConversations = HaciendaSavedData.paidConversations
        Hacienda.linkedChars = HaciendaSavedData.linkedChars
        Hacienda.accountSettings = HaciendaSavedData.settings
        Hacienda.characterSettings = HaciendaCharacterSettings
        Hacienda.unreadCounts = Hacienda.characterSettings.unreadCounts
        Hacienda.pendingTotals = HaciendaSavedData.pendingTotals
        
        -- Ensure all settings have default values
        if Hacienda.accountSettings.conversationsListCollapsed == nil then
            Hacienda.accountSettings.conversationsListCollapsed = false
        end
        
        -- Initialize pending totals for existing conversations
        for contact, messages in pairs(Hacienda.conversations) do
            if contact ~= GUILD_BANK_CONTACT and contact ~= PAID_OS_CONTACT then
                local total = 0
                for _, msg in ipairs(messages) do
                    if msg.outgoing and msg.moneyAmount then
                        total = total + (msg.moneyAmount or 0)
                    end
                end
                if total > 0 then
                    Hacienda.pendingTotals[contact] = total
                end
            end
        end
        
        -- Update all guild notes on login
        Hacienda:UpdateAllGuildNotes()
    
    -- Handle outgoing whispers (OS tracking)
    elseif event == "CHAT_MSG_WHISPER_INFORM" then
        local message = arg1
        local recipient = arg2

        -- Only process messages containing "Precio OS:"
        if string.find(string.lower(message), "precio os:") then
            -- Clean the message
            local cleanMessage = string.gsub(message, "^[Pp][Rr][Ee][Cc][Ii][Oo] [Oo][Ss]:%s*", "")
            cleanMessage = string.gsub(cleanMessage, "%s*>>>INGRESAR EN BANCO DE LA GUILD<<<%s*$", "")
            
            -- Extract and convert money to copper
            local totalCopper = 0
            
            -- Extract gold
            local _, _, goldStr = string.find(message, "(%d+)g")
            local gold = tonumber(goldStr) or 0
            totalCopper = totalCopper + (gold * 10000)
            
            -- Extract silver
            local _, _, silverStr = string.find(message, "(%d+)s")
            local silver = tonumber(silverStr) or 0
            totalCopper = totalCopper + (silver * 100)
            
            -- Extract copper
            local _, _, copperStr = string.find(message, "(%d+)c")
            local copper = tonumber(copperStr) or 0
            totalCopper = totalCopper + copper

            -- Ensure conversation exists
            if not Hacienda.conversations[recipient] then
                Hacienda.conversations[recipient] = {}
            end

            -- Check for duplicates
            local isDuplicate = false
            if table.getn(Hacienda.conversations[recipient]) > 0 then
                local lastMessage = Hacienda.conversations[recipient][table.getn(Hacienda.conversations[recipient])]
                if lastMessage.outgoing and lastMessage.message == cleanMessage and lastMessage.moneyAmount == totalCopper then
                    isDuplicate = true
                end
            end
            
            if not isDuplicate then
                -- Add the message
                local entry = {
                    message = cleanMessage,
                    time = time(),
                    outgoing = true,
                    moneyAmount = totalCopper,  -- Original total amount
                    paidAmount = 0,             -- Amount paid so far (starts at 0)
                    paymentTime = nil           -- When fully paid (nil until paid)
                }
                table.insert(Hacienda.conversations[recipient], entry)
    
                -- Update pending total
                Hacienda.pendingTotals[recipient] = (Hacienda.pendingTotals[recipient] or 0) + totalCopper
                
                -- Update guild note with debt information (only when new OS is added)
                Hacienda:UpdateGuildNoteWithDebt(recipient)
            end
            
            -- Update UI
            if Hacienda.frame and Hacienda.frame:IsVisible() then
                Hacienda:UpdateContactList()
                if Hacienda.selectedContact == recipient then
                    Hacienda:UpdateChatHistory()
                end
            end
        end
    
    -- Handle system messages (player offline)
    elseif event == "CHAT_MSG_SYSTEM" then
        local sysMessage = arg1
        local _, _, playerName = string.find(sysMessage, "No player named '(.+)' is currently playing.")
        
        if playerName then
            if Hacienda.conversations[playerName] and table.getn(Hacienda.conversations[playerName]) > 0 then
                local lastMessage = Hacienda.conversations[playerName][table.getn(Hacienda.conversations[playerName])]
                if lastMessage.outgoing then
                    Hacienda:RemoveLastMessage(playerName)
                    Hacienda:AddSystemMessage(playerName, playerName .. " is offline.", true)
                end
            end
        end
    
    -- Handle guild bank opening
    elseif event == "GUILDBANKFRAME_OPENED" then
        RequestGuildBankLog(MAX_GUILDBANK_SLOTS_PER_TAB or 50)
        
        local waitFrame = CreateFrame("Frame")
        waitFrame:SetScript("OnUpdate", function()
            this.timePassed = (this.timePassed or 0) + arg1
            if this.timePassed >= 1 then
                this:SetScript("OnUpdate", nil)
            end
        end)
    
    -- Handle guild bank logs (deposits)
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message = arg1, arg2
        if prefix == GUILD_BANK_PREFIX and string.find(message, "MoneyLog:") then
            if not self.lastBankLogProcess or (GetTime() - self.lastBankLogProcess) > 1 then
                self.lastBankLogProcess = GetTime()
                
                local logLine = string.gsub(message, "MoneyLog:", "")
                local transactions = self:explode(logLine, "=")
                local addedCount = 0
                
                if not HaciendaSavedData.conversations[GUILD_BANK_CONTACT] then
                    HaciendaSavedData.conversations[GUILD_BANK_CONTACT] = {}
                end
                
                for _, transaction in ipairs(transactions) do
                    if transaction and transaction ~= "" and transaction ~= "end" then
                        local logParts = self:explode(transaction, ";")
                        if table.getn(logParts) >= 4 then
                            local timestamp = tonumber(logParts[1])
                            local player = logParts[2]
                            local action = tonumber(logParts[3])
                            local amount = tonumber(logParts[4])
                            
                            if action == ACTION_DEPOSIT_MONEY then
                                local exists = false
                                for _, msg in ipairs(HaciendaSavedData.conversations[GUILD_BANK_CONTACT]) do
                                    if msg.time == timestamp and msg.player == player and msg.amountCopper == amount then
                                        exists = true
                                        break
                                    end
                                end
                                                
                                if not exists then
                                    self:ProcessBankTransaction(transaction)
                                    addedCount = addedCount + 1
                                    
                                    -- Update guild note when a deposit is processed
                                    Hacienda:UpdateGuildNoteWithDebt(player)
                                end
                            end
                        end
                    end
                end
                
                if addedCount > 0 then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Added "..addedCount.." new guild bank transactions.")
                    if self.frame and self.frame:IsVisible() and self.selectedContact == GUILD_BANK_CONTACT then
                        self:UpdateChatHistory()
                    end
                end
            end
        end
        
    -- Handle guild roster updates (but only use for initial sync, not constant updates)
    elseif event == "GUILD_ROSTER_UPDATE" then
        -- Only update notes on initial guild roster load, not every update
        if not self.guildRosterInitialized then
            self.guildRosterInitialized = true
            -- Small delay to ensure roster is fully loaded
            self:ScheduleEvent(function()
                Hacienda:UpdateAllGuildNotes()
            end, 2)
        end
    end
end

-- Helper functions for linked characters
function Hacienda:GetMainChar(char)
    return self.linkedChars[char] or char
end

function Hacienda:GetGroupMembers(char)
    local main = self:GetMainChar(char)
    local members = {main}
    for c, m in pairs(self.linkedChars) do
        if m == main and c ~= main then
            table.insert(members, c)
        end
    end
    return members
end

function Hacienda:GetGroupPending(char)
    local members = self:GetGroupMembers(char)
    local total = 0
    for _, m in ipairs(members) do
        total = total + (self.pendingTotals[m] or 0)
    end
    return total
end

-- New function to update guild note with debt information
function Hacienda:UpdateGuildNoteWithDebt(playerName)
    -- Only proceed if we're in a guild and have permission to edit notes
    if not IsInGuild() or not CanEditPublicNote() then
        return
    end
    
    local main = self:GetMainChar(playerName)
    local members = self:GetGroupMembers(main)
    local groupTotal = self:GetGroupPending(playerName)
    
    if groupTotal <= 0 then
        -- If no debt, remove any existing debt note for all members
        self:RemoveDebtFromGuildNote(playerName)
        return
    end
    
    -- Convert copper to gold/silver/copper
    local gold = floor(groupTotal / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local silver = floor((groupTotal - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
    local copper = mod(groupTotal, COPPER_PER_SILVER)
    
    -- Format the debt text
    local debtText = string.format("OS: %dg %ds %dc", gold, silver, copper)
    
    -- Update note for each member in the group
    for _, member in ipairs(members) do
        -- Find the player in the guild roster
        for i = 1, GetNumGuildMembers() do
            local name, rank, rankIndex, level, class, zone, note, officerNote, online, status = GetGuildRosterInfo(i)
            if name and string.lower(name) == string.lower(member) then
                -- Check if the note already contains debt information
                local newNote = note or ""
                local originalNoteWithoutDebt = newNote
                
                -- Remove any existing debt information
                newNote = string.gsub(newNote, "OS: %d+g %d+s %d+c", "")
                newNote = string.gsub(newNote, "OS: %d+g %d+s", "")
                newNote = string.gsub(newNote, "OS: %d+g", "")
                newNote = string.gsub(newNote, "OS: %d+s %d+c", "")
                newNote = string.gsub(newNote, "OS: %d+s", "")
                newNote = string.gsub(newNote, "OS: %d+c", "")
                
                -- Clean up: remove ALL pipes and extra spaces, then reconstruct properly
                newNote = string.gsub(newNote, "|", "") -- Remove all pipes
                newNote = string.gsub(newNote, "%s+", " ") -- Collapse multiple spaces
                newNote = Hacienda:Trim(newNote) -- Trim whitespace
                
                -- Preserve the original note content (without debt info)
                local cleanNote = newNote
                
                -- Add the new debt information with a single separator if needed
                if cleanNote and cleanNote ~= "" then
                    newNote = cleanNote .. " | " .. debtText
                else
                    newNote = debtText
                end
                
                -- Only update if the note has actually changed
                if newNote ~= originalNoteWithoutDebt then
                    GuildRosterSetPublicNote(i, newNote)
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Updated guild note for " .. member .. ": " .. newNote)
                end
                break
            end
        end
    end
end

-- New function to remove debt information from guild note
function Hacienda:RemoveDebtFromGuildNote(playerName)
    -- Only proceed if we're in a guild and have permission to edit notes
    if not IsInGuild() or not CanEditPublicNote() then
        return
    end
    
    local main = self:GetMainChar(playerName)
    local members = self:GetGroupMembers(main)
    
    -- Update note for each member in the group
    for _, member in ipairs(members) do
        -- Find the player in the guild roster
        for i = 1, GetNumGuildMembers() do
            local name, rank, rankIndex, level, class, zone, note, officerNote, online, status = GetGuildRosterInfo(i)
            if name and string.lower(name) == string.lower(member) then
                -- Remove any debt information from the note
                if note then
                    local originalNote = note
                    local newNote = note
                    
                    -- Remove debt information
                    newNote = string.gsub(newNote, "OS: %d+g %d+s %d+c", "")
                    newNote = string.gsub(newNote, "OS: %d+g %d+s", "")
                    newNote = string.gsub(newNote, "OS: %d+g", "")
                    newNote = string.gsub(newNote, "OS: %d+s %d+c", "")
                    newNote = string.gsub(newNote, "OS: %d+s", "")
                    newNote = string.gsub(newNote, "OS: %d+c", "")
                    
                    -- Clean up: remove ALL pipes and extra spaces
                    newNote = string.gsub(newNote, "|", "") -- Remove all pipes
                    newNote = string.gsub(newNote, "%s+", " ") -- Collapse multiple spaces
                    newNote = Hacienda:Trim(newNote) -- Trim whitespace
                    
                    -- Only update if the note has actually changed
                    if newNote ~= originalNote then
                        GuildRosterSetPublicNote(i, newNote)               
                    end
                end
                break
            end
        end
    end
end

-- New function to update all guild notes with current debt information
function Hacienda:UpdateAllGuildNotes()
    -- Only proceed if we're in a guild and have permission to edit notes
    if not IsInGuild() or not CanEditPublicNote() then
        return
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Updating all guild notes with current debt information...")
    
    -- Get unique mains from pending totals
    local mains = {}
    for player, _ in pairs(Hacienda.pendingTotals) do
        mains[self:GetMainChar(player)] = true
    end
    
    -- Update notes for each unique group
    for main, _ in pairs(mains) do
        local groupTotal = self:GetGroupPending(main)
        if groupTotal > 0 then
            self:UpdateGuildNoteWithDebt(main)
        else
            self:RemoveDebtFromGuildNote(main)
        end
    end
end

function Hacienda:explode(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from-1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    table.insert(result, string.sub(str, from))
    return result
end

function Hacienda:ProcessMoneyLog(logData)
    -- First, clear existing guild bank transactions from saved variables
    if not HaciendaSavedData.conversations[GUILD_BANK_CONTACT] then
        HaciendaSavedData.conversations[GUILD_BANK_CONTACT] = {}
    else
        -- Keep only non-system messages (if any exist)
        local cleanedMessages = {}
        for _, msg in ipairs(HaciendaSavedData.conversations[GUILD_BANK_CONTACT]) do
            if not msg.system then
                table.insert(cleanedMessages, msg)
            end
        end
        HaciendaSavedData.conversations[GUILD_BANK_CONTACT] = cleanedMessages
    end

    -- Now process new transactions
    local transactions = self:explode(logData, "=")
    local addedCount = 0
    
    for _, transaction in ipairs(transactions) do
        if transaction and transaction ~= "" and transaction ~= "end" then
            local logParts = self:explode(transaction, ";")
            if table.getn(logParts) >= 4 then
                local timestamp = tonumber(logParts[1])
                local player = logParts[2]
                local action = tonumber(logParts[3])
                local amount = tonumber(logParts[4])
                
                if action == ACTION_DEPOSIT_MONEY then
                    -- Only process if not a duplicate
                    if not self:IsDuplicateTransaction(timestamp, player, "deposito", amount) then
                        self:ProcessBankTransaction(transaction)
                        addedCount = addedCount + 1
                    end
                end
            end
        end
    end
    
    if addedCount > 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Loaded "..addedCount.." new guild bank transactions.")
    end
end

function Hacienda:GetContactFrame()
    if table.getn(Hacienda.contactFramePool) > 0 then
        local frame = table.remove(Hacienda.contactFramePool)
        frame:Show()
        return frame
    else
        local scaleFactor = 1.10
        local frame = CreateFrame("Button", nil, Hacienda.contactList)
        frame:SetWidth(105 * scaleFactor)  -- Original: 105
        frame:SetHeight(16 * scaleFactor)  -- Original: 16
        frame:EnableMouse(true)
        
        local statusIcon = frame:CreateFontString(nil, "ARTWORK")
        statusIcon:SetFont("Fonts\\FRIZQT__.TTF", 16 * scaleFactor)  -- Slightly larger font
        statusIcon:SetPoint("LEFT", frame, "LEFT", -5 * scaleFactor, -2 * scaleFactor)  -- Adjusted position
        frame.statusIcon = statusIcon
        
        local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", statusIcon, "RIGHT", 3 * scaleFactor, 1 * scaleFactor)  -- Adjusted position
        frame.text = text
        
        return frame
    end
end

function Hacienda:ReturnContactFrame(frame)
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetScript("OnMouseDown", nil)
    frame:SetScript("OnEnter", nil)
    frame:SetScript("OnLeave", nil)
    frame.contactName = nil
    frame.statusIcon:SetText("")
    frame.statusIcon:SetTextColor(1, 1, 1)
    table.insert(Hacienda.contactFramePool, frame)
end

function Hacienda:ClearActiveContactFrames()
    for i = 1, table.getn(Hacienda.activeContactFrames) do
        Hacienda:ReturnContactFrame(Hacienda.activeContactFrames[i])
    end
    Hacienda.activeContactFrames = {}
end

function Hacienda:AddMessage(contact, message, isOutgoing, moneyAmount)
    if not Hacienda.conversations then return end

    if not Hacienda.conversations[contact] then
        Hacienda.conversations[contact] = {}
    end

    local entry = {
        message = message,
        time = time(),
        outgoing = isOutgoing,
        moneyAmount = moneyAmount  -- Store the extracted money pattern
    }

    table.insert(Hacienda.conversations[contact], entry)

    if not isOutgoing then
        if (not Hacienda.frame or not Hacienda.frame:IsVisible()) or (Hacienda.selectedContact ~= contact) then
            if not Hacienda.unreadCounts[contact] then
                Hacienda.unreadCounts[contact] = 0
            end
            Hacienda.unreadCounts[contact] = Hacienda.unreadCounts[contact] + 1
        end
    end

    if Hacienda.frame and Hacienda.frame:IsVisible() then
        Hacienda:UpdateContactList()
        
        if Hacienda.selectedContact == contact then
            Hacienda:UpdateChatHistory()
        end
    end
end

function Hacienda:AddSystemMessage(contact, message, isTransient, timestamp)
    local targetTableContainer
    if isTransient then
        targetTableContainer = self.transientMessages
    else
        targetTableContainer = self.conversations
    end

    if not targetTableContainer[contact] then
        targetTableContainer[contact] = {}
    end

    local entry = {
        message = message,
        time = timestamp or time(),  -- Use provided timestamp or current time
        system = true
    }

    table.insert(targetTableContainer[contact], entry)

    if self.frame and self.frame:IsVisible() and self.selectedContact == contact then
        self:UpdateChatHistory()
    end
end

function Hacienda:CreateFrame()
    if Hacienda.frame then return end
    local scaleFactor = 1.10
    Hacienda.scaleFactor = scaleFactor

    -- Main Frame
    local frame = CreateFrame("Frame", "HaciendaFrame", UIParent)
    frame:SetWidth(590 * Hacienda.scaleFactor)
    frame:SetHeight(450 * Hacienda.scaleFactor)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("MEDIUM")
    frame:SetToplevel(true)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.7)
    frame:SetBackdropBorderColor(0.6, 0.6, 0.6)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function() frame:StartMoving(); frame:SetFrameStrata("HIGH") end)
    frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    frame:Show() -- Ensure main frame is visible
    Hacienda.frame = frame

    -- Initialize tables if they don't exist
    if not Hacienda.pending then Hacienda.pending = {} end
    if not Hacienda.conversations then Hacienda.conversations = {} end
    if not Hacienda.paidConversations then Hacienda.paidConversations = {} end

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -10 * Hacienda.scaleFactor)
    title:SetText("Hacienda Conquistadores")

    -- Close
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5 * Hacienda.scaleFactor, -5 * Hacienda.scaleFactor)
    closeButton:SetScript("OnClick", function() Hacienda:HideFrame() end)

    -- Total Debt
    Hacienda.totalDebtText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Hacienda.totalDebtText:SetPoint("TOP", frame, "TOP", 0, -30 * Hacienda.scaleFactor)
    Hacienda.totalDebtText:SetText("Deuda Total: 0g 0s 0c")
    Hacienda.totalDebtText:SetTextColor(1, 0.5, 0.5)

    -- Contact Frame
    local contactFrame = CreateFrame("Frame", nil, frame)
    contactFrame:SetWidth(170 * Hacienda.scaleFactor)
    contactFrame:SetHeight(250 * Hacienda.scaleFactor)
    contactFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 * Hacienda.scaleFactor, -70 * Hacienda.scaleFactor)
    contactFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    contactFrame:SetBackdropColor(0, 0, 0, 0.7)
    contactFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)

    local contactTitle = contactFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contactTitle:SetPoint("TOP", contactFrame, "TOP", 0, -5 * Hacienda.scaleFactor)
    contactTitle:SetText("Deudores")

    local contactScroll = CreateFrame("ScrollFrame", "HaciendaContactScroll", contactFrame)
    contactScroll:SetPoint("TOPLEFT", contactFrame, "TOPLEFT", 5 * Hacienda.scaleFactor, -20 * Hacienda.scaleFactor)
    contactScroll:SetPoint("BOTTOMRIGHT", contactFrame, "BOTTOMRIGHT", -5 * Hacienda.scaleFactor, 5 * Hacienda.scaleFactor)

    local contactContent = CreateFrame("Frame", nil, contactScroll)
    contactContent:SetWidth(130 * Hacienda.scaleFactor)
    contactContent:SetHeight(1)
    contactScroll:SetScrollChild(contactContent)
    Hacienda.contactList = contactContent

    -- Chat Frame
    local chatFrame = CreateFrame("Frame", nil, frame)
    chatFrame:SetWidth(390 * Hacienda.scaleFactor)
    chatFrame:SetHeight(250 * Hacienda.scaleFactor)
    chatFrame:SetPoint("TOPLEFT", contactFrame, "TOPRIGHT", 10 * Hacienda.scaleFactor, 0)
    chatFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    chatFrame:SetBackdropColor(0, 0, 0, 0.7)
    chatFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)

    Hacienda.chatTitle = chatFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Hacienda.chatTitle:SetPoint("TOP", chatFrame, "TOP", 0, -5 * Hacienda.scaleFactor)
    Hacienda.chatTitle:SetText("Historial de conversaciones")

    Hacienda.chatHistory = CreateFrame("ScrollingMessageFrame", "HaciendaChatHistory", chatFrame)
    Hacienda.chatHistory:SetPoint("TOPLEFT", chatFrame, "TOPLEFT", 5 * Hacienda.scaleFactor, -20 * Hacienda.scaleFactor)
    Hacienda.chatHistory:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMRIGHT", -5 * Hacienda.scaleFactor, 40 * Hacienda.scaleFactor)
    Hacienda.chatHistory:SetFontObject(GameFontNormal)
    Hacienda.chatHistory:SetJustifyH("LEFT")
    Hacienda.chatHistory:SetMaxLines(100)
    Hacienda.chatHistory:SetFading(false)

    -- Data Sync Panel
    local syncFrame = CreateFrame("Frame", nil, frame)
    syncFrame:SetWidth(170 * Hacienda.scaleFactor)
    syncFrame:SetHeight(110 * Hacienda.scaleFactor)
    syncFrame:SetPoint("TOPLEFT", contactFrame, "BOTTOMLEFT", 0, -10 * Hacienda.scaleFactor)
    syncFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    syncFrame:SetBackdropColor(0, 0, 0, 0.7)
    syncFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)

    local syncTitle = syncFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    syncTitle:SetPoint("TOP", syncFrame, "TOP", 0, -10 * Hacienda.scaleFactor)
    syncTitle:SetText("Data Sync")

    local importButton = CreateFrame("Button", nil, syncFrame, "UIPanelButtonTemplate")
    importButton:SetWidth(100 * Hacienda.scaleFactor)
    importButton:SetHeight(20 * Hacienda.scaleFactor)
    importButton:SetPoint("TOP", syncTitle, "BOTTOM", 0, -15 * Hacienda.scaleFactor)
    importButton:SetText("Import")
    importButton:SetScript("OnClick", function() Hacienda:ShowImportExportFrame("import") end)

    local exportButton = CreateFrame("Button", nil, syncFrame, "UIPanelButtonTemplate")
    exportButton:SetWidth(100 * Hacienda.scaleFactor)
    exportButton:SetHeight(20 * Hacienda.scaleFactor)
    exportButton:SetPoint("TOP", importButton, "BOTTOM", 0, -12 * Hacienda.scaleFactor)
    exportButton:SetText("Export")
    exportButton:SetScript("OnClick", function() Hacienda:ShowImportExportFrame("export") end)

    -- Debt Entry Frame (Deuda Manual)
    local debtEntryFrame = CreateFrame("Frame", nil, frame)
    debtEntryFrame:SetWidth(390 * Hacienda.scaleFactor)
    debtEntryFrame:SetHeight(110 * Hacienda.scaleFactor)
    debtEntryFrame:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT", 0, -10 * Hacienda.scaleFactor)
    debtEntryFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    debtEntryFrame:SetBackdropColor(0, 0, 0, 0.7)
    debtEntryFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
    debtEntryFrame:Show() -- Ensure debtEntryFrame is visible

    local manualDebtTitle = debtEntryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    manualDebtTitle:SetPoint("TOPLEFT", debtEntryFrame, "TOPLEFT", 10 * Hacienda.scaleFactor, -10 * Hacienda.scaleFactor)
    manualDebtTitle:SetText("Deuda Manual")

    -- Player input
    local playerLabel = debtEntryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    playerLabel:SetPoint("TOPLEFT", debtEntryFrame, "TOPLEFT", 10 * Hacienda.scaleFactor, -35 * Hacienda.scaleFactor)
    playerLabel:SetText("Personaje:")

    local playerBox = CreateFrame("Frame", nil, debtEntryFrame)
    playerBox:SetWidth(120 * Hacienda.scaleFactor)
    playerBox:SetHeight(22 * Hacienda.scaleFactor)
    playerBox:SetPoint("LEFT", playerLabel, "RIGHT", 5 * Hacienda.scaleFactor, 0)
    playerBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    playerBox:SetBackdropColor(0, 0, 0, 0.75)
    playerBox:SetBackdropBorderColor(0.5, 0.5, 0.5)
    playerBox:Show()

    Hacienda.debtPlayerInput = CreateFrame("EditBox", nil, playerBox)
    Hacienda.debtPlayerInput:SetPoint("TOPLEFT", playerBox, "TOPLEFT", 5, -3)
    Hacienda.debtPlayerInput:SetPoint("BOTTOMRIGHT", playerBox, "BOTTOMRIGHT", -5, 3)
    Hacienda.debtPlayerInput:SetAutoFocus(false)
    Hacienda.debtPlayerInput:SetFontObject("GameFontNormalSmall")
    Hacienda.debtPlayerInput:SetTextInsets(0, 0, 0, 0)
    Hacienda.debtPlayerInput:Show()

    -- Amount input
    local amountLabel = debtEntryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    amountLabel:SetPoint("LEFT", playerBox, "RIGHT", 15 * Hacienda.scaleFactor, 0)
    amountLabel:SetText("Cantidad:")

    local amountBox = CreateFrame("Frame", nil, debtEntryFrame)
    amountBox:SetWidth(120 * Hacienda.scaleFactor)
    amountBox:SetHeight(22 * Hacienda.scaleFactor)
    amountBox:SetPoint("LEFT", amountLabel, "RIGHT", 5 * Hacienda.scaleFactor, 0)
    amountBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    amountBox:SetBackdropColor(0, 0, 0, 0.75)
    amountBox:SetBackdropBorderColor(0.5, 0.5, 0.5)
    amountBox:Show()

    Hacienda.debtAmountInput = CreateFrame("EditBox", nil, amountBox)
    Hacienda.debtAmountInput:SetPoint("TOPLEFT", amountBox, "TOPLEFT", 5, -3)
    Hacienda.debtAmountInput:SetPoint("BOTTOMRIGHT", amountBox, "BOTTOMRIGHT", -5, 3)
    Hacienda.debtAmountInput:SetAutoFocus(false)
    Hacienda.debtAmountInput:SetFontObject("GameFontNormalSmall")
    Hacienda.debtAmountInput:SetTextInsets(0, 0, 0, 0)
    Hacienda.debtAmountInput:Show()

    -- Link Characters UI
    local linkTitle = debtEntryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    linkTitle:SetPoint("TOPLEFT", debtEntryFrame, "TOPLEFT", 10 * Hacienda.scaleFactor, -60 * Hacienda.scaleFactor)
    linkTitle:SetText("Link Characters")
    linkTitle:Show()

    local mainLabel = debtEntryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mainLabel:SetPoint("TOPLEFT", debtEntryFrame, "TOPLEFT", 10 * Hacienda.scaleFactor, -85 * Hacienda.scaleFactor)
    mainLabel:SetText("Main Char:")
    mainLabel:Show()

    local mainBox = CreateFrame("Frame", nil, debtEntryFrame)
    mainBox:SetWidth(120 * Hacienda.scaleFactor)
    mainBox:SetHeight(22 * Hacienda.scaleFactor)
    mainBox:SetPoint("LEFT", mainLabel, "RIGHT", 5 * Hacienda.scaleFactor, 0)
    mainBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    mainBox:SetBackdropColor(0, 0, 0, 0.75)
    mainBox:SetBackdropBorderColor(0.5, 0.5, 0.5)
    mainBox:Show()

    Hacienda.linkMainInput = CreateFrame("EditBox", nil, mainBox)
    Hacienda.linkMainInput:SetPoint("TOPLEFT", mainBox, "TOPLEFT", 5, -3)
    Hacienda.linkMainInput:SetPoint("BOTTOMRIGHT", mainBox, "BOTTOMRIGHT", -5, 3)
    Hacienda.linkMainInput:SetAutoFocus(false)
    Hacienda.linkMainInput:SetFontObject("GameFontNormalSmall")
    Hacienda.linkMainInput:SetTextInsets(0, 0, 0, 0)
    Hacienda.linkMainInput:Show()

    local altLabel = debtEntryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    altLabel:SetPoint("LEFT", mainBox, "RIGHT", 15 * Hacienda.scaleFactor, 0)
    altLabel:SetText("Alt Char:")
    altLabel:Show()

    local altBox = CreateFrame("Frame", nil, debtEntryFrame)
    altBox:SetWidth(120 * Hacienda.scaleFactor)
    altBox:SetHeight(22 * Hacienda.scaleFactor)
    altBox:SetPoint("LEFT", altLabel, "RIGHT", 5 * Hacienda.scaleFactor, 0)
    altBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    altBox:SetBackdropColor(0, 0, 0, 0.75)
    altBox:SetBackdropBorderColor(0.5, 0.5, 0.5)
    altBox:Show()

    Hacienda.linkAltInput = CreateFrame("EditBox", nil, altBox)
    Hacienda.linkAltInput:SetPoint("TOPLEFT", altBox, "TOPLEFT", 5, -3)
    Hacienda.linkAltInput:SetPoint("BOTTOMRIGHT", altBox, "BOTTOMRIGHT", -5, 3)
    Hacienda.linkAltInput:SetAutoFocus(false)
    Hacienda.linkAltInput:SetFontObject("GameFontNormalSmall")
    Hacienda.linkAltInput:SetTextInsets(0, 0, 0, 0)
    Hacienda.linkAltInput:Show()

    -- Focus + ESC/Enter/Tab behavior
    local function focusFX(edit, box, onEnter, nextField)
        if not edit or not box then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Error: edit or box is nil in focusFX")
            return
        end
        edit:SetScript("OnEditFocusGained", function()
            box:SetBackdropBorderColor(1, 0.82, 0)
        end)
        edit:SetScript("OnEditFocusLost", function()
            box:SetBackdropBorderColor(0.5, 0.5, 0.5)
        end)
        edit:SetScript("OnEscapePressed", function()
            edit:ClearFocus()
            edit:SetText("")
        end)
        if onEnter then
            edit:SetScript("OnEnterPressed", onEnter)
        end
        if nextField then
            edit:SetScript("OnTabPressed", function()
                nextField:SetFocus()
            end)
        end
    end

    -- Debug checks for EditBox creation
    if not Hacienda.debtPlayerInput then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Error: debtPlayerInput is nil after creation")
    end
    if not Hacienda.debtAmountInput then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Error: debtAmountInput is nil after creation")
    end
    if not Hacienda.linkMainInput then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Error: linkMainInput is nil after creation")
    end
    if not Hacienda.linkAltInput then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Error: linkAltInput is nil after creation")
    end

    -- Apply focusFX calls
    focusFX(Hacienda.debtPlayerInput, playerBox, nil, Hacienda.debtAmountInput)
    focusFX(Hacienda.debtAmountInput, amountBox, function()
        Hacienda:AddManualDebtEntry()
        Hacienda.debtPlayerInput:SetText("")
        Hacienda.debtAmountInput:SetText("")
        Hacienda.debtPlayerInput:ClearFocus()
        Hacienda.debtAmountInput:ClearFocus()
    end, Hacienda.linkMainInput)
    focusFX(Hacienda.linkMainInput, mainBox, function()
        Hacienda:LinkCharacters(Hacienda.linkMainInput:GetText(), Hacienda.linkAltInput:GetText())
        Hacienda.linkMainInput:SetText("")
        Hacienda.linkAltInput:SetText("")
        Hacienda.linkMainInput:ClearFocus()
        Hacienda.linkAltInput:ClearFocus()
    end, Hacienda.linkAltInput)
    focusFX(Hacienda.linkAltInput, altBox, function()
        Hacienda:LinkCharacters(Hacienda.linkMainInput:GetText(), Hacienda.linkAltInput:GetText())
        Hacienda.linkMainInput:SetText("")
        Hacienda.linkAltInput:SetText("")
        Hacienda.linkMainInput:ClearFocus()
        Hacienda.linkAltInput:ClearFocus()
    end, Hacienda.debtPlayerInput)

    -- Debug frame visibility
    if not debtEntryFrame:IsVisible() then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Debug: debtEntryFrame is not visible")
    end
end

function Hacienda:CreateMinimapButton()
    if self.minimapButton then return end
    
    local minimapButton = CreateFrame("Button", "HaciendaMinimapButton", Minimap)
    minimapButton:SetHeight(32)
    minimapButton:SetWidth(32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    minimapButton:SetMovable(true)

    minimapButton.texture = minimapButton:CreateTexture(nil, "BACKGROUND")
    minimapButton.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Chat-Up")
    minimapButton.texture:SetHeight(20)
    minimapButton.texture:SetWidth(20)
    minimapButton.texture:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)

    minimapButton.border = minimapButton:CreateTexture(nil, "OVERLAY")
    minimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    minimapButton.border:SetHeight(54)
    minimapButton.border:SetWidth(54)
    minimapButton.border:SetPoint("TOPLEFT", minimapButton, "TOPLEFT", 0, 0)

    minimapButton.highlight = minimapButton:CreateTexture(nil, "HIGHLIGHT")
    minimapButton.highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    minimapButton.highlight:SetBlendMode("ADD")
    minimapButton.highlight:SetHeight(32)
    minimapButton.highlight:SetWidth(32)
    minimapButton.highlight:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)

    -- right-click menu
    local menu = CreateFrame("Frame", "HaciendaMinimapMenu", UIParent)
    menu:SetWidth(150)
    menu:SetHeight(1) -- will resize dynamically
    menu:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    menu:SetBackdropColor(0, 0, 0, 0.9)

    menu:SetFrameStrata("TOOLTIP")   -- always above UI
    menu:SetFrameLevel(999)
    menu:Hide()

    local menuButtons = {}
    local function AddMenuButton(text, order, onClick)
        local btn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
        btn:SetText(text)
        btn:SetWidth(120)
        btn:SetHeight(22)
        btn:SetPoint("TOP", menu, "TOP", 0, -10 - (order-1)*25)
        btn:SetScript("OnClick", function()
            onClick()
            menu:Hide()
        end)
        table.insert(menuButtons, btn)
        menu:SetHeight(table.getn(menuButtons) * 25 + 20)
    end

    -- menu entries
    AddMenuButton("Open Hacienda", 1, function() Hacienda:ToggleFrame() end)
    AddMenuButton("Export Data", 2, function() Hacienda:ShowImportExportFrame("export") end)
    AddMenuButton("Import Data", 3, function() Hacienda:ShowImportExportFrame("import") end)
    AddMenuButton("Update Notes", 4, function() Hacienda:UpdateAllGuildNotes() end)
    AddMenuButton("Linked Characters", 5, function() Hacienda:ShowLinkedCharactersFrame()
        if HaciendaLinksFrame then
            if HaciendaLinksFrame:IsShown() then
                HaciendaLinksFrame:Hide()
            else
                HaciendaLinksFrame:Show()
            end
        end
    end)

    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            Hacienda:ToggleFrame()
        elseif arg1 == "RightButton" then
            if menu:IsShown() then
                menu:Hide()
            else
                -- smart anchor
                local x, y = minimapButton:GetCenter()
                local uiWidth, uiHeight = UIParent:GetWidth(), UIParent:GetHeight()
                menu:ClearAllPoints()

                if y > uiHeight/2 then
                    -- top half → menu goes down
                    if x < uiWidth/2 then
                        menu:SetPoint("TOPLEFT", minimapButton, "BOTTOMLEFT", 0, -2)
                    else
                        menu:SetPoint("TOPRIGHT", minimapButton, "BOTTOMRIGHT", 0, -2)
                    end
                else
                    -- bottom half → menu goes up
                    if x < uiWidth/2 then
                        menu:SetPoint("BOTTOMLEFT", minimapButton, "TOPLEFT", 0, 2)
                    else
                        menu:SetPoint("BOTTOMRIGHT", minimapButton, "TOPRIGHT", 0, 2)
                    end
                end
                menu:Show()
            end
        end
    end)

    minimapButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(minimapButton, "ANCHOR_LEFT")
        GameTooltip:SetText("Hacienda", 1, 1, 1)
        GameTooltip:AddLine("Left-click to open Hacienda", nil, nil, nil, 1)
        GameTooltip:AddLine("Right-click for options", nil, nil, nil, 1)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    minimapButton:EnableMouse(true)
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetScript("OnDragStart", function() this:StartMoving() end)
    minimapButton:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

    self.minimapButton = minimapButton
    self.minimapMenu = menu
end

-- New function for manual debt entry
function Hacienda:AddManualDebtEntry()
    local playerName = Hacienda:Trim(Hacienda.debtPlayerInput:GetText())
    local amountText = Hacienda:Trim(Hacienda.debtAmountInput:GetText())

    if playerName == "" or amountText == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Please enter both player name and amount.")
        return
    end

    -- Validate amountText is a string
    if type(amountText) ~= "string" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Invalid amount format.")
        return
    end

    -- Parse amount (supports formats like "10g 5s 2c", "10g", "5s", etc.)
    local totalCopper = 0
    local gold = tonumber(string.match(amountText, "(%d+)g")) or 0
    local silver = tonumber(string.match(amountText, "(%d+)s")) or 0
    local copper = tonumber(string.match(amountText, "(%d+)c")) or 0
    totalCopper = (gold * COPPER_PER_SILVER * SILVER_PER_GOLD) + (silver * COPPER_PER_SILVER) + copper

    if totalCopper <= 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Invalid amount entered. Please use format like '10g 5s 2c'.")
        return
    end

    -- Ensure conversation exists
    if not Hacienda.conversations[playerName] then
        Hacienda.conversations[playerName] = {}
    end

    -- Create message
    local messageText = string.format("Manual debt entry: %dg %ds %dc", gold, silver, copper)
    
    -- Add the message
    local entry = {
        message = messageText,
        time = time(),
        outgoing = true,
        moneyAmount = totalCopper,
        paidAmount = 0,
        paymentTime = nil
    }
    table.insert(Hacienda.conversations[playerName], entry)

    -- Update pending total
    Hacienda.pendingTotals[playerName] = (Hacienda.pendingTotals[playerName] or 0) + totalCopper

    -- Update guild note
    Hacienda:UpdateGuildNoteWithDebt(playerName)

    -- Clear inputs
    Hacienda.debtPlayerInput:SetText("")
    Hacienda.debtAmountInput:SetText("")

    -- Update UI
    if Hacienda.frame and Hacienda.frame:IsVisible() then
        Hacienda:UpdateContactList()
        if Hacienda.selectedContact == playerName then
            Hacienda:UpdateChatHistory()
        end
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Added manual debt of " .. messageText .. " for " .. playerName)
end

function Hacienda:UpdateTotalDebtDisplay()
    if not Hacienda.totalDebtText then return end
    
    local totalDebt = 0
    if Hacienda.pendingTotals then
        for _, amount in pairs(Hacienda.pendingTotals) do
            totalDebt = totalDebt + (amount or 0)
        end
    end
    
    local gold = floor(totalDebt / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local silver = floor((totalDebt - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
    local copper = mod(totalDebt, COPPER_PER_SILVER)
    
    local debtText = "Deuda Total: "
    if gold > 0 then debtText = debtText .. gold .. "g " end
    if silver > 0 then debtText = debtText .. silver .. "s " end
    if copper > 0 then debtText = debtText .. copper .. "c" end
    if totalDebt == 0 then debtText = debtText .. "0g 0s 0c" end
    
    Hacienda.totalDebtText:SetText(debtText)
end

function Hacienda:UpdateContactList()
    if not Hacienda.contactList then return end
    Hacienda:ClearActiveContactFrames()
    local yOffset = 0

    -- Always show Banco de la Guild first
    local guildBankFrame = Hacienda:GetContactFrame()
    guildBankFrame:SetPoint("TOPLEFT", Hacienda.contactList, "TOPLEFT", 5, yOffset)
    guildBankFrame.text:SetText(GUILD_BANK_CONTACT)
    guildBankFrame.statusIcon:SetText("•")
    guildBankFrame.statusIcon:SetTextColor(0, 1, 0) -- Green for Banco de la Guild
    guildBankFrame.text:SetTextColor(1, 1, 1)
    guildBankFrame.contactName = GUILD_BANK_CONTACT
    guildBankFrame:SetScript("OnMouseDown", function() Hacienda:SelectContact(GUILD_BANK_CONTACT) end)
    guildBankFrame:SetScript("OnEnter", function() this.text:SetTextColor(1, 0.82, 0) end)
    guildBankFrame:SetScript("OnLeave", function() this.text:SetTextColor(1, 1, 1) end)
    table.insert(Hacienda.activeContactFrames, guildBankFrame)
    yOffset = yOffset - 18

    -- Show OS Pagadas category
    local paidOSFrame = Hacienda:GetContactFrame()
    paidOSFrame:SetPoint("TOPLEFT", Hacienda.contactList, "TOPLEFT", 5, yOffset)
    paidOSFrame.text:SetText(PAID_OS_CONTACT)
    paidOSFrame.statusIcon:SetText("•")
    paidOSFrame.statusIcon:SetTextColor(1, 1, 0) -- Yellow for OS Pagadas
    paidOSFrame.text:SetTextColor(1, 1, 1)
    paidOSFrame.contactName = PAID_OS_CONTACT
    paidOSFrame:SetScript("OnMouseDown", function() Hacienda:SelectContact(PAID_OS_CONTACT) end)
    paidOSFrame:SetScript("OnEnter", function() this.text:SetTextColor(1, 0.82, 0) end)
    paidOSFrame:SetScript("OnLeave", function() this.text:SetTextColor(1, 1, 1) end)
    table.insert(Hacienda.activeContactFrames, paidOSFrame)
    yOffset = yOffset - 18

    -- Sort contacts by group total descending
    local sortedContacts = {}
    local processedMains = {}
    for contact, _ in pairs(Hacienda.pendingTotals) do
        local main = self:GetMainChar(contact)
        if not processedMains[main] then
            processedMains[main] = true
            table.insert(sortedContacts, {main = main, total = self:GetGroupPending(main)})
        end
    end
    table.sort(sortedContacts, function(a, b) return a.total > b.total end)

    -- Display sorted contacts
    for _, entry in ipairs(sortedContacts) do
        local main = entry.main
        local groupTotal = entry.total
        local members = self:GetGroupMembers(main)
        local displayName = main
        local memberString = ""
        if table.getn(members) > 1 then
            table.sort(members)
            memberString = table.concat(members, ", ")
            displayName = main .. " (" .. (table.getn(members) - 1) .. " alts)"
        end

        local gold = floor(groupTotal / (COPPER_PER_SILVER * SILVER_PER_GOLD))
        local silver = floor((groupTotal - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
        local copper = mod(groupTotal, COPPER_PER_SILVER)
        local amountText = ""
        if gold > 0 then amountText = amountText .. gold .. "g " end
        if silver > 0 then amountText = amountText .. silver .. "s " end
        if copper > 0 then amountText = amountText .. copper .. "c" end

        local contactFrame = Hacienda:GetContactFrame()
        contactFrame:SetPoint("TOPLEFT", Hacienda.contactList, "TOPLEFT", 5, yOffset)
        contactFrame.text:SetText(displayName .. " - " .. amountText)
        contactFrame.statusIcon:SetText("•")
        contactFrame.statusIcon:SetTextColor(1, 0, 0) -- Red for debtors
        contactFrame.text:SetTextColor(1, 1, 1)
        contactFrame.contactName = main
        contactFrame:SetScript("OnMouseDown", function() Hacienda:SelectContact(main) end)
        contactFrame:SetScript("OnEnter", function()
            this.text:SetTextColor(1, 0.82, 0)
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText(displayName)
            GameTooltip:AddLine("Pending OS: " .. amountText, 1, 0, 0)
            if memberString ~= "" then
                GameTooltip:AddLine("Group Members: " .. memberString, 1, 1, 1)
            end
            
            -- List individual OS records
            GameTooltip:AddLine("\nOS Records:")
            local hasRecords = false
            for _, member in ipairs(members) do
                if Hacienda.conversations[member] then
                    for _, msg in ipairs(Hacienda.conversations[member]) do
                        if msg.outgoing and msg.moneyAmount then
                            local remaining = msg.moneyAmount - (msg.paidAmount or 0)
                            if remaining > 0 then
                                hasRecords = true
                                local remGold = floor(remaining / (COPPER_PER_SILVER * SILVER_PER_GOLD))
                                local remSilver = floor((remaining - (remGold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
                                local remCopper = mod(remaining, COPPER_PER_SILVER)
                                local remText = ""
                                if remGold > 0 then remText = remText .. remGold .. "g " end
                                if remSilver > 0 then remText = remText .. remSilver .. "s " end
                                if remCopper > 0 then remText = remText .. remCopper .. "c" end
                                
                                local paidText = ""
                                if msg.paidAmount and msg.paidAmount > 0 then
                                    local paidGold = floor(msg.paidAmount / (COPPER_PER_SILVER * SILVER_PER_GOLD))
                                    local paidSilver = floor((msg.paidAmount - (paidGold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
                                    local paidCopper = mod(msg.paidAmount, COPPER_PER_SILVER)
                                    
                                    paidText = " (Paid: "
                                    if paidGold > 0 then paidText = paidText .. paidGold .. "g " end
                                    if paidSilver > 0 then paidText = paidText .. paidSilver .. "s " end
                                    if paidCopper > 0 then paidText = paidText .. paidCopper .. "c" end
                                    paidText = paidText .. ")"
                                end
                                
                                GameTooltip:AddLine("  " .. remText .. paidText, 1, 1, 1)
                            end
                        end
                    end
                end
            end
            if not hasRecords then
                GameTooltip:AddLine("  No OS records found", 1, 0.5, 0.5)
            end
            
            -- Add total line
            local totalText = "Group Total: " .. amountText
            GameTooltip:AddLine("\n" .. totalText, 0, 1, 0)
            GameTooltip:Show()
        end)
        contactFrame:SetScript("OnLeave", function() 
            this.text:SetTextColor(1, 1, 1)
            GameTooltip:Hide()
        end)
        -- Add right-click functionality (deletes conversation and debt)
        contactFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        contactFrame:SetScript("OnClick", function()
            if arg1 == "RightButton" then
                Hacienda:DeleteConversation(this.contactName)
            elseif arg1 == "LeftButton" and IsShiftKeyDown() then
                Hacienda:WhisperDebtReminder(this.contactName)
            end
        end)
        table.insert(Hacienda.activeContactFrames, contactFrame)
        yOffset = yOffset - 18
    end
    
    Hacienda.contactList:SetHeight(math.abs(yOffset) + 20)
    
    -- Update scroll frame
    if HaciendaContactScroll then
        HaciendaContactScroll:UpdateScrollChildRect()
        HaciendaContactScroll:SetVerticalScroll(0) -- Scroll to top
    end
    
    -- Update total debt display
    Hacienda:UpdateTotalDebtDisplay()
end

-- New function to whisper debt reminder to player
function Hacienda:WhisperDebtReminder(playerName)
    if not playerName or playerName == GUILD_BANK_CONTACT or playerName == PAID_OS_CONTACT then
        return
    end
    
    local groupTotal = Hacienda:GetGroupPending(playerName)
    
    if groupTotal <= 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r " .. playerName .. " has no pending OS.")
        return
    end
    
    -- Convert copper to gold/silver/copper
    local gold = floor(groupTotal / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local silver = floor((groupTotal - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
    local copper = mod(groupTotal, COPPER_PER_SILVER)
    
    -- Format the message
    local amountText = ""
    if gold > 0 then amountText = amountText .. gold .. "g " end
    if silver > 0 then amountText = amountText .. silver .. "s " end
    if copper > 0 then amountText = amountText .. copper .. "c" end
    
    local message = string.format("Recordatorio: Tienes %s de OS pendiente por pagar a la hermandad. Por favor deposita en el banco de la hermandad cuando te sea conveniente. ¡Gracias!", amountText)
    
    -- Set the chat box to whisper mode and populate it
    if ChatFrame1EditBox then
        ChatFrame1EditBox:SetAttribute("chatType", "WHISPER")
        ChatFrame1EditBox:SetAttribute("tellTarget", playerName)
        ChatFrame1EditBox:SetText(message)
        ChatFrame1EditBox:Show()
        ChatFrame1EditBox:SetFocus()
    else
        -- Fallback: use SendChatMessage if edit box isn't available
        SendChatMessage(message, "WHISPER", nil, playerName)
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Whispering debt reminder to " .. playerName .. ".")
end

function Hacienda:ShowDeleteConfirmation(contactName)
    -- Create confirmation dialog
    if not Hacienda.deleteConfirmation then
        Hacienda.deleteConfirmation = CreateFrame("Frame", "HaciendaDeleteConfirmation", UIParent)
        Hacienda.deleteConfirmation:SetWidth(300)
        Hacienda.deleteConfirmation:SetHeight(120)
        Hacienda.deleteConfirmation:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        Hacienda.deleteConfirmation:SetFrameStrata("DIALOG")
        Hacienda.deleteConfirmation:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = {left = 11, right = 12, top = 12, bottom = 11}
        })
        Hacienda.deleteConfirmation:SetBackdropColor(0, 0, 0, 0.8)
        Hacienda.deleteConfirmation:Hide()
        
        -- Title
        Hacienda.deleteConfirmation.title = Hacienda.deleteConfirmation:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Hacienda.deleteConfirmation.title:SetPoint("TOP", Hacienda.deleteConfirmation, "TOP", 0, -15)
        Hacienda.deleteConfirmation.title:SetText("Delete Conversation")
        
        -- Message
        Hacienda.deleteConfirmation.message = Hacienda.deleteConfirmation:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        Hacienda.deleteConfirmation.message:SetPoint("TOP", Hacienda.deleteConfirmation.title, "BOTTOM", 0, -15)
        Hacienda.deleteConfirmation.message:SetWidth(280)
        Hacienda.deleteConfirmation.message:SetJustifyH("CENTER")
        
        -- Yes button
        Hacienda.deleteConfirmation.yesButton = CreateFrame("Button", nil, Hacienda.deleteConfirmation, "UIPanelButtonTemplate")
        Hacienda.deleteConfirmation.yesButton:SetWidth(80)
        Hacienda.deleteConfirmation.yesButton:SetHeight(22)
        Hacienda.deleteConfirmation.yesButton:SetPoint("BOTTOM", Hacienda.deleteConfirmation, "BOTTOM", -50, 15)
        Hacienda.deleteConfirmation.yesButton:SetText("Yes")
        Hacienda.deleteConfirmation.yesButton:SetScript("OnClick", function()
            if Hacienda.deleteConfirmation.contactName then
                Hacienda:DeleteConversation(Hacienda.deleteConfirmation.contactName)
            end
            this:GetParent():Hide()
        end)
        
        -- No button
        Hacienda.deleteConfirmation.noButton = CreateFrame("Button", nil, Hacienda.deleteConfirmation, "UIPanelButtonTemplate")
        Hacienda.deleteConfirmation.noButton:SetWidth(80)
        Hacienda.deleteConfirmation.noButton:SetHeight(22)
        Hacienda.deleteConfirmation.noButton:SetPoint("BOTTOM", Hacienda.deleteConfirmation, "BOTTOM", 50, 15)
        Hacienda.deleteConfirmation.noButton:SetText("No")
        Hacienda.deleteConfirmation.noButton:SetScript("OnClick", function()
            this:GetParent():Hide()
        end)
    end
    
    -- Set the contact name and message
    Hacienda.deleteConfirmation.contactName = contactName
    Hacienda.deleteConfirmation.message:SetText("Are you sure you want to delete the conversation with " .. contactName .. "?")
    
    -- Show the confirmation dialog
    Hacienda.deleteConfirmation:Show()
end

function Hacienda:DeleteConversation(contactName)
    if not contactName or contactName == GUILD_BANK_CONTACT or contactName == PAID_OS_CONTACT then
        return
    end
    
    -- Get group members and delete conversation-related data
    local members = Hacienda:GetGroupMembers(contactName)
    for _, member in ipairs(members) do
        -- Remove from conversations
        if Hacienda.conversations[member] then
            Hacienda.conversations[member] = nil
        end
        
        -- Remove from pending totals (force-clear debt)
        if Hacienda.pendingTotals[member] then
            Hacienda.pendingTotals[member] = nil
        end
        
        -- Remove from unread counts
        if Hacienda.unreadCounts[member] then
            Hacienda.unreadCounts[member] = nil
        end
        
        -- Remove from paid conversations
        if Hacienda.paidConversations[member] then
            Hacienda.paidConversations[member] = nil
        end
    end
    
    -- Remove debt information from guild notes
    Hacienda:RemoveDebtFromGuildNote(contactName)
    
    -- If this was the selected contact, clear the chat history
    if Hacienda.selectedContact == contactName then
        Hacienda.selectedContact = nil
        if Hacienda.chatHistory then
            Hacienda.chatHistory:Clear()
        end
        if Hacienda.chatTitle then
            Hacienda.chatTitle:SetText("Historial de conversaciones")
        end
    end
    
    -- Update the contact list and total debt
    Hacienda:UpdateContactList()
    Hacienda:UpdateTotalDebtDisplay()
    
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Conversation group with " .. contactName .. " deleted (debt cleared, links preserved).")
end

function Hacienda:SelectContact(contact)
    if not contact or (Hacienda.selectedContact == contact and Hacienda.frame and Hacienda.frame:IsVisible()) then return end
    Hacienda.selectedContact = contact
    Hacienda.chatTitle:SetText("" .. contact)
    if not Hacienda.conversations[contact] then Hacienda.conversations[contact] = {} end
    if Hacienda.unreadCounts then Hacienda.unreadCounts[contact] = 0 end
    Hacienda:UpdateContactList()
    Hacienda:UpdateChatHistory()
end

function Hacienda:GetCenteredString(text)
    if not self.tempFontString then return text end
    self.tempFontString:SetText(text)
    local textWidth = self.tempFontString:GetStringWidth()
    self.tempFontString:SetText(" ")
    local spaceWidth = self.tempFontString:GetStringWidth()
    local chatHistoryWidth = Hacienda.chatHistory:GetWidth()
    if textWidth >= chatHistoryWidth or spaceWidth <= 0 then return text end
    local paddingRequired = (chatHistoryWidth - textWidth) / 2
    local numSpaces = math.max(0, math.ceil(paddingRequired / spaceWidth) + 12)
    local padding = string.rep(" ", numSpaces)
    return padding .. text
end

function Hacienda:ColorizeCurrency(text)
    local goldColor = "|cFFFFFF00"  -- Yellow
    local silverColor = "|cFFC0C0C0" -- Light gray
    local copperColor = "|cFFEDA55F" -- Copper/brown
    
    text = string.gsub(text, "(%d+)g", goldColor.."%1g|r")
    text = string.gsub(text, "(%d+)s", silverColor.."%1s|r")
    text = string.gsub(text, "(%d+)c", copperColor.."%1c|r")
    return text
end

function Hacienda:ProcessBankTransaction(logLine)
    local logParts = self:explode(logLine, ";")
    local timestamp = tonumber(logParts[1]) or time()
    local player = logParts[2]
    local action = tonumber(logParts[3])
    local amountCopper = tonumber(logParts[4])

    -- Only process deposits
    if action == ACTION_DEPOSIT_MONEY then
        -- First check if this clears any pending OS
        self:CheckAndClearPendingOS(player, amountCopper, timestamp)

        -- Rest of the existing deposit processing code...
        local actionText = "deposita"
        local gold = floor(amountCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD))
        local silver = floor((amountCopper - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
        local copper = mod(amountCopper, COPPER_PER_SILVER)

        local amountText = ""
        if gold > 0 then amountText = amountText .. gold .. "g " end
        if silver > 0 then amountText = amountText .. silver .. "s " end
        if copper > 0 then amountText = amountText .. copper .. "c" end

        local fullMessage = string.format("%s %s %s en el banco de la guild", player, actionText, amountText)

        local entry = {
            message = fullMessage,
            time = timestamp,
            system = true,
            player = player,
            amountCopper = amountCopper
        }

        if not Hacienda.conversations[GUILD_BANK_CONTACT] then
            Hacienda.conversations[GUILD_BANK_CONTACT] = {}
        end
        table.insert(Hacienda.conversations[GUILD_BANK_CONTACT], entry)

        -- ✅ NEW: update this player’s guild note immediately after processing deposit
        Hacienda:UpdateGuildNoteWithDebt(player)
    end
end

function Hacienda:ShowFrame()
    if not self.frame then self:CreateFrame() end
    self:UpdateContactList()
    if self.selectedContact then self:UpdateChatHistory() end
    self.frame:Show()
end

function Hacienda:HideFrame()
    if self.frame then self.frame:Hide() end
end

function Hacienda:ToggleFrame()
    if self.frame and self.frame:IsVisible() then self:HideFrame() else self:ShowFrame() end
end

function Hacienda:UpdateChatHistory()
    if not self.frame or not self.frame:IsVisible() then return end
    if not self.selectedContact or not self.chatHistory then return end
    
    self.chatHistory:Clear()
    self.chatHistory:SetJustifyH("LEFT")
    
    -- For OS Pagadas category, show all paid messages from all players
    if self.selectedContact == PAID_OS_CONTACT then
        self:DisplayPaidOSHistory()
        return
    end
    
    -- Combine persistent and transient messages for regular contacts
    local allMessages = {}
    
    -- Add persistent messages
    if self.conversations[self.selectedContact] then
        for _, msg in ipairs(self.conversations[self.selectedContact]) do
            table.insert(allMessages, msg)
        end
    end
    
    -- Add transient messages
    if self.transientMessages[self.selectedContact] then
        for _, msg in ipairs(self.transientMessages[self.selectedContact]) do
            table.insert(allMessages, msg)
        end
    end
    
    -- Sort messages by timestamp
    table.sort(allMessages, function(a, b)
        if not a.time and not b.time then return false end
        if not a.time then return true end
        if not b.time then return false end
        if a.time == b.time then
            return tostring(a.message) < tostring(b.message)
        end
        return a.time < b.time
    end)
    
    -- Display settings
    local dateColor = "|cffa0a0a0"  -- Grey for dates
    local systemColor = "|cffffcc00" -- Yellow for system
    local outgoingColor = "|cff00ff00" -- Green for outgoing
    local incomingColor = "|cffffffff" -- White for incoming
    
    -- Add each message to the chat history
    for i, msg in ipairs(allMessages) do
        local timeText = date("%m/%d %H:%M", msg.time or time())
        local coloredTime = dateColor.."["..timeText.."]|r "
        
        local messageText = msg.message
        if msg.system then
            messageText = systemColor..self:ColorizeCurrency(messageText).."|r"
        elseif msg.outgoing then
            messageText = outgoingColor..self:ColorizeCurrency(messageText).."|r"
        else
            messageText = incomingColor..self:ColorizeCurrency(messageText).."|r"
        end
        
        self.chatHistory:AddMessage(coloredTime..messageText)
        
        -- Add separator if not the last message
        if i < table.getn(allMessages) then
            self.chatHistory:AddMessage("|cff808080---------------|r")
        end
    end
    
    self.chatHistory:ScrollToBottom()
end

function Hacienda:DisplayPaidOSHistory()
    local dateColor = "|cffa0a0a0"  -- Grey for dates
    local paidColor = "|cff00ff00"  -- Green for paid messages
    local systemColor = "|cffffcc00" -- Yellow for system messages
    
    -- Collect all paid messages from all players
    local allPaidMessages = {}
    
    -- First, add messages from paidConversations (archived paid OS)
    for playerName, messages in pairs(self.paidConversations) do
        for _, msg in ipairs(messages) do
            -- Add player name to the message for context
            local enhancedMessage = msg.message
            if not string.find(enhancedMessage, playerName) then
                enhancedMessage = playerName .. ": " .. enhancedMessage
            end
            table.insert(allPaidMessages, {
                message = enhancedMessage,
                time = msg.time,
                player = playerName,
                paidAmount = msg.paidAmount,
                moneyAmount = msg.moneyAmount,
                paymentTime = msg.paymentTime
            })
        end
    end
    
    -- Then add paid messages from active conversations
    for playerName, messages in pairs(self.conversations) do
        if playerName ~= GUILD_BANK_CONTACT and playerName ~= PAID_OS_CONTACT then
            for _, msg in ipairs(messages) do
                if msg.outgoing and msg.paymentTime then
                    -- This is a paid message that hasn't been archived yet
                    local enhancedMessage = msg.message
                    if not string.find(enhancedMessage, playerName) then
                        enhancedMessage = playerName .. ": " .. enhancedMessage
                    end
                    table.insert(allPaidMessages, {
                        message = enhancedMessage,
                        time = msg.paymentTime or msg.time,
                        player = playerName,
                        paidAmount = msg.paidAmount,
                        moneyAmount = msg.moneyAmount,
                        paymentTime = msg.paymentTime
                    })
                end
            end
        end
    end
    
    -- Sort by payment time (oldest first instead of newest first)
    table.sort(allPaidMessages, function(a, b)
        return (a.paymentTime or a.time) < (b.paymentTime or b.time)
    end)
    
    -- Display the paid messages
    if table.getn(allPaidMessages) == 0 then
        self.chatHistory:AddMessage("No paid OS records found.")
        return
    end
    
    self.chatHistory:AddMessage("|cffffcc00OS Pagadas Records (Oldest to Newest):|r")
    self.chatHistory:AddMessage("|cff808080---------------|r")
    
    for i, msg in ipairs(allPaidMessages) do
        local timeText = date("%m/%d %H:%M", msg.paymentTime or msg.time or time())
        local coloredTime = dateColor.."["..timeText.."]|r "
        
        -- Format the payment amount if available
        local amountText = ""
        if msg.paidAmount and msg.paidAmount > 0 then
            local gold = floor(msg.paidAmount / (COPPER_PER_SILVER * SILVER_PER_GOLD))
            local silver = floor((msg.paidAmount - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
            local copper = mod(msg.paidAmount, COPPER_PER_SILVER)
            
            amountText = " |cff00ff00(Paid: "
            if gold > 0 then amountText = amountText .. gold .. "g " end
            if silver > 0 then amountText = amountText .. silver .. "s " end
            if copper > 0 then amountText = amountText .. copper .. "c" end
            amountText = amountText .. ")|r"
        end
        
        local messageText = paidColor..self:ColorizeCurrency(msg.message)..amountText.."|r"
        
        self.chatHistory:AddMessage(coloredTime..messageText)
        
        -- Add separator if not the last message
        if i < table.getn(allPaidMessages) then
            self.chatHistory:AddMessage("|cff808080---------------|r")
        end
    end
    
    self.chatHistory:ScrollToBottom()
end

function Hacienda:ScheduleEvent(func, delay)
    local frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", function()
        this.timePassed = (this.timePassed or 0) + arg1
        if this.timePassed >= delay then
            func()
            this:SetScript("OnUpdate", nil)
        end
    end)
end

function Hacienda:IsDuplicateTransaction(timestamp, player, action, amount)
    if not Hacienda.conversations[GUILD_BANK_CONTACT] then 
        return false 
    end
    
    -- Normalize inputs
    local normalizedAmount = string.gsub(tostring(amount), "%s+", " "):trim()
    local normalizedPlayer = player:trim():lower()
    
    for _, msg in ipairs(Hacienda.conversations[GUILD_BANK_CONTACT]) do
        if msg.system and msg.message then
            -- Improved pattern matching
            local existingPlayer, existingAction, existingAmount = 
                string.match(msg.message, "^([%w]+)%s+(%a+)%s+(.+)%s+en el banco de la guild$")
            
            if existingPlayer and existingAction and existingAmount then
                -- Normalize comparison strings
                local normExistingPlayer = existingPlayer:trim():lower()
                local normExistingAmount = string.gsub(existingAmount, "%s+", " "):trim()
                
                -- Comparison with 30-second window
                local isDuplicate = (
                    normExistingPlayer == normalizedPlayer and
                    existingAction == action and
                    normExistingAmount == normalizedAmount and
                    math.abs((msg.time or 0) - (timestamp or 0)) <= 30
                )
                
                if isDuplicate then
                    return true
                end
            end
        end
    end
    
    return false
end

function Hacienda:GetPendingTotal(character)
    return Hacienda.pendingTotals[character] or 0
end

function Hacienda:ClearPendingTotal(character)
    if Hacienda.pendingTotals[character] then
        Hacienda.pendingTotals[character] = nil
    end
end

function Hacienda:CheckAndClearPendingOS(playerName, depositAmount, depositTime)
    -- Validate inputs
    if not playerName or not depositAmount or not depositTime then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Error: Invalid input to CheckAndClearPendingOS")
        return false
    end

    -- Initialize used deposits tracking if it doesn't exist
    if not Hacienda.usedDeposits then
        Hacienda.usedDeposits = {}
    end

    -- Check if this deposit has already been used
    local depositKey = playerName .. ":" .. depositTime .. ":" .. depositAmount
    if Hacienda.usedDeposits[depositKey] then
        return false
    end

    -- Mark this deposit as used
    Hacienda.usedDeposits[depositKey] = true
    
    -- Get group
    local main = self:GetMainChar(playerName)
    local members = self:GetGroupMembers(main)
    local groupTotal = self:GetGroupPending(playerName)
    
    if groupTotal <= 0 then
        return false
    end

    -- Collect all unpaid messages across the group
    local unpaid = {}
    for _, member in ipairs(members) do
        if self.conversations[member] then
            for index, msg in ipairs(self.conversations[member]) do
                if msg.outgoing and msg.moneyAmount and type(msg.moneyAmount) == "number" and not msg.paymentTime then
                    local remaining = msg.moneyAmount - (msg.paidAmount or 0)
                    if remaining > 0 then
                        table.insert(unpaid, {member = member, index = index, msg = msg, remaining = remaining, time = msg.time})
                    end
                else
                    if msg.outgoing and not msg.paymentTime then
                        DEFAULT_CHAT_FRAME:AddMessage(string.format(
                            "|cffffffff[|cff00ff00Hacienda|cffffffff]|r Warning: Skipping invalid message for %s: %s (moneyAmount: %s, system: %s)",
                            member, tostring(msg.message), tostring(msg.moneyAmount), tostring(msg.system)
                        ))
                    end
                end
            end
        end
    end
    
    -- Sort by time (oldest first)
    table.sort(unpaid, function(a, b) return a.time < b.time end)
    
    local remainingDeposit = depositAmount
    local clearedMessages = {}
    
    for _, entry in ipairs(unpaid) do
        if remainingDeposit <= 0 then break end
        local amountToApply = math.min(remainingDeposit, entry.remaining)
        entry.msg.paidAmount = (entry.msg.paidAmount or 0) + amountToApply
        remainingDeposit = remainingDeposit - amountToApply
        entry.remaining = entry.remaining - amountToApply
        if entry.msg.paidAmount >= entry.msg.moneyAmount then
            entry.msg.paymentTime = depositTime
            table.insert(clearedMessages, {member = entry.member, index = entry.index})
        end
    end
    
    -- Update pending totals for affected members
    local affectedMembers = {}
    for _, entry in ipairs(unpaid) do
        affectedMembers[entry.member] = true
    end
    for member, _ in pairs(affectedMembers) do
        local total = 0
        for _, msg in ipairs(self.conversations[member] or {}) do
            if msg.outgoing and msg.moneyAmount and type(msg.moneyAmount) == "number" and not msg.paymentTime then
                total = total + (msg.moneyAmount - (msg.paidAmount or 0))
            end
        end
        if total > 0 then
            self.pendingTotals[member] = total
        else
            self.pendingTotals[member] = nil
        end
    end
    
    -- Archive fully paid messages
    for i = table.getn(clearedMessages), 1, -1 do
        local cl = clearedMessages[i]
        local paidMessage = table.remove(self.conversations[cl.member], cl.index)
        if not self.paidConversations[cl.member] then
            self.paidConversations[cl.member] = {}
        end
        table.insert(self.paidConversations[cl.member], paidMessage)
    end
    
    -- Clean up empty conversations for the group
    for _, member in ipairs(members) do
        if self.conversations[member] and table.getn(self.conversations[member]) == 0 then
            self.conversations[member] = nil
        end
    end
    
    -- Add system message for the payment
    local amountApplied = depositAmount - remainingDeposit
    if amountApplied > 0 then
        local appliedGold = floor(amountApplied / (COPPER_PER_SILVER * SILVER_PER_GOLD))
        local appliedSilver = floor((amountApplied - (appliedGold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
        local appliedCopper = mod(amountApplied, COPPER_PER_SILVER)
        
        local appliedText = ""
        if appliedGold > 0 then appliedText = appliedText .. appliedGold .. "g " end
        if appliedSilver > 0 then appliedText = appliedText .. appliedSilver .. "s " end
        if appliedCopper > 0 then appliedText = appliedText .. appliedCopper .. "c" end
        
        local groupRemaining = self:GetGroupPending(playerName)
        local remainingGold = floor(groupRemaining / (COPPER_PER_SILVER * SILVER_PER_GOLD))
        local remainingSilver = floor((groupRemaining - (remainingGold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
        local remainingCopper = mod(groupRemaining, COPPER_PER_SILVER)
        
        local remainingText = ""
        if remainingGold > 0 then remainingText = remainingText .. remainingGold .. "g " end
        if remainingSilver > 0 then remainingText = remainingText .. remainingSilver .. "s " end
        if remainingCopper > 0 then remainingText = remainingCopper .. "c" end
        
        local message = string.format("Payment applied: %s (Remaining: %s)", appliedText, remainingText)
        
        if groupRemaining == 0 then
            message = message .. " - All OS cleared!"
        end
        
        Hacienda:AddSystemMessage(playerName, message, false, depositTime)
        
        -- Update UI if open
        if Hacienda.frame and Hacienda.frame:IsVisible() then
            Hacienda:UpdateContactList()
            if Hacienda.selectedContact == playerName or Hacienda.selectedContact == PAID_OS_CONTACT then
                Hacienda:UpdateChatHistory()
            end
        end
        
        -- Update guild note for the player
        Hacienda:UpdateGuildNoteWithDebt(playerName)
        
        return true
    end
    
    return false
end

-------------------------------------------------
-- Export / Import (Classic-Compatible)
-------------------------------------------------

-- Simple serializer
local function SerializeTable(t)
    local result = "{"
    local first = true
    for k, v in pairs(t) do
        if not first then result = result .. "," end
        first = false
        local key
        if type(k) == "number" then
            key = "[" .. k .. "]"   -- keep numeric indices
        else
            key = "[" .. string.format("%q", k) .. "]"
        end
        if type(v) == "table" then
            result = result .. key .. "=" .. SerializeTable(v)
        elseif type(v) == "string" then
            result = result .. key .. "=" .. string.format("%q", v)
        else
            result = result .. key .. "=" .. tostring(v)
        end
    end
    return result .. "}"
end

-- Custom popup for 1.12 (scrollable edit box)
local function ShowTextPopup(title, initialText, onAccept)
    if not HaciendaTextPopup then
        local f = CreateFrame("Frame", "HaciendaTextPopup", UIParent)
        f:SetWidth(500)
        f:SetHeight(300)
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        f:SetFrameStrata("DIALOG")
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = {left = 11, right = 12, top = 12, bottom = 11}
        })
        f:SetBackdropColor(0,0,0,1)
        f:Hide()

        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.title:SetPoint("TOP", f, "TOP", 0, -10)

        local scroll = CreateFrame("ScrollFrame", "HaciendaTextPopupScroll", f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -30)
        scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 45)

        local editBox = CreateFrame("EditBox", "HaciendaTextPopupEditBox", scroll)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(GameFontHighlight)
        editBox:SetWidth(440)
        editBox:SetAutoFocus(true)
        editBox:SetScript("OnEscapePressed", function() f:Hide() end)
        scroll:SetScrollChild(editBox)

        f.editBox = editBox

        local accept = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        accept:SetWidth(100)
        accept:SetHeight(25)
        accept:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 60, 10)
        accept:SetText("Accept")
        f.accept = accept

        local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        close:SetWidth(100)
        close:SetHeight(25)
        close:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -60, 10)
        close:SetText("Close")
        close:SetScript("OnClick", function() f:Hide() end)
        f.close = close
    end

    HaciendaTextPopup.title:SetText(title or "Text Popup")
    HaciendaTextPopup.editBox:SetText(initialText or "")
    HaciendaTextPopup:Show()

    if onAccept then
        HaciendaTextPopup.accept:SetScript("OnClick", function()
            local text = HaciendaTextPopup.editBox:GetText()
            onAccept(text)
            HaciendaTextPopup:Hide()
        end)
    else
        HaciendaTextPopup.accept:SetScript("OnClick", function()
            HaciendaTextPopup:Hide()
        end)
    end
end

-- Export only conversations that have pending OS
function Hacienda:ExportData()
    local export = {
        conversations = {},
    }

    for contact, messages in pairs(Hacienda.conversations or {}) do
        -- Use `next(messages)` to check if the table contains any entries.
        if messages and next(messages) then
            export.conversations[contact] = {}
            for _, msg in ipairs(messages) do
                table.insert(export.conversations[contact], {
                    message     = msg.message,
                    time        = msg.time,
                    outgoing    = msg.outgoing,
                    moneyAmount = msg.moneyAmount,
                    paidAmount  = msg.paidAmount,
                    paymentTime = msg.paymentTime,
                    system      = msg.system,
                })
            end
        end
    end

    -- Prefer the SerializeTable helper (your file used this previously).
    local exportString
    if SerializeTable and type(SerializeTable) == "function" then
        exportString = SerializeTable(export)
    else
        -- Fallback (not pretty, but avoids nil)
        exportString = tostring(export)
    end

    return exportString
end

-- Import conversations only (clean replace)
function Hacienda:ImportData(importString)
    if not importString or importString == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Import string is empty.")
        return
    end

    local imported = nil
    local success, decoded = pcall(function()
        return loadstring("return " .. importString)()
    end)

    if success and type(decoded) == "table" then
        imported = decoded
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Failed to decode import string.")
        return
    end

    if not imported.conversations then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r No conversations found in import data.")
        return
    end

    -- ✅ Merge conversations instead of replacing
    for contact, messages in pairs(imported.conversations or {}) do
        if not HaciendaSavedData.conversations[contact] then
            HaciendaSavedData.conversations[contact] = {}
        end

        for _, msg in pairs(messages) do
            local isDuplicate = false
            for _, existing in ipairs(HaciendaSavedData.conversations[contact]) do
                if existing.time == msg.time and existing.message == msg.message then
                    isDuplicate = true
                    break
                end
            end
            if not isDuplicate then
                table.insert(HaciendaSavedData.conversations[contact], msg)
            end
        end
    end

    -- Refresh reference
    Hacienda.conversations = HaciendaSavedData.conversations

    -- ✅ Recalculate pending totals
    Hacienda.pendingTotals = {}
    for contact, messages in pairs(Hacienda.conversations) do
        local total = 0
        for _, msg in ipairs(messages) do
            if msg.outgoing and msg.moneyAmount and not msg.paymentTime then
                local remaining = msg.moneyAmount - (msg.paidAmount or 0)
                if remaining > 0 then
                    total = total + remaining
                end
            end
        end
        if total > 0 then
            Hacienda.pendingTotals[contact] = total
        end
    end

    -- ✅ Update guild notes right after import (only if in guild & can edit)
    Hacienda:UpdateAllGuildNotes()

    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Import complete. Conversations merged.")
end


-- Slash commands
SLASH_HACIENDAEXPORT1 = "/hcexport"
SlashCmdList["HACIENDAEXPORT"] = function()
    Hacienda:ExportData()
end

SLASH_HACIENDAIMPORT1 = "/hcimport"
SlashCmdList["HACIENDAIMPORT"] = function()
    ShowTextPopup("Hacienda Import (Paste Below)", "", function(text)
        Hacienda:ImportData(text)
    end)
end

-- Debug command
SLASH_HACIENDADEBUG1 = "/hcdebug"
SlashCmdList["HACIENDADEBUG"] = function()
    for contact, total in pairs(Hacienda.pendingTotals or {}) do
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Hacienda|r Contact: " .. contact .. " owes " .. (total/10000) .. "g")
    end
end

function Hacienda:ShowImportExportFrame(mode)
    if not self.importExportFrame then
        local f = CreateFrame("Frame", "HaciendaImportExportFrame", UIParent)
        f:SetWidth(400)
		f:SetHeight(300)
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        f:SetFrameStrata("DIALOG")
        f:SetToplevel(true)
        f:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.8)
        f:SetBackdropBorderColor(0.6, 0.6, 0.6)

        -- Title
        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        f.title:SetPoint("TOP", f, "TOP", 0, -10)

        -- EditBox with Scroll
        local scroll = CreateFrame("ScrollFrame", "HaciendaImportExportScroll", f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -40)
        scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -35, 50)

        local editBox = CreateFrame("EditBox", nil, scroll)
        editBox:SetMultiLine(true)
        editBox:SetFontObject("GameFontNormal")
        editBox:SetWidth(340)
        editBox:SetAutoFocus(false)
        scroll:SetScrollChild(editBox)
        f.editBox = editBox

        -- Close Button
        local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT")

        -- Action Button
        f.actionButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        f.actionButton:SetWidth(100)
		f.actionButton:SetHeight(24)
        f.actionButton:SetPoint("BOTTOM", f, "BOTTOM", 0, 15)

        f:Hide()
        self.importExportFrame = f
    end

    local f = self.importExportFrame
    f:Show()

    if mode == "export" then
        f.title:SetText("Export Data")
        local exportString = Hacienda:ExportData() -- your existing export function
        f.editBox:SetText(exportString or "")
        f.editBox:HighlightText()
        f.actionButton:SetText("Copy")
        f.actionButton:SetScript("OnClick", function()
            f.editBox:SetFocus()
            f.editBox:HighlightText()
        end)
    elseif mode == "import" then
        f.title:SetText("Import Data")
        f.editBox:SetText("")
        f.actionButton:SetText("Import")
        f.actionButton:SetScript("OnClick", function()
            local text = f.editBox:GetText()
            Hacienda:ImportData(text)
            f:Hide()
        end)
    end
end

function Hacienda:ShowLinkedCharactersFrame()
    if not self.linkedCharactersFrame then
        local f = CreateFrame("Frame", "HaciendaLinkedCharactersFrame", UIParent)
        f:SetWidth(300)
        f:SetHeight(300)
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        f:SetFrameStrata("DIALOG")
        f:SetToplevel(true)
        f:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.8)
        f:SetBackdropBorderColor(0.6, 0.6, 0.6)

        -- Title
        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", f, "TOP", 0, -10)
        title:SetText("Linked Characters")

        -- Scroll Frame
        local scroll = CreateFrame("ScrollFrame", "HaciendaLinkedCharactersScroll", f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -60)
        scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -35, 40)

        local content = CreateFrame("Frame", nil, scroll)
        content:SetWidth(250)
        content:SetHeight(1)
        scroll:SetScrollChild(content)
        f.content = content

        -- Close Button
        local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT")

        f:Hide()
        self.linkedCharactersFrame = f
    end

    -- Clear previous content
    for _, child in ipairs({self.linkedCharactersFrame.content:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Populate linked characters
    local yOffset = 0
    local lineHeight = 20
    if not Hacienda.linkedChars or next(Hacienda.linkedChars) == nil then
        local text = self.linkedCharactersFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("TOPLEFT", self.linkedCharactersFrame.content, "TOPLEFT", 10, yOffset)
        text:SetText("No linked characters found.")
        text:SetTextColor(1, 0.5, 0.5)
        yOffset = yOffset - lineHeight
    else
        local sortedLinks = {}
        for alt, main in pairs(Hacienda.linkedChars) do
            table.insert(sortedLinks, {alt = alt, main = main})
        end
        table.sort(sortedLinks, function(a, b) return a.alt < b.alt end)

        for _, link in ipairs(sortedLinks) do
            local textFrame = CreateFrame("Button", nil, self.linkedCharactersFrame.content)
            textFrame:SetWidth(220)
            textFrame:SetHeight(lineHeight)
            textFrame:SetPoint("TOPLEFT", self.linkedCharactersFrame.content, "TOPLEFT", 10, yOffset)
            
            -- Set up the button to capture clicks
            textFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            textFrame:SetScript("OnClick", function(self, button)
                if button == "RightButton" then
                    -- Confirmation dialog
                    StaticPopupDialogs["HACIENDA_UNLINK_CONFIRM"] = {
                        text = "Are you sure you want to unlink %s from %s?",
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            Hacienda:UnlinkCharacters(nil, link.alt)
                            Hacienda:ShowLinkedCharactersFrame() -- Refresh the frame
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3,
                    }
                    StaticPopup_Show("HACIENDA_UNLINK_CONFIRM", link.alt, link.main)
                end
            end)
            
            -- Add highlight texture for better UX
            textFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            
            local textString = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            textString:SetPoint("LEFT", textFrame, "LEFT", 0, 0)
            textString:SetText(string.format("%s -> %s", link.alt, link.main))
            textString:SetTextColor(1, 1, 1)
            textString:SetWidth(200)

            yOffset = yOffset - lineHeight
        end
    end

    self.linkedCharactersFrame.content:SetHeight(math.abs(yOffset))
    self.linkedCharactersFrame:Show()
end

-- Slash command to show linked characters frame
SLASH_HACIENDALINKS1 = "/hclinks"
SlashCmdList["HACIENDALINKS"] = function()
    Hacienda:ShowLinkedCharactersFrame()
end

-- New function to show link frame
function Hacienda:ShowLinkFrame()
    if not self.linkFrame then
        local f = CreateFrame("Frame", "HaciendaLinkFrame", UIParent)
        f:SetWidth(300)
        f:SetHeight(150)
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        f:SetFrameStrata("DIALOG")
        f:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.8)
        f:SetBackdropBorderColor(0.6, 0.6, 0.6)

        -- Title
        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", f, "TOP", 0, -10)
        title:SetText("Link Characters")

        -- Main Char Input
        local mainLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        mainLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -40)
        mainLabel:SetText("Main Char:")

        self.linkMainInput = CreateFrame("EditBox", nil, f)
        self.linkMainInput:SetWidth(150)
        self.linkMainInput:SetHeight(20)
        self.linkMainInput:SetPoint("LEFT", mainLabel, "RIGHT", 10, 0)
        self.linkMainInput:SetAutoFocus(false)
        self.linkMainInput:SetFontObject("GameFontNormal")
        self.linkMainInput:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            insets = {left = 5, right = 5, top = 5, bottom = 5}
        })
        self.linkMainInput:SetBackdropColor(0.1, 0.1, 0.1, 1)
        self.linkMainInput:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        -- Alt Char Input
        local altLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        altLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -70)
        altLabel:SetText("Alt Char:")

        self.linkAltInput = CreateFrame("EditBox", nil, f)
        self.linkAltInput:SetWidth(150)
        self.linkAltInput:SetHeight(20)
        self.linkAltInput:SetPoint("LEFT", altLabel, "RIGHT", 10, 0)
        self.linkAltInput:SetAutoFocus(false)
        self.linkAltInput:SetFontObject("GameFontNormal")
        self.linkAltInput:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            insets = {left = 5, right = 5, top = 5, bottom = 5}
        })
        self.linkAltInput:SetBackdropColor(0.1, 0.1, 0.1, 1)
        self.linkAltInput:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        -- Link Button
        local linkBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        linkBtn:SetWidth(100)
        linkBtn:SetHeight(25)
        linkBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 20)
        linkBtn:SetText("Link")
        linkBtn:SetScript("OnClick", function()
            Hacienda:LinkCharacters(self.linkMainInput:GetText(), self.linkAltInput:GetText())
            f:Hide()
        end)

        -- Close Button
        local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT")

        f:Hide()
        self.linkFrame = f
    end

    self.linkFrame:Show()
    self.linkMainInput:SetText("")
    self.linkAltInput:SetText("")
end

-- Function to link characters
function Hacienda:LinkCharacters(main, alt)
    main = self:Trim(main)
    alt = self:Trim(alt)
    if main == "" or alt == "" or main == alt then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Invalid main or alt name.")
        return
    end

    local currentMain = self:GetMainChar(main)
    local currentAltMain = self:GetMainChar(alt)

    -- Merge groups if necessary
    if currentAltMain ~= currentMain then
        for c, m in pairs(self.linkedChars) do
            if m == currentAltMain then
                self.linkedChars[c] = currentMain
            end
        end
    end

    self.linkedChars[alt] = currentMain

    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Linked " .. alt .. " to " .. main .. ".")
    self:UpdateAllGuildNotes()
    if self.frame and self.frame:IsVisible() then
        self:UpdateContactList()
    end
end

function Hacienda:UnlinkCharacters(main, alt)
    main = Hacienda:Trim(main or "")
    alt = Hacienda:Trim(alt or "")

    if alt ~= "" and Hacienda.linkedChars[alt] then
        -- Remove only this alt from its main
        Hacienda.linkedChars[alt] = nil
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Unlinked " .. alt .. " from " .. (main ~= "" and main or "its main"))
    elseif main ~= "" then
        -- Remove all alts pointing to this main
        local removed = false
        for c, m in pairs(Hacienda.linkedChars) do
            if m == main then
                Hacienda.linkedChars[c] = nil
                DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Unlinked " .. c .. " from " .. main)
                removed = true
            end
        end
        if not removed then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r No alts linked to " .. main)
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[|cff00ff00Hacienda|cffffffff]|r Please enter a Main and/or Alt to unlink.")
    end

    Hacienda:UpdateContactList()
end