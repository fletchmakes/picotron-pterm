--[[pod_format="raw",created="2024-03-28 16:28:33",modified="2024-03-31 01:28:44",revision=88]]
-- pterm.lua
-- fletch
-- a helpful utility that acts like a terminal but with helper functions for controlled printing

--          _                      
--         | |                     
--    _ __ | |_ ___ _ __ _ __ ___  
--   | '_ \| __/ _ \ '__| '_ ` _ \ 
--   | |_) | ||  __/ |  | | | | | |
--   | .__/ \__\___|_|  |_| |_| |_|
--   | |                           
--   |_|            
local VERSION = "0.0.1"

-- easy copy/paste command for convenience during testing
-- create_process("/documents/projects/pterm.lua", {window_attribs={show_in_workspace=true}})

-- bounds of the lil_mono.font characters
local CWIDTH = 5
local CHEIGHT = 8

-- how many rows and columns should our terminal window be
-- TODO: read these from the env().argv
local ROWS = 20
local COLS = 50

-- keep track of our current location and colors
local CURSOR = {x=0,y=0,fcol=7,bcol=0,col=14}

-- controls whether or not we are currently accepting input from the user
local IS_INPUT = false

-- ---------------------------
-- LIFE CYCLE
-- ---------------------------

function _init()
	-- poke the mono font into the main font slot
	poke(0x4000, get(fetch("/system/fonts/lil_mono.font")))
	
	-- create a window that has our specific number of rows/columns to print on
	window(CWIDTH*COLS,CHEIGHT*ROWS)
	
	-- print the logo and initial prompt
	welcome_msg()
	
	-- store the last date() call
	d = date()
end

function _update()
	-- blink the cursor if input is on
	if IS_INPUT then
		if d ~= date() then
			-- TODO: make blink every 0.5 second
			CURSOR.col = abs(CURSOR.col - 14) -- blink on and off
			d = date()
		end
	else
		CURSOR.col = 0
	end
end

function _draw()
	-- draw the cursor location
	local printx,printy = CURSOR.x*CWIDTH,CURSOR.y*CHEIGHT 
	rectfill(printx,printy,printx+CWIDTH,printy+CHEIGHT,CURSOR.col)
end

-- ---------------------------
-- PRINTING FUNCTIONS
-- ---------------------------

-- pprint - print text to a pterm.lua terminal
-- param: text - the text to print
-- param: fcol? - the foreground color (text color)
-- param: bcol? - the background color
-- param: x? - the column on which to print
-- param: y? - the row on which to print
function pprint(text, fcol, bcol, x, y)
	-- TODO: account for text-wrapping (ew)
	
	-- text is a required parameter
	if text == nil then return end

	-- get our default values
	fcol = fcol and fcol or CURSOR.fcol
	bcol = bcol and bcol or CURSOR.bcol
	x = x and x or CURSOR.x
	y = y and y or CURSOR.y
	
	-- perform the printing
	local printx, printy = x*CWIDTH, y*CHEIGHT
	local text_len = #text*CWIDTH-1
	rectfill(printx,printy,printx+text_len,printy+CHEIGHT-1,bcol)
	print(text,printx,printy,fcol)
	
	-- move the cursor
	CURSOR.x = x+#text+1
	CURSOR.y = y
end

-- pcursor - change the pterm.lua's cursor position
-- param: x - the column on which to print
-- param: y - the row on which to print
function pcursor(x, y)
	-- x and y are required parameters
	if x == nil or y == nil then return end
	
	CURSOR.x = x
	CURSOR.y = y
end

-- pcolor - change the pterm.lua's cursor colors
-- param: fcol - the color to use for text
-- param: bcol? - the color to use behind the text
function pcolor(fcol, bcol)
	-- fcol is a required parameter
	if fcol == nil then return end
	
	bcol = bcol and bcol or CURSOR.bcol
	CURSOR.fcol = fcol
	CURSOR.bcol = bcol
end

-- get_input - prompt the user for a question and await the answer
-- param: prompt - the text to prompt the user's response
function get_input(prompt)
	-- prompt is a required parameter
	if prompt == nil then return end

	pprint(prompt)
	IS_INPUT = true
	-- TODO: await the user's input via peektext(), readtext(), and keyp()
	-- return the typed value after an "enter" key is pressed back to the process who called get_input()
	-- use a send_message()?
end

-- get_cursor - get cursor details
-- returns: a table containing cursor information: {x=, y=, fcol=, bcol=}
function get_cursor()
	-- return a copy of the cursor object so that it cannot be directly manipulated
	return {
		x=CURSOR.x,
		y=CURSOR.y,
		fcol=CURSOR.fcol,
		bcol=CURSOR.bcol
	}
end

-- prompt - print the terminal prompt
function prompt()
	CURSOR.y += 1
	CURSOR.x = 1
	-- TODO: print the user's pwd
	pprint("/>")
	IS_INPUT = true
end

-- welcome_msg - print the welcome prompt
function welcome_msg()
	-- ascii art
	pprint("        _",8,0,0,0)
	pprint(" _ __ | |_ ___ _ __ _ __ ___",25,0,1,1)
	pprint("| '_ \\| __/ _ \\ '__| '_ ` _ \\",10,0,1,2)
	pprint("| |_) | ||  __/ |  | | | | | |",27,0,1,3)
	pprint("| .__/ \\__\\___|_|  |_| |_| |_|",12,0,1,4)
	pprint("| |",13,0,1,5)
	pprint("|_|",18,0,1,6)
	
	-- system information
	pprint("picotron terminal by fletch",7,0,1,8)
	pprint("version "..VERSION,7,0,1,9)
	
	-- leave a line of space
	CURSOR.y += 1
	
	-- prompt the user to type
	prompt()
end

-- ---------------------------
-- I/O FROM EXTERNAL PROCESSES
-- ---------------------------
-- the following events will come from pterm_io.lua - processes that communicate with pterm can include
-- pterm_io.lua to get access to convenience functions that will manipulate the terminal

on_event("pprint", function(msg)
	-- TODO: read params from msg and call pprint
end)

on_event("pcursor", function(msg)
	-- TODO: read params from msg and call pcursor
end)

on_event("pcolor", function(msg)
	-- TODO: read params from msg and call pcolor
end)

on_event("get_input", function(msg)
	-- TODO: read params from msg and call get_input
end)

on_event("get_cursor", function(msg)
	-- TODO: read params from msg and call get_cursor
end)

-- ---------------------------
-- TERMINAL IMPLEMENTATION
-- ---------------------------

-- TODO: refactor zep's /system/apps/terminal.lua into pterm.lua
-- TODO: add wildcard (*) support to terminal commands that acccept filenames
-- TODO: support the HOME and END keys on the keyboard