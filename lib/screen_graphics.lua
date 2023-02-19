Graphics = {}

function Graphics:render()
	flash = flash==HIGH and MED or HIGH
	screen.clear()
	self:draw_column(1)
	self:draw_column(2)
	if not target:is_leaf() then 
		self:draw_column(3) 
	end

	self:tbuf()
	self:sidebars()
	self:post()
	self:dividers()
	
	if context_window.open then self:cw() end

	screen.update()
end

function Graphics:cw()
	screen.level(OFF)
	screen.rect(4,4,120,56)
	screen.fill()

	screen.level(MED)
	screen.line_width(2)
	screen.rect(4,4,120,56)
	screen.stroke()

	screen.move(64,12)
	screen.level(HIGH)
	screen.text_center(context_window.name)

	screen.move(64,21)
	screen.level(LOW)
	screen.text_center(context_window.description)

	for k,v in ipairs(context_window.options) do
		if k>4 then break end
		local x = 8
		local y = (24+(8*k)) + ((4-#context_window.options)*8)
		screen.level(context_window.last_selection==k and HIGH or LOW)
		screen.move(x,y)
		screen.text(k)

		screen.level(LOW)
		local lx = x + screen.text_extents(k) + 4
		screen.move(lx, y-2)
		screen.line_width(1)
		screen.line_rel((128-x)-(screen.text_extents(v))-20,0)
		screen.stroke()

		screen.level(context_window.last_selection==k and MED or LOW)
		screen.move(128-x,y)
		screen.text_right(v)
	end
end

function Graphics:dividers()
	screen.level(LOW)
	screen.line_width(1)

	screen.move(0,55)
	screen.line(128,55)
	screen.stroke()

	screen.move(69,55)
	screen.line(69,0)
	screen.stroke()
end

function Graphics:sidebars()
	for k,v in ipairs(view_attrs) do
		local x = 0
		local y = 8 * k
		screen.level(v == params:string('view_attr') and HIGH or LOW)
		screen.move(x,y)
		screen.text(k..': '..v)
		screen.move(screen.text_extents(k..': '..v)+4,y-2)
		screen.line_width(1)
		screen.level(LOW)
		screen.line(60-screen.text_extents(target[v]),y-2)
		screen.stroke()
		screen.move(64,y)
		screen.level(v == params:string('view_attr') and HIGH or LOW)
		-- screen.move(x+37,y)
		screen.text_right(target[v])
	end
	-- screen.level(LOW)
	-- screen.move(0,36)
	-- screen.text('children')
	-- screen.move(37,36)
	-- screen.text(#target.children)
end

function Graphics:tbuf()
	if #tbuf > 0 then 
		screen.move(1,51)
		screen.level(LOW)
		screen.text(tbuf)
	end
end

function Graphics:post()
	screen.move(1,62)
	screen.level(MED)
	screen.text('\u{0bb}')
	screen.move(8,62)
	screen.text(post_buffer)
end

function Graphics:draw_column(n)
	for i=-3,3 do
		local x = 75 + (20*(n-1))
		local y = 29 + (i*8)
		local node_to_print
		if target == root then
			if i == 0 then node_to_print = root end
		else
			if n == 1 then
				node_to_print = target.parent:get_sibling(i)
			elseif n == 2 then
				node_to_print = target:get_sibling(i)
			elseif n == 3 then
				node_to_print = target:child(i+4)
			end
			-- if n == 1 then
			-- 	node_to_print = target.parent.parent:child(target.parent:pos_in_parent()+i)
			-- elseif n == 2 then
			-- 	node_to_print = target.parent:child(target:pos_in_parent()+i)
			-- elseif n == 3 then
			-- 	node_to_print = target:child(i+3)
			-- end
		end
		if node_to_print then
			screen.move(x,y)
			screen.level(((node_to_print==target) and n~=3) and HIGH or LOW)
			if node_to_print.selected then 
				screen.level(flash)
			end
			local str = node_to_print:is_leaf() and node_to_print.id or '>'
			local str
			if node_to_print:is_leaf() then
				str = node_to_print[params:string('view_attr')]
			elseif node_to_print == root then
				str = '/'
			else
				str = '>'
				if params:string('view_attr') == 'duration' then
					str = node_to_print.duration..str
				end 
			end
			screen.text(str)
	
			if node_to_print.is_playhead then
				screen.move(x-4,y)
				screen.text(':')
			end
		end
	end
end


return Graphics