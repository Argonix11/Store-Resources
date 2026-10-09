--[[
    Argonix VIP Store — FiveM server resource.

    This resource PULLS your store's purchased commands from Argonix and runs them in this
    server's console. Argonix never connects to your server; this resource reaches out to
    Argonix on a timer, using your store secret. Set it up in server.cfg:

        ensure argonix-store
        set argonix_store_secret "YOUR-STORE-SECRET"      # from your Argonix store dashboard
        add_ace resource.argonix-store command allow      # lets it run console commands

    Optional (only if your Argonix is on a different host than the default):
        set argonix_store_url "https://argonix.dev/api/store/gameserver"
]]

local baseUrl = GetConvar('argonix_store_url', 'https://argonix.dev/api/store/gameserver')
local secret = GetConvar('argonix_store_secret', '')
local defaultInterval = 30 -- seconds; overridden by the server's meta.next_check

local function headers()
    return {
        ['X-Argonix-Secret'] = secret,
        ['Content-Type'] = 'application/json',
        ['Accept'] = 'application/json',
    }
end

local function log(msg)
    print(('[argonix-store] %s'):format(msg))
end

-- Acknowledge executed command ids so Argonix marks them delivered and stops serving them.
local function acknowledge(ids)
    if #ids == 0 then return end
    local parts = {}
    for _, id in ipairs(ids) do
        parts[#parts + 1] = 'ids[]=' .. id
    end
    local url = baseUrl .. '/queue?' .. table.concat(parts, '&')
    PerformHttpRequest(url, function(status)
        if status ~= 200 then
            log(('acknowledge failed (status %s) for %d command(s)'):format(tostring(status), #ids))
        end
    end, 'DELETE', '', headers())
end

-- Fetch and run the commands waiting for this store, then acknowledge them.
local function runOfflineCommands()
    PerformHttpRequest(baseUrl .. '/queue/offline-commands', function(status, body)
        if status ~= 200 or not body then
            log(('could not fetch commands (status %s)'):format(tostring(status)))
            return
        end

        local ok, data = pcall(json.decode, body)
        if not ok or type(data) ~= 'table' or type(data.commands) ~= 'table' then
            return
        end

        local executed = {}
        for _, cmd in ipairs(data.commands) do
            if cmd.command and cmd.command ~= '' then
                ExecuteCommand(cmd.command)
                executed[#executed + 1] = cmd.id
            end
        end

        acknowledge(executed)
    end, 'GET', '', headers())
end

-- One poll cycle: ask whether to run, do it, then schedule the next check.
local function poll()
    PerformHttpRequest(baseUrl .. '/queue', function(status, body)
        local interval = defaultInterval

        if status == 200 and body then
            local ok, data = pcall(json.decode, body)
            if ok and type(data) == 'table' and type(data.meta) == 'table' then
                interval = tonumber(data.meta.next_check) or defaultInterval
                if data.meta.execute_offline then
                    runOfflineCommands()
                end
            end
        else
            log(('queue check failed (status %s) — is the secret correct?'):format(tostring(status)))
        end

        SetTimeout(math.max(5, interval) * 1000, poll)
    end, 'GET', '', headers())
end

CreateThread(function()
    if secret == '' then
        log('No secret set. Add to server.cfg:  set argonix_store_secret "your-secret"')
        return
    end
    log('started — polling ' .. baseUrl)
    poll()
end)
