keys = {}

function keys:char(input_ch)
  -- print('char',input_ch)
	if input_ch == ':' or tab.contains(math_symbols,input_ch) then
		post(math_descriptions[input_ch])
		entering_text = true
	end
	if entering_text then
		tbuf = tbuf..input_ch
		return
	end
	
	local ch = string.lower(input_ch)
	if ch == 'q' or ch == 'a' then
		params:delta('view_attr',ch=='a' and 1 or -1)
		post('scroll selected value')
	elseif ch == 'w' or ch == 's' then
		local d = ch=='w' and 1 or -1
		target[2]:delta_attr(params:string('view_attr'),d)
		post((d==1 and 'in' or 'de')..'crement '..params:string('view_attr'))
	-- elseif ch == 'h' then
	-- 	self:code('LEFT',1)
	-- elseif ch == 'j' then
	-- 	self:code('DOWN',1)
	-- elseif ch == 'k' then
	-- 	self:code('UP',1)
	-- elseif ch == 'l' then
	-- 	self:code('RIGHT',1)
	elseif ch == 'n' then
		if keyboard.shift() then
			post('add child')
			target[2]:add_child()
		else
			post('duplicate node')
			table.insert(target[2].parent.children, target[2]:pos_in_parent()+1, target[2]:get_copy())
		end
	end
end

function keys:code(code, value)
	-- print('code',code)
	if value==1 and (code=='UP' or code=='DOWN' or code=='K' or code=='J') then
		self:updown(code)
	elseif value==1 and (code=='LEFT' or code=='H') then
		self:left()
	elseif value==1 and (code=='RIGHT' or code=='L') then
		self:right()
	elseif value==1 and code=='ENTER' then
		enter_command(tbuf)
	elseif value==1 and code=='BACKSPACE' then
		self:backspace()
	elseif value==1 and code=='ESC' then
		self:escape()
	elseif value==1 and code=='SPACE' then
		target[2].selected = not target[2].selected
	end
end

function keys:updown(code)
	local tn = keyboard.shift() and 1 or 2
	local d = (code=='UP' or code=='k') and -1 or 1
	delta_target(tn,d)
	post('traverse tree')
end

function keys:left()
	if target[1] == root then 
		post('can\'t go up - at root')
		return 
	end
	target[2] = target[1]
	target[1] = target[1].parent
	post('ascend tree')
	root:all_children(function(x) x.selected = false end)
end

function keys:right()
	if target[2]:is_leaf() then 
		post('can\'t go down - at bottom')
		return 
	end
	target[1] = target[2]
	target[2] = target[2]:child(#target[2].children)
	post('descend tree')
	root:all_children(function(x) x.selected = false end)
end

function keys:backspace()
	if entering_text then
		tbuf = string.sub(tbuf,1,-2)
	else
		target[2].parent:remove_child(target[2]:pos_in_parent())
	end
end

function keys:escape()
if context_window.open then
	context_window.open = false
	else
		if #tbuf > 0 then
			tbuf = ''
			entering_text = false
		else
			root:all_children(function(x) x.selected = false end)
		end
	end
end

return keys