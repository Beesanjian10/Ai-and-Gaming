-- highscore.lua
--
-- MODERN LUA FEATURE: to-be-closed variables (Lua 5.4).
--   local file <close> = io.open(...)
-- When `file` goes out of scope (normal return OR error) Lua automatically calls
-- its __close metamethod, which closes the file. No manual file:close() needed.
--
-- NOTE: LÖVE runs on LuaJIT (Lua 5.1 syntax), where `<close>` is a syntax error.
-- So the Lua 5.4 version below is compiled with load(): on Lua 5.4 (`lua main.lua`)
-- it is used as-is, and under LÖVE we fall back to an equivalent pcall version.
local HighScore = {}

local FILENAME = "highscore.txt"

-- The assignment's version, as a string so LuaJIT doesn't choke on the syntax.
local lua54_source = [[
local FILENAME = ...
local impl = {}

function impl.save(score)
  local file <close> = io.open(FILENAME, "w")
  if file then
    file:write(tostring(score))
    -- File automatically closes even if an error occurs
  end
end

function impl.load()
  local file <close> = io.open(FILENAME, "r")
  if file then
    local content = file:read("a")
    return tonumber(content) or 0
  end
  return 0
end

return impl
]]

local compile = loadstring or load
local chunk = compile(lua54_source, "highscore_lua54")
local impl

if chunk then
  impl = chunk(FILENAME) -- Lua 5.4: real to-be-closed variables
else
  -- LuaJIT / Lua 5.1 fallback: same behaviour, closing the file by hand.
  impl = {}

  function impl.save(score)
    local file = io.open(FILENAME, "w")
    if file then
      pcall(file.write, file, tostring(score))
      file:close()
    end
  end

  function impl.load()
    local file = io.open(FILENAME, "r")
    if file then
      local content = file:read("*a")
      file:close()
      return tonumber(content) or 0
    end
    return 0
  end
end

function HighScore:save(score)
  impl.save(score)
end

function HighScore:load()
  return impl.load()
end

return HighScore
