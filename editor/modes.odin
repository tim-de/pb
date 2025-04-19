package editor

import "core:reflect"
import "core:fmt"
import "core:strings"

import lua "vendor:lua/5.4"

Mode :: enum i32 {
    Command,
    Insert,
}

register_modes :: proc() -> bool {
    if lua.getglobal(ed.state, "Pb") != i32(lua.TTABLE) {
        fmt.eprintln("register_modes: Failed to get Pb global")
        return false
    }
    lua.newtable(ed.state)
    modes := reflect.enum_fields_zipped(Mode)
    for mode in modes {
        lua.pushinteger(ed.state, lua.Integer(mode.value))
        modename := strings.clone_to_cstring(mode.name, context.temp_allocator)
        lua.setfield(ed.state, -2, modename)
    }
    lua.setfield(ed.state, -2, "mode")
    return true
}
