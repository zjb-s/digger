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
view_attrs = {'note','velocity','duration'}
tbuf = ''
entering_text = false
math_symbols = {'=','+','-','*','/'}
post_buffer = 'digger @zbs'

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
		clock.sleep(1/4)
		
		root:all_children(function(x) x.is_playhead = false end)
		-- for _,v in pairs(all) do v.is_playhead = false end
		playhead = root:advance()

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
			-- target[2]:delta_attr(nil,n)
		elseif symbol == '*' then
			target[2]:multiply_attr(nil,n)
		elseif symbol == '/' then
			target[2]:multiply_attr(nil,1/n)
		elseif symbol == '=' then
			target[2]:set_attr(nil,n)
		end
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
	if n == 1 or n == 2 then
		delta_target(n,d)
	elseif n == 3 then
		target[2]:delta_attr(nil,d)
	end
end

function key(n,d)
	if d == 0 then return end

	if n == 1 then 

	elseif n == 2 then
		keyboard.code('LEFT',1)
	elseif n == 3 then
		keyboard.code('RIGHT',1)
	end
end
