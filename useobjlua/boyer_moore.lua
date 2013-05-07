require "useobjlua.base"

boyer_moore = base:subclass("boyer_moore")

function boyer_moore:initialize()
	print("this is boyer_moore:initialize()")
end

function boyer_moore:execute()
	print("==================")
	io.write("请输入 src : ")
	local src = io.read("*line")
	io.write("请输入 model: ")
	local model = io.read("*line")
	local res = self:core_cal(src, model)
	if res ~= nil then
		if type(res) == "number" then
			print("找到~ 在第"..res.."个")
		else
			print("没找到~")
		end
	else
		print("没找到~")
	end
	self:exit()
end

function boyer_moore:getGoods(model)
	assert(type(model) == "string")
	local goodChars = {}
	local res = {}
	for i = #model, 1, -1 do
		goodChars[i] = string.sub(model, i, #model)
		res[goodChars[i]] = {} --空表
		table.insert(res[goodChars[i]], i)
		--在前面一半字符串中搜索重复
		if i >= #model/2 then --可能重复
			for j = i-1, 1, 0-#goodChars[i] do
		        local findModel = string.sub(model, 1, i-1)
				local start = j - #goodChars[i] + 1
				local found = string.find(findModel, goodChars[i], start)
				if found ~= nil then
					table.insert(res[goodChars[i]], found)
				end
			end
		end
	end
	return res
end

function boyer_moore:core_cal(src, model)
	assert(type(src) == "string")
	assert(type(model) == "string")
    
	--好后缀记录表 --就是都包含哪些好后缀，不带好后缀的重复信息。这个是一个帮助表，没啥意义
	--[[
		goodChars = {
			e = 7,
			le = 6,
			ple = 5,
			mple = 4,
			ample = 3,
			xample = 2,
			example = 1,
		}
	--]]
    local goodChars = {}
	--hash表用来检测坏字符是否在model串中
	--[[
		charMask = {
			e = {7, 1},
			x = {2},
			a = {3},
			m = {4},
			p = {5},
			l = {6},
		}
	--]]
	local charMask = {}
	--初始化上述2个表
	for i = #model, 1, -1 do
		local ch = string.sub(model, i, i)
		if charMask[ch] == nil then
			charMask[ch] = {}
		end
		table.insert(charMask[ch], i)
		--table.sort(charMask[ch], function(c1, c2) return c1<c2 end)
		table.insert(goodChars, string.sub(model, i, #model))
	end
	--初始化好后缀表 --真正的好后缀表
	--[[
		goodCharsPopTable = {
			e = {7, 1},
			le = {6},
			ple = {5},
			mple = {4},
			ample = {3},
			xample = {2},
			example = {1},
		}
	--]]
	local goodCharsPosTable = self:getGoods(model)
	--开始 
	--srcIndex 表示每次循环 的起始点
	local srcIndex = #model
	while srcIndex <= #src do -- 起始点超过 src长度则返回
		--因为下面过程srcIndex需要往回退，所以记录初始值
	    local saveSrcIndex = srcIndex
		--skipNums表示这一次 前进多少位
		local skipNums = nil
		--badIndex 表示坏字符出现，model串失配的位置
		local badIndex = nil
		--下面的循环就是，model串与src比较，找出坏字符
		for j = #model, 1, -1 do
			local srcChar = string.sub(src, srcIndex, srcIndex)
			local modelChar = string.sub(model, j, j)
			if srcChar == modelChar then
				srcIndex = srcIndex - 1
			else
				badIndex = j
				break;
			end
		end
		--此时，如果badIndex为空，则说明所有的model字符都匹配了，那么就是找到了直接返回
		--如果不为空，则说明，出现了坏字符，此时，srcIndex表示坏字符对应的src的下标，badIndex表示，此时 model对应位置。
		if badIndex == nil then --找到了
			return srcIndex + 1
		else
			--坏字符出现，需要比较坏字符 和好后缀 哪一个 跳的比较远
			local badNextIndex
			local goodNextIndex
			--坏字符
			--badChar: 坏字符是什么
			local badChar = string.sub(src, srcIndex, srcIndex)
			--badMaskIndex: 坏字符在model串中的位置
			local badMaskIndex = nil
			if charMask[badChar] ~= nil then
                for k = #charMask[badChar], 1, -1 do
                    if charMask[badChar][k] < badIndex then
                        badMaskIndex = charMask[badChar][k]
                        break
                    end
                end
			end
			--如果坏字符不在model串中，则赋值为0
			if badMaskIndex == nil then
				badMaskIndex = 0
			end
			-- 坏字符规则：前进步数 = 坏字符出现时model对应的下标(model失配位置) - 坏字符在model串中的位置
			badNextIndex = badIndex - badMaskIndex
			--有一种情况是没有好后缀的 就是 失配位置 就是 model串的最后一位
			if badIndex == #model then --没有好后缀
				skipNums = badNextIndex
			else
			--好后缀
				--因为我们goodCharsPosTable的结构，导致只需要判断后缀的最后一位就可以了。
                local goodSuffix = goodChars[1]
				--如果最后一位没有重复，则用坏字符规则，否则使用好后缀
                if #goodCharsPosTable[goodSuffix] > 1 then
                    local tmpIndex = nil
					--从好后缀中找出 小于失配位置值中最大值
                    for ii = 1, #goodCharsPosTable[goodSuffix] do
                        if goodCharsPosTable[goodSuffix][ii] < badIndex + 1 then
                            tmpIndex = goodCharsPosTable[goodSuffix][ii]
                        end
                    end
                    if tmpIndex ~= nil then
                        goodNextIndex = badIndex + 1 - tmpIndex
                        skipNums = goodNextIndex < badNextIndex and goodNextIndex or badNextIndex
                        break
                    end
                else
                    skipNums = badNextIndex
                end
			end
		end
		srcIndex = saveSrcIndex + skipNums
	end
end

function boyer_moore:exit()
	print("==================")
end