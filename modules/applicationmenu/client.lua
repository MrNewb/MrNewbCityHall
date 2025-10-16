function ApplicationInputs(id, appType)
    local availableApps = Config.Applications[appType]
    if not availableApps then return false, Bridge.Notify.SendNotify(locale("Notify.InvalidApplication"), "error", 5000) end
    local length = #availableApps.questions
    if length < 1 then return false, Bridge.Notify.SendNotify(locale("Notify.NoQuestions"), "error", 5000) end
    local data = {}
    for k, v in pairs(availableApps.questions) do
        table.insert(data, {
            type = "input",
            label = v.question,
            description = "",
            placeholder = locale("ApplicationMenu.Placeholder1"),
            required = v.required or false,
        })
    end
    local inputData = Bridge.Input.Open(locale("ApplicationMenu.ApplicationTitle", appType), data, false, locale("ApplicationMenu.Submit"))
    if not inputData or not inputData[length] then return false, Bridge.Notify.SendNotify(locale("ApplicationMenu.NoInput"), "error", 5000) end
    TriggerServerEvent("MrNewbCityHall:SubmitApplication", id, appType, inputData)
end

function OpenApplicationMenuOptions(id)
    local availableApps = Config.Applications
    local shopMenu = {
        {
            title = locale("ApplicationMenu.SubTitle"),
            description = locale("ApplicationMenu.SubTitleDescription"),
            icon = locale("ApplicationMenu.SubTitleIcon"),
        },
    }
    for k, v in pairs(availableApps) do
        table.insert(shopMenu, {
            title = locale("ApplicationMenu.SubTitleOption", k),
            icon = locale("ApplicationMenu.SubTitleIcon"),
            onSelect = function()
                ApplicationInputs(id, k)
            end,
        }
    )
    end
    local menuID = Bridge.Ids.Random(nil, 10)
    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("ApplicationMenu.MenuTitle"), options = shopMenu }, false)
end