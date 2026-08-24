local queuedApplicationLogs = {}
local flushIsScheduled = false
local botAvatarUrl = 'https://avatars.githubusercontent.com/u/47620135?v=4&size=64'

local function isDiscordWebhookUrl(webhookUrl)
	return webhookUrl:match('^https://discord%.com/api/webhooks/') or webhookUrl:match('^https://discordapp%.com/api/webhooks/') or webhookUrl:match('^https://ptb%.discord%.com/api/webhooks/') or webhookUrl:match('^https://canary%.discord%.com/api/webhooks/')
end

local function sanitizeAnswerText(answer)
	if type(answer) ~= 'string' then return 'No response provided' end

	local cleanedText = answer:gsub('[\r\n]+', ' '):gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
	if cleanedText == '' then return 'No response provided' end
	if #cleanedText > 500 then cleanedText = cleanedText:sub(1, 500) end
	return cleanedText
end

local function formatApplicationAnswers(applicationType, answers)
	local application = GetApplication(applicationType)
	if not application or type(application.questions) ~= 'table' then
		return 'No questions configured for this application type'
	end

	local questionCount = math.min(#application.questions, 20)
	local answerLines = {}
	for questionIndex = 1, questionCount do
		local question = application.questions[questionIndex]
		local requiredTag = question.required and locale('Discord.Required') or locale('Discord.Optional')
		answerLines[#answerLines + 1] = ('%s%s\n%s'):format(locale('Discord.Question', question.question), requiredTag, sanitizeAnswerText(answers[questionIndex]))
	end

	return table.concat(answerLines, '\n\n')
end

local function sendApplicationLog(applicationLog)
	local responseBody = formatApplicationAnswers(applicationLog.applicationType, applicationLog.answers)
	if #responseBody > 1024 then
		responseBody = responseBody:sub(1, 1000) .. '\n\n*Response was too long and has been shortened...*'
	end

	local jobTitle = applicationLog.applicationType:gsub('^%l', string.upper):gsub('_', ' ')

	PerformHttpRequest(applicationLog.webhookUrl, function(statusCode, responseText)
		if statusCode ~= 200 and statusCode ~= 204 then
			lib.print.error(('Discord webhook failed (%s): %s'):format(statusCode, responseText or ''))
		end
	end, 'POST', json.encode({
		username = 'City Hall Applications',
		avatar_url = botAvatarUrl,
		allowed_mentions = { parse = {} },
		embeds = {{
			color = 3447003,
			title = locale('Discord.NewApplication', jobTitle),
			description = locale('Discord.ApplicationSubmitted'),
			thumbnail = { url = botAvatarUrl },
			fields = {
				{ name = locale('Discord.AppInfo'), value = ('Name: %s | Player ID: %s'):format(applicationLog.characterName, applicationLog.identifier) },
				{ name = locale('Discord.AppResp'), value = responseBody },
				{ name = locale('Discord.Submitted'), value = ('<t:%d:R>'):format(os.time()), inline = true },
				{ name = locale('Discord.Status'), value = locale('Discord.AwaitingReview'), inline = true },
			},
			timestamp = applicationLog.timestamp,
			footer = { text = 'City Hall Application System', icon_url = botAvatarUrl },
		}},
	}), { ['Content-Type'] = 'application/json' })
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
	if type(applicationType) ~= 'string' or applicationType == '' then return false end
	if type(answers) ~= 'table' then return false end
	if type(Config.Webhooks) ~= 'table' then return false end

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
		characterName = characterName or 'Anonymous Applicant',
		identifier = identifier or 'Unknown',
		webhookUrl = webhookUrl,
		timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
	}

	if flushIsScheduled then return true end
	flushIsScheduled = true
	SetTimeout(2000, flushQueuedApplicationLogs)
	return true
end
