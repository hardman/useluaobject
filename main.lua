--package.path = package.path ..";C:\\Users\\dodo\\Desktop\\git\ user\\?.lua" require "main"
--dofile "C:\\Users\\dodo\\Desktop\\git\ user\\main.lua"


require "useobjlua.config"

configKeyTable = {}
--����
for i,v in pairs(configs) do
	require(v)
	if type(i) == "string" then
		table.insert(configKeyTable, i)
	end
end
--����
table.sort(configKeyTable, 
function (c1, c2)
	return c1 > c2
end
)
--��ʾ
while true do
	print("������(q�˳�):")
	for i = 1, #configKeyTable do
		print(""..i..": "..configKeyTable[i])
	end
	io.write("����:")
	local num = io.read("*line") --��ȡһ������
	if num ~= nil then
		local innerNum = tonumber(num)
		if innerNum == nil then
			if type(num) == "string" and num == "q" then
				break;
			else
				print("�������1")
			end
		else
			if innerNum >= 0 and innerNum <= #configKeyTable then
				require(configs[configKeyTable[innerNum]])
				local obj = objectlua.Object:find(configKeyTable[innerNum])
				if obj ~= nil then
					local objInstance = obj:new()
					if objInstance ~= nil then
						if objInstance.execute ~= nil then
							objInstance:execute()
						else
							print("����1")
						end
					else
						print("����2")
					end
				else
					print("����3")
				end
			else
				print("�������2")
			end
		end
	else
		break
	end
end