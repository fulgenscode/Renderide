//! Fullscreen pass: samples HDR [`scene_color_hdr`] and writes the displayable color target.
//! `#ifdef MULTIVIEW` selects the per-eye layer; the non-multiview path samples layer 0.
//! Future exposure / tonemap / grading hook.

#import renderide::core::fullscreen as fs
#import renderide::frame::types as ft

@group(0) @binding(0) var scene_color_hdr: texture_2d_array<f32>;
@group(0) @binding(1) var scene_color_sampler: sampler;
@group(0) @binding(2) var<uniform> frame: ft::FrameGlobals;

@vertex
fn vs_main(@builtin(vertex_index) vid: u32) -> fs::FullscreenVertexOutput {
    return fs::vertex_main(vid);
}

@fragment
fn fs_main(
    in: fs::FullscreenVertexOutput,
#ifdef MULTIVIEW
    @builtin(view_index) view: u32,
#endif
) -> @location(0) vec4<f32> {
#ifdef MULTIVIEW
    let layer = i32(view);
#else
    let layer = 0;
#endif
    var hdr = textureSample(scene_color_hdr, scene_color_sampler, in.uv, layer);
    let test = 0.25*fract(f32(frame.frame_tail.x)) ;			// TEST
     	hdr += vec4<f32>(vec3<f32>(test), 0.0) ;
    return vec4<f32>(max(hdr.rgb, vec3<f32>(0.0)), hdr.a);
}
