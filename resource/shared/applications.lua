local maxQuestionCount = 20
local maxAnswerCharacterCount = 500

function GetApplication(applicationType)
	if type(applicationType) ~= 'string' or applicationType == '' or #applicationType > 64 then return end
	local application = Config.Applications and Config.Applications[applicationType]
	if type(application) ~= 'table' or type(application.questions) ~= 'table' then return end
	return application
end

function ValidateApplicationAnswers(application, answers)
	if type(application) ~= 'table' or type(application.questions) ~= 'table' then return false end
	if type(answers) ~= 'table' then return false end

	local questionCount = math.min(#application.questions, maxQuestionCount)
	if questionCount < 1 then return false end

	for questionIndex = 1, questionCount do
		local question = application.questions[questionIndex]
		if type(question) ~= 'table' then return false end

		local answerText = answers[questionIndex]
		if question.required then
			if type(answerText) ~= 'string' or not answerText:match('%S') or #answerText > maxAnswerCharacterCount then
				return false
			end
		elseif answerText ~= nil then
			if type(answerText) ~= 'string' or #answerText > maxAnswerCharacterCount then
				return false
			end
		end
	end

	return true
end
