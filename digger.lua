-- ------------ digger -------------
-- 
-- v0.1 @zbs
--
-- branching tracker
-- HID keyboard required
--
--   \/\/ controls below \/\/
--
-- ARROWS/HJKL: traverse
-- SHIFT+ARROWS: select nodes
-- SPACE: play/pause
-- ENTER: select single node
-- BACKSPACE: delete node
-- ESC: back/cancel/exit

node = include('lib/node')
context_window = include('lib/context_window')
key_input = include('lib/key_input')
screen_graphics = include('lib/screen_graphics')
prms = include('lib/prms')
nb = include('lib/nb/lib/nb')
mu = require 'musicutil'

OFF=0
LOW=1
MED=5
HIGH=12

flash = LOW
root = prms.loaded_table and prms.loaded_table or {}
all = {}
target = {}
playhead = {}
id_counter = 0
view_attrs = {'note','velocity','mod','duration','retrig'}
new_node_options = {'before','after','split','as child'}
tbuf = ''
entering_text = false
math_symbols = {'=','+','-','*','/','?'}
math_descriptions = {
	['='] = 'set'
,	['+'] = 'add'
,	['-'] = 'subtract'
,	['*'] = 'multiply'
,	['/'] = 'divide'
,	['?'] = 'randomize by amount'
}
post_buffer = 'digger @zbs'
pset_filename = ''
shift = false
-- selected_nodes = {}
clipboard = {}

params.action_write = function(filename, name, pset_number)
	prms:action_write(filename,name,pset_number)
end

params.action_read = function(filename, silent, pset_number)
	prms:action_read(filename,silent,pset_number)
end

params.action_delete = function(filename, name, pset_number)
	prms:action_delete(filename,name,pset_number)
end

function post(str)
	post_buffer = str
end

function init_root()
	root = node:new()
	root.parent = 'none'
	-- for i=1,3 do 
	-- 	root:add_child()
	-- 	for j=1,5 do
	-- 		root.children[i]:add_child()
	-- 	end
	-- end
	for _,v in ipairs{64, 66, 67, 71, 69, 71} do
		root:add_child{note=v}
	end
end

function init()
	nb:init()
	prms:add()
	init_root()
	target = root:child()
	clock.run(stepper)
	visual_metro = metro.init(update_visuals,1/15,-1)
	visual_metro:start()
end

function stepper()
	while true do
		clock.sync(1/4)
		if params:get('playing') == 1 then
			root:all_children(function(x) x.is_playhead = false end)
			local playhead, reset, play = root:advance()
			local old_node = playhead
			while playhead.duration == 0 do
				playhead, reset, play = root:advance()
				if playhead == old_node then
					-- if we've wrapped all the way around, just step forward anyway
					break
				end
			end
			-- print(playhead,reset,play)
			if play then
				local player = params:lookup_param('voice'):get_player()
				player:modulate(playhead.mod/127)
				-- print(playhead.mod)
				player:play_note(playhead.note, playhead.velocity/127, 0.01)
			end

			local t = playhead
			while t ~= root do
				t.is_playhead = true
				t = t.parent
			end
		end
	end
end

function update_visuals() redraw() end
function redraw() screen_graphics:render() end

function enter_command(input_str)
	entering_text = false
	local str = input_str
	-- if string.sub(str,1,1) == ':' then
	-- 	str = string.sub(input_str,2,-1)
	-- end
	str = string.lower(str)
	
	if tab.contains(math_symbols,string.sub(str,1,1)) and tonumber(string.sub(str,2,-1)) then
		local n = tonumber(string.sub(str,2,-1))
		local symbol = string.sub(str,1,1)
		local name = params:string('view_attr')
		local func, str
		if symbol == '+' then
			func = node.delta_attr
			str = 'added '..n.. ' to '..name
		elseif symbol == '-' then
			func = node.delta_attr
			n = 0 - n
			str = 'subtracted '..n..' from '..name
		elseif symbol == '*' then
			func = node.multiply_attr
			str = 'multiplied '..name.. ' by '..n
		elseif symbol == '/' then
			func = node.multiply_attr
			n = 1 / n
			str = 'divided '..name..' by '..n
		elseif symbol == '=' then
			func = node.set_attr
			str = 'set '..name..' to '..n
		elseif symbol == '?' then
			-- target:delta_attr(nil,math.random(0-n,n))
			func = node.delta_attr
			n = math.random(0-n, n)
			str = 'randomized '..name..' by +/- '..n
		end

		root:all_children(function(x) 
			if x.selected or x == target then
				func(x,name,n)
			end
		end)
	else
		entering_text = true
		post('not a command')
	end

	if not entering_text then
		tbuf = ''
	end
end

function delta_target(d)
	if target:get_sibling(d) then
		target = target:get_sibling(d)
	end
end

function get_selected_nodes(obj)
	local obj = obj and obj or root
	local r = {}
	obj:all_children(function(v)
		if v.selected or v == target then
			table.insert(r,v)
		end
	end)
	return r
end

function deselect_all(obj)
	local obj = obj and obj or root
	obj:all_children(function(v) v.selected = false end)
end

function keyboard.char(input_ch) 
	key_input:char(input_ch) 
end
function keyboard.code(code,value) 
	key_input:code(code,value) 
end

function enc(n,d)
	if n == 1 then
		params:delta('view_attr',d)
	elseif n == 2 then
		delta_target(d)
	elseif n == 3 then
		target:delta_attr(nil,d)
	end
end

function key(n,d)

	if n == 1 then 
		shift = d==1 

	elseif n == 2 and d == 1 then
		keyboard.code('LEFT',1)
	elseif n == 3 and d == 1 then
		keyboard.code('RIGHT',1)
	end
end
