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
target = {{},{},{}}
playhead = {}
id_counter = 0
view_attrs = {'note','velocity','mod','duration','retrig'}
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
	for i=1,3 do 
		root:add_child()
		for j=1,5 do
			root.children[i]:add_child()
		end
	end
end

function init()
	nb:init()
	prms:add()
	init_root()
	target[1] = root
	target[2] = target[1]:child()
	target[3] = nil
	clock.run(stepper)
	visual_metro = metro.init(update_visuals,1/15,-1)
	visual_metro:start()
end

function stepper()
	while true do
		clock.sync(1/4)
		
		root:all_children(function(x) x.is_playhead = false end)
		local playhead, reset, play = root:advance()
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

function update_visuals() redraw() end
function redraw() screen_graphics:render() end

function enter_command(input_str)
	entering_text = false
	local str = input_str
	if string.sub(str,1,1) == ':' then
		str = string.sub(input_str,2,-1)
	end
	str = string.lower(str)
	
	if tab.contains(math_symbols,string.sub(str,1,1)) and tonumber(string.sub(str,2,-1)) then
		local n = tonumber(string.sub(str,2,-1))
		local symbol = string.sub(str,1,1)
		if symbol == '+' or symbol == '-' then
			if symbol=='-' then n=0-n end
			root:all_children(function(x)
				if x.selected or target[2]==x then 
					x:delta_attr(nil,n)
				end
			end)

		elseif symbol == '*' then
			target[2]:multiply_attr(nil,n)
			post('multiplied '..params:string('view_attr')..' by '..n)
		elseif symbol == '/' then
			target[2]:multiply_attr(nil,1/n)
			post('divided '..params:string('view_attr')..' by '..n)
		elseif symbol == '=' then
			target[2]:set_attr(nil,n)
			post('set '..params:string('view_attr')..' to '..n)
		elseif symbol == '?' then
			target[2]:delta_attr(nil,math.random(0-n,n))
			post('randomized '..params:string('view_attr').. ' +/- '..n)
		end
	elseif str == 'save' or str == 'w' or str == 'write' then
		-- params:write(pset_filename)
		-- todo
	else
		entering_text = true
		post('not a command')
	end

	if not entering_text then
		tbuf = ''
	end
end

function delta_target(n,d)
	if n == 1 then
		target[1] = target[1].parent:child(util.clamp(target[1]:pos_in_parent()+d,1,#target[1].parent.children))
		target[2] = target[1]:child(util.clamp(target[2]:pos_in_parent(),1,#target[1].children))
	elseif n == 2 then
		target[2] = target[1]:child(util.clamp(target[2]:pos_in_parent()+d,1,#target[1].children))
	end
end

function keyboard.char(input_ch) 
	key_input:char(input_ch) 
end
function keyboard.code(code,value) 
	key_input:code(code,value) 
end

function enc(n,d)
	if n == 2 or n == 3 then
		delta_target(n-1,d)
	elseif n == 1 then
		if shift then
			params:delta('view_attr',d)
		else
			target[2]:delta_attr(nil,d)
		end
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
