module("L_GMailAtom1", package.seeall)

require("lxp/lom")

local PLUGIN_VERSION = "0.5"
local ATOM_SERV = "urn:nodecentral-net:serviceId:GMailAtom1"
local SEC_SERV = "urn:micasaverde-com:serviceId:SecuritySensor1"
local HA_SERV = "urn:micasaverde-com:serviceId:HaDevice1"
local PLUGIN_STATUS = nil
local DEBUG_MODE = nil
local DISPLAY_LABEL = nil
local DISPLAY_COUNT = nil
local DEFAULT_LABELS = nil
local CUSTOM_LABELS = nil
local DEVICE = nil
local USERNAME = nil
local PASSWORD = nil
local LABELS = nil


local function log(text, level)
	local construct = "ATOM> " .. text
	local message = construct:gsub("ATOM> debug:", "ATOM debug>")
	luup.log(message, (level or 1))
end

function debug(text)
	local livedebug = luup.variable_get(ATOM_SERV, "DEBUG_MODE", tonumber(DEVICE))
	if (livedebug == true or livedebug == "true") then
		log("debug " .. text, 50)
	end
end

local function trim(s)
	return s:match'^%s*(.*)'
end

local function Split(string, seperator)
    result = {};
    for match in (string..seperator):gmatch("(.-)"..seperator) do
        table.insert(result, match);
    end 
    --print (result)
	return result
end

local function checkVariable(sid, varname, dev, default)
	local v = luup.variable_get(sid, varname, dev)
	--luup.log("existing ? = "..tostring(v))
	if (v == nil) then
		luup.variable_set(sid, varname, default or "", dev)
		debug(""..varname.." variable created, with default val = "..tostring(default))
	end
	return v
end

local function processDateTime(dateTime)
	--local latest = 0
	for year, month, day, hour, min, sec in string.gmatch(dateTime, "(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)Z") do
		local t = {}
		t.year = year; t.month = month; t.day = day; t.hour = hour; t.min = min; t.sec = sec
		local timestamp = os.time(t)
		return timestamp
	end
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

local function getAtomData(LABEL)
	debug("Getting unread Atom mails for " .. LABEL)
	
	local CurlCommand = "curl -u " .. USERNAME .. ":" .. PASSWORD .. " --silent https://mail.google.com/mail/feed/atom/" ..LABEL
	debug("Curl command sent "..CurlCommand)
	
	local handle = io.popen(CurlCommand)
	local XMLdata = handle:read("*a")
	handle:close()
			
	if (XMLdata) then
		debug("Received XML response " .. XMLdata)
		return XMLdata
	else
		luup.variable_set(ATOM_SERV, "ICON", 2, DEVICE)
		luup.variable_set(ATOM_SERV, "PLUGIN_STATUS", "ERROR: Debug and check logs 2/2", DEVICE)
		log("ERROR: Received empty response")
	end
end
	
function NC_ATOMrefreshCustomLabels(LABEL)
	log("Polling GMail Atom feed for ["..LABEL.."]", 50)
	
	for _, labval in pairs(Split(LABEL, ",")) do
		debug("Processing ["..labval.."] Atom label..")
		labval = trim(labval)
		--local timestamp = os.time()
		local atomXMLdata = getAtomData(labval)
		local tabxml = lxp.lom.parse (atomXMLdata)
		local labelCount = tabxml[3][1] or 9999 -- 1
		debug("labelCount = " .. tostring(labelCount))
		if tostring(labelCount) ~= "0" then
			local dateTime = tabxml[6][5][1] or "1974-05-26T10:10:10Z"-- e.g. 2022-01-31T10:33:32Z
			debug("dateTime = " .. tostring(dateTime))
			local dateTime = processDateTime(dateTime)
			debug("Timestamp = " .. dateTime)
			local display = os.date('%Y-%m-%d %H:%M:%S', dateTime)
			debug("Display = " .. display)
			local displabval = luup.variable_get(ATOM_SERV, "DISPLAY_LABEL", DEVICE)
			--local latest = timestamp
			luup.variable_set(ATOM_SERV, labval, labval, DEVICE)
			luup.variable_set(ATOM_SERV, labval .."Count", labelCount, DEVICE)
			luup.variable_set(ATOM_SERV, labval .."Timestamp", dateTime, DEVICE)
			luup.variable_set(ATOM_SERV, labval .."Display", display, DEVICE)
			debug("UI = [" .. labval.."] vs ["..displabval.."]")
			if labval == displabval then 
				luup.variable_set(ATOM_SERV,"DISPLAY_COUNT", labelCount, DEVICE)
			end
		else
			local timestamp = os.time()
			local display = os.date('%Y-%m-%d %H:%M:%S', timestamp)
			luup.variable_set(ATOM_SERV, labval .."Count", 0, DEVICE)
			luup.variable_set(ATOM_SERV, labval .."Timestamp", timestamp, DEVICE)
			luup.variable_set(ATOM_SERV, labval .."Display", display, DEVICE)
		end
		luup.call_delay("NC_ATOMrefreshCustomLabels", 60, LABEL)
	end
end
		

local function checkSetUp()
	log("Checking GMail Atom Atributes", 50)
	
	USERNAME = luup.variable_get(ATOM_SERV, "USERNAME", DEVICE)
	PASSWORD = luup.variable_get(ATOM_SERV, "PASSWORD", DEVICE)
	LABELS = luup.variable_get(ATOM_SERV, "CUSTOM_LABELS", DEVICE)
	
	debug("USERNAME " ..tostring(USERNAME))
	debug("PASSWORD " ..tostring(PASSWORD))
	debug("CUSTOM_LABELS " ..tostring(LABELS))
	
	if USERNAME == "" or PASSWORD == "" or LABELS == "" or 
		USERNAME == nil or PASSWORD == nil or LABELS == nil then
		
		luup.variable_set(ATOM_SERV, "PLUGIN_STATUS", "USER/PASS/LABEL Incomplete 1/2", DEVICE)
		luup.variable_set(ATOM_SERV, "ICON", 2, DEVICE)
		log("ERROR: [USER/PASS/LABEL] incomplete")
	else
		luup.variable_set(ATOM_SERV, "PLUGIN_STATUS", "USER/PASS/LABEL Found 2/2", DEVICE)
		luup.variable_set(ATOM_SERV, "ICON", 1, DEVICE)
		log("SUCCESS: [USER/PASS/LABEL] all present")
		NC_ATOMrefreshCustomLabels(LABELS)
	end
end

local function globaliseTheseFunctions()
	log("Registering Global(_G) ATOM Functions")
	
   -- Stick all the luup.call_delay and time targets into the Global namespace table.
   -- Otherwise they are not visible to luup.call_delay and timer and won't be executed.
   -- I always prefix them with 'NC_' to help avoid Global namespace collisions.

   _G["NC_ATOMrefreshCustomLabels"] = NC_ATOMrefreshCustomLabels
   -- _G["NC_ATOMrefreshDefaultLabels"] = NC_ATOMrefreshDefaultLabels

end
	
function GMailAtomStartup(lul_device)	
	log("Loading GMail ATOM Defaults", 50)
	
	DEVICE = lul_device
	
	checkVariable(ATOM_SERV, "PLUGIN_VERSION", DEVICE, PLUGIN_VERSION)
	checkVariable(ATOM_SERV, "PLUGIN_STATUS", DEVICE, "Loading Atom Defaults 1/2")
	checkVariable(ATOM_SERV, "CUSTOM_LABELS", DEVICE, "")
	checkVariable(ATOM_SERV, "DISPLAY_LABEL", DEVICE, "Your label")
	checkVariable(ATOM_SERV, "DISPLAY_COUNT", DEVICE, 0)
	checkVariable(ATOM_SERV, "DEBUG_MODE", DEVICE, "false")
	checkVariable(ATOM_SERV, "USERNAME", DEVICE, "")
	checkVariable(ATOM_SERV, "PASSWORD", DEVICE, "")
	--checkVariable(ATOM_SERV, "DEFAULT_LABELS", DEVICE, "")
	checkVariable(ATOM_SERV, "ICON", DEVICE, 2)
	
	globaliseTheseFunctions()
	checkSetUp()
	
end