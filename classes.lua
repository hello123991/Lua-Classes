math.randomseed(os.time()^2)
local classes = {}
classes.Classes = {}
classes.ClassInstances = {}
classes.ENV = nil
local self = classes
function ctable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[ctable(orig_key)] = ctable(orig_value)
        end
        setmetatable(copy, ctable(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
function GetPointer(t)
  return tostring(tostring(t):gsub(type(t)..": ",""))
end
function GenerateID()
  local s = ""
  for i=1,10 do
    s = s..string.char(math.random(("a"):byte(),("z"):byte()))
  end
  return s
end
function classes.class (name)
  local cname = (type(name) == 'string' and name) or GenerateID()
  local env = self.ENV
  --[[if type(name) == 'table' then
    self.Classes[cname]= name
    self.CLasses[cname].prototype = {}
    setmetatable(self.Classes[cname].prototype,{
        __newindex = function(a, b, c)
          if type(c) == 'function' then
            getfenv(c).this = classes.this(cname)
          end
          rawset(self.Classes[cname],b,c)
        end
    })
    local p = GetPointer(self.Classes[cname])
    setmetatable(self.Classes[cname],{
        __tostring = function(a)
        
        end
    })
  end]]
  self.Classes[cname] = (type(name) == 'table' and name) or {}
  self.Classes[cname].prototype = {}
  setmetatable(self.Classes[cname].prototype,{
        __newindex = function(a, b, c)
            if type(c) == 'function' then
              getfenv(c).this = classes.this(cname)
            end
            rawset(self.Classes[cname], b, c)
        end
    })
  local p = GetPointer(self.Classes[cname])
  setmetatable(self.Classes[cname],{
      __tostring = function(a)
        return cname.." Object "..p
      end,
      __index = function(a, b)
        for i,v in pairs(self.Classes[cname]) do
          if Split(tostring(v),":") then
            local spl = Split(tostring(v),":")
            if spl[1] then
              if spl[1] == "StaticObject" then
                if spl[2] == b then
                  return v.ObjectValue
                end
              end
            end
          end
        end
      return rawget(a, b)
      end
  })
    env[cname] = self.Classes[cname]
    if type(name) ~= 'table' then
      return function(data)
          for i,v in pairs(data) do
            self.Classes[cname][i] = v
          end
          env[cname] = self.Classes[cname]
          return cname
      end
    else
      return cname
    end
end
function classes.this (id)
    if self.ClassInstances[id] then
        local t = {}
        setmetatable(t,{
            __index = function(a,b)
                return rawget(self.ClassInstances[id], b)
            end,
            __newindex = function(a, b, c)
                rawset(self.ClassInstances[id],b,c)
            end
        })
        return t
    end
end
function classes.get (name)
    return function(data)
        local t = {
            ObjectType = "GetObject",
            ObjectName = name,
            ObjectCallback = data[1]
        }
        local ptable = {}
        setmetatable(ptable,{
            __index = function(a, b)
                return t['ObjectCallback']
            end,
            __tostring = function(a)
                return t.ObjectType..":"..t.ObjectName
            end
        })
        return ptable
    end
end
function classes.set (name)
    return function(data)
        local t = {
            ObjectType = "SetObject",
            ObjectName = name,
            ObjectCallback = data[1]
        }
        local ptable = {}
        setmetatable(ptable,{
            __index = function(a, b)
                return t['ObjectCallback']
            end,
            __tostring = function(a)
                return t.ObjectType..":"..t.ObjectName
            end
        })
        return ptable
    end
end
function classes.static (name)
    return function(data)
        local t = {
            ObjectType = "StaticObject",
            ObjectName = name,
            ObjectValue = data[1]
        }
        local ptable = {}
        setmetatable(ptable,{
            __index = function(a, b)
                return t[b]
            end,
            __tostring = function(a)
                return t.ObjectType..":"..t.ObjectName
            end
        })
        return ptable
    end
end
function classes.new (name)
    if not self.Classes[name] then return end
    local Class = self.Classes[name]
    local Data = ctable(Class)
    local ptable = {}
    local p = GetPointer(ptable)
    local id = name..p
    self.ClassInstances[id] = Data
    Data = self.ClassInstances[id]
    if Data.constructor then
        getfenv(Data.constructor).this = classes.this(id)
    end
    for i,v in pairs(Data) do
      if Split(tostring(v), ":") then
        local spl = Split(tostring(v),":")
        if spl[1] then
          if spl[1] == "StaticObject" then
            Data[i] = nil
          end
        end
      end
  end
    setmetatable(ptable,{
        __call = function(t, ...)
            Data.constructor(...)
            return ptable
        end,
        __index = function(a, b)
            for i,v in pairs(Data) do
                if Split(tostring(v),":") then
                    local spl = Split(tostring(v),":")
                    if spl[1] then
                        if spl[1] == "GetObject" then
                            if spl[2] == b then
                                getfenv(v.ObjectCallback).this = classes.this(id)
                                return v.ObjectCallback()
                            end
                        end
                    end
                end
            end
            local obj = rawget(Data, b)
            if type(obj) == 'function' then
                getfenv(obj).this = classes.this(id)
            end
            return obj
        end,
      __tostring = function(a)
        return name.." Object "..p
      end,
      __newindex = function(a, b, c)
        for i,v in pairs(Data) do
          if Split(tostring(v),":") then
            local spl = Split(tostring(v),":")
            if spl[1] then
                if spl[1] == "SetObject" then
                    if spl[2] == b then
                        getfenv(v.ObjectCallback).this = classes.this(id)
                        return v.ObjectCallback(c)
                    end
                end
            end
          end
        end
      end
    })
    return ptable
end
function init(_env)
  self.ENV = _env
  local env = self.ENV
  env.class = classes.class
  env.new = classes.new
  env.get = classes.get
  env.set = classes.set
  env.static = classes.static
end
return init
