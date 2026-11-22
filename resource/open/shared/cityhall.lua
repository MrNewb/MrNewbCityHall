--		___  ___       _   _                  _      _____              _         _
--		|  \/  |      | \ | |                | |    /  ___|            (_)       | |
--		| .  . | _ __ |  \| |  ___ __      __| |__  \ `--.   ___  _ __  _  _ __  | |_  ___
--		| |\/| || '__|| . ` | / _ \\ \ /\ / /| '_ \  `--. \ / __|| '__|| || '_ \ | __|/ __|
--		| |  | || |   | |\  ||  __/ \ V  V / | |_) |/\__/ /| (__ | |   | || |_) || |_ \__ \
--		\_|  |_/|_|   \_| \_/ \___|  \_/\_/  |_.__/ \____/  \___||_|   |_|| .__/  \__||___/
--									          							  | |
--									          							  |_|
--
--		  Need support? Join our Discord server for help: https://discord.gg/mrnewbscripts
--		  If you need help with configuration or have any questions, please do not hesitate to ask.
--		  Docs Are Always Available At -- https://mrnewb.github.io/docs/
--        For paid scripts get them here :) https://mrnewbscripts.tebex.io/


Config = Config or {}

Config.IdCardPrice = 100
Config.IdCardItem = 'id_card'
Config.InteractDistance = 5.0
Config.ApplicationCooldown = 60

Config.AvailableJobs = {
    --['police'] = 1,
    --['sheriff'] = 1,
    --['ambulance'] = 1,
    --['mechanic'] = 1,
    ['bus'] = 0,
    ['taxi'] = 0,
}

Config.CityHallLocations = {
    ['Job Center'] = {
        location = vector4(-267.7597, -959.0208, 30.2231, 206.4160),
        model = 's_m_y_hwaycop_01',
        availableJobs = Config.AvailableJobs,
        blipData = {
            sprite = 419,
            color = 0,
            scale = 0.8,
            label = 'City Hall',
        },
    },
}
