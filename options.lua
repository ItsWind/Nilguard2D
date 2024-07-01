local this = {}

function this.SaveCurrentOptions()
	local luaFileStr = [[local this = {}

this.volume = %f

return this]]

	luaFileStr = luaFileStr:format(Sounds.GetMasterVolume())

	local homeDirectoryString = Util.GetHomeDirectory()
	--os.execute("mkdir \"" .. homeDirectoryString .. "\\_options\"")
	love.filesystem.createDirectory("_options")
	local file, err = io.open(love.filesystem.getSaveDirectory() .. "\\_options\\saved.lua", "w")
	if file then
		file:write(luaFileStr)
		file:close()
	else
		print(err)
	end
end

function this.LoadSavedOptions()
	local savedOptions = nil
	if pcall(function()
		savedOptions = require("_options/saved")
	end) then else
		return
	end

	Sounds.SetMasterVolume(savedOptions.volume)
end

return this