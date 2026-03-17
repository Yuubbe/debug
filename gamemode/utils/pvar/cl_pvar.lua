TKRBASE.LocalData = TKRBASE.LocalData or {}

net.Receive("gSetVar", function()
	local key = net.ReadString()
	local value = net.ReadType()
	TKRBASE.LocalData[key] = value
end)

function gGetLocalVar(key)
	return TKRBASE.LocalData[key]
end

print("utils/pvar/cl_pvar.lua | LOAD !")