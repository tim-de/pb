local write = io.write

Pb = {}

Pb.prompt = function()
    return "-> "
end

local pb_meta = {
    __call = function(self)
        write(self.prompt())
        io.flush()
    end
}

Pb.list_modes = function()
    for mode, _ in pairs(Pb.mode) do
        print(mode)
    end
end

setmetatable(Pb, pb_meta)

