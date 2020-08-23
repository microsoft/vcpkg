vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.78
    SHA512 2410df5b39d5ca14ea7181ef4f3b501ad8879e10895ed540f079f213dcc528b50e57cc16fce6f50a67e8a7be00b03c5833cabfd5db4ba210cafce6d95da389c6
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if(("metal-binding" IN_LIST FEATURES OR "osx-binding" IN_LIST FEATURES) AND (NOT VCPKG_TARGET_IS_OSX))
    message(FATAL_ERROR "Feature metal-binding and osx-binding are only supported on osx.")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    allegro5-binding            IMGUI_BUILD_ALLEGRO5_BINDING
    dx9-binding                 IMGUI_BUILD_DX9_BINDING
    dx10-binding                IMGUI_BUILD_DX10_BINDING
    dx11-binding                IMGUI_BUILD_DX11_BINDING
    dx12-binding                IMGUI_BUILD_DX12_BINDING
    glfw-binding                IMGUI_BUILD_GLFW_BINDING
    glut-binding                IMGUI_BUILD_GLUT_BINDING
    marmalade-binding           IMGUI_COPY_MARMALADE_BINDING
    metal-binding               IMGUI_BUILD_METAL_BINDING
    opengl2-binding             IMGUI_BUILD_OPENGL2_BINDING
    opengl3-glew-binding        IMGUI_BUILD_OPENGL3_GLEW_BINDING
    opengl3-glad-binding        IMGUI_BUILD_OPENGL3_GLAD_BINDING
    opengl3-gl3w-binding        IMGUI_BUILD_OPENGL3_GL3W_BINDING
    opengl3-glbinding-binding   IMGUI_BUILD_OPENGL3_GLBINDING_BINDING
    osx-binding                 IMGUI_BUILD_OSX_BINDING
    sdl2-binding                IMGUI_BUILD_SDL2_BINDING
    vulkan-binding              IMGUI_BUILD_VULKAN_BINDING
    win32-binding               IMGUI_BUILD_WIN32_BINDING
    freetype                    IMGUI_FREETYPE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)