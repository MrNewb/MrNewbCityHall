MAX_QUESTION_COUNT = 20
local maxAnswerCharacterCount = 500

function GetApplication(applicationType)
	if type(applicationType) ~= 'string' or #applicationType > 64 then return end
	return Config.Applications[applicationType]
end

function ValidateApplicationAnswers(application, answers)
	if type(answers) ~= 'table' then return false end

	local questionCount = math.min(#application.questions, MAX_QUESTION_COUNT)
	if questionCount < 1 then return false end

	for questionIndex = 1, questionCount do
		local question = application.questions[questionIndex]

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
