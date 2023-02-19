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
  self.name = 'new node'
  self.description = 'where to add a new node'
	self.exit_func = function()
		params:set('new_node_location',self.last_selection)
		local loc = params:string('new_node_location')
		if loc == 'before' then
			table.insert(target.parent.children, target:pos_in_parent(), target:get_copy())
			post('inserted node before target')
		elseif loc == 'after' then
			table.insert(target.parent.children, target:pos_in_parent()+1, target:get_copy())
			post('inserted node after target')
		elseif loc == 'split' then
			table.insert(target.parent.children, target:pos_in_parent()+1, target:get_copy())
			local old_num = target.duration
			target:multiply_attr('duration',0.499)
			target:get_sibling(1):multiply_attr('duration',0.499)
			if old_num % 2 == 1 then
				target:delta_attr('duration',1)
			end
			post('split target node')
		elseif loc == 'as child' then
			target:add_child()
			post('created child node')
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