-- Create the main addon frame
local frame = CreateFrame("Frame", "WorldBossCheckFrame", UIParent, "BackdropTemplate")
-- slightly larger so delete buttons have breathing room (wider + taller minimum)
frame:SetSize(360, 380)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

-- Set backdrop
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})

-- Make the main frame a reasonable frame level so children render above the UI
frame:SetFrameLevel(70)

-- Title
local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
titleText:SetText("World Boss Check")

-- Put the title into its own small frame so we can control its draw order
local titleFrame = CreateFrame("Frame", nil, frame)
titleFrame:SetSize(260, 22)
titleFrame:SetPoint("TOP", frame, "TOP", 0, -14)
titleText:SetParent(titleFrame)
titleText:SetPoint("CENTER", 0, 0)
titleFrame:SetFrameLevel(95)

-- Tabs container (buttons to switch views)
local tabs = CreateFrame("Frame", nil, frame)
tabs:SetSize(200, 20)
tabs:SetPoint("TOP", 0, -36)

local function CreateTabButton(name, text, xOffset)
    local btn = CreateFrame("Button", nil, tabs, "UIPanelButtonTemplate")
    btn:SetSize(90, 20)
    btn:SetPoint("LEFT", tabs, "LEFT", xOffset, 0)
    btn:SetText(text)
    return btn
end

local tabAllBtn = CreateTabButton("WBC_TabAll", "Sha/Gall", 0)
local tabOonBtn = CreateTabButton("WBC_TabOondasta", "Oon/Nalak", 96)
tabAllBtn:SetFrameStrata("MEDIUM")
tabOonBtn:SetFrameStrata("MEDIUM")
tabAllBtn:SetFrameLevel(90)
tabOonBtn:SetFrameLevel(90)

-- Close button
local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
closeButton:SetSize(24, 24)

-- Main and Oondasta-specific containers
local mainContainer = CreateFrame("Frame", nil, frame)
mainContainer:SetAllPoints(frame)

local oondastaContainer = CreateFrame("Frame", nil, frame)
oondastaContainer:SetAllPoints(frame)
oondastaContainer:Hide()

-- Content frames (provide inner padded area that hides with each tab)
local contentFrame = CreateFrame("Frame", nil, mainContainer)
-- reduce top inset and bottom inset so interior gets more usable height
-- move content area down to give more space under the title/tabs
contentFrame:SetPoint("TOPLEFT", mainContainer, "TOPLEFT", 12, -56)
contentFrame:SetPoint("BOTTOMRIGHT", mainContainer, "BOTTOMRIGHT", -12, 30)

local contentFrameOon = CreateFrame("Frame", nil, oondastaContainer)
contentFrameOon:SetPoint("TOPLEFT", oondastaContainer, "TOPLEFT", 12, -56)
contentFrameOon:SetPoint("BOTTOMRIGHT", oondastaContainer, "BOTTOMRIGHT", -12, 30)

-- Oondasta bosses frame (mirror of `bossesFrame` layout for the second tab)
local bossesFrameOon = CreateFrame("Frame", nil, contentFrameOon)
bossesFrameOon:SetSize(260, 72)
bossesFrameOon:SetFrameLevel(90)
bossesFrameOon:SetPoint("TOPLEFT", contentFrameOon, "TOPLEFT", 0, -8)

-- Oondasta status line placed inside the Oondasta bosses frame (mirrors main tab layout)
local oondastaStatusText = bossesFrameOon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
oondastaStatusText:SetPoint("TOPLEFT", 0, -10)
oondastaStatusText:SetText("Oondasta: (loading...)")

local nalakStatusText = bossesFrameOon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
nalakStatusText:SetPoint("TOPLEFT", oondastaStatusText, "BOTTOMLEFT", 0, -20)
nalakStatusText:SetText("Nalak: (loading...)")

-- Boss kill lines

-- Group boss status lines into their own frame to keep them above the row list
bossesFrame = CreateFrame("Frame", nil, frame)
bossesFrame:SetSize(260, 72)
bossesFrame:SetFrameLevel(90)

local shaOfAngerText = bossesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- nudge the Sha line down a few more pixels so the boss lines sit lower together
shaOfAngerText:SetPoint("TOPLEFT", 0, -10)


local galleonText = bossesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
galleonText:SetPoint("TOPLEFT", shaOfAngerText, "BOTTOMLEFT", 0, -20)


-- Alts header
-- Alts header: put into its own frame so it can sit above rows
local altsHeaderFrame = CreateFrame("Frame", nil, contentFrame)
altsHeaderFrame:SetSize(260, 20)
altsHeaderFrame:SetPoint("TOPLEFT", bossesFrame, "BOTTOMLEFT", 0, -20)
altsHeaderFrame:SetFrameLevel(95)

local altsHeader = altsHeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
altsHeader:SetPoint("TOPLEFT", 0, 0)
altsHeader:SetText("Characters:")

-- Alt status text
-- Container for character rows
-- Container for character rows
local altsContainer = CreateFrame("Frame", nil, contentFrame)
-- move the character list slightly up (less negative offset) per user request
altsContainer:SetPoint("TOPLEFT", altsHeaderFrame, "BOTTOMLEFT", 0, -7)
altsContainer:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", 0, 20)
altsContainer:SetWidth(260)

-- Oondasta-specific header/container (separate from main)
-- Oondasta-specific characters header (use its own frame for layering)

local altsHeaderOonFrame = CreateFrame("Frame", nil, contentFrameOon)
altsHeaderOonFrame:SetSize(260, 20)
-- anchor the Oondasta characters header under the bosses frame with offset to place below next boss area
altsHeaderOonFrame:ClearAllPoints()
altsHeaderOonFrame:SetPoint("TOPLEFT", bossesFrameOon, "BOTTOMLEFT", 0, -20)
altsHeaderOonFrame:SetFrameLevel(95)

local altsHeaderOon = altsHeaderOonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
altsHeaderOon:SetPoint("TOPLEFT", 0, 0)
altsHeaderOon:SetText("Characters:")

local altsContainerOon = CreateFrame("Frame", nil, contentFrameOon)
altsContainerOon:SetPoint("TOPLEFT", altsHeaderOonFrame, "BOTTOMLEFT", 0, -6)
altsContainerOon:SetPoint("BOTTOMRIGHT", contentFrameOon, "BOTTOMRIGHT", 0, 20)
altsContainerOon:SetWidth(260)

-- Reset text (create before re-parenting so variables exist)
local resetTextMain = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
resetTextMain:SetPoint("BOTTOMLEFT", contentFrame, "BOTTOMLEFT", 0, -6)
resetTextMain:SetText("Next reset: (loading...)")

local resetTextOon = contentFrameOon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
resetTextOon:SetPoint("BOTTOMLEFT", contentFrameOon, "BOTTOMLEFT", 0, -6)
resetTextOon:SetText("Next reset: (loading...)")

-- Move existing UI elements into containers by re-parenting
-- Rows and containers should be children of mainContainer; header and boss lines already live in their own frames
altsContainer:SetParent(contentFrame)
resetTextMain:SetParent(contentFrame)
-- bossesFrame is already parented to mainContainer and contains the boss fontstrings
-- ensure bossesFrame is a child of the main container view
-- now that content frames exist, parent and position bossesFrame inside the main contentFrame
bossesFrame:SetParent(contentFrame)
bossesFrame:ClearAllPoints()
bossesFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -8)
-- make header frames children of their respective containers now that those containers exist
altsHeaderFrame:SetParent(contentFrame)
altsHeaderOonFrame:SetParent(contentFrameOon)

-- Oondasta section: next boss placeholder (for upcoming world boss)
-- Oondasta tab: next boss header within the Oondasta content frame
local nextBossHeader = contentFrameOon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- position the next-boss header under the Oondasta bosses frame so the order matches the main tab
nextBossHeader:SetPoint("TOPLEFT", bossesFrameOon, "BOTTOMLEFT", 0, -10)
nextBossHeader:SetText("Next world boss:")

local nextBossText = contentFrameOon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
nextBossText:SetPoint("TOPLEFT", nextBossHeader, "BOTTOMLEFT", 0, -6)
nextBossText:SetText("(empty) - use the database or wait for an update")

-- Oondasta status line similar to main tab (shows check/cross for current character)
-- oondastaStatusText is created inside bossesFrameOon to match main tab layout

-- Update the Oondasta next-boss display from saved data (hide if none)
local function UpdateOondastaNextBoss()
    WorldBossCheckDB = WorldBossCheckDB or {}
    local nb = WorldBossCheckDB.nextBoss
    if nb and nb ~= "" then
        nextBossHeader:Show()
        nextBossText:Show()
        nextBossText:SetText(nb)
    else
        -- hide placeholder if there's no known next boss
        nextBossHeader:Hide()
        nextBossText:Hide()
    end
end

-- Row pool
local rowPool = {}
local activeRowsMain = {}
local activeRowsOon = {}
-- Row height used for spacing and resizing
local ROW_HEIGHT = 20

local function AcquireRow()
    local row = table.remove(rowPool)
    if row then
        -- clear previous anchors so we don't accumulate points when reusing rows
        row:ClearAllPoints()
        row:SetParent(frame)
        row:SetFrameLevel(50)
        return row
    end
    row = CreateFrame("Frame", nil, frame)
    row:SetSize(280, ROW_HEIGHT)

    row.icon = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.icon:SetPoint("LEFT", 0, 0)
    row.icon:SetWidth(24)

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.nameText:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWidth(220)

    row.deleteBtn = CreateFrame("Button", nil, row, "UIPanelCloseButton")
    row.deleteBtn:SetSize(20, 20)
    row.deleteBtn:SetPoint("RIGHT", row, "RIGHT", -10, 0)

        -- per-row Oondasta manual checkbox (hidden by default; shown only for current character)
        row.oonChk = CreateFrame("CheckButton", nil, row, "ChatConfigCheckButtonTemplate")
        row.oonChk:SetSize(20, 20)
        row.oonChk:SetPoint("RIGHT", row, "RIGHT", -36, 0)
        row.oonChk:Hide()
        row.oonChk.Text:SetText("")

        -- per-row Nalak manual checkbox
        row.nalakChk = CreateFrame("CheckButton", nil, row, "ChatConfigCheckButtonTemplate")
        row.nalakChk:SetSize(20, 20)
        row.nalakChk:SetPoint("RIGHT", row.oonChk, "LEFT", -4, 0)
        row.nalakChk:Hide()
        row.nalakChk.Text:SetText("")

    -- default row level lower than headers so headers stay visible
    row:SetFrameLevel(50)

    return row
end

local function ReleaseRow(row)
    row:Hide()
    row.icon:SetText("")
    row.nameText:SetText("")
    row.deleteBtn:Hide()
    row.deleteBtn:SetScript("OnClick", nil)
    if row.oonChk then
        row.oonChk:Hide()
        row.oonChk:SetScript("OnClick", nil)
    end
    if row.nalakChk then
        row.nalakChk:Hide()
        row.nalakChk:SetScript("OnClick", nil)
    end
    -- clear anchors to avoid accumulating multiple SetPoint anchors when reused
    row:ClearAllPoints()
    -- reparent to the main frame to keep pool rows out of the visible container
    row:SetParent(frame)
    table.insert(rowPool, row)
end

-- Delete helper (defined early so confirm dialog can call it)
local function DeleteCharacter(fullName)
    if not WorldBossCheckDB or not WorldBossCheckDB.characters then return false end
    if WorldBossCheckDB.characters[fullName] then
        WorldBossCheckDB.characters[fullName] = nil
        return true
    end
    return false
end

-- forward declare confirmFrame so row handlers reference the local upvalue (set later)
local confirmFrame
-- forward declare ShowConfirmToDelete so row handlers can call it
local ShowConfirmToDelete

-- Reset text

-- Refresh button

-- Footer
local footerText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
footerText:SetPoint("BOTTOMRIGHT", -10, 10)
footerText:SetText("Version 0.5 - By xoYeni")

-- Checkbox for auto-open preference
local autoOpenCheckbox = CreateFrame("CheckButton", "WorldBossCheckAutoOpenCheckbox", frame, "ChatConfigCheckButtonTemplate")
-- move lower to avoid overlapping the reset timer
autoOpenCheckbox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 12)
autoOpenCheckbox.Text:SetText("Show on login if bosses incomplete")
autoOpenCheckbox:SetChecked(true)
autoOpenCheckbox:SetScript("OnClick", function(self)
    WorldBossCheckDB.autoOpen = self:GetChecked()
end)

-- Initialize checkbox state from DB
local function UpdateAutoOpenCheckbox()
    if WorldBossCheckDB and WorldBossCheckDB.autoOpen ~= nil then
        autoOpenCheckbox:SetChecked(WorldBossCheckDB.autoOpen)
    else
        autoOpenCheckbox:SetChecked(true)
    end
end

-- Resize frame based on character count
local MIN_FRAME_HEIGHT = 380
local function ResizeFrameToFitCharacters(count)
    local baseHeight = 150
    local perAltLine = ROW_HEIGHT
    local staticUIHeight = 80
    local newHeight = baseHeight + (count * perAltLine) + staticUIHeight
    frame:SetHeight(math.max(newHeight, MIN_FRAME_HEIGHT))
end

-- Generic updater for a character list inside a container
local function UpdateAltStatusDisplayFor(container, altsHeaderLocal, altsContainerLocal, resetTextLocal, activeRows, includeCurrent)
    -- Clear active rows
    for _, row in ipairs(activeRows) do
        ReleaseRow(row)
    end
    wipe(activeRows)

    if not WorldBossCheckDB or not WorldBossCheckDB.characters then return end

    local name, realm = UnitName("player")
    local currentChar = name .. "-" .. (realm or GetRealmName())

    -- Collect display entries
    local entries = {}
    for charName, data in pairs(WorldBossCheckDB.characters) do
        if charName ~= currentChar and (data.level or 0) >= 85 then
            table.insert(entries, { key = charName, data = data })
        end
    end

    table.sort(entries, function(a,b) return a.data.name < b.data.name end)

    -- Create rows
    for i, entry in ipairs(entries) do
        local row = AcquireRow()
        row:SetParent(altsContainerLocal)
        row:SetPoint("TOPLEFT", altsContainerLocal, "TOPLEFT", 0, -(i-1) * ROW_HEIGHT)
        local data = entry.data
        -- small local icons for ready/cross
        local checkIcon = "|TInterface\\RaidFrame\\ReadyCheck-Ready:16|t"
        local waitingIcon = "|TInterface\\RaidFrame\\ReadyCheck-Waiting:16|t"
        local crossIcon = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:16|t"

        -- If we're rendering the Oondasta tab, show Oondasta-specific status
        local isOon = (altsContainerLocal == altsContainerOon)
        local icon
        if isOon then
            local combined = (data.oonKilled and 1 or 0) + (data.nalakKilled and 1 or 0)
            if combined == 2 then
                icon = checkIcon
            elseif combined == 1 then
                icon = waitingIcon
            else
                icon = crossIcon
            end
        else
            if data.kills == 2 then
                icon = checkIcon
            elseif data.kills == 1 then
                icon = waitingIcon
            else
                icon = crossIcon
            end
        end

        row.icon:SetText(icon)
        row.nameText:SetText(data.name .. " - " .. data.realm)

        -- Delete button
        row.deleteBtn:Show()
        row.deleteBtn:SetScript("OnClick", function()
            ShowConfirmToDelete(entry.key)
        end)

        -- Oondasta manual checkbox handling: show editable checkbox only for the current character
        if isOon then
            if row.oonChk then
                if entry.key == currentChar then
                    -- editable checkbox for the currently logged-in character
                    row.oonChk:Show()
                    row.oonChk:SetChecked(data.oonKilled == true)
                    row.oonChk:SetScript("OnClick", function(self)
                        WorldBossCheckDB = WorldBossCheckDB or {}
                        WorldBossCheckDB.characters = WorldBossCheckDB.characters or {}
                        local cur = WorldBossCheckDB.characters[entry.key] or data
                        cur.oonKilled = self:GetChecked()
                        cur.lastUpdate = time()
                        WorldBossCheckDB.characters[entry.key] = cur
                        -- refresh display to update icon/state
                        UpdateAltStatusDisplay()
                    end)
                else
                    -- hide the editable checkbox for remote alts
                    row.oonChk:Hide()
                end
            end
            if row.nalakChk then
                if entry.key == currentChar then
                    row.nalakChk:Show()
                    row.nalakChk:SetChecked(data.nalakKilled == true)
                    row.nalakChk:SetScript("OnClick", function(self)
                        WorldBossCheckDB = WorldBossCheckDB or {}
                        WorldBossCheckDB.characters = WorldBossCheckDB.characters or {}
                        local cur = WorldBossCheckDB.characters[entry.key] or data
                        cur.nalakKilled = self:GetChecked()
                        cur.lastUpdate = time()
                        WorldBossCheckDB.characters[entry.key] = cur
                        -- refresh display to update icon/state
                        UpdateAltStatusDisplay()
                    end)
                else
                    row.nalakChk:Hide()
                end
            end
        else
            if row.oonChk then row.oonChk:Hide() end
            if row.nalakChk then row.nalakChk:Hide() end
        end

        row:Show()
        table.insert(activeRows, row)
    end

    ResizeFrameToFitCharacters(#entries)

    -- Reposition reset text below the container so it never overlaps headers
    resetTextLocal:ClearAllPoints()
    resetTextLocal:SetPoint("TOPLEFT", altsContainerLocal, "BOTTOMLEFT", 0, -8)
end

-- Wrapper to update both tabs
local function UpdateAltStatusDisplay()
    -- pass the header frames (parents of the FontStrings) so anchors are consistent
    UpdateAltStatusDisplayFor(mainContainer, altsHeaderFrame, altsContainer, resetTextMain, activeRowsMain)
    UpdateAltStatusDisplayFor(oondastaContainer, altsHeaderOonFrame, altsContainerOon, resetTextOon, activeRowsOon)
end

-- Confirmation dialog factory (lazy-created)
local targetToDelete = nil
local function EnsureConfirmFrame()
    if confirmFrame then return end
    confirmFrame = CreateFrame("Frame", "WorldBossCheckConfirmFrame", UIParent, "BackdropTemplate")
    confirmFrame:SetSize(300, 100)
    confirmFrame:SetPoint("CENTER")
    confirmFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    confirmFrame:Hide()

    confirmFrame.title = confirmFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    confirmFrame.title:SetPoint("TOP", 0, -8)
    confirmFrame.title:SetText("Confirm Deletion")

    confirmFrame.text = confirmFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    confirmFrame.text:SetPoint("TOP", confirmFrame.title, "BOTTOM", 0, -8)
    confirmFrame.text:SetWidth(260)
    confirmFrame.text:SetJustifyH("CENTER")

    local yesBtn = CreateFrame("Button", nil, confirmFrame, "UIPanelButtonTemplate")
    yesBtn:SetSize(100, 24)
    yesBtn:SetPoint("BOTTOMLEFT", confirmFrame, "BOTTOM", -110, 12)
    yesBtn:SetText("Yes")
    yesBtn:SetScript("OnClick", function()
        if targetToDelete then
            if DeleteCharacter(targetToDelete) then
                print("WorldBossCheck: Removed " .. targetToDelete)
                UpdateAltStatusDisplay()
            else
                print("WorldBossCheck: Could not find " .. targetToDelete)
            end
        end
        targetToDelete = nil
        confirmFrame:Hide()
    end)

    local noBtn = CreateFrame("Button", nil, confirmFrame, "UIPanelButtonTemplate")
    noBtn:SetSize(100, 24)
    noBtn:SetPoint("BOTTOMRIGHT", confirmFrame, "BOTTOM", 110, 12)
    noBtn:SetText("No")
    noBtn:SetScript("OnClick", function()
        targetToDelete = nil
        confirmFrame:Hide()
    end)
end

ShowConfirmToDelete = function(fullName)
    EnsureConfirmFrame()
    targetToDelete = fullName
    confirmFrame.text:SetText("Delete saved data for " .. fullName .. "? This action cannot be undone.")
    confirmFrame:Show()
end

-- Tab switching
local function ShowTab(tab)
    WorldBossCheckDB = WorldBossCheckDB or {}
    WorldBossCheckDB.lastTab = tab
    if tab == "oondasta" then
        mainContainer:Hide()
        oondastaContainer:Show()
        tabOonBtn:Disable()
        tabAllBtn:Enable()
    else
        oondastaContainer:Hide()
        mainContainer:Show()
        tabAllBtn:Disable()
        tabOonBtn:Enable()
    end
end

tabAllBtn:SetScript("OnClick", function() ShowTab("all") end)
tabOonBtn:SetScript("OnClick", function() ShowTab("oondasta") end)

-- Update boss kill statuses
function WorldBossCheck_Update()
    local checkIcon = "|TInterface\\RaidFrame\\ReadyCheck-Ready:16|t"
    local crossIcon = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:16|t"

    -- Ensure database exists
    WorldBossCheckDB = WorldBossCheckDB or {}
    WorldBossCheckDB.characters = WorldBossCheckDB.characters or {}

    -- Reset outdated character data
    local now = time()
    local nextReset = C_DateAndTime.GetSecondsUntilWeeklyReset()
    local thisResetTimestamp = now + nextReset - 604800

    for charName, data in pairs(WorldBossCheckDB.characters) do
        if data.lastUpdate and data.lastUpdate < thisResetTimestamp then
            WorldBossCheckDB.characters[charName].kills = 0
            WorldBossCheckDB.characters[charName].lastUpdate = nil
            -- clear manual Oondasta mark on weekly reset
            WorldBossCheckDB.characters[charName].oonKilled = nil
            WorldBossCheckDB.characters[charName].nalakKilled = nil
        end
    end

    -- Current character info
    local name, realm = UnitName("player")
    local level = UnitLevel("player")
    realm = realm or GetRealmName()
    local fullName = name .. "-" .. realm

    -- Automatic cleanup: remove any character entries for this account that match the current character's name but have a different realm
    for charName, data in pairs(WorldBossCheckDB.characters) do
        if data and data.name == name and data.realm ~= realm then
            WorldBossCheckDB.characters[charName] = nil
        end
    end

    -- Ignore and cleanup lowbies
    if level < 85 then
        -- Show level-up message for low-level characters
        shaOfAngerText:SetText("Not lvl 85 Yet go level!")
        galleonText:SetText("")
        oondastaStatusText:SetText("Not lvl 85 Yet go level!")
        nalakStatusText:SetText("")
        nextBossHeader:SetText("")
        nextBossText:SetText("Not lvl 85 Yet go level!")
        WorldBossCheckDB.characters[fullName] = nil
        UpdateAltStatusDisplay()
        return
    end

    -- Boss kills
    local shaKilled = C_QuestLog.IsQuestFlaggedCompleted(32099)
    local galleonKilled = C_QuestLog.IsQuestFlaggedCompleted(32098)
    local questOon = C_QuestLog.IsQuestFlaggedCompleted(32519)
    local questNalak = C_QuestLog.IsQuestFlaggedCompleted(32518)

    -- Update UI
    shaOfAngerText:SetText("Sha of Anger: " .. (shaKilled and checkIcon or crossIcon))
    galleonText:SetText("Galleon: " .. (galleonKilled and checkIcon or crossIcon))

    -- Save progress
    -- preserve any manual Oondasta flag while updating auto-detected kills
    local existing = WorldBossCheckDB.characters[fullName] or {}
    local oonKilled = questOon or existing.oonKilled  -- quest takes priority, else manual
    local nalakKilled = questNalak or existing.nalakKilled
    WorldBossCheckDB.characters[fullName] = {
        name = name,
        realm = realm,
        level = level,
        kills = (shaKilled and 1 or 0) + (galleonKilled and 1 or 0),
        lastUpdate = now,
        oonKilled = oonKilled,
        nalakKilled = nalakKilled,
    }

    -- Update Oondasta status line in Oondasta tab for the current character
    if oondastaStatusText then
        oondastaStatusText:SetText("Oondasta: " .. (oonKilled and checkIcon or crossIcon))
    end
    if nalakStatusText then
        nalakStatusText:SetText("Nalak: " .. (nalakKilled and checkIcon or crossIcon))
    end

    UpdateAltStatusDisplay()
end

-- Update reset timer
local function UpdateResetTimer()
    local secondsUntilReset = C_DateAndTime.GetSecondsUntilWeeklyReset()
    local days = math.floor(secondsUntilReset / 86400)
    local hours = math.floor((secondsUntilReset % 86400) / 3600)
    local minutes = math.floor((secondsUntilReset % 3600) / 60)
    local txt = string.format("Next reset: %dd %dh %dm", days, hours, minutes)
    if resetTextMain then resetTextMain:SetText(txt) end
    if resetTextOon then resetTextOon:SetText(txt) end
end

-- Timer updater
local elapsed = 0
frame:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + delta
    if elapsed >= 1 then
        UpdateResetTimer()
        elapsed = 0
    end
end)

-- Weekly refresh scheduler
local function ScheduleWeeklyRefresh()
    local secondsUntilReset = C_DateAndTime.GetSecondsUntilWeeklyReset()
    C_Timer.After(secondsUntilReset + 1, function()
        print("WorldBossCheck: Weekly reset occurred! Refreshing boss data.")
        WorldBossCheck_Update()
        print("WorldBossCheck: Please review the Oondasta tab and mark which characters killed Oondasta this week.")
        ScheduleWeeklyRefresh()
    end)
end

-- Auto update events
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        WorldBossCheckDB = WorldBossCheckDB or {}
        UpdateAutoOpenCheckbox()
        local level = UnitLevel("player")
        local shaKilled = C_QuestLog.IsQuestFlaggedCompleted(32099)
        local galleonKilled = C_QuestLog.IsQuestFlaggedCompleted(32098)
        local autoOpen = WorldBossCheckDB.autoOpen
        if level < 85 or (shaKilled and galleonKilled) or (autoOpen == false) then
            frame:Hide()
        else
            frame:Show()
        end
        WorldBossCheck_Update()
        UpdateResetTimer()
    UpdateOondastaNextBoss()
        ScheduleWeeklyRefresh()
    -- restore last-open tab
    ShowTab(WorldBossCheckDB.lastTab or "all")
    elseif event == "QUEST_LOG_UPDATE" then
        WorldBossCheck_Update()
    end
end)

-- Minimap Button via LibDataBroker
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dbicon = LibStub("LibDBIcon-1.0")

local ldbIcon = ldb:NewDataObject("WorldBossCheck", {
    type = "data source",
    text = "World Boss Check",
    icon = "Interface\\Icons\\inv_axe_2h_pandaraid_d_01",
    OnClick = function(_, button)
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("World Boss Check")
        tooltip:AddLine("Click to toggle window", 1, 1, 1)
    end,
})

WorldBossCheckDB = WorldBossCheckDB or {}
WorldBossCheckDB.minimap = WorldBossCheckDB.minimap or {}
dbicon:Register("WorldBossCheck", ldbIcon, WorldBossCheckDB)
dbicon:Show("WorldBossCheck")
