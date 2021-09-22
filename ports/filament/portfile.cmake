vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/filament
    REF v1.9.20
    SHA512 d7c0a4ebca9be27c145e5081e93cfe65c02ba6f88b496ac15ada84080ee8fcb652cb5100da5f7d50b31c02984a08c5f3e469aa0e2389366004b5aad4dc7f4d9a
    HEAD_REF master
    PATCHES
        use_external_libs.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(USE_STATIC_CRT ON)
else()
    set(USE_STATIC_CRT OFF)
endif()

file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/benchmark")
#file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/getopt")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/imgui")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libassimp")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libgtest")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libpng")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libsdl2")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libz")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/robin-map")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/spirv-cross")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/spirv-tools")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/stb")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/tinyexr")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/debug/bin")  #so that tools that are self-produced during build process, which might depend on vcpkg-provided shared libraries, do not silently fail due to missing .dlls
    vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin")
endif()

if(VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(CLANG)
    set(COMPILER -DCMAKE_CXX_COMPILER=${CLANG}++ -DCMAKE_C_COMPILER=${CLANG})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${COMPILER}
        -DUSE_STATIC_CRT=${USE_STATIC_CRT}
        -DFILAMENT_ENABLE_JAVA=OFF
        -DFILAMENT_USE_EXTERNAL_GLES3=OFF
        -DFILAMENT_USE_SWIFTSHADER=OFF
        -DFILAMENT_GENERATE_JS_DOCS=OFF
        -DFILAMENT_ENABLE_LTO=OFF
        -DFILAMENT_SKIP_SAMPLES=ON
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES
    cmgen
    filamesh
    glslminifier
    matc
    matinfo
    mipgen
    normal-blending
    resgen
    roughness-prefilter
    specular-color
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE ${CURRENT_PACKAGES_DIR}/README.md)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE ${CURRENT_PACKAGES_DIR}/debug/README.md)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/Findfilament.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
