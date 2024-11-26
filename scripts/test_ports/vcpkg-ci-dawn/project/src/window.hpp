//
// Copyright (c) 2024 xiaozhuai
//

#pragma once
#ifndef VCPKG_CI_DAWN_WINDOW_HPP
#define VCPKG_CI_DAWN_WINDOW_HPP

#define GLFW_INCLUDE_NONE

#include <functional>
#include <string>
#include <vector>

#include "GLFW/glfw3.h"
#include "log.hpp"
#include "webgpu/webgpu_cpp.h"

#if defined(__EMSCRIPTEN__)
#include <emscripten/emscripten.h>
#endif

class Window final {
public:
    Window();
    ~Window();

    Window(const Window &) = delete;
    Window &operator=(const Window &) = delete;
    Window(Window &&) = delete;
    Window &operator=(Window &&) = delete;

    void open();

    [[nodiscard]] wgpu::Surface create_surface(wgpu::Instance &instance);

    void configure_surface(wgpu::Adapter &adapter, wgpu::Device &device);

    [[nodiscard]] wgpu::TextureFormat surface_format() const { return surface_format_; }

    void exec(wgpu::Device &device);

    void close();

public:
    inline Window &set_title(std::string title) {
        title_ = std::move(title);
        if (window_) glfwSetWindowTitle(window_, title_.c_str());
        return *this;
    }

    inline Window &set_size(int width, int height) {
        width_ = width;
        height_ = height;
        if (window_) glfwSetWindowSize(window_, width_, height_);
        return *this;
    }

    inline Window &set_resizeable(bool resizeable) {
        resizeable_ = resizeable;
        if (window_) glfwSetWindowAttrib(window_, GLFW_RESIZABLE, resizeable_);
        return *this;
    }

    inline Window &set_close_on_esc(bool close_on_esc) {
        close_on_esc_ = close_on_esc;
        return *this;
    }

    [[nodiscard]] inline bool opened() const { return window_ != nullptr; }

    [[nodiscard]] inline const std::string &title() const { return title_; }

    [[nodiscard]] inline int width() const { return width_; }

    [[nodiscard]] inline int height() const { return height_; }

    [[nodiscard]] inline int fb_width() const { return fb_width_; }

    [[nodiscard]] inline int fb_height() const { return fb_height_; }

    [[nodiscard]] inline float content_scale() const {
        float xscale;
        float yscale;
        glfwGetWindowContentScale(window_, &xscale, &yscale);
        return xscale;
    }

    [[nodiscard]] inline bool resizeable() const { return resizeable_; }

    [[nodiscard]] inline bool close_on_esc() const { return close_on_esc_; }

    [[nodiscard]] inline int get_key(int key) const { return glfwGetKey(window_, key); }

    inline void set_cursor_mode(int mode) const {
#if !defined(__EMSCRIPTEN__)
        glfwSetInputMode(window_, GLFW_CURSOR, mode);
#else
        LOGD("set_cursor_mode() is not supported on Emscripten");
#endif
    }

    inline void get_cursor_pos(double *xpos, double *ypos) const { glfwGetCursorPos(window_, xpos, ypos); }

public:
    using OnOpenCallback = std::function<void()>;
    using OnCloseCallback = std::function<void()>;
    using OnUpdateCallback = std::function<void(wgpu::Surface &surface)>;
    using OnResizeCallback = std::function<void(int width, int height)>;
    using OnFbSizeCallback = std::function<void(int fb_width, int fb_height)>;
    using OnKeyCallback = std::function<void(int key, int scancode, int action, int mods)>;
    using OnMouseButtonCallback = std::function<void(int button, int action, int mods)>;
    using OnMouseMoveCallback = std::function<void(double x, double y)>;
    using OnMouseScrollCallback = std::function<void(double delta_x, double delta_y)>;
    using OnCharCallback = std::function<void(unsigned int codepoint)>;
    using OnCharModsCallback = std::function<void(unsigned int codepoint, int mods)>;
    using OnDropCallback = std::function<void(const std::vector<std::string> &paths)>;
    using OnCursorEnterCallback = std::function<void(bool entered)>;
    using OnFocusCallback = std::function<void(bool focused)>;
    using OnIconifyCallback = std::function<void(bool iconified)>;
    using OnMaximizeCallback = std::function<void(bool maximized)>;
    using OnWindowMoveCallback = std::function<void(int x, int y)>;
    using OnRefreshCallback = std::function<void()>;
    using OnContentScaleCallback = std::function<void(float xscale, float yscale)>;

public:
    inline Window &on_open(OnOpenCallback &&callback) {
        on_open_ = std::move(callback);
        return *this;
    }
    inline Window &on_close(OnCloseCallback &&callback) {
        on_close_ = std::move(callback);
        return *this;
    }
    inline Window &on_update(OnUpdateCallback &&callback) {
        on_update_ = std::move(callback);
        return *this;
    }
    inline Window &on_resize(OnResizeCallback &&callback) {
        on_resize_ = std::move(callback);
        return *this;
    }
    inline Window &on_fb_size(OnFbSizeCallback &&callback) {
        on_fb_size_ = std::move(callback);
        return *this;
    }
    inline Window &on_key(OnKeyCallback &&callback) {
        on_key_ = std::move(callback);
        return *this;
    }
    inline Window &on_mouse_button(OnMouseButtonCallback &&callback) {
        on_mouse_button_ = std::move(callback);
        return *this;
    }
    inline Window &on_mouse_move(OnMouseMoveCallback &&callback) {
        on_mouse_move_ = std::move(callback);
        return *this;
    }
    inline Window &on_mouse_scroll(OnMouseScrollCallback &&callback) {
        on_mouse_scroll_ = std::move(callback);
        return *this;
    }
    inline Window &on_char(OnCharCallback &&callback) {
        on_char_ = std::move(callback);
        return *this;
    }
    inline Window &on_drop(OnDropCallback &&callback) {
        on_drop_ = std::move(callback);
        return *this;
    }
    inline Window &on_cursor_enter(OnCursorEnterCallback &&callback) {
        on_cursor_enter_ = std::move(callback);
        return *this;
    }
    inline Window &on_focus(OnFocusCallback &&callback) {
        on_focus_ = std::move(callback);
        return *this;
    }
    inline Window &on_iconify(OnIconifyCallback &&callback) {
        on_iconify_ = std::move(callback);
        return *this;
    }
    inline Window &on_maximize(OnMaximizeCallback &&callback) {
        on_maximize_ = std::move(callback);
        return *this;
    }
    inline Window &on_window_move(OnWindowMoveCallback &&callback) {
        on_window_move_ = std::move(callback);
        return *this;
    }
    inline Window &on_refresh(OnRefreshCallback &&callback) {
        on_refresh_ = std::move(callback);
        return *this;
    }
    inline Window &on_content_scale(OnContentScaleCallback &&callback) {
        on_content_scale_ = std::move(callback);
        return *this;
    }

private:
    void setup_callbacks();

private:
    wgpu::SurfaceConfiguration surface_config_;
    wgpu::Surface surface_ = nullptr;
    wgpu::TextureFormat surface_format_ = wgpu::TextureFormat::Undefined;
    std::vector<wgpu::PresentMode> supported_present_modes_;
    std::vector<const char *> supported_present_mode_names_;
    int present_mode_index_ = 0;
    bool surface_config_dirty_ = false;

    GLFWwindow *window_ = nullptr;
    bool executing_ = false;
    std::string title_;
    int width_ = 0;
    int height_ = 0;
    int fb_width_ = 0;
    int fb_height_ = 0;
    bool resizeable_ = true;
    bool close_on_esc_ = true;

private:
    OnOpenCallback on_open_;
    OnCloseCallback on_close_;
    OnUpdateCallback on_update_;
    OnResizeCallback on_resize_;
    OnFbSizeCallback on_fb_size_;
    OnKeyCallback on_key_;
    OnMouseButtonCallback on_mouse_button_;
    OnMouseMoveCallback on_mouse_move_;
    OnMouseScrollCallback on_mouse_scroll_;
    OnCharCallback on_char_;
    OnDropCallback on_drop_;
    OnCursorEnterCallback on_cursor_enter_;
    OnFocusCallback on_focus_;
    OnIconifyCallback on_iconify_;
    OnMaximizeCallback on_maximize_;
    OnWindowMoveCallback on_window_move_;
    OnRefreshCallback on_refresh_;
    OnContentScaleCallback on_content_scale_;
};

#endif  // VCPKG_CI_DAWN_WINDOW_HPP
