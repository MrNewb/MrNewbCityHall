function OpenIdCardMenuOptions(id)
    local shopMenu = {
        {
            title = locale("IdMenu.SubTitle"),
            description = locale("IdMenu.SubTitleDescription", Config.IdCardPrice),
            icon = locale("IdMenu.SubTitleIcon"),
            onSelect = function()
                TriggerServerEvent('MrNewbCityHall:Server:PurchaseIdCard', id)
            end,
        },
    }
    local menuID = Bridge.Ids.Random(nil, 10)
    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("IdMenu.MenuTitle"), options = shopMenu }, false)
end