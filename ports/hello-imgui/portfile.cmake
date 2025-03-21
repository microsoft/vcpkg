vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # this mirrors ImGui's portfile behavior

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pthom/hello_imgui
    REF "v${VERSION}"
    SHA512 b44741e27278974f6a545a3143abd18027d98503cc912085e08528c467197fb208d2d4876e483f74e518f3dfc14d12c3579e379b9939dc364a1fff4ee98bb8f5
    HEAD_REF master
    PATCHES
        cmake-config.diff
        imgui-test-engine.diff
        # PR has been merged into https://github.com/pthom/hello_imgui/pull/142. This patch should not be needed in the next release.
        support-imgui-1_91_9.patch
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/external/imgui"
    "${SOURCE_PATH}/external/nlohmann_json"
    "${SOURCE_PATH}/external/OpenGL_Loaders"
    "${SOURCE_PATH}/external/stb_hello_imgui/stb_image.h"
    "${SOURCE_PATH}/external/stb_hello_imgui/stb_image_write.h"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        # "target platforms"
        opengl3-binding     HELLOIMGUI_HAS_OPENGL3
        metal-binding       HELLOIMGUI_HAS_METAL
        experimental-vulkan-binding HELLOIMGUI_HAS_VULKAN
        experimental-dx11-binding   HELLOIMGUI_HAS_DIRECTX11
        experimental-dx12-binding   HELLOIMGUI_HAS_DIRECTX12
        # "platform backends"
        glfw-binding        HELLOIMGUI_USE_GLFW3
        # sdl2-binding        HELLOIMGUI_USE_SDL2 # removed with imgui[sdl2-binding]
        # other
        test-engine         HELLOIMGUI_WITH_TEST_ENGINE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DHELLO_IMGUI_IMGUI_SHARED=OFF
        -DHELLOIMGUI_BUILD_DEMOS=OFF
        -DHELLOIMGUI_BUILD_IMGUI=OFF
        -DHELLOIMGUI_FETCH_FORBIDDEN=ON
        -DHELLOIMGUI_FREETYPE_STATIC=OFF
        -DHELLOIMGUI_MACOS_NO_BUNDLE=OFF
        -DHELLOIMGUI_USE_IMGUI_CMAKE_PACKAGE=ON
        -DHELLOIMGUI_WIN32_NO_CONSOLE=ON
        -DHELLOIMGUI_WIN32_AUTO_WINMAIN=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_glad=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_nlohmann_json=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_glad
        HELLOIMGUI_WIN32_NO_CONSOLE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/hello_imgui" PACKAGE_NAME "hello-imgui")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/hello-imgui/hello_imgui_cmake/ios-cmake"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
if (NOT HELLOIMGUI_HAS_OPENGL3
    AND NOT HELLOIMGUI_HAS_METAL
    AND NOT HELLOIMGUI_HAS_VULKAN
    AND NOT HELLOIMGUI_HAS_DIRECTX11
    AND NOT HELLOIMGUI_HAS_DIRECTX12)
    set(no_rendering_backend TRUE)
endif()
if (NOT HELLOIMGUI_USE_GLFW3
    AND NOT HELLOIMGUI_USE_SDL2)
    set(no_platform_backend TRUE)
endif()
if (no_rendering_backend OR no_platform_backend)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "
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

     - At least one (or more) platform backend (Glfw3*):
       Make your choice according to your needs and your target platforms, between:
          glfw-binding
       *) This port currently doesn't offer an SDL platform backend.

    For example, you could use:
        vcpkg install \"hello-imgui[opengl3-binding,glfw-binding]\"

    ########################################################################
       !!!!                    WARNING                              !!!!!
       !!!!   Installed hello-imgui without a viable backend        !!!!!
    ########################################################################
    ")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
