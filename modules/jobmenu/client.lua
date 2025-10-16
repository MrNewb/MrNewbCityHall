function OpenJobMenuOptions(id, jobs)
    -- I hate how gross menus make everything look
    local jobData = Bridge.Framework.GetPlayerJobData()
    local shopMenu = {
        {
            title = locale("JobMenu.SubTitle", jobData.jobLabel, jobData.gradeLabel),
            description = locale("JobMenu.SubTitleDescription"),
            icon = locale("JobMenu.SubTitleIcon"),
        },
    }
    for k, v in pairs(jobs) do
        table.insert(shopMenu, {
            title = locale("JobMenu.SubTitleOption", k),
            icon = locale("JobMenu.SubTitleIcon"),
            onSelect = function()
                TriggerServerEvent('MrNewbCityHall:Server:SetJob', id, k)
            end,
        }
    )
    end
    local menuID = Bridge.Ids.Random(nil, 10)
    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("JobMenu.MenuTitle"), options = shopMenu }, false)
end