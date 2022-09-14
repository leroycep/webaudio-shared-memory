const std = @import("std");
const js = @import("sysjs");

pub fn main() !void {
    const console = js.global().get("console").view(.object);
    _ = console.call("log", &.{js.createString("All your base are belong to us!").toValue()});
}

var audio_buffer: [1024]f32 = undefined;
pub export fn process(time: f32, sample_rate: f32, length: usize) ?[*]const f32 {
    if (length >= audio_buffer.len) return null;

    for (audio_buffer[0..length]) |*sample, sample_index| {
        const sample_time = time + @intToFloat(f32, sample_index) / sample_rate;
        const frequency = 440.0;
        sample.* = std.math.sin(2.0 * std.math.pi * sample_time * frequency);
    }

    return &audio_buffer;
}
