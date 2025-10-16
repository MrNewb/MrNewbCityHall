local pendingLogs = {}
local sendTimer = nil

local function formatApplicationAnswers(answers, appType)
    if type(answers) ~= "table" then
        return tostring(answers) or "No application data provided"
    end

    local appConfig = Config and Config.Applications and Config.Applications[appType]
    if not appConfig or not appConfig.questions then
        local formatted = {}
        for i, answer in ipairs(answers) do
            table.insert(formatted, string.format("%s: %s", locale("Discord.QuestionNumber", i), tostring(answer)))
        end
        return #formatted > 0 and table.concat(formatted, "\n\n") or "No questions configured for this application type"
    end

    local formatted = {}
    for i, question in ipairs(appConfig.questions) do
        local answer = answers[i] or "No response provided"
        local requiredIndicator = question.required and locale("Discord.Required") or locale("Discord.Optional")

        table.insert(formatted, string.format("%s%s\n%s", locale("Discord.Question", question.question), requiredIndicator, tostring(answer)))
    end

    return #formatted > 0 and table.concat(formatted, "\n\n") or "No application responses provided"
end

local function sendBufferedLogsToDiscord()
    if #pendingLogs == 0 then
        sendTimer = nil
        return
    end

    local logsByWebhook = {}
    for _, log in ipairs(pendingLogs) do
        if not logsByWebhook[log.hookUrl] then
            logsByWebhook[log.hookUrl] = {}
        end
        table.insert(logsByWebhook[log.hookUrl], log)
    end

    for hookUrl, logs in pairs(logsByWebhook) do
        local embeds = {}
        for _, log in ipairs(logs) do
            local formattedMessage = formatApplicationAnswers(log.message, log.appType)
            local jobTitle = log.appType:gsub("^%l", string.upper):gsub("_", " ")
            table.insert(embeds, {
                color = 3447003,
                title = locale("Discord.NewApplication", jobTitle),
                description = locale("Discord.ApplicationSubmitted"),
                thumbnail = { url = "https://avatars.githubusercontent.com/u/47620135?v=4&size=64" },
                fields = {
                    {
                        name = locale("Discord.AppInfo"),
                        value = string.format("Name: %s | Player ID: %s", log.sender, log.identifier),
                        inline = false
                    },
                    {
                        name = locale("Discord.AppResp"),
                        value = string.len(formattedMessage) > 1024 and 
                               (string.sub(formattedMessage, 1, 1000) .. "\n\n*Response was too long and has been shortened...*") or 
                               formattedMessage,
                        inline = false
                    },
                    {
                        name = locale("Discord.Submitted"),
                        value = string.format("<t:%d:R>", os.time()),
                        inline = true
                    },
                    {
                        name = locale("Discord.Status"),
                        value = locale("Discord.AwaitingReview"),
                        inline = true
                    }
                },
                timestamp = log.timestamp,
                footer = {
                    text = "City Hall Application System",
                    icon_url = "https://avatars.githubusercontent.com/u/47620135?v=4&size=64"
                }
            })
        end

        local maxEmbedsPerMessage = 10
        for i = 1, #embeds, maxEmbedsPerMessage do
            local batch = {}
            for j = i, math.min(i + maxEmbedsPerMessage - 1, #embeds) do
                table.insert(batch, embeds[j])
            end
            PerformHttpRequest(hookUrl, function(err, text, headers)
                if err ~= 200 and err ~= 204 then
                    print(("[City Hall] Oops! Couldn't send the application notification to Discord. Error %s: %s"):format(err, text or ""))
                end
            end, 'POST', json.encode({
                username = "City Hall Applications",
                avatar_url = 'https://avatars.githubusercontent.com/u/47620135?v=4&size=64',
                embeds = batch
            }), { ['Content-Type'] = 'application/json' })
        end
    end

    pendingLogs = {}
    sendTimer = nil
end

local function queueLogForDiscord(hookUrl, message, sender, identifier, appType)
    if #pendingLogs >= 25 then
        print("[City Hall] Wow, we're getting lots of applications! Had to remove the oldest one to make room.")
        table.remove(pendingLogs, 1)
    end

    table.insert(pendingLogs, {
        message = message,
        appType = appType or "general",
        sender = sender or "Anonymous Applicant",
        identifier = identifier or "Unknown",
        resource = "MrNewbCityHall",
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        hookUrl = hookUrl
    })

    if not sendTimer then
        sendTimer = true
        SetTimeout(2000, function()
            sendBufferedLogsToDiscord()
        end)
    end
end

function SubmitDiscordLog(appType, message, sender, identifier)
    if not appType or type(appType) ~= "string" then return false, print("[City Hall] Hmm, something's wrong with the application type. Please check the configuration.") end

    if not message then return false, print("[City Hall] No application data was provided. Can't process an empty application!") end

    if not Config or not Config.Webhooks then return false, print("[City Hall] Discord webhooks aren't configured yet. Please set them up in the config.") end

    local hookUrl = Config.Webhooks[appType]
    if not hookUrl or hookUrl == "" then return false, print(string.format("[City Hall] No Discord webhook is set up for '%s' applications. Please add one to the config.", appType)) end

    if not string.match(hookUrl, "^https://discord%.com/api/webhooks/") then return false, print(string.format("[City Hall] The Discord webhook URL for '%s' applications doesn't look right. Please check the config.", appType)) end

    queueLogForDiscord(hookUrl, message, sender, identifier, appType)
    return true
end