# MrNewbCityHall

A simple and easy-to-use city hall script for FiveM that provides essential citizen services including ID card replacements, job applications, and job assignments.

## ⚠️ Development Status

**This script was made in less than an hour out of boredom and for continued practice with metatables.** I'm unsure if this is completely finished as I haven't given it a thorough once-over yet. I'm just uploading this so I can go play Battlefield 6! 🎮

## 🌟 Features

- **ID Card Replacement** - Citizens can purchase replacement ID cards
- **Job Applications** - Submit applications for various city jobs
- **Job Assignment** - Get hired for available positions
- **Discord Integration** - Job applications are sent to a specified webhook with timestamps
- **Configurable** - Easy to customize jobs, locations, and prices

## 📍 Locations

- **Job Center** - Located at City Hall with a configurable NPC
- Blip marker on the map for easy navigation
- Interactive target system for accessing services

## 🔧 Configuration

### Job Configuration
Jobs are configured in `configs/cityhall.lua` where you can:
- Add/remove available jobs
- Set job availability
- Configure ID card pricing
- Set up city hall locations

### Application System
Applications are set up in `configs/applications.lua` with:
- Customizable questions per job
- Required vs optional fields
- Job descriptions and labels

### Discord Webhooks
Configure your Discord webhook in `configs/webhooks.lua` to receive job applications with:
- Timestamp information
- Application details
- Formatted embeds

## 📦 Dependencies

- **community_bridge** - Required for integration
- **Server version 6116+**
- **OneSync enabled**

## 🚀 Installation

1. Download and place in your resources folder
2. Add `ensure MrNewbCityHall` to your server.cfg
3. Configure webhooks and job settings
4. Restart your server

## ⚙️ Framework Support

Built using the community_bridge system for compatibility.

## 🎮 Usage

1. Visit the City Hall location marked on your map
2. Interact with the NPC to access services:
   - Purchase a new ID card
   - Apply for available jobs
   - Accept job positions

## 💡 Notes

This was a quick development project focused on practicing metatable implementation. While functional, it may benefit from additional testing and refinement.

---

**Made by MrNewb** | *Quick & Dirty City Hall Solution*