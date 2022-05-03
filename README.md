# Lua Classes!
## This module lets you create javascript-like classes in lua!

You should have some understanding of javascript classes including: constructors, getters/setters, and statics to use this.

### Installation
Your lua version needs `getfenv()`
To install, copy the source code into a new lua file and name it "classes.lua"
You require it by doing 
```lua
require("classes")
```
and initialize it by doing
```lua
require("classes")(getfenv())
```

### Creating a class
You can easily create a class by typing `class 'class_name' {}`
Here is an example of using this to create a user.
```lua
require("classes")(getfenv())
class 'User' {
  constructor = function(first_name, last_name, age)
    this.first_name = first_name
    this.last_name = last_name
    this.age = age
  end,
  get 'full_name' {
    function()
      return this.first_name.." "..this.last_name
    end
  },
  set 'full_name' {
    function(t)
      this.first_name = t[1]
      this.last_name = t[2]
    end
  }
}
```
### Using classes
Using our example from before, you can do this.
```lua
local John = new "User" ("John", "Smith", 29)
print(John.full_name) --> John Smith
John.full_name = {"John", "Doe")
print(John.full_name) --> John Doe
```
### Getters and Setters
#### Getters
Getters allow you to define properties
Here is an example:
```lua
class "User" {
  constructor = function(first_name, last_name, age)
    this.first_name = first_name
    this.last_name = last_name
    this.age = age
  end,
  get 'full_name' {
		function()
			return this.first_name.." "..this.last_name
		end
  }
}
local John = new "User" ("John", "Smith", 29)
print(John.full_name) -- "John Smith"
```
#### Setters
Setters allow you to run code when you change a property.
Here is an example:
```lua
class "User" {
  constructor = function(first_name, last_name, age)
    this.first_name = first_name
    this.last_name = last_name
    this.age = age
  end,
  get 'age' {
		function()
			return this.age
		end
  },
  set 'age' {
	function(age)
		if age < this.age then
			return print(("Cannot set %s's age to something less than its current age"):format(this.first_name))
		else
			this.age = age
		end
	end
  }
}
local John = new "User" ("John", "Smith", 29)
print(John.age) --> 29
John.age = 100
print(John.age) --> 100
John.age = 99 --> Cannot set John's age to something less than its current age
print(John.age) --> 100
```
### Prototype
You can add to methods and properties to classes using `prototype`
Here is an example using the same class as above.
```lua
User.prototype.double_age = function()
  return this.age * 2
end
local John = new "User" ("John", "Smith", 29)
print(John.double_age) --> 58
```

### Advanced
You can even make a function return a class!
Example:
```lua
function MakeRectangle(length, width)
	return class {
		constructor = function()
			this.length = length
			this.width = width
		end,
		get 'area' {
			function()
				return this.length * this.width
			end
		},
		set 'area' {
			function(new_area)
				this.length = new_area/2
				this.width = new_area/2
			end
		}
	}
end
local MyRectangle = MakeRectangle(20, 40)
local Rect = new (MyRectangle)()
print(Rect.area) --> 800
```
### Errors
Your code editor probably tells you that many things are undefined including 'class', 'new', 'get', 'set', 'static', 'this', and any names of the classes.
To silence these errors, put this before you initialize this module:
```lua
class, new, get, set, static, this = nil, nil, nil, nil, nil, nil
```

Thats it! Its a pretty simple module.
