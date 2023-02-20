cw = {
  open = false
,	options = {'example LONG WORDS','example 2','example 3','example_4'}
,	last_selection = 1
,	name = 'none'
,	description = 'example description'
}

function cw:new_node()
  self.open = true
  self.options = new_node_options
	self.last_selection = util.clamp(params:get('new_node_location'),1,#self.options)
  self.name = 'new node'
  self.description = 'where to add a new node'
	self.exit_func = function()
		params:set('new_node_location',self.last_selection)
		local loc = params:string('new_node_location')
		if loc == 'before' then
			target = target.parent:add_child(target:get_copy(), target:pos_in_parent())
			post('inserted before target')
		elseif loc == 'after' then
			-- table.insert(target.parent.children, target:pos_in_parent()+1, target:get_copy())
			target = target.parent:add_child(target:get_copy(), target:pos_in_parent()+1)
			post('inserted after target')
		elseif loc == 'split' then
			local old_target = target
			target = target.parent:add_child(target:get_copy(), target:pos_in_parent()+1)
			old_target:multiply_attr('duration',0.499)
			target:multiply_attr('duration',0.499)
			if old_target.duration % 2 == 1 then
				old_target:delta_attr('duration',1)
			end
			post('split target')
		elseif loc == 'as child' then
			target:add_child()
			post('created child')
		end
	end
end

function cw:select_all()
	self.open = true
	self.options = {'siblings','children'}
	self.last_selection = util.clamp(self.last_selection,1,#self.options)
	self.name = 'group select'
	self.description = 'select all...'
	self.exit_func = function()
		local which = self.options[self.last_selection]
		if which == 'siblings' then
			for _,v in pairs(target.parent.children) do
				v.selected = true
			end
			post('selected all siblings')
		elseif which == 'children' then
			target:all_children(function(v) v.selected = true end)
			post('selected all children')
		end
	end
end

function cw:close(silent)
	self.open = false
	if not silent then 
		self:exit_func() 
	end
end

return cw