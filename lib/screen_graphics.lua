Graphics = {}

function Graphics:render()
	flash = flash==HIGH and MED or HIGH
	screen.clear()
	self:draw_column(1)
	self:draw_column(2)
	if not target[2]:is_leaf() then 
		target[3] = target[2]:child(1)
		self:draw_column(3) 
	end

	self:tbuf()
	self:sidebars()
	self:post()
	self:dividers()

	screen.update()
end

function Graphics:dividers()
	screen.level(LOW)
	screen.line_width(1)

	screen.move(0,55)
	screen.line(128,55)
	screen.stroke()

	screen.move(67,55)
	screen.line(67,0)
	screen.stroke()
end

function Graphics:sidebars()
	for k,v in ipairs(view_attrs) do
		local x = 0
		local y = 9 * k
		screen.level(v == params:string('view_attr') and HIGH or LOW)
		screen.move(x,y)
		screen.text(v)
		screen.move(x+37,y)
		screen.text(target[2][v])
	end
	-- screen.level(LOW)
	-- screen.move(0,36)
	-- screen.text('children')
	-- screen.move(37,36)
	-- screen.text(#target[2].children)
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
		if target[n] == root then
			if i == 0 then node_to_print = root end
		else
			node_to_print = target[n].parent:child(target[n]:pos_in_parent()+i)
		end
		if node_to_print then
			screen.move(x,y)
			screen.level(((node_to_print==target[n]) and n~=3) and HIGH or LOW)
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