vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # this mirrors ImGui's portfile behavior

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pthom/hello_imgui
    REF "v${VERSION}"
    SHA512 b44741e27278974f6a545a3143abd18027d98503cc912085e08528c467197fb208d2d4876e483f74e518f3dfc14d12c3579e379b9939dc364a1fff4ee98bb8f5
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "opengl3-binding" HELLOIMGUI_HAS_OPENGL3
    "metal-binding" HELLOIMGUI_HAS_METAL
    "experimental-vulkan-binding" HELLOIMGUI_HAS_VULKAN
    "experimental-dx11-binding" HELLOIMGUI_HAS_DIRECTX11
    "experimental-dx12-binding" HELLOIMGUI_HAS_DIRECTX12
    "glfw-binding" HELLOIMGUI_USE_GLFW3
    "sdl2-binding" HELLOIMGUI_USE_SDL2
    "freetype-lunasvg" HELLOIMGUI_USE_FREETYPE # When hello_imgui is built with freetype, it will also build with lunasvg
)

if (NOT HELLOIMGUI_HAS_OPENGL3
    AND NOT HELLOIMGUI_HAS_METAL
    AND NOT HELLOIMGUI_HAS_VULKAN
    AND NOT HELLOIMGUI_HAS_DIRECTX11
    AND NOT HELLOIMGUI_HAS_DIRECTX12)
    set(no_rendering_backend ON)
endif()

if (NOT HELLOIMGUI_USE_GLFW3 AND NOT HELLOIMGUI_USE_SDL2)
    set(no_platform_backend ON)
endif()


set(platform_options "")
if(VCPKG_TARGET_IS_WINDOWS)
    # Standard win32 options (these are the defaults for HelloImGui)
    # we could add a vcpkg feature for this, but it would have to be platform specific
    list(APPEND platform_options
        -DHELLOIMGUI_WIN32_NO_CONSOLE=ON
        -DHELLOIMGUI_WIN32_AUTO_WINMAIN=ON
    )
endif()

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    # Standard macOS options (these are the defaults for HelloImGui)
    # we could add a vcpkg feature for this, but it would have to be platform specific
    list(APPEND platform_options
        -DHELLOIMGUI_MACOS_NO_BUNDLE=OFF
    )
endif()


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHELLOIMGUI_BUILD_DEMOS=OFF
        -DHELLOIMGUI_BUILD_DOCS=OFF
        -DHELLOIMGUI_BUILD_TESTS=OFF

        # vcpkg does not support ImGui Test Engine, so we cannot enable it
        -DHELLOIMGUI_WITH_TEST_ENGINE=OFF

        -DHELLOIMGUI_USE_IMGUI_CMAKE_PACKAGE=ON
        -DHELLO_IMGUI_IMGUI_SHARED=OFF
        -DHELLOIMGUI_BUILD_IMGUI=OFF

        ${platform_options}

        # Rendering backends
        -DHELLOIMGUI_HAS_OPENGL3=${HELLOIMGUI_HAS_OPENGL3}
        -DHELLOIMGUI_HAS_METAL=${HELLOIMGUI_HAS_METAL}
        -DHELLOIMGUI_HAS_VULKAN=${HELLOIMGUI_HAS_VULKAN}
        -DHELLOIMGUI_HAS_DIRECTX11=${HELLOIMGUI_HAS_DIRECTX11}
        -DHELLOIMGUI_HAS_DIRECTX12=${HELLOIMGUI_HAS_DIRECTX12}

        # Platform backends
        -DHELLOIMGUI_USE_GLFW3=${HELLOIMGUI_USE_GLFW3}
        -DHELLOIMGUI_USE_SDL2=${HELLOIMGUI_USE_SDL2}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/hello_imgui PACKAGE_NAME "hello-imgui")  # should be active once himgui produces a config

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/hello-imgui/hello_imgui_cmake/ios-cmake"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if (no_rendering_backend OR no_platform_backend)
    message(STATUS "
    ########################################################################
       !!!!                    WARNING                              !!!!!
       !!!!   Installed hello-imgui without a viable backend        !!!!!
    ########################################################################

    When installing hello-imgui, you should specify:

     - At least one (or more) rendering backend (OpenGL3, Metal, Vulkan, DirectX11, DirectX12)
       Make your choice according to your needs and your target platforms, between:
          opengl3-binding              # This is the recommended choice, especially for beginners
          metal-binding                # Apple only, advanced users only
          experimental-vulkan-binding  # Advanced users only
          experimental-dx11-binding    # Windows only, still experimental
          experimental-dx12-binding    # Windows only, advanced users only, still experimental

     - At least one (or more) platform backend (SDL2, Glfw3):
      Make your choice according to your needs and your target platforms, between:
          glfw-binding
          sdl-binding

    For example, you could use:
        vcpkg install \"hello-imgui[opengl3-binding,glfw-binding]\"

    ########################################################################
       !!!!                    WARNING                              !!!!!
       !!!!   Installed hello-imgui without a viable backend        !!!!!
    ########################################################################
    ")
endif()
