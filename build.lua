#!/usr/bin/env lua

---------------------
-- End of settings --
---------------------

local common = require "build_tools.lua.common"

local message, abort = common.build_rom("sonic", "s1built", "", "-p=FF", false, "https://github.com/sonicretro/s1disasm")

if message then
	exit_code = false
end

if abort then
	os.exit(exit_code, true)
end

-- Append symbol table to the ROM.
local extra_tools = common.find_tools("debug symbol generator", "https://github.com/vladikcomper/md-modules", "https://github.com/sonicretro/s1disasm", "convsym")

os.execute(extra_tools.convsym .. " sonic.lst s1built.bin -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a")

-- Correct the ROM's header with a proper checksum and end-of-ROM value.
common.fix_header("s1built.bin")

os.exit(exit_code, false)
