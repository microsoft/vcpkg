//
// Copyright (c) 2024 xiaozhuai
//

#define GLFW_INCLUDE_NONE

#include <cstdio>
#include <string>
#include <vector>

#include "GLFW/glfw3.h"
#include "webgpu/webgpu_cpp.h"

#if defined(__EMSCRIPTEN__)
#include "emscripten/emscripten.h"
#endif

#define LOG(fmt, ...) printf(fmt "\n", ##__VA_ARGS__)

#if !defined(__PRETTY_FUNCTION__) && !defined(__GNUC__)
#define MY_PRETTY_FUNCTION __FUNCSIG__
#else
#define MY_PRETTY_FUNCTION __PRETTY_FUNCTION__
#endif

#define ASSERT(expr, fmt, ...)                                                        \
    do {                                                                              \
        if (!(expr)) {                                                                \
            LOG("Assertion failed: %s:%d, func: \"%s\", expr: \"%s\", message: " /**/ \
                fmt,                                                             /**/ \
                __FILE__, __LINE__, MY_PRETTY_FUNCTION, #expr,                   /**/ \
                ##__VA_ARGS__);                                                       \
            abort();                                                                  \
        }                                                                             \
    } while (0)

wgpu::Instance create_instance() {
    wgpu::InstanceDescriptor instance_desc;
    std::vector<wgpu::InstanceFeatureName> required_features = {
        wgpu::InstanceFeatureName::TimedWaitAny,
    };
    instance_desc.requiredFeatureCount = required_features.size();
    instance_desc.requiredFeatures = required_features.data();
    return wgpu::CreateInstance(&instance_desc);
}

wgpu::Surface create_surface(const wgpu::Instance &instance, GLFWwindow *window);

wgpu::Adapter request_adapter(const wgpu::Instance &instance, const wgpu::Surface &surface) {
    wgpu::RequestAdapterOptions adapter_options;
    adapter_options.compatibleSurface = surface;
    adapter_options.powerPreference = wgpu::PowerPreference::HighPerformance;

    wgpu::Adapter adapter;
    auto adapter_future = instance.RequestAdapter(
        &adapter_options, wgpu::CallbackMode::WaitAnyOnly,
        [&adapter](wgpu::RequestAdapterStatus status, wgpu::Adapter adapter_ret, wgpu::StringView message) {
            ASSERT(status == wgpu::RequestAdapterStatus::Success && adapter_ret != nullptr, "Failed to get adapter: %s",
                   message.data);
            adapter = std::move(adapter_ret);
        });
    ASSERT(instance.WaitAny(adapter_future, wgpu::kLimitU64Undefined) == wgpu::WaitStatus::Success,
           "Failed to wait for adapter request");

    return adapter;
}

void device_lost_callback(const wgpu::Device &, wgpu::DeviceLostReason, wgpu::StringView message) {
    LOG("Device lost: %s", message.data);
}

void device_uncaptured_error_callback(const wgpu::Device &, wgpu::ErrorType type, wgpu::StringView message) {
    const char *error_type;
    switch (type) {
        case wgpu::ErrorType::Validation:
            error_type = "Validation";
            break;
        case wgpu::ErrorType::OutOfMemory:
            error_type = "Out of memory";
            break;
        case wgpu::ErrorType::Internal:
            error_type = "Internal";
            break;
        case wgpu::ErrorType::Unknown:
            error_type = "Unknown";
            break;
        default:
            ASSERT(false, "Unknown ErrorType");
    }
    LOG("Uncaptured Error %s: %s", error_type, message.data);
}

wgpu::Device request_device(const wgpu::Instance &instance, const wgpu::Adapter &adapter) {
    wgpu::DeviceDescriptor device_desc;

    device_desc.SetDeviceLostCallback(wgpu::CallbackMode::AllowSpontaneous, device_lost_callback);
    device_desc.SetUncapturedErrorCallback(device_uncaptured_error_callback);

    wgpu::Device device;
    auto device_future = adapter.RequestDevice(
        &device_desc, wgpu::CallbackMode::WaitAnyOnly,
        [&device](wgpu::RequestDeviceStatus status, wgpu::Device device_ret, wgpu::StringView message) {
            ASSERT(status == wgpu::RequestDeviceStatus::Success && device_ret != nullptr, "Failed to get device: %s",
                   message.data);
            device = std::move(device_ret);
        });
    ASSERT(instance.WaitAny(device_future, wgpu::kLimitU64Undefined) == wgpu::WaitStatus::Success,
           "Failed to wait for device request");

    return device;
}

wgpu::ShaderModule create_shader(const wgpu::Device &device, const std::string &shader_code) {
    wgpu::ShaderSourceWGSL shader_code_desc;
    shader_code_desc.sType = wgpu::SType::ShaderSourceWGSL;
    shader_code_desc.code = shader_code.c_str();
    wgpu::ShaderModuleDescriptor shader_desc;
    shader_desc.nextInChain = &shader_code_desc;
    return device.CreateShaderModule(&shader_desc);
}

struct alignas(16) Uniforms {
    struct {
        float width = 0.0f;
        float height = 0.0f;
    } resolution;
    float time = 0.0f;
};

void glfw_error_callback(int error, const char *description) { LOG("GLFW error, %d, %s", error, description); }

struct AppState {
    wgpu::Instance instance;
    wgpu::Surface surface;
    wgpu::Adapter adapter;
    wgpu::Device device;
    wgpu::Queue queue;
    wgpu::SurfaceConfiguration surface_config;
    int surface_width = 0;
    int surface_height = 0;
};

int main() {
    glfwSetErrorCallback(glfw_error_callback);
    ASSERT(glfwInit(), "GLFW init failed");
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    auto *window = glfwCreateWindow(1024, 1024, "vcpkg-ci-dawn", nullptr, nullptr);

    AppState state;
    state.instance = create_instance();
    state.surface = create_surface(state.instance, window);
    state.adapter = request_adapter(state.instance, state.surface);
    state.device = request_device(state.instance, state.adapter);
    state.queue = state.device.GetQueue();

    wgpu::SurfaceCapabilities surface_capabilities;
    state.surface.GetCapabilities(state.adapter, &surface_capabilities);
    glfwGetFramebufferSize(window, &state.surface_width, &state.surface_height);

    state.surface_config.device = state.device;
    state.surface_config.usage = wgpu::TextureUsage::RenderAttachment;
    state.surface_config.format = surface_capabilities.formats[0];
    state.surface_config.presentMode = surface_capabilities.presentModes[0];
    state.surface_config.alphaMode = surface_capabilities.alphaModes[0];
    state.surface_config.width = state.surface_width;
    state.surface_config.height = state.surface_height;
    state.surface.Configure(&state.surface_config);

    glfwSetWindowUserPointer(window, &state);

    glfwSetKeyCallback(window, [](GLFWwindow *window, int key, int scancode, int action, int mods) {
        if (key == GLFW_KEY_ESCAPE && action == GLFW_RELEASE) {
            glfwSetWindowShouldClose(window, GLFW_TRUE);
        }
    });
    glfwSetFramebufferSizeCallback(window, [](GLFWwindow *window, int width, int height) {
        auto &state = *static_cast<AppState *>(glfwGetWindowUserPointer(window));
        state.surface_width = width;
        state.surface_height = height;
        state.surface_config.width = width;
        state.surface_config.height = height;
        state.surface.Configure(&state.surface_config);
    });

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
    auto shader_module = create_shader(state.device, shader_source);

    constexpr float vertices[12] = {-1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0};
    constexpr int vertex_count = std::size(vertices) / 2;
    wgpu::BufferDescriptor vertex_buffer_desc;
    vertex_buffer_desc.size = sizeof(vertices);
    vertex_buffer_desc.usage = wgpu::BufferUsage::Vertex | wgpu::BufferUsage::CopyDst;
    wgpu::Buffer vertex_buffer = state.device.CreateBuffer(&vertex_buffer_desc);
    state.queue.WriteBuffer(vertex_buffer, 0, vertices, sizeof(vertices));

    Uniforms uniforms;
    wgpu::BufferDescriptor uniform_buffer_desc;
    uniform_buffer_desc.size = sizeof(uniforms);
    uniform_buffer_desc.usage = wgpu::BufferUsage::Uniform | wgpu::BufferUsage::CopyDst;
    wgpu::Buffer uniform_buffer = state.device.CreateBuffer(&uniform_buffer_desc);
    state.queue.WriteBuffer(uniform_buffer, 0, &uniforms, sizeof(uniforms));

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
    color_target.format = state.surface_config.format;
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

    wgpu::RenderPipeline pipeline = state.device.CreateRenderPipeline(&pipeline_desc);

    std::vector<wgpu::BindGroupEntry> bind_group_entries(1);
    bind_group_entries[0].binding = 0;
    bind_group_entries[0].buffer = uniform_buffer;
    bind_group_entries[0].size = uniform_buffer.GetSize();

    wgpu::BindGroupDescriptor bind_group_desc;
    bind_group_desc.layout = pipeline.GetBindGroupLayout(0);
    bind_group_desc.entryCount = bind_group_entries.size();
    bind_group_desc.entries = bind_group_entries.data();
    wgpu::BindGroup bind_group = state.device.CreateBindGroup(&bind_group_desc);

    const double start_time = glfwGetTime();
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
#if defined(__EMSCRIPTEN__)
        emscripten_sleep(0);
#endif

        const double time = glfwGetTime() - start_time;

        wgpu::SurfaceTexture surface_texture;
        state.surface.GetCurrentTexture(&surface_texture);
        ASSERT(surface_texture.status == wgpu::SurfaceGetCurrentTextureStatus::SuccessOptimal ||
                   surface_texture.status == wgpu::SurfaceGetCurrentTextureStatus::SuccessSuboptimal,
               "Failed to get current texture");
        if (surface_texture.status == wgpu::SurfaceGetCurrentTextureStatus::SuccessSuboptimal) {
            LOG("Surface texture is suboptimal");
        }

        wgpu::Texture texture = surface_texture.texture;
        wgpu::TextureView frame = texture.CreateView();

        uniforms.resolution.width = static_cast<float>(texture.GetWidth());
        uniforms.resolution.height = static_cast<float>(texture.GetHeight());
        uniforms.time = static_cast<float>(time);
        state.queue.WriteBuffer(uniform_buffer, 0, &uniforms, sizeof(uniforms));

        auto encoder = state.device.CreateCommandEncoder();

        wgpu::RenderPassColorAttachment color_attachment;
        color_attachment.view = frame;
        color_attachment.loadOp = wgpu::LoadOp::Clear;
        color_attachment.storeOp = wgpu::StoreOp::Store;
        color_attachment.clearValue = {0.1f, 0.2f, 0.3f, 1.0f};
        wgpu::RenderPassDescriptor pass_desc;
        pass_desc.colorAttachmentCount = 1;
        pass_desc.colorAttachments = &color_attachment;
        pass_desc.depthStencilAttachment = nullptr;

        auto pass = encoder.BeginRenderPass(&pass_desc);
        pass.SetPipeline(pipeline);
        pass.SetVertexBuffer(0, vertex_buffer, 0, vertex_buffer.GetSize());
        pass.SetBindGroup(0, bind_group, 0, nullptr);
        pass.Draw(vertex_count);
        pass.End();

        wgpu::CommandBuffer command_buffer = encoder.Finish();
        state.queue.Submit(1, &command_buffer);

#if !defined(__EMSCRIPTEN__)
        ASSERT(state.surface.Present(), "Failed to present the surface");
        state.device.Tick();
#endif
    }

    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}
