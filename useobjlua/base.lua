require "objectlua.init"

base = objectlua.Object:subclass("base")

function base:initialize()
	print("this is base:initialize()")
end

function base:execute()
	print("this is base:execute")
	self:exit()
end

function base:exit()
	print("this is base:exit")
end