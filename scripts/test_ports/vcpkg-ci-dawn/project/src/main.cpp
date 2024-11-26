//
// Copyright (c) 2024 xiaozhuai
//

#include <vector>

#include "assert.hpp"
#include "log.hpp"
#include "webgpu_utils.hpp"
#include "window.hpp"

struct alignas(16) Uniforms {
    struct {
        float width = 0.0f;
        float height = 0.0f;
    } resolution;
    float time = 0.0f;
};

int main() {
    Window window;
    window.set_title("vcpkg-ci-dawn").set_size(1024, 1024).set_resizeable(true).open();

    auto instance = create_instance();
    auto surface = window.create_surface(instance);
    auto adapter = request_adapter(instance, surface);
    auto device = request_device(instance, adapter);
    auto queue = device.GetQueue();
    window.configure_surface(adapter, device);

    std::string shader_source = R"(
struct Uniforms {
    resolution: vec2f,
    time: f32,
};

@group(0)
@binding(0)
var<uniform> uniforms: Uniforms;

struct VertexInput {
    @location(0)
    pos: vec2f,
};

struct VertexOutput {
    @builtin(position)
    pos: vec4f,
};

@vertex
fn vs_main(input: VertexInput) -> VertexOutput {
    var output: VertexOutput;
    output.pos = vec4f(input.pos, 0.0, 1.0);
    return output;
}

struct FragmentInput {
    @builtin(position)
    coord: vec4f,
};

struct FragmentOutput {
    @location(0)
    color: vec4f,
};

fn palette(t: f32) -> vec3f{
    let a = vec3f(0.5, 0.5, 0.5);
    let b = vec3f(0.5, 0.5, 0.5);
    let c = vec3f(1.0, 1.0, 1.0);
    let d = vec3f(0.263, 0.416, 0.557);
    return a + b * cos(6.28318 * (c * t + d));
}

@fragment
fn fs_main(input: FragmentInput) -> FragmentOutput {
    var uv = (input.coord.xy * 2.0 - uniforms.resolution) / min(uniforms.resolution.x, uniforms.resolution.y);
    let uv0 = uv;
    var color = vec3f(0.0);
    for (var i: f32 = 0.0; i < 4.0; i += 1.0) {
        uv = fract(uv * 1.5) - 0.5;
        var d = length(uv) * exp(-length(uv0));
        let col = palette(length(uv0) + i * 0.4 + uniforms.time * 0.4);
        d = sin(d * 8.0 + uniforms.time) / 8.0;
        d = abs(d);
        d = pow(0.01 / d, 1.2);
        color += col * d;
    }
    var output: FragmentOutput;
    output.color = vec4f(color, 1.0);
    return output;
}
)";
    auto shader_module = create_shader(device, shader_source);

    const float vertices[12] = {-1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0};
    const int vertex_count = sizeof(vertices) / sizeof(vertices[0]) / 2;
    wgpu::BufferDescriptor vertex_buffer_desc;
    vertex_buffer_desc.size = sizeof(vertices);
    vertex_buffer_desc.usage = wgpu::BufferUsage::Vertex | wgpu::BufferUsage::CopyDst;
    wgpu::Buffer vertex_buffer = device.CreateBuffer(&vertex_buffer_desc);
    queue.WriteBuffer(vertex_buffer, 0, vertices, sizeof(vertices));

    Uniforms uniforms;
    wgpu::BufferDescriptor uniform_buffer_desc;
    uniform_buffer_desc.size = sizeof(uniforms);
    uniform_buffer_desc.usage = wgpu::BufferUsage::Uniform | wgpu::BufferUsage::CopyDst;
    wgpu::Buffer uniform_buffer = device.CreateBuffer(&uniform_buffer_desc);
    queue.WriteBuffer(uniform_buffer, 0, &uniforms, sizeof(uniforms));

    wgpu::RenderPipelineDescriptor pipeline_desc;

    std::vector<wgpu::VertexAttribute> vertex_attributes(1);
    vertex_attributes[0].format = wgpu::VertexFormat::Float32x2;
    vertex_attributes[0].offset = 0;
    vertex_attributes[0].shaderLocation = 0;
    std::vector<wgpu::VertexBufferLayout> vertex_layouts(1);
    vertex_layouts[0].arrayStride = 2 * sizeof(float);
    vertex_layouts[0].attributeCount = vertex_attributes.size();
    vertex_layouts[0].attributes = vertex_attributes.data();
    vertex_layouts[0].stepMode = wgpu::VertexStepMode::Vertex;

    pipeline_desc.vertex.bufferCount = vertex_layouts.size();
    pipeline_desc.vertex.buffers = vertex_layouts.data();

    pipeline_desc.vertex.module = shader_module;
    pipeline_desc.vertex.entryPoint = "vs_main";
    pipeline_desc.vertex.constantCount = 0;
    pipeline_desc.vertex.constants = nullptr;

    pipeline_desc.primitive.topology = wgpu::PrimitiveTopology::TriangleList;
    pipeline_desc.primitive.stripIndexFormat = wgpu::IndexFormat::Undefined;
    pipeline_desc.primitive.frontFace = wgpu::FrontFace::CCW;
    pipeline_desc.primitive.cullMode = wgpu::CullMode::None;

    wgpu::FragmentState fragment_state;
    fragment_state.module = shader_module;
    fragment_state.entryPoint = "fs_main";
    fragment_state.constantCount = 0;
    fragment_state.constants = nullptr;

    wgpu::BlendState blend_state;
    blend_state.color.srcFactor = wgpu::BlendFactor::SrcAlpha;
    blend_state.color.dstFactor = wgpu::BlendFactor::OneMinusSrcAlpha;
    blend_state.color.operation = wgpu::BlendOperation::Add;
    blend_state.alpha.srcFactor = wgpu::BlendFactor::Zero;
    blend_state.alpha.dstFactor = wgpu::BlendFactor::One;
    blend_state.alpha.operation = wgpu::BlendOperation::Add;

    wgpu::ColorTargetState color_target;
    color_target.format = window.surface_format();
    color_target.blend = &blend_state;
    color_target.writeMask = wgpu::ColorWriteMask::All;

    fragment_state.targetCount = 1;
    fragment_state.targets = &color_target;
    pipeline_desc.fragment = &fragment_state;

    pipeline_desc.depthStencil = nullptr;
    pipeline_desc.multisample.count = 1;
    pipeline_desc.multisample.mask = ~0u;

    pipeline_desc.multisample.alphaToCoverageEnabled = false;
    pipeline_desc.layout = nullptr;

    wgpu::RenderPipeline pipeline = device.CreateRenderPipeline(&pipeline_desc);

    auto create_bind_group = [&]() {
        std::vector<wgpu::BindGroupEntry> bind_group_entries(1);
        bind_group_entries[0].binding = 0;
        bind_group_entries[0].buffer = uniform_buffer;
        bind_group_entries[0].size = uniform_buffer.GetSize();

        wgpu::BindGroupDescriptor bind_group_desc;
        bind_group_desc.layout = pipeline.GetBindGroupLayout(0);
        bind_group_desc.entryCount = bind_group_entries.size();
        bind_group_desc.entries = bind_group_entries.data();
        return device.CreateBindGroup(&bind_group_desc);
    };
    wgpu::BindGroup bind_group = create_bind_group();

    const double start_time = glfwGetTime();
    window.on_update([&](wgpu::Surface &surface) {
        const double time = glfwGetTime() - start_time;

        wgpu::SurfaceTexture surface_texture;
        surface.GetCurrentTexture(&surface_texture);
        ASSERT(surface_texture.status == wgpu::SurfaceGetCurrentTextureStatus::SuccessOptimal ||
                   surface_texture.status == wgpu::SurfaceGetCurrentTextureStatus::SuccessSuboptimal,
               "Failed to get current texture");
        if (surface_texture.status == wgpu::SurfaceGetCurrentTextureStatus::SuccessSuboptimal) {
            LOGW("Surface texture is suboptimal");
        }

        wgpu::Texture texture = surface_texture.texture;
        wgpu::TextureView frame = texture.CreateView();

        uniforms.resolution.width = float(texture.GetWidth());
        uniforms.resolution.height = float(texture.GetHeight());
        uniforms.time = float(time);
        queue.WriteBuffer(uniform_buffer, 0, &uniforms, sizeof(uniforms));

        auto encoder = device.CreateCommandEncoder();

        wgpu::RenderPassColorAttachment color_attachment;
        color_attachment.view = frame;
        color_attachment.loadOp = wgpu::LoadOp::Undefined;
        color_attachment.storeOp = wgpu::StoreOp::Store;
        color_attachment.clearValue = {0.1f, 0.2f, 0.3f, 1.0f};
        wgpu::RenderPassDescriptor pass_desc;
        pass_desc.colorAttachmentCount = 1;
        pass_desc.colorAttachments = &color_attachment;
        pass_desc.depthStencilAttachment = nullptr;

        {
            color_attachment.loadOp = wgpu::LoadOp::Clear;
            auto pass = encoder.BeginRenderPass(&pass_desc);
            pass.SetPipeline(pipeline);
            pass.SetVertexBuffer(0, vertex_buffer, 0, vertex_buffer.GetSize());
            pass.SetBindGroup(0, bind_group, 0, nullptr);
            pass.Draw(vertex_count);
            pass.End();
        }

        wgpu::CommandBuffer command_buffer = encoder.Finish();
        queue.Submit(1, &command_buffer);
    });
    window.exec(device);
    return 0;
}
