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
--		  Docs Are Always Available At -- https://mrnewbs-scrips.gitbook.io/guide
--        For paid scripts get them here :) https://mrnewbscripts.tebex.io/


Config = Config or {}
Config.Applications = {
    ["police"] = {
        label = "Police Department",
        description = "Apply to become a police officer.",
        questions = {
            {
                question = "Why do you want to join the police force?",
                type = "text",
                required = true,
            },
            {
                question = "Do you have any prior experience in law enforcement?",
                type = "text",
                required = false,
            },
        },
    },
    ["mechanic"] = {
        label = "Mechanic",
        description = "Apply to become a mechanic.",
        questions = {
            {
                question = "Why do you want to become a mechanic?",
                type = "text",
                required = true,
            },
            {
                question = "Do you have any prior experience in mechanic work or automotive repair?",
                type = "text",
                required = false,
            },
        },
    },
}