require "useobjlua.base"

boyer_moore = base:subclass("boyer_moore")

function boyer_moore:initialize()
	print("this is boyer_moore:initialize()")
end

function boyer_moore:execute()
	print("==================")
	io.write("������ src : ")
	local src = io.read("*line")
	io.write("������ model: ")
	local model = io.read("*line")
	local res = self:core_cal(src, model)
	if res ~= nil then
		if type(res) == "number" then
			print("�ҵ�~ �ڵ�"..res.."��")
		else
			print("û�ҵ�~")
		end
	else
		print("û�ҵ�~")
	end
	self:exit()
end

function boyer_moore:getGoods(model)
	assert(type(model) == "string")
	local goodChars = {}
	local res = {}
	for i = #model, 1, -1 do
		goodChars[i] = string.sub(model, i, #model)
		res[goodChars[i]] = {} --�ձ�
		table.insert(res[goodChars[i]], i)
		--��ǰ��һ���ַ����������ظ�
		if i >= #model/2 then --�����ظ�
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
    
	--�ú�׺��¼�� --���Ƕ�������Щ�ú�׺�������ú�׺���ظ���Ϣ�������һ��������ûɶ����
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
	--hash��������⻵�ַ��Ƿ���model����
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
	--��ʼ������2����
	for i = #model, 1, -1 do
		local ch = string.sub(model, i, i)
		if charMask[ch] == nil then
			charMask[ch] = {}
		end
		table.insert(charMask[ch], i)
		--table.sort(charMask[ch], function(c1, c2) return c1<c2 end)
		table.insert(goodChars, string.sub(model, i, #model))
	end
	--��ʼ���ú�׺�� --�����ĺú�׺��
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
	--��ʼ 
	--srcIndex ��ʾÿ��ѭ�� ����ʼ��
	local srcIndex = #model
	while srcIndex <= #src do -- ��ʼ�㳬�� src�����򷵻�
		--��Ϊ�������srcIndex��Ҫ�����ˣ����Լ�¼��ʼֵ
	    local saveSrcIndex = srcIndex
		--skipNums��ʾ��һ�� ǰ������λ
		local skipNums = nil
		--badIndex ��ʾ���ַ����֣�model��ʧ���λ��
		local badIndex = nil
		--�����ѭ�����ǣ�model����src�Ƚϣ��ҳ����ַ�
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
		--��ʱ�����badIndexΪ�գ���˵�����е�model�ַ���ƥ���ˣ���ô�����ҵ���ֱ�ӷ���
		--�����Ϊ�գ���˵���������˻��ַ�����ʱ��srcIndex��ʾ���ַ���Ӧ��src���±꣬badIndex��ʾ����ʱ model��Ӧλ�á�
		if badIndex == nil then --�ҵ���
			return srcIndex + 1
		else
			--���ַ����֣���Ҫ�Ƚϻ��ַ� �ͺú�׺ ��һ�� ���ıȽ�Զ
			local badNextIndex
			local goodNextIndex
			--���ַ�
			--badChar: ���ַ���ʲô
			local badChar = string.sub(src, srcIndex, srcIndex)
			--badMaskIndex: ���ַ���model���е�λ��
			local badMaskIndex = nil
			if charMask[badChar] ~= nil then
                for k = #charMask[badChar], 1, -1 do
                    if charMask[badChar][k] < badIndex then
                        badMaskIndex = charMask[badChar][k]
                        break
                    end
                end
			end
			--������ַ�����model���У���ֵΪ0
			if badMaskIndex == nil then
				badMaskIndex = 0
			end
			-- ���ַ�����ǰ������ = ���ַ�����ʱmodel��Ӧ���±�(modelʧ��λ��) - ���ַ���model���е�λ��
			badNextIndex = badIndex - badMaskIndex
			--��һ�������û�кú�׺�� ���� ʧ��λ�� ���� model�������һλ
			if badIndex == #model then --û�кú�׺
				skipNums = badNextIndex
			else
			--�ú�׺
				--��Ϊ����goodCharsPosTable�Ľṹ������ֻ��Ҫ�жϺ�׺�����һλ�Ϳ����ˡ�
                local goodSuffix = goodChars[1]
				--������һλû���ظ������û��ַ����򣬷���ʹ�úú�׺
                if #goodCharsPosTable[goodSuffix] > 1 then
                    local tmpIndex = nil
					--�Ӻú�׺���ҳ� С��ʧ��λ��ֵ�����ֵ
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