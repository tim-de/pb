package buffer

import "core:os"
import "core:strings"

Buffer :: struct {
    pos: int,
    modified: bool,
    lines: [dynamic]string,
}

destroy :: proc(buf: Buffer, allocator := context.allocator) {
    for line in buf.lines {
        delete(line, allocator)
    }
    delete(buf.lines)
}

new :: proc {
    init_empty,
    load_file_from_path,
    load_file_from_handle,
}

init_empty :: proc() -> (buf: Buffer, ok: bool) {
    return Buffer {
        lines = make([dynamic]string)
    }, true
}

load_file_from_buffer :: proc(data: []u8) -> (buf: Buffer, ok: bool) {
    lines := strings.split_lines(string(data))
    defer delete(lines)
    buf.lines = make([dynamic]string, 0, len(lines))
    for line in lines {
        append(&buf.lines, line)
    }
    return buf, true
}

load_file_from_path :: proc(file_path: string) -> (buf: Buffer, ok: bool) {
    data, success := os.read_entire_file(file_path)
    if !success {
        return Buffer{}, false
    }
    defer delete(data)
    return load_file_from_buffer(data)
}

load_file_from_handle :: proc(file_handle: os.Handle) -> (buf: Buffer, ok: bool) {
    data, success := os.read_entire_file(file_handle)
    if !success {
        return Buffer{}, false
    }
    defer delete(data)
    return load_file_from_buffer(data)
}
