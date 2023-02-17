cw = {
  open = false
,	options = {}
,	name = ''
,	description = ''
}

function cw:open_new_node()
  self.open = true
  self.options = {'after','before','split'}
  self.name = 'new'
  self.description = 'where to add a new node'
end

return cw