keys = {}

function keys:char(input_ch)
  -- print('char',input_ch)

	if tab.contains(math_symbols,input_ch) then
		post(math_descriptions[input_ch])
		entering_text = true
	end

	if entering_text then
		tbuf = tbuf..input_ch
		return
	end
end

function keys:code(code, value)
	print('code',code)
	if value==1 and (code=='UP' or code=='DOWN' or code=='K' or code=='J') then
		self:updown(code)
	elseif value==1 and (code=='LEFT' or code=='H') then
		self:left()
	elseif value==1 and (code=='RIGHT' or code=='L') then
		self:right()
	elseif value==1 and code=='ENTER' then
		self:enter()
	elseif value==1 and code=='BACKSPACE' or code=='DELETE' then
		self:backspace()
	elseif value==1 and code=='ESC' then
		self:escape()
	elseif value==1 and code=='SPACE' then
		params:delta('playing',1)
	elseif value==1 and code=='R' then
		self:reset()
	elseif value==1 and tonumber(code) and not keyboard.shift() then
		self:numbers(code)
	elseif value==1 and (code=='Q' or code=='W') then
		self:incdec(code=='W' and 1 or -1)
	elseif code=='A' then
		self:all(code,value)
	elseif code=='N' then
		self:new_node(code,value)
	elseif value==1 and (code=='X' or code=='C' or code=='V') then
		self:clipboard(code)
	elseif value==1 and code=='B' then 
		self:bundle()
	end
end

function keys:all(code,value)
	if value == 1 then
		context_window:select_all()
	elseif value == 0 and context_window.open then
		context_window:close()
	end
end

function keys:reset()
	root:all_children(function(v)
		v.pos = 1
		v.counter = 1
	end)
	post('reset')
end

function keys:bundle()
	local t = target.parent:add_child({},target:pos_in_parent())
	target.selected = true
	for _,v in ipairs(get_selected_nodes()) do
		t:add_child(v:get_copy())
		v.parent:remove_child(v:pos_in_parent())
	end
	target = t
	post('bundled nodes')
	tab.print(t.children)
end

function keys:incdec(d)
	root:all_children(function(x) 
		if x.selected or x == target then
			x:delta_attr(nil,d)
		end
	end)
	post((d==1 and 'in' or 'de')..'crement attribute')
end

function keys:clipboard(code)
	if code=='X' then
		clipboard = {}
		for _,v in ipairs(get_selected_nodes()) do
			table.insert(clipboard,v)
			v.parent:remove_child(v:pos_in_parent())
		end
		post('cut node/s')
	elseif code=='C' then
		clipboard = {}
		for k,v in ipairs(get_selected_nodes()) do
			table.insert(clipboard,v)
		end
		post('copied node/s')
	elseif code=='V' then
		for _,v in ipairs(clipboard) do
			target.parent:add_child(v:get_copy(),target:pos_in_parent()+1)
			-- table.insert(target.parent.children, target:pos_in_parent(), v:get_copy())
		end
		post('pasted node/s')
	end

	root:all_children(function(x) x.selected = false end)
end

function keys:enter()
	if #tbuf > 0 then
		enter_command(tbuf)
	else
		target.selected = not target.selected
	end
end

function keys:new_node(code,value)
	if value == 1 then
		context_window:new_node()
	elseif value == 0 and context_window.open then
		context_window:close()
	end
end

function keys:numbers(code)
	if context_window.open then
		context_window.last_selection = util.clamp(tonumber(code),1,#context_window.options)
	elseif not entering_text then
		params:set('view_attr',tonumber(code))
		post('selected '..params:string('view_attr'))
	end
end

function keys:updown(code)
	local d = (code=='UP' or code=='K') and -1 or 1
	if context_window.open then
		context_window.last_selection = util.clamp(context_window.last_selection+d,1,#context_window.options)
		return
	end
	local old_target = target
	delta_target(d)
	if keyboard.shift() then
		target.selected = true
		old_target.selected = true
	end
	post(keyboard.shift() and 'select node' or 'traverse tree')
end

function keys:left()
	if target.parent == root then 
		post('can\'t go up - at root')
		return 
	end
	target = target.parent
	post('ascend tree')
	deselect_all()
end

function keys:right()
	if target:is_leaf() then 
		post('can\'t go down - at leaf')
		return 
	end
	target = target:child(util.round(#target.children/2))
	post('descend tree')
	deselect_all()
end

function keys:backspace()
	if entering_text then
		tbuf = string.sub(tbuf,1,-2)
	else
		for _,v in ipairs(get_selected_nodes()) do
			v.parent:remove_child(v:pos_in_parent())
		end
		post('removed node/s')
	end
end

function keys:escape()
	if context_window.open then
		context_window:close(true)
	elseif #tbuf > 0 then
		tbuf = ''
		entering_text = false
	else
		deselect_all()
	end
end

return keys