-- Konfigurierbarer Pfad zu dem zu überprüfenden Ordner
local folderToScan = "./resources/[faulestüsckscheisse]" -- Standardordner
-- local folderToScan = "./resources/[deinOrdnerName]"
-- local folderToScan = "./resources/[deinOrdnerName]"
-- local folderToScan = "./resources/[deinOrdnerName]"
-- local folderToScan = "./resources/[deinOrdnerName]"
-- local folderToScan = "./resources/[deinOrdnerName]"
-- local folderToScan = "./resources/[deinOrdnerName]"
-- local folderToScan = "./resources/[deinOrdnerName]"
-- etc man kann so viel adden wie man will
local keywords = {
    "TriggerServerEvent",
    "PerformHttpRequest",
    "os.execute",
    "io.popen",
    "loadstring",
    "RunString",
    "LoadResourceFile",
    "debug.setupvalue",
    "GetResourceMetadata",
    "Citizen.InvokeNative"
}

-- Funktion: Überprüft Dateien in einem Ordner rekursiv
local function scanDirectory(directory)
    local foundFiles = {}

    -- Hole alle Dateien und Ordner
    local handle = io.popen('dir "' .. directory .. '" /b /s')
    if handle then
        for line in handle:lines() do
            if line:find("%.lua$") then -- Nur Lua-Dateien scannen
                local file = io.open(line, "r")
                if file then
                    local content = file:read("*all")
                    file:close()

                    -- Suche nach gefährlichen Schlüsselwörtern
                    for _, keyword in ipairs(keywords) do
                        if content:find(keyword) then
                            table.insert(foundFiles, line)
                            print("^1[Gefährlich] Backdoor gefunden: " .. line .. "^0")
                            break
                        end
                    end
                else
                    print("^3[Warnung] Konnte Datei nicht lesen: " .. line .. "^0")
                end
            end
        end
        handle:close()
    end

    return foundFiles
end

-- Funktion: Loggt verdächtige Dateien in einer Log-Datei
local function logSuspiciousFiles(files)
    local logFile = io.open("backdoor_log.txt", "a")
    if logFile then
        logFile:write("\n--- Verdächtige Dateien gefunden (" .. os.date() .. ") ---\n")
        for _, file in ipairs(files) do
            logFile:write(file .. "\n")
        end
        logFile:close()
        print("^2[Info] Log-Datei erstellt: backdoor_log.txt^0")
    else
        print("^1[Fehler] Konnte Log-Datei nicht erstellen!^0")
    end
end

-- Hauptroutine: Scanne den konfigurierten Ordner
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("^3[Info] Backdoor-Scanner gestartet...^0")

        -- Überprüfe, ob der Ordner existiert
        local handle = io.popen('cd "' .. folderToScan .. '"')
        local result = handle:read("*a")
        handle:close()

        if result == "" then
            print("^1[Fehler] Der Ordner '" .. folderToScan .. "' existiert nicht!^0")
            return
        end

        -- Verzeichnis scannen
        local suspiciousFiles = scanDirectory(folderToScan)

        -- Log erstellen
        if #suspiciousFiles > 0 then
            logSuspiciousFiles(suspiciousFiles)
            print("^1[Warnung] Verdächtige Dateien gefunden! Überprüfe die Log-Datei.^0")
        else
            print("^2[Info] Keine verdächtigen Dateien gefunden!^0")
        end
    end
end)
