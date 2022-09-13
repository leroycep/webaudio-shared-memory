const std = @import("std");
const js = @import("sysjs");

pub fn main() !void {
    const console = js.global().get("console").view(.object);
    _ = console.call("log", &.{js.createString("All your base are belong to us!").toValue()});
}
