function OpenJobMenu(locationId, availableJobs)
	local currentJob = bridge.framework.getPlayerJobData() or {}
	local menuOptions = {
		{
			title = locale('JobMenu.SubTitle', currentJob.jobLabel or '-', currentJob.gradeName or currentJob.grade or '-'),
			description = locale('JobMenu.SubTitleDescription'),
			icon = locale('JobMenu.SubTitleIcon'),
			disabled = true,
		},
	}

	for jobName in pairs(availableJobs) do
		menuOptions[#menuOptions + 1] = {
			title = locale('JobMenu.SubTitleOption', jobName),
			icon = locale('JobMenu.SubTitleIcon'),
			onSelect = function()
				lib.callback.await('MrNewbCityHall:server:selectedJob', false, locationId, jobName)
			end,
		}
	end

	bridge.menu.openMenu({
		id = ('mrnewb_cityhall_jobs_%s'):format(locationId:gsub('%s+', '_'):lower()),
		title = locale('JobMenu.MenuTitle'),
		options = menuOptions,
	})
end

function OpenIdCardMenu(locationId)
	bridge.menu.openMenu({
		id = ('mrnewb_cityhall_id_%s'):format(locationId:gsub('%s+', '_'):lower()),
		title = locale('IdMenu.MenuTitle'),
		options = {
			{
				title = locale('IdMenu.SubTitle'),
				description = locale('IdMenu.SubTitleDescription', Config.IdCardPrice),
				icon = locale('IdMenu.SubTitleIcon'),
				onSelect = function()
					lib.callback.await('MrNewbCityHall:server:purchasedIdCard', false, locationId)
				end,
			},
		},
	})
end

local function collectApplicationAnswers(locationId, applicationType)
	local application = GetApplication(applicationType)
	if not application then
		bridge.notifications.notify({ description = locale('Notify.InvalidApplication'), type = 'error' })
		return
	end

	if not application.questions or #application.questions < 1 then
		bridge.notifications.notify({ description = locale('Notify.NoQuestions'), type = 'error' })
		return
	end

	local questionFields = {}
	local questionCount = math.min(#application.questions, MAX_QUESTION_COUNT)
	for questionIndex = 1, questionCount do
		local question = application.questions[questionIndex]
		questionFields[questionIndex] = {
			type = 'input',
			label = question.question,
			description = '',
			placeholder = locale('ApplicationMenu.Placeholder1'),
			required = question.required == true,
		}
	end

	local applicationAnswers = bridge.inputs.inputdialog(
		locale('ApplicationMenu.ApplicationTitle', application.label),
		questionFields
	)
	if not applicationAnswers then return end

	if not ValidateApplicationAnswers(application, applicationAnswers) then
		bridge.notifications.notify({ description = locale('ApplicationMenu.NoInput'), type = 'error' })
		return
	end

	lib.callback.await('MrNewbCityHall:server:submittedApplication', false, locationId, applicationType, applicationAnswers)
end

function OpenApplicationMenu(locationId)
	local menuOptions = {
		{
			title = locale('ApplicationMenu.SubTitle'),
			description = locale('ApplicationMenu.SubTitleDescription'),
			icon = locale('ApplicationMenu.SubTitleIcon'),
			disabled = true,
		},
	}

	for applicationType, application in pairs(Config.Applications) do
		menuOptions[#menuOptions + 1] = {
			title = locale('ApplicationMenu.SubTitleOption', application.label),
			icon = locale('ApplicationMenu.SubTitleIcon'),
			onSelect = function()
				collectApplicationAnswers(locationId, applicationType)
			end,
		}
	end

	bridge.menu.openMenu({
		id = ('mrnewb_cityhall_apps_%s'):format(locationId:gsub('%s+', '_'):lower()),
		title = locale('ApplicationMenu.MenuTitle'),
		options = menuOptions,
	})
end
