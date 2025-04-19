package editor

import "base:runtime"

import "core:fmt"
import lua "vendor:lua/5.4"

import "buffer"

primitives :: []struct{name: cstring, func: lua.CFunction} {
    {
        name = "insert",
        func = insert_mode_primitive,
    },
    {
        name = "command",
        func = command_mode_primitive,
    },
}

bind_primitives :: proc() -> bool {
    if lua.getglobal(ed.state, "Pb") != i32(lua.TTABLE) {
        fmt.eprintln("bind_primitives: Failed to get Pb global")
        return false
    }
    lua.newtable(ed.state)
    for primitive in primitives {
        lua.pushcfunction(ed.state, primitive.func)
        lua.setfield(ed.state, -2, primitive.name)
    }
    lua.setfield(ed.state, -2, "primitive")
    return true
}

insert_mode_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    ed.mode = .Insert
    return 0
}

command_mode_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    ed.mode = .Command
    return 0
}

