if (VCPKG_TARGET_IS_EMSCRIPTEN)
    # emscripten has built-in dawn library
    set(VCPKG_BUILD_TYPE release)
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/DawnConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dawn")
    set(DAWN_PKGCONFIG_CFLAGS "--use-port=emdawnwebgpu")
    set(DAWN_PKGCONFIG_DEPS "--use-port=emdawnwebgpu")
    set(DAWN_PKGCONFIG_REQUIRES "")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-webgpu-dawn.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unofficial-webgpu-dawn.pc" @ONLY)
    vcpkg_fixup_pkgconfig()
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    return()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/dawn
    REF e8356f257403e1c979d73f9d6d136ea8e30f52d2 # chromium_7371
    SHA512 4fbb77e1bb6cf5c67a98f79c632c4b001bf272273851b929c241ed45a700d2f2dd73fdb5516d459eecf630ccdf7ee1c62308768dccd4989abbec0936a29600dc
    HEAD_REF master
    PATCHES
        001-fix-windows-build.patch
        002-fix-uwp.patch
        003-deps.patch
)

# vcpkg_find_acquire_program(PYTHON3)
# vcpkg_execute_in_download_mode(
#     COMMAND "${PYTHON3}" tools/fetch_dawn_dependencies.py
#     WORKING_DIRECTORY "${SOURCE_PATH}"
# )
#
# get_dawn_deps_commit() { curl -s "https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7371/$1" | htmlq .gitlink-detail --text; }
#

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
    "${SOURCE_PATH}/third_party/khronos/EGL-Registry"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/EGL-Registry"
    "7dea2ed79187cd13f76183c4b9100159b9e3e071"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/khronos/OpenGL-Registry"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/OpenGL-Registry"
    "5bae8738b23d06968e7c3a41308568120943ae77"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/markupsafe"
    "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
    "0bad08bb207bbfc1d6f3bbc82b9242b0c50e5794"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/glslang/src"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/glslang"
    "fcf4e9296fa400e2b03c34e23b261e0c8a0ac34d"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/spirv-headers/src"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers"
    "a8637796c28386c3cf3b4e8107020fbb52c46f3f"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/spirv-tools/src"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools"
    "f386417185be0601894b20d9ad000aceb73d898b"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/vulkan-headers/src"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Headers"
    "2efaa559ff41655ece68b2e904e2bb7e7d55d265"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/vulkan-loader/src"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Loader"
    "484f3cd7dfb13f63a8b8930cb0397e9b849ab076"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/vulkan-utility-libraries/src"
    "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Utility-Libraries"
    "4f4c0b6c61223b703f1c753a404578d7d63932ad"
)

vcpkg_find_acquire_program(PYTHON3)

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
        -DDAWN_BUILD_MONOLITHIC_LIBRARY=${DAWN_BUILD_MONOLITHIC_LIBRARY}
        -DDAWN_ENABLE_INSTALL=ON
        -DDAWN_USE_GLFW=OFF
        -DDAWN_BUILD_PROTOBUF=OFF
        -DDAWN_BUILD_SAMPLES=OFF
        -DDAWN_BUILD_TESTS=OFF
        -DTINT_BUILD_TESTS=OFF
        -DTINT_ENABLE_INSTALL=OFF
        -DTINT_BUILD_CMD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Dawn)

set(DAWN_ABSL_REQUIRES "absl_flat_hash_set absl_flat_hash_map absl_inlined_vector absl_no_destructor absl_overload absl_str_format_internal absl_strings absl_span absl_string_view")

if (VCPKG_TARGET_IS_WINDOWS)
    set(DAWN_PKGCONFIG_CFLAGS "")
    set(DAWN_PKGCONFIG_DEPS "-lwebgpu_dawn -ldxguid -lonecore")
    set(DAWN_PKGCONFIG_REQUIRES "${DAWN_ABSL_REQUIRES}")
elseif (VCPKG_TARGET_IS_OSX)
    set(DAWN_PKGCONFIG_CFLAGS "")
    set(DAWN_PKGCONFIG_DEPS "-lwebgpu_dawn -framework IOSurface -framework Metal -framework QuartzCore")
    set(DAWN_PKGCONFIG_REQUIRES "${DAWN_ABSL_REQUIRES}")
else ()
    set(DAWN_PKGCONFIG_CFLAGS "")
    set(DAWN_PKGCONFIG_DEPS "-lwebgpu_dawn")
    set(DAWN_PKGCONFIG_REQUIRES "${DAWN_ABSL_REQUIRES}")
endif ()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-webgpu-dawn.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/unofficial-webgpu-dawn.pc" @ONLY)
endif()
if (EXISTS "${CURRENT_PACKAGES_DIR}/lib")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-webgpu-dawn.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unofficial-webgpu-dawn.pc" @ONLY)
endif()
vcpkg_fixup_pkgconfig()

# Restore the original library linkage
set(VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE_BACKUP})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
