key_input = {}

function key_input:char(input_ch)
  -- print('char',input_ch)
	if input_ch == ':' or tab.contains(math_symbols,input_ch) then
		entering_text = true
	end
	if entering_text then
		tbuf = tbuf..input_ch
		return
	end
	
	local ch = string.lower(input_ch)
	if ch == 'q' or ch == 'a' then
		params:delta('view_attr',ch=='a' and 1 or -1)
	elseif ch == 'w' or ch == 's' then
		local d = ch=='w' and 1 or -1
		target[2]:delta_attr(params:string('view_attr'),d)
	elseif ch == 'h' then
		self:code('LEFT',1)
	elseif ch == 'j' then
		self:code('DOWN',1)
	elseif ch == 'k' then
		self:code('UP',1)
	elseif ch == 'l' then
		self:code('RIGHT',1)
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

function key_input:code(code, value)
  if value == 0 then return end
	-- print('code',code)

	if code == 'UP' or code == 'DOWN' then
		local tn = keyboard.shift() and 1 or 2
		local d = code=='UP' and -1 or 1
		delta_target(tn,d)
		post('traverse')
	elseif code == 'LEFT' then
		if target[1] == root then 
			post('can\'t go up - at root')
			return 
		end
		target[2] = target[1]
		target[1] = target[1].parent
		post('up')
	elseif code == 'RIGHT' then
		if target[2]:is_leaf() then 
			post('can\'t go down - at bottom')
			return 
		end
		target[1] = target[2]
		target[2] = target[2]:child(#target[2].children)
		post('down')
	elseif code == 'ENTER' then
		enter_command(tbuf)
	elseif code == 'BACKSPACE' then
		if entering_text then
			tbuf = string.sub(tbuf,1,-2)
		else
			target[2].parent:remove_child(target[2]:pos_in_parent())
		end
	elseif code == 'ESC' then
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
	elseif code == 'SPACE' then
		target[2].selected = not target[2].selected
	end
end

return key_input