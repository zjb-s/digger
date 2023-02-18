cw = {
  open = false
,	options = {'example LONG WORDS','example 2','example 3','example_4'}
,	name = 'none'
,	description = 'example description'
}

function cw:new_node()
  self.open = true
  self.options = {'after','before','split'}
  self.name = 'new node'
  self.description = 'where to add a new node'
end

return cw