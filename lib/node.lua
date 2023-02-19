local Node = {}

function Node:new(args)
  i = {}
  
	id_counter = id_counter + 1
	local args = args and args or {}
  i = {
    id = id_counter
    , note = args.note and args.note or 64
    , velocity = args.velocity and args.velocity or 80
    , mod = args.mod and args.mod or 0
    , duration = args.duration and args.duration or 1
    , counter = args.counter and args.counter or 1
    , children = args.children and args.children or {}
    , pos = args.pos and args.pos or 1
    , retrig = args.retrig and args.retrig or 0
		,	is_playhead = false
		,	selected = false
  }

  setmetatable(i, self)
  self.__index = self

	all[id_counter] = i
  return i
end

function Node:get_sibling(offset)
  if self == root and offset ~= 0 then 
    return nil 
  else
    if offset==0 then 
      return self
    else
	    return self.parent:child(self:pos_in_parent()+offset)
    end
  end
end

function Node:delta_attr(attr,delta)
  self:set_attr(attr, self:get_attr(attr) + delta)
end

function Node:set_attr(attr,new_val)
	local attr = attr and attr or params:string('view_attr')
  local max = attr=='retrig' and 1 or 127
	self[attr] = util.round(util.clamp(new_val,0,max))
end

function Node:multiply_attr(attr,n)
	self:set_attr(attr, self:get_attr(attr) * n)
end

function Node:get_attr(attr)
	local attr = attr and attr or params:string('view_attr')
	return self[attr]
end

function Node:is_leaf()
  return #self.children == 0
end

function Node:pos_in_parent()
  return tab.key(self.parent.children,self)
end

function Node:child(index)
	local i = index and index or self.pos
	return self.children[i]
end

function Node:all_children(func)
	func(self)
	for k,v in pairs(self.children) do
		v:all_children(func)
	end
end

function Node:add_child(args,index)
  local args = args and args or {}
  local index = index and index or #self.children+1
  table.insert(self.children,index,self:new(args))
  self:child(index).parent = self
  if self.pos == 0 then self.pos = index end
end

function Node:get_copy()  
  local r = self:new{
		note = self.note
	,	velocity = self.velocity
	,	duration = self.duration
	,	counter = 1
	,	children = {}
	,	pos = 1
	}
	for _,v in ipairs(self.children) do
		table.insert(r.children, v:get_copy())
		r:child(#r.children).parent = r
	end
  return r
end

function Node:remove_child(ix)
  if self == root and #self.children == 1 then
    post('can\'t delete last node')
    return
  end
  if self:child(ix) == target then
    if ix < #self.children then
      target = self:child(ix+1)
    elseif #self.children == 1 then
      keyboard.code('LEFT',1)
    else
      target = self:child(#self.children-1)
    end
  end
  table.remove(self.children,ix)
  self.pos = util.clamp(self.pos,1,#self.children)
  self.pos = (util.clamp(self.pos,1,128))
end

function Node:advance()
  if self:is_leaf() then
    return self, true, (self.counter==1 or self.retrig == 1)
  else
    local result, reset, play = self:child():advance()
    if reset then
      if self:child().counter < self:child().duration then
        self:child().counter = self:child().counter + 1
      else
        self:child().counter = 1
        self.pos = self.pos + 1
      end
      if self.pos > #self.children then
        self.pos = 1
        return result, true, play
      else
        return result, false, play
      end
    else
      return result, false, play
    end
  end
end

return Node