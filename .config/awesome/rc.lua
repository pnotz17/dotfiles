------ {{{ Required libraries }}} ------
pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local vicious = require("vicious")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

------ {{{  Error handling }}} ------
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
	title = "Oops, there were errors during startup!",
	text = awesome.startup_errors })
end
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
	if in_error then return end
	in_error = true
	naughty.notify({ preset = naughty.config.presets.critical,
	title = "Oops, an error happened!",
	text = tostring(err) })
	in_error = false
end)
end

------ {{{ Variable definitions }}} ------
beautiful.init("~/.config/awesome/default/theme.lua") 
beautiful.gap_single_client = true
beautiful.useless_gap = 1
modkey = "Mod4"
terminal = "st"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor

------ {{{ Layouts }}} ------
awful.layout.layouts = {
awful.layout.suit.tile,
awful.layout.suit.tile.left,
awful.layout.suit.tile.bottom,
awful.layout.suit.tile.top,
awful.layout.suit.floating,
awful.layout.suit.spiral.dwindle,
awful.layout.suit.max,}

------ {{{ Menu }}} ------
local menu = {}
local items = {}
local makeMenu = function()

-- Applications menu list.
menu["Programs"] = {
{ "Neovim", "st -e nvim" },
{ "Qutebrowser", "/usr/bin/qutebrowser" },
{ "Firefox", "firefox" },
{ "Gimp", "gimp" },
{ "Transmission", "transmission-gtk" },
{ "Alsa mixer", "st -e alsamixer" },
{ "Lxappearance", "lxappearance" },
{ "Htop", "st -e htop" },}

-- Exit menu
menu["Exit Menu"] = {
{ "Log out", function() awesome.quit() end },
{ "Reboot", "systemctl reboot" },
{ "Shutdown", "systemctl poweroff" }}

-- Additional items.
items[#items + 1] =  {"File Manager", "spacefm" }
items[#items + 1] =  {"Terminal", "st" }
items[#items + 1] =  {"Browser", "firefox" }
items[#items + 1] =  {"Mail Client", "st -e mutt" }
items[#items + 1] =  {"Editor", "geany" }
items[#items + 1] =  {"Kill", "xkill" }

-- Add all menus in order to the items table.
items[#items + 1] = { "Programs", menu["Programs"] }
items[#items + 1] = { "Exit Menu ", menu["Exit Menu"] }
  
-- Return the built menu.
return awful.menu({
	items = items})
end

-- Create the main menu.
mymainmenu = makeMenu()
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
menu = mymainmenu })

----- {{{ Widgets}}} -----
-- Separator widget
spr = wibox.widget.textbox('   |   ')

-- Pacman Widget
pacwidget = wibox.widget.textbox()
pacwidget_t = awful.tooltip({ objects = { pacwidget},})
vicious.register(pacwidget, vicious.widgets.pkg,

function(widget,args)
	local io = { popen = io.popen }
	local s = io.popen("checkupdates")
	local str = ''
	local i = 0
	for line in s:lines() do
	str = str .. line .. "\n"
	i = i + 1
end
	pacwidget_t:set_text(str)
	s:close()	
    return "updates: "   .. i .. ""
end , 1800, "Arch")

-- hdd widget
fswidget = wibox.widget.textbox()
vicious.register(fswidget, vicious.widgets.fs, " hdd:  ${/ used_p}%", 10)

-- Thermal widget
local function script_output()
    local f = io.popen("~/.local/bin/get_temp")
    local out = f:read("*a")
    f:close()
    return { out }
end
thermalwidget  = wibox.widget.textbox()
vicious.register(thermalwidget, script_output, "tem: $1")

--Gmail Widget
function run_script()
    local filedescriptor = io.popen("~/.local/bin/modules/sb_gmail")
    local value = filedescriptor:read()
   filedescriptor:close()
    return {value}
end
mailwidget = wibox.widget.textbox()
vicious.register(mailwidget, run_script, 'mail: $1', 20)
 
-- CPU widget
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, "cpu: $1%")

-- Memory widget
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, "mem: $1%")

-- Volume widget
volumewidget = wibox.widget.textbox()
volumewidget:set_font(beautiful.font)
volumewidget:set_align("right")

function update_volume(widget)
	local fd = io.popen("amixer sget Master")
	local status = fd:read("*all")
	fd:close()
	local volume = string.match(status, "(%d?%d?%d)%%")
	volume = string.format("% 3d", volume)
	status = string.match(status, "%[(o[^%]]*)%]")
	if string.find(status, "on", 1, true) then
	volume = volume .. "%"
	else
	volume = volume .. "婢"
end
	widget:set_markup("vol:" .. volume)
end

update_volume(volumewidget)
mytimer = timer({ timeout = 0.2 })
mytimer:connect_signal("timeout", function () update_volume(volumewidget) end)
mytimer:start()

-- Upload Speed widget
netupwidget = wibox.widget.textbox()
vicious.register(netupwidget, vicious.widgets.net, 'up:  ${enp2s0 up_mb}', 2)

-- Download Speed widget
netdownwidget = wibox.widget.textbox()
vicious.register(netdownwidget, vicious.widgets.net, 'do:  ${enp2s0 down_mb}', 2)

-- Time and Date widget
datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, "%b %d, %R")

----- {{{ Wibar}}} -----
-- Tags
awful.tag({ "01", "02", "03", "04", "05", "06", "07", "08", "09" }, s, awful.layout.layouts[1])

-- Create a wibox 
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end))
local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))
awful.screen.connect_for_each_screen(function(s)
    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
   
-- Taglist
   s.mytaglist = awful.widget.taglist {
	screen  = s,
	filter  = awful.widget.taglist.filter.all,
	buttons = taglist_buttons}

-- Tasklist
s.mytasklist = awful.widget.tasklist {
	screen  = s,
	filter  = awful.widget.tasklist.filter.currenttags,
	buttons = tasklist_buttons}

-- Create the wibox
s.mywibox = awful.wibar({ position = "top", screen = s,opacity = .90 })

-- Add widgets to the wibox
s.mywibox:setup {layout = wibox.layout.align.horizontal,

-- Left widgets
{ layout = wibox.layout.fixed.horizontal,
	mylauncher,
	s.mytaglist,
	s.mypromptbox,},

-- Middle widget
s.mytasklist, 

-- Right widgets
{ layout = wibox.layout.fixed.horizontal,
	spr,mailwidget,
	spr,pacwidget,
	spr,cpuwidget,
	spr,memwidget,
	spr,volumewidget,
	spr,netupwidget,
	spr,netdownwidget,
	spr,datewidget,
	spr,s.mylayoutbox,
	wibox.widget.systray(),},}
end)

------ {{{ Key Bindings }}} ------
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),		
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),  
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

-- My keybindings
    awful.key({ modkey, "Shift" }, "b", 
		function () awful.util.spawn("firefox") 
    end),
    awful.key({ modkey, "Shift" }, "p", 
		function () awful.util.spawn(".local/bin/dmenuexit.sh") 
    end),
    awful.key({ modkey, "Shift" }, "f", 
		function () awful.util.spawn("pcmanfm") 
    end),
    awful.key({ modkey }, "d", 
		function () awful.util.spawn("dmenu_run") 
    end),
    awful.key({ }, "F10", 
		function ()awful.util.spawn("amixer set Master toggle",
	 false) end),
	 awful.key({ }, "F11", 
		function ()awful.util.spawn("amixer set Master 2%-", 
	false) end),
	awful.key({ }, "F12", 
		function ()awful.util.spawn("amixer set Master 2%+", 
	false) end),
	awful.key({ }, "Print", 
		function () awful.util.spawn("scrot -e 'mv $f ~/pictures/screenshots/%Y-%m-%d-%H-%M-%S.png 2>/dev/null'", 
    false) end),    
    awful.key({ modkey }, "b", function ()
		for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
        end,
        {description = "toggle wibox", group = "awesome"}),
    awful.key({ modkey,           }, "]",
			function()           
		local c = client.focus                                            
			if c then c.opacity = c.opacity - 0.1 end
		end,                    
			{description = "decrease window opacity"}),
    awful.key({ modkey,           }, "[",
			function()           
		local c = client.focus                                            
			if c then c.opacity = c.opacity +0.1 end
		end,                    
			{description = "increase window opacity"})
)

----- {{{ Functions }}} ------
clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
     awful.key({ modkey, 'Control' }, 't',
        function(c)
            awful.titlebar.toggle(c)
        end,
        {description = 'toggle title bar', group = 'client'}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
                       c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}))

----- {{{ Tag bindings }}} ------
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"}))

------ {{{ Mouse bindings }}} -----
root.buttons(gears.table.join(
    --awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)))
end
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end))

----- {{{ Set Keys }}} ------
root.keys(globalkeys)

------ {{{  Rules }}} ------
 awful.rules.rules = {
{ rule = { },
	properties = { border_width = beautiful.border_width,
	border_color = beautiful.border_normal,
	focus = awful.client.focus.filter,
	raise = true,
	keys = clientkeys,
	buttons = clientbuttons,
	screen = awful.screen.preferred,
	placement = awful.placement.no_overlap+awful.placement.no_offscreen + awful.placement.centered,
	size_hints_honor = false}},

------ {{{  Floating windows }}} ------
	{ rule = { class = "mpv" },
	properties = { floating = true } },
	{ rule = { class = "gimp" },
	properties = { floating = true } },
	
	{ rule_any = {type = { "normal", "dialog" }
	}, properties = { titlebars_enabled = false }},
}

------ {{{  Signals }}} ------
client.connect_signal("manage", function (c)
if awesome.startup
and not c.size_hints.user_position
and not c.size_hints.program_position then
awful.placement.no_offscreen(c)
    end
end)

------ {{{  Add a titlebar  }}} ------
client.connect_signal("request::titlebars", function(c)
local buttons = gears.table.join(
awful.button({ }, 1, function()
	c:emit_signal("request::activate", "titlebar", {raise = true})
	awful.mouse.client.move(c)
end),
awful.button({ }, 3, function()
	c:emit_signal("request::activate", "titlebar", {raise = true})
	awful.mouse.client.resize(c)
end))

------ {{{ Titlebar Settings }}} ------
awful.titlebar(c, { size = 15}) : setup {

-- Left
	{ awful.titlebar.widget.iconwidget(c),
buttons = buttons,
layout  = wibox.layout.fixed.horizontal},

-- Middle
	{ { align  = "center",
widget = awful.titlebar.widget.titlewidget(c)},
buttons = buttons,
layout  = wibox.layout.flex.horizontal},

-- Right
	{ awful.titlebar.widget.floatingbutton (c),
awful.titlebar.widget.maximizedbutton(c),
awful.titlebar.widget.stickybutton   (c),
awful.titlebar.widget.ontopbutton    (c),
awful.titlebar.widget.closebutton    (c),
layout = wibox.layout.fixed.horizontal()},
layout = wibox.layout.align.horizontal}
end)

------ {{{  Sloppy focus  }}} ------
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
