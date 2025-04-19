package buffer

insert_line :: proc(buf: ^Buffer, line: string) {
    inject_at(&buf.lines, buf.pos, line)
}

delete_line :: proc(buf: ^Buffer) {
    ordered_remove(&buf.lines, buf.pos)
}
