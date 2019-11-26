include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.74
    SHA512 e49e5cbe55899c0d0abc9b66c4e6e3e9941542af542d0ed3304bd3bde34c769baa2367355b77b91acb7fca56f9bcfd233dfc99881cfc8f5f6a2e2e6839990832
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    vulkan IMGUI_INCLUDE_IMPL_VULKAN
    sdl2 IMGUI_INCLUDE_IMPL_SDL2
    example IMGUI_COMPILE_ALL_EXAMPLES
)

if ("example" IN_LIST FEATURES AND ("sdl2" IN_LIST FEATURES OR "vulkan" IN_LIST FEATURES))
    message (FATAL_ERROR "example feature uses includes whole examples folder, do not use it with other features")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
        -DIMGUI_INCLUDE_IMPL_VULKAN=ON
        -DIMGUI_INCLUDE_IMPL_SDL2=ON
)

vcpkg_install_cmake()

if ("example" IN_LIST FEATURES)
    if (NOT VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature example only support windows.")
    endif()
    vcpkg_build_msbuild(
        USE_VCPKG_INTEGRATION
        PROJECT_PATH ${SOURCE_PATH}/examples/imgui_examples.sln
    )

    # Install headers
    file(GLOB IMGUI_EXAMPLE_INCLUDES ${SOURCE_PATH}/examples/*.h)
    file(INSTALL ${IMGUI_EXAMPLE_INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

    # Install tools
    file(GLOB_RECURSE IMGUI_EXAMPLE_BINARIES ${SOURCE_PATH}/examples/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    file(INSTALL ${IMGUI_EXAMPLE_BINARIES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/imgui/copyright COPYONLY)
