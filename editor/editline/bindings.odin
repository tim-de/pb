package editline

import "core:c"
import "core:c/libc"
import "core:strings"
foreign import "system:editline"

foreign editline {
    @(private="file", link_name="readline")
    internal_readline :: proc(prompt: cstring) -> cstring ---
    add_history :: proc(line: cstring) ---
    read_history :: proc(filename: cstring) -> c.int ---
    write_history :: proc(filename: cstring) -> c.int ---
    @(link_name="rl_uninitialize")
    uninitialize :: proc() ---
}

readline :: proc(prompt: string) -> string {
    return string(internal_readline(strings.clone_to_cstring(prompt, context.temp_allocator)))
}

free :: proc(line: string) {
    libc.free(rawptr(strings.unsafe_string_to_cstring(line)))
}
