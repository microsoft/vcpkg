//
// Copyright (c) 2024 xiaozhuai
//

#include "window.hpp"

#include "assert.hpp"
#include "webgpu_glfw.hpp"

static void glfw_error_callback(int error, const char *description) { LOGE("GLFW error, {}, {}", error, description); }

static Window *window_singleton_ = nullptr;

Window::Window() {
    ASSERT(window_singleton_ == nullptr, "Window should be singleton");
    window_singleton_ = this;
    glfwSetErrorCallback(glfw_error_callback);
    ASSERT(glfwInit(), "GLFW init failed");
}

Window::~Window() {
    if (window_ != nullptr) {
        glfwDestroyWindow(window_);
        window_ = nullptr;
    }
    window_singleton_ = nullptr;
    glfwTerminate();
}

void Window::open() {
    ASSERT(!opened(), "Window already opened");
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindowHint(GLFW_RESIZABLE, resizeable_ ? GLFW_TRUE : GLFW_FALSE);
    window_ = glfwCreateWindow(width_, height_, title_.c_str(), nullptr, nullptr);

    glfwSetWindowUserPointer(window_, this);
    setup_callbacks();
    if (on_open_) {
        on_open_();
    }
}

wgpu::Surface Window::create_surface(wgpu::Instance &instance) {
    surface_ = wgpu::glfw::CreateSurfaceForWindow(instance, window_);
    return surface_;
}

void Window::configure_surface(wgpu::Adapter &adapter, wgpu::Device &device) {
    glfwGetFramebufferSize(window_, &fb_width_, &fb_height_);
    wgpu::SurfaceCapabilities surface_capabilities;
    surface_.GetCapabilities(adapter, &surface_capabilities);
    surface_format_ = surface_capabilities.formats[0];
    supported_present_modes_.reserve(surface_capabilities.presentModeCount);
    supported_present_mode_names_.reserve(surface_capabilities.presentModeCount);
    for (size_t i = 0; i < surface_capabilities.presentModeCount; i++) {
        auto mode = surface_capabilities.presentModes[i];
        const char *name;
        switch (mode) {
            case wgpu::PresentMode::Fifo:
                name = "Fifo";
                break;
            case wgpu::PresentMode::FifoRelaxed:
                name = "FifoRelaxed";
                break;
            case wgpu::PresentMode::Immediate:
                name = "Immediate";
                break;
            case wgpu::PresentMode::Mailbox:
                name = "Mailbox";
                break;
            default:
                ASSERT(false, "Unknown PresentMode");
        }
        supported_present_modes_.emplace_back(mode);
        supported_present_mode_names_.emplace_back(name);
    }

    surface_config_.device = device;
    surface_config_.usage = wgpu::TextureUsage::RenderAttachment;
    surface_config_.format = surface_format_;
    surface_config_.presentMode = supported_present_modes_[present_mode_index_];
    surface_config_.alphaMode = surface_capabilities.alphaModes[0];
    surface_config_.width = fb_width_;
    surface_config_.height = fb_height_;
    surface_.Configure(&surface_config_);
}

void Window::exec(wgpu::Device &device) {
    ASSERT(opened(), "Window not opened");
    executing_ = true;
    while (!glfwWindowShouldClose(window_)) {
        glfwPollEvents();
        if (surface_config_dirty_) {
            surface_.Configure(&surface_config_);
            surface_config_dirty_ = false;
        }
#if defined(__EMSCRIPTEN__)
        emscripten_sleep(0);
#endif
        if (on_update_) {
            on_update_(surface_);
        }
#if !defined(__EMSCRIPTEN__)
        surface_.Present();
        device.Tick();
#endif
    }
    executing_ = false;
    if (on_close_) {
        on_close_();
    }
    glfwDestroyWindow(window_);
    window_ = nullptr;
}

void Window::close() {
    ASSERT(opened(), "Window not opened");
    if (executing_) {
        glfwSetWindowShouldClose(window_, GLFW_TRUE);
    } else {
        if (on_close_) {
            on_close_();
        }
        glfwDestroyWindow(window_);
        window_ = nullptr;
    }
}

void Window::setup_callbacks() {
    glfwSetWindowSizeCallback(window_, [](GLFWwindow *window, int width, int height) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        self->width_ = width;
        self->height_ = height;
        if (self->on_resize_) {
            self->on_resize_(width, height);
        }
    });
    glfwSetFramebufferSizeCallback(window_, [](GLFWwindow *window, int width, int height) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        self->fb_width_ = width;
        self->fb_height_ = height;
        self->surface_config_.width = self->fb_width_;
        self->surface_config_.height = self->fb_height_;
        self->surface_config_dirty_ = true;
        if (self->on_fb_size_) {
            self->on_fb_size_(width, height);
        }
    });
    glfwSetKeyCallback(window_, [](GLFWwindow *window, int key, int scancode, int action, int mods) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_key_) {
            self->on_key_(key, scancode, action, mods);
        }
        if (key == GLFW_KEY_ESCAPE && action == GLFW_RELEASE && self->close_on_esc_) {
            self->close();
        }
    });
    glfwSetMouseButtonCallback(window_, [](GLFWwindow *window, int button, int action, int mods) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_mouse_button_) {
            self->on_mouse_button_(button, action, mods);
        }
    });
    glfwSetCursorPosCallback(window_, [](GLFWwindow *window, double x, double y) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_mouse_move_) {
            self->on_mouse_move_(x, y);
        }
    });
    glfwSetScrollCallback(window_, [](GLFWwindow *window, double delta_x, double delta_y) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_mouse_scroll_) {
            self->on_mouse_scroll_(delta_x, delta_y);
        }
    });
    glfwSetCharCallback(window_, [](GLFWwindow *window, unsigned int codepoint) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_char_) {
            self->on_char_(codepoint);
        }
    });
    glfwSetDropCallback(window_, [](GLFWwindow *window, int count, const char **paths) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_drop_) {
            std::vector<std::string> vec(count);
            for (int i = 0; i < count; i++) {
                vec[i] = paths[i];
            }
            self->on_drop_(vec);
        }
    });
    glfwSetCursorEnterCallback(window_, [](GLFWwindow *window, int entered) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_cursor_enter_) {
            self->on_cursor_enter_(entered);
        }
    });
    glfwSetWindowFocusCallback(window_, [](GLFWwindow *window, int focused) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_focus_) {
            self->on_focus_(focused);
        }
    });
    glfwSetWindowIconifyCallback(window_, [](GLFWwindow *window, int iconified) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_iconify_) {
            self->on_iconify_(iconified);
        }
    });
    glfwSetWindowMaximizeCallback(window_, [](GLFWwindow *window, int maximized) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_maximize_) {
            self->on_maximize_(maximized);
        }
    });
    glfwSetWindowPosCallback(window_, [](GLFWwindow *window, int x, int y) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_window_move_) {
            self->on_window_move_(x, y);
        }
    });
    glfwSetWindowRefreshCallback(window_, [](GLFWwindow *window) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_refresh_) {
            self->on_refresh_();
        }
    });
    glfwSetWindowContentScaleCallback(window_, [](GLFWwindow *window, float xscale, float yscale) {
        auto *self = ((Window *)glfwGetWindowUserPointer(window));
        if (self->on_content_scale_) {
            self->on_content_scale_(xscale, yscale);
        }
    });
}
