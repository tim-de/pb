package main

import "core:fmt"
import lua "vendor:lua/5.4"

import "buffer"

primitives := []struct{name: cstring, func: lua.CFunction} {
    {
        name = "insert",
        func = insert_mode_primitive,
    },
    {
        name = "command",
        func = command_mode_primitive,
    },
}

insert_mode_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    if ed, ok := get_ed(L); ok {
        ed.mode = .Insert
    }
    return 0
}

command_mode_primitive :: proc "c" (L: ^lua.State) -> (ret_count: i32) {
    if ed, ok := get_ed(L); ok {
        ed.mode = .Command
    }
    return 0
}

@(private="file")
get_ed :: proc "contextless" (L: ^lua.State) -> (ed: ^Editor, ok: bool) {
    if lua.getglobal(L, "Pb") != i32(lua.OK) {
        lua.L_error(L, "Global Pb not found")
        return nil, false
    }
    if lua.getfield(L, -1, "ed") != i32(lua.OK) {
        lua.L_error(L, "failed to get Pb.ed")
        return nil, false
    }
    if !lua.islightuserdata(L, -1) {
        lua.L_error(L, "Pb.ed is not lightuserdata")
        return nil, false
    }
    ed = transmute(^Editor)lua.touserdata(L, -1)
    return ed, true
}
