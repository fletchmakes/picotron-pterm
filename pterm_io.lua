--[[pod_format="raw",created="2024-04-05 07:00:00",modified="2024-04-05 07:00:00",revision=1]]
-- pterm_io.lua
-- fletch
-- a library for interacting with pterm.lua

--          _                      
--         | |                     
--    _ __ | |_ ___ _ __ _ __ ___  
--   | '_ \| __/ _ \ '__| '_ ` _ \ 
--   | |_) | ||  __/ |  | | | | | |
--   | .__/ \__\___|_|  |_| |_| |_|
--   | |                           
--   |_|            
local VERSION = "0.0.1"

-- this library just wraps `send_message` calls to make interacting with pterm.lua much
-- more convenient and straight-forward.

local PTERM_PID = -1

-- create_pterm - creates a new pterm.lua window
-- param: path - the path to the pterm.lua library file
-- param: rows? - the number of characters tall the window should be (defaults to 20)
-- param: cols? - the number of characters wide the window should be (defaults to 50)
function create_pterm(path, rows, cols)
  PTERM_PID = create_process(path, argv={rows, cols})
end

-- set_pid - sets the pid to target with send_message calls. Must be set before other
--           convenience functions can be ran
-- param: pid - the pid to set as the target process
function set_pid(pid)
  -- pid is a required parameter
  if pid == nil then return end

  PTERM_PID = pid
end

-- pprint - print text to a pterm.lua terminal
-- param: text - the text to print
-- param: fcol? - the foreground color (text color)
-- param: bcol? - the background color
-- param: x? - the column on which to print
-- param: y? - the row on which to print
function pprint(text, fcol, bcol, x, y)
  -- TODO: error handling?
  if PTERM_PID == -1 then return end

  -- text is a required parameter
	if text == nil then return end

  send_message(PTERM_PID, {
    event="pprint",
    msg={
      text=text,
      fcol=fcol,
      bcol=bcol,
      x=x,
      y=y
    }
  })
end

-- pcursor - change the pterm.lua's cursor position
-- param: x - the column on which to print
-- param: y - the row on which to print
function pcursor(x, y)
  -- TODO: error handling?
  if PTERM_PID == -1 then return end

  -- x and y are required parameters
	if x == nil or y == nil then return end

  send_message(PTERM_PID, {
    event="pcursor",
    msg={
      x=x,
      y=y
    }
  })
end

-- pcolor - change the pterm.lua's cursor colors
-- param: fcol - the color to use for text
-- param: bcol? - the color to use behind the text
function pcolor(fcol, bcol)
  -- TODO: error handling?
  if PTERM_PID == -1 then return end

  -- fcol is a required parameter
	if fcol == nil then return end

  send_message(PTERM_PID, {
    event="pcolor",
    msg={
      fcol=fcol,
      bcol=bcol
    }
  })
end

-- get_input - prompt the user for a question and await the answer
-- param: prompt - the text to prompt the user's response
function get_input(prompt)
  -- TODO: error handling?
  if PTERM_PID == -1 then return end

  -- prompt is a required parameter
	if prompt == nil then return end

  send_message(PTERM_PID, {
    event="get_input",
    msg={
      prompt=prompt,
      -- send our process's pid() so that pterm can send us a message back
      pid=pid()
    }
  })
end

-- get_cursor - get cursor details
-- returns: a table containing cursor information: {x=, y=, fcol=, bcol=}
function get_cursor()
  -- TODO: error handling?
  if PTERM_PID == -1 then return end
  send_message(PTERM_PID, {
    event="get_cursor",
    msg={
      -- send our process's pid() so that pterm can send us a message back
      pid=pid()
    }
  })
end