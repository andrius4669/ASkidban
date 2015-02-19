#!/usr/bin/env lua

pcall(function() require("debugger")() end)

assert(pcall(function() loadstring"goto label ::label::"() end), "Lua version 5.2 or luajit is required")
bit32 = bit32 or bit or require"bit"

local lfs = require"lfs"

local oldcd = lfs.currentdir()
local script, sep = arg[0], package.config:sub(1, 1)
lfs.chdir(script:match(".*%" .. sep))

local fp, L = require"kblibs.fp", require"kblibs.lambda"
local map = fp.map


geoipfn = oldcd .. sep .. "GeoIPASNum2.csv"
commit = false
force = false

local function getarg(option)
  assert(#arg > 0, "Missing argument for " .. option)
  return table.remove(arg, 1)
end
local options = {
  h = function()
    print[[
Usage: ASkidban {[-h] | [-g <GeoIPASNum2.csv file>]... {hits | decide | compile}}

Options:
	-h		show help
	-g <file>	GeoIP ASnum database
	-c		commit changes to git
	-f		force (refresh cached IP ranges)

Commands:
	hits		import IP hits from stdin to seed AS numbers list
	decide		tag AS numbers
	compile		fetch IP ranges associated with the AS numbers
]]
  end,
  g = function() geoipfn = getarg"-g" end,
  c = function() commit = true end,
  f = function() force = true end,
}
local commands = map.vm(L"_, loadfile(_ .. '.lua')", "hits", "decide", "compile")

local cmd
while #arg > 0 do
  local a = table.remove(arg, 1)
  if a:sub(1, 1) == '-' then assert(options[a:sub(2)], "Unknown option " .. a)()
  else cmd = assert(commands[a:match("([^%.]+)%.?l?u?a?")], "Unknown command " .. a) end
end


db = require"kblibs.db".load"db"
print("Database check succeeded.")
return cmd and cmd()
