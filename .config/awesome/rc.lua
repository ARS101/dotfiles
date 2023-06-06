local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.autofocus") -- Better keep it on

-- require("awful.hotkeys_popup.keys")

-- {{{ Error handling

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(_err)
		-- ARS: WTF is going on here. This doesn't make sense

		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(_err),
		})
		in_error = false
	end)
end

-- }}}

-- {{{ Variable definitions

beautiful.init("~/.config/awesome/themes/default/theme.lua")

terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
menubar.utils.terminal = terminal

-- I don't know the use of other tiling modes yet
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}

-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu

myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},

	{ "manual", terminal .. " -e man awesome" },

	{ "edit config", editor_cmd .. " " .. awesome.conffile },

	{ "restart", awesome.restart },

	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },

		{ "open terminal", terminal },
	},
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- }}}

-- {{{ Wibar

mykeyboardlayout = awful.widget.keyboardlayout()

mytextclock = wibox.widget.textclock()

-- Default config had stupid numbers all over the place
-- So I added these to make the code more readable
LEFT_MOUSE_BUTTON = 1
RIGHT_MOUSE_BUTTON = 3

-- Create a taglist actions for button in each screen on wibar
local taglist_button_actions = gears.table.join(

	awful.button({}, LEFT_MOUSE_BUTTON, function(_tag)
		_tag:view_only()
	end),

	awful.button({ modkey }, LEFT_MOUSE_BUTTON, function(_tag)
		if client.focus then
			client.focus:move_to_tag(_tag)
		end
	end),

	awful.button({}, RIGHT_MOUSE_BUTTON, awful.tag.viewtoggle),

	awful.button({ modkey }, RIGHT_MOUSE_BUTTON, function(_tag)
		if client.focus then
			client.focus:toggle_tag(_tag)
		end
	end)
)

-- Create a tasklist actions for buttons in each screen on wibar
local tasklist_button_actions = gears.table.join(awful.button({}, LEFT_MOUSE_BUTTON, function(_client)
	if _client == client.focus then
		_client.minimized = true
	else
		_client:emit_signal("request::activate", "tasklist", { raise = true })
	end
end))

local function set_wallpaper(_screen)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(_screen)
		end
		gears.wallpaper.maximized(wallpaper, _screen, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Create and connect the widgets to every screen
awful.screen.connect_for_each_screen(function(_screen)
	set_wallpaper(_screen)

	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, _screen, awful.layout.suit.tile)

	_screen.mypromptbox = awful.widget.prompt()

	_screen.mylayoutbox = awful.widget.layoutbox(_screen)

	_screen.mylayoutbox:buttons(gears.table.join(

		awful.button({}, LEFT_MOUSE_BUTTON, function()
			awful.layout.inc(1)
		end),

		awful.button({}, RIGHT_MOUSE_BUTTON, function()
			awful.layout.inc(-1)
		end)
	))

	_screen.mytaglist = awful.widget.taglist({
		screen = _screen,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_button_actions,
	})

	_screen.mytasklist = awful.widget.tasklist({
		screen = _screen,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_button_actions,
	})

	_screen.mywibox = awful.wibar({ position = "top", screen = _screen })

	-- Add widgets to the wibox
	_screen.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			mylauncher,
			_screen.mytaglist,
			_screen.mypromptbox,
		},
		_screen.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			mykeyboardlayout,
			wibox.widget.systray(),
			mytextclock,
			_screen.mylayoutbox,
		},
	})
end)

-- }}}

-- {{{ Key bindings

globalkeys = gears.table.join(

	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),

	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),

	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),

	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),

	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),

	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),

	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),

	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),

	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),

	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),

	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.02)
	end, { description = "increase master width factor", group = "layout" }),

	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.02)
	end, { description = "decrease master width factor", group = "layout" }),

	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),

	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),

	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),

	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),

	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),

	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local _client = awful.client.restore()
		-- Focus restored client
		if _client then
			_client:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	awful.key({ modkey }, "r", function()
		awful.screen.focused().mypromptbox:run()
	end, { description = "run prompt", group = "launcher" }),

	-- Menubar
	awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "launcher" }),

	-- Screenshot
	awful.key({}, "Print", function()
		os.execute("maim -s | xclip -selection clipboard -t image/png")
	end, { description = "Select screenshot to clipboard", group = "System" }),

	awful.key({ "Mod1" }, "Shift_L", function()
		os.execute("setxkbmap -layout us,ir -option grp:alt_shift_toggle")
	end, { description = "Switch keyboard layout", group = "System" }),

	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("amixer set Master 5%+", false)
	end, { description = "Volume Up", group = "System" }),

	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("amixer set Master 5%-", false)
	end, { description = "Volume Down", group = "System" })
)

clientkeys = gears.table.join(

	awful.key({ modkey }, "f", function(_client)
		_client.fullscreen = not _client.fullscreen
		_client:raise()
	end, { description = "toggle fullscreen", group = "client" }),

	awful.key({ modkey, "Shift" }, "c", function(_client)
		_client:kill()
	end, { description = "close", group = "client" }),

	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),

	awful.key({ modkey, "Control" }, "Return", function(_client)
		_client:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),

	awful.key({ modkey }, "o", function(_client)
		_client:move_to_screen()
	end, { description = "move to screen", group = "client" }),

	awful.key({ modkey }, "t", function(_client)
		_client.ontop = not _client.ontop
	end, { description = "toggle keep on top", group = "client" }),

	awful.key({ modkey }, "n", function(_client)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		_client.minimized = true
	end, { description = "minimize", group = "client" }),

	awful.key({ modkey }, "m", function(_client)
		_client.maximized = not _client.maximized
		_client:raise()
	end, { description = "(un)maximize", group = "client" }),

	awful.key({ modkey, "Control" }, "m", function(_client)
		_client.maximized_vertical = not _client.maximized_vertical
		_client:raise()
	end, { description = "(un)maximize vertically", group = "client" }),

	awful.key({ modkey, "Shift" }, "m", function(_client)
		_client.maximized_horizontal = not _client.maximized_horizontal
		_client:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(

		globalkeys,

		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),

		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),

		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),

		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

-- Buttons for action on clients upon click
clientbuttons = gears.table.join(

	awful.button({}, LEFT_MOUSE_BUTTON, function(_client)
		_client:emit_signal("request::activate", "mouse_click", { raise = true })
	end),

	awful.button({ modkey }, LEFT_MOUSE_BUTTON, function(_client)
		_client:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(_client)
	end),

	awful.button({ modkey }, RIGHT_MOUSE_BUTTON, function(_client)
		_client:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(_client)
	end)
)

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

-- Rules to apply to new clients (through the "manage" signal).
awful.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
				"Media viewer", -- For Telegram image and video viewing
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	-- { rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = true } },

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
--
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(_client)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	if not awesome.startup then
		awful.client.setslave(_client)
	end

	if awesome.startup and not _client.size_hints.user_position and not _client.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(_client)
		-- If a window is partially or completely off-screen after a monitor configuration change
		-- it can become inaccessible to the user. So we write this code to prevent that
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(_client)
	-- buttons for the titlebar
	local buttons = gears.table.join(

		awful.button({}, LEFT_MOUSE_BUTTON, function()
			_client:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(_client)
		end),

		awful.button({}, RIGHT_MOUSE_BUTTON, function()
			_client:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(_client)
		end)
	)

	awful.titlebar(_client):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(_client),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(_client),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(_client),
			awful.titlebar.widget.maximizedbutton(_client),
			awful.titlebar.widget.stickybutton(_client),
			awful.titlebar.widget.ontopbutton(_client),
			awful.titlebar.widget.closebutton(_client),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

client.connect_signal("focus", function(_client)
	_client.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(_client)
	_client.border_color = beautiful.border_normal
end)

-- }}}
