const std = @import("std");
const js = @import("sysjs");

pub fn main() !void {
    const console = js.global().get("console").view(.object);
    _ = console.call("log", &.{js.createString("All your base are belong to us!").toValue()});
}

var start_time: f32 = 0.0;
var stop_time: f32 = 0.0;
var audio_buffer: [1024]f32 = undefined;
pub export fn process(time: f32, sample_rate: f32, length: usize) ?[*]const f32 {
    if (length >= audio_buffer.len) return null;

    for (audio_buffer[0..length]) |*sample, sample_index| {
        const sample_time = time + @intToFloat(f32, sample_index) / sample_rate;
        if (sample_time > stop_time) {
            sample.* = 0;
            continue;
        }

        const duration = stop_time - start_time;
        const progress_through_note = (sample_time - start_time) / duration;
        const gain = (1.0 - progress_through_note) * (1.0 - progress_through_note);

        const frequency = 440.0;
        sample.* = std.math.sin(2.0 * std.math.pi * sample_time * frequency) * gain;
    }

    return &audio_buffer;
}

pub export fn playSineWave(time: f32) void {
    start_time = time;
    stop_time = time + 1.0;
}
