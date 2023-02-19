local nb = include('n.kria/lib/nb/lib/nb')

local Prms = {}

Prms.loaded_table = nil

function Prms:action_write(filename, name, pset_number)
  tab.save(root,filename..'.tree')
  print('writing root table to file as',filename,name,pset_number)
end

function Prms:action_read(filename,silent,pset_number)
  pset_filename = filename
  print('loading root table from file')
  local l = tab.load(filename..'.tree')
  node.__index = node
  
  local function loader_loop(x)
    setmetatable(x,node)
    for _,v in pairs(x.children) do
      v.parent = x
      loader_loop(v)
    end
  end

  loader_loop(l)
  root = l
  target = root:child()
end

function Prms:action_delete(filename,name,pset_number)
  print('deleting root table')
  os.execute('rm /home/we/dust/data/digger/'..filename..'.tree')
end

function Prms:add()
  nb:add_player_params()
  params:add_separator('DIGGER')
  nb:add_param('voice','voice')
	params:add_binary('playing','playing?','toggle',0)
  params:add_option('view_attr','view_attr',view_attrs,1)
	params:add_option('new_node_location','new node location',new_node_options,1)
end

return Prms