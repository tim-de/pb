local write = io.write
Pb = {};

Pb.prompt = function()
    return "-> ";
end

local pb_meta = {
    __call = function(self)
        write(self.prompt() .. "\n");
        io.flush()
    end
};

setmetatable(Pb, pb_meta);
