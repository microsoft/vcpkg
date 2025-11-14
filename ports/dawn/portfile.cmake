if (VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/google/dawn/releases/download/v${VERSION}/emdawnwebgpu_pkg-v${VERSION}.zip"
        FILENAME "emdawnwebgpu_pkg-v${VERSION}.zip"
        SHA512 c1689b201eb51f9de4443d6b326814367cc21feb0b30585c9efa8ed141405d861853a2c71004e56ba8ededa20bc456e13ae9de9fc9f59aaa24890fbe871fb444
    )
    vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        PATCHES
            000-fix-emdawnwebgpu.patch
    )
    set(VCPKG_BUILD_TYPE release)

    file(INSTALL
        "${SOURCE_PATH}/webgpu/include"
        "${SOURCE_PATH}/webgpu_cpp/include"
        DESTINATION "${CURRENT_PACKAGES_DIR}"
    )
    file(INSTALL
        "${SOURCE_PATH}/webgpu/src"
        "${SOURCE_PATH}/emdawnwebgpu.port.py"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
        PATTERN "LICENSE" EXCLUDE
    )
    file(INSTALL
        "${CMAKE_CURRENT_LIST_DIR}/DawnConfig.cmake"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    )

    set(DAWN_PKGCONFIG_CFLAGS "--use-port=\${prefix}/share/${PORT}/emdawnwebgpu.port.py")
    set(DAWN_PKGCONFIG_LIBS "--use-port=\${prefix}/share/${PORT}/emdawnwebgpu.port.py")
    set(DAWN_PKGCONFIG_REQUIRES "")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial_webgpu_dawn.pc.in"
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unofficial_webgpu_dawn.pc" @ONLY)

    vcpkg_fixup_pkgconfig()
    vcpkg_install_copyright(FILE_LIST
        "${SOURCE_PATH}/webgpu/src/LICENSE"
        "${SOURCE_PATH}/webgpu_cpp/LICENSE"
    )
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    return()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/dawn
    REF "v${VERSION}"
    SHA512 f0b2a614c2a275864e4e78a5ac686f347f7a27b022e796955a9cf6633a30ff3690229c4577458b46ffa31118ed9ec4ec25eddf38de3c6d99f92ef93bf2ee59d4
    HEAD_REF master
    PATCHES
        001-fix-windows-build.patch
        002-fix-uwp.patch
        003-fix-d3d11.patch
        004-deps.patch
        005-bsd-support.patch
        006-fix-null-backend.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        d3d11     DAWN_ENABLE_D3D11
        d3d12     DAWN_ENABLE_D3D12
        gl        DAWN_ENABLE_DESKTOP_GL
        gles      DAWN_ENABLE_OPENGLES
        metal     DAWN_ENABLE_METAL
        vulkan    DAWN_ENABLE_VULKAN
        wayland   DAWN_USE_WAYLAND
        x11       DAWN_USE_X11
)

function(checkout_in_path PATH URL REF)
    if(EXISTS "${PATH}")
        file(GLOB_RECURSE subdirectory_children "${CURRENT_PACKAGES_DIR}/include/${directory_child}/*")
        if(NOT "${subdirectory_children}" STREQUAL "")
            return()
        else()
            file(REMOVE_RECURSE "${PATH}")
        endif()
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
    )
    file(RENAME "${DEP_SOURCE_PATH}" "${PATH}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

checkout_in_path(
    "${SOURCE_PATH}/third_party/jinja2"
    "https://chromium.googlesource.com/chromium/src/third_party/jinja2"
    "e2d024354e11cc6b041b0cff032d73f0c7e43a07"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/markupsafe"
    "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
    "0bad08bb207bbfc1d6f3bbc82b9242b0c50e5794"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/spirv-headers/src"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers"
    "f2e4bd213104fe323a01e935df56557328d37ac8"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/spirv-tools/src"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools"
    "05b0ab1253db43c3ea29efd593f3f13dfa621ab1"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/webgpu-headers/src"
    "https://chromium.googlesource.com/external/github.com/webgpu-native/webgpu-headers"
    "706853a9da45b8e89b7ea005aa267294d115f8ce"
)

vcpkg_find_acquire_program(PYTHON3)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" MSVC_USE_MD)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(DAWN_BUILD_MONOLITHIC_LIBRARY "STATIC")
else()
    set(DAWN_BUILD_MONOLITHIC_LIBRARY "SHARED")
endif()

# DAWN_BUILD_MONOLITHIC_LIBRARY SHARED/STATIC requires BUILD_SHARED_LIBS=OFF
set(VCPKG_LIBRARY_LINKAGE_BACKUP ${VCPKG_LIBRARY_LINKAGE})
set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPython3_EXECUTABLE="${PYTHON3}"
        -DDAWN_MSVC_DYNAMIC_RUNTIME=${MSVC_USE_MD}
        -DDAWN_BUILD_MONOLITHIC_LIBRARY=${DAWN_BUILD_MONOLITHIC_LIBRARY}
        -DDAWN_FORCE_SYSTEM_COMPONENT_LOAD=ON
        -DDAWN_ENABLE_PIC=ON
        -DDAWN_ENABLE_INSTALL=ON
        -DDAWN_USE_GLFW=OFF
        -DDAWN_BUILD_PROTOBUF=OFF
        -DDAWN_BUILD_SAMPLES=OFF
        -DDAWN_BUILD_TESTS=OFF
        -DTINT_BUILD_TESTS=OFF
        -DTINT_ENABLE_INSTALL=OFF
        -DTINT_BUILD_CMD_TOOLS=OFF
        -DDAWN_ENABLE_NULL=ON
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        DAWN_MSVC_DYNAMIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Dawn)

list(APPEND DAWN_ABSL_REQUIRES
    absl_flat_hash_set
    absl_flat_hash_map
    absl_inlined_vector
    absl_no_destructor
    absl_overload
    absl_str_format_internal
    absl_strings
    absl_span
    absl_string_view
)
list(JOIN DAWN_ABSL_REQUIRES ", " DAWN_ABSL_REQUIRES)

set(DAWN_PKGCONFIG_CFLAGS "")
set(DAWN_PKGCONFIG_REQUIRES "${DAWN_ABSL_REQUIRES}")
set(DAWN_PKGCONFIG_LIBS "-lwebgpu_dawn")

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND NOT VCPKG_TARGET_IS_UWP)
    set(DAWN_PKGCONFIG_LIBS "${DAWN_PKGCONFIG_LIBS} -lonecore -luser32 -ldelayimp")
endif()
if (DAWN_ENABLE_D3D11 OR DAWN_ENABLE_D3D12)
    set(DAWN_PKGCONFIG_LIBS "${DAWN_PKGCONFIG_LIBS} -ldxguid")
endif()
if (DAWN_ENABLE_METAL)
    set(DAWN_PKGCONFIG_LIBS "${DAWN_PKGCONFIG_LIBS} -framework IOSurface -framework Metal -framework QuartzCore")
    if (VCPKG_TARGET_IS_OSX)
        set(DAWN_PKGCONFIG_LIBS "${DAWN_PKGCONFIG_LIBS} -framework Cocoa -framework IOKit")
    endif()
endif()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial_webgpu_dawn.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/unofficial_webgpu_dawn.pc" @ONLY)
endif()
if (EXISTS "${CURRENT_PACKAGES_DIR}/lib")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial_webgpu_dawn.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unofficial_webgpu_dawn.pc" @ONLY)
endif()
vcpkg_fixup_pkgconfig()

# Restore the original library linkage
set(VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE_BACKUP})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
