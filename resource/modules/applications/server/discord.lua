local queuedApplicationLogs = {}
local flushIsScheduled = false
local botAvatarUrl = 'https://avatars.githubusercontent.com/u/47620135?v=4&size=64'

local function isDiscordWebhookUrl(webhookUrl)
	return webhookUrl:match('^https://discord%.com/api/webhooks/') or webhookUrl:match('^https://discordapp%.com/api/webhooks/') or webhookUrl:match('^https://ptb%.discord%.com/api/webhooks/') or webhookUrl:match('^https://canary%.discord%.com/api/webhooks/')
end

local function sanitizeAnswerText(answer, maxLength)
	local cleanedText = (answer or ''):gsub('%s+', ' '):gsub('^ ', ''):gsub(' $', '')
	if cleanedText == '' then return locale('Discord.NoResponse') end
	if #cleanedText > maxLength then cleanedText = cleanedText:sub(1, maxLength - 3) .. '...' end
	return cleanedText
end

local function buildAnswerComponents(application, answers)
	local questionCount = math.min(#application.questions, MAX_QUESTION_COUNT)
	local maxLength = math.min(500, 2600 // questionCount)
	local components = {}

	for questionIndex = 1, questionCount do
		local question = application.questions[questionIndex]
		local requiredTag = question.required and locale('Discord.Required') or locale('Discord.Optional')
		components[#components + 1] = {
			type = 10,
			content = ('**%d. %s**%s\n> %s'):format(questionIndex, question.question, requiredTag, sanitizeAnswerText(answers[questionIndex], maxLength)),
		}
	end

	return components
end

local function buildApplicationMessage(applicationLog, application)
	local jobTitle = applicationLog.applicationType:gsub('^%l', string.upper):gsub('_', ' ')
	local containerComponents = {
		{
			type = 9,
			components = {
				{ type = 10, content = ('## %s'):format(locale('Discord.NewApplication', jobTitle)) },
				{ type = 10, content = ('-# %s'):format(locale('Discord.ApplicationSubmitted')) },
			},
			accessory = { type = 11, media = { url = botAvatarUrl } },
		},
		{ type = 14, divider = true, spacing = 2 },
		{ type = 10, content = ('### %s\n%s'):format(locale('Discord.AppInfo'), locale('Discord.ApplicantInfo', applicationLog.characterName, applicationLog.identifier)) },
		{ type = 14, divider = true, spacing = 2 },
		{ type = 10, content = ('### %s'):format(locale('Discord.AppResp')) },
	}

	for _, component in ipairs(buildAnswerComponents(application, applicationLog.answers)) do
		containerComponents[#containerComponents + 1] = component
	end

	containerComponents[#containerComponents + 1] = { type = 14, divider = true, spacing = 1 }
	containerComponents[#containerComponents + 1] = {
		type = 10,
		content = ('-# %s <t:%d:R>  |  %s: %s  |  %s'):format(locale('Discord.Submitted'), os.time(), locale('Discord.Status'), locale('Discord.AwaitingReview'), locale('Discord.Footer')),
	}

	return {
		username = locale('Discord.BotName'),
		avatar_url = botAvatarUrl,
		allowed_mentions = { parse = {} },
		flags = 32768,
		components = {{ type = 17, accent_color = 3447003, components = containerComponents }},
	}
end

local function sendApplicationLog(applicationLog)
	local application = GetApplication(applicationLog.applicationType)
	if not application then return end

	local separator = applicationLog.webhookUrl:find('?', 1, true) and '&' or '?'
	PerformHttpRequest(applicationLog.webhookUrl .. separator .. 'with_components=true', function(statusCode, responseText)
		if statusCode ~= 200 and statusCode ~= 204 then
			lib.print.error(('Discord webhook failed (%s): %s'):format(statusCode, responseText or ''))
		end
	end, 'POST', json.encode(buildApplicationMessage(applicationLog, application)), { ['Content-Type'] = 'application/json' })
end

local function flushQueuedApplicationLogs()
	local logsToSend = queuedApplicationLogs
	queuedApplicationLogs = {}
	flushIsScheduled = false

	for logIndex = 1, #logsToSend do
		sendApplicationLog(logsToSend[logIndex])
	end
end

function SubmitDiscordLog(applicationType, answers, characterName, identifier)
	local webhookUrl = Config.Webhooks[applicationType]
	if type(webhookUrl) ~= 'string' or webhookUrl == '' then return false end
	if not isDiscordWebhookUrl(webhookUrl) then
		lib.print.error(('Invalid Discord webhook URL for "%s".'):format(applicationType))
		return false
	end

	if #queuedApplicationLogs >= 25 then
		table.remove(queuedApplicationLogs, 1)
	end

	queuedApplicationLogs[#queuedApplicationLogs + 1] = {
		applicationType = applicationType,
		answers = answers,
		characterName = characterName or locale('Discord.Anonymous'),
		identifier = identifier or 'Unknown',
		webhookUrl = webhookUrl,
		timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
	}

	if flushIsScheduled then return true end
	flushIsScheduled = true
	SetTimeout(2000, flushQueuedApplicationLogs)
	return true
end
