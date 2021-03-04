vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if ("docking-experimental" IN_LIST FEATURES)
    vcpkg_from_github(
       OUT_SOURCE_PATH SOURCE_PATH
       REPO ocornut/imgui
       REF 239d09804d17997e147f4bcfb451ead04c1d67ff
       SHA512 7e93dd8c1a465b8405d32f08aa2be0c1a2bea7762384ba6a16848e10b10f5684f8969b672cec6e994a90fc6a6189519730dd7d15b82ae39b5221278eae23ba61
       HEAD_REF docking
       )
else()
    vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.81
    SHA512 d7a2b66dea77359f78068a595607d7668e09ddd0b91910f67fc6463cb920b91b0cc1855984bd4d41e6a880b69ca7cd5e3adc064dcf461c0629b9f8c845a4fc3e
    HEAD_REF master
    )
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/imgui-config.cmake.in DESTINATION ${SOURCE_PATH})
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
    wchar32                     IMGUI_USE_WCHAR32
)

if ("libigl-imgui" IN_LIST FEATURES)
    vcpkg_download_distfile(
        IMGUI_FONTS_DROID_SANS_H
        URLS
            https://raw.githubusercontent.com/libigl/libigl-imgui/c3efb9b62780f55f9bba34561f79a3087e057fc0/imgui_fonts_droid_sans.h
        FILENAME "imgui_fonts_droid_sans.h"
        SHA512
            abe9250c9a5989e0a3f2285bbcc83696ff8e38c1f5657c358e6fe616ff792d3c6e5ff2fa23c2eeae7d7b307392e0dc798a95d14f6d10f8e9bfbd7768d36d8b31
    )

    file(INSTALL ${IMGUI_FONTS_DROID_SANS_H} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

if ("freetype" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imconfig.h" "//#define IMGUI_ENABLE_FREETYPE" "#define IMGUI_ENABLE_FREETYPE")
endif()
if ("wchar32" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imconfig.h" "//#define IMGUI_USE_WCHAR32" "#define IMGUI_USE_WCHAR32")
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
