if (VCPKG_TARGET_IS_EMSCRIPTEN)
    # emscripten has built-in dawn library
    set(VCPKG_BUILD_TYPE release)
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/DawnConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dawn")
    set(DAWN_PKGCONFIG_CFLAGS "--use-port=emdawnwebgpu")
    set(DAWN_PKGCONFIG_DEPS "--use-port=emdawnwebgpu")
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
    "${SOURCE_PATH}/third_party/abseil-cpp"
    "https://chromium.googlesource.com/chromium/src/third_party/abseil-cpp"
    "cae4b6a3990e1431caa09c7b2ed1c76d0dfeab17"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/dxc"
    "https://chromium.googlesource.com/external/github.com/microsoft/DirectXShaderCompiler"
    "39f1dc165ca38e7548d74eaad88d5ee47f1de5a6"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/dxheaders"
    "https://chromium.googlesource.com/external/github.com/microsoft/DirectX-Headers"
    "980971e835876dc0cde415e8f9bc646e64667bf7"
)

checkout_in_path(
    "${SOURCE_PATH}/third_party/glfw"
    "https://chromium.googlesource.com/external/github.com/glfw/glfw"
    "b35641f4a3c62aa86a0b3c983d163bc0fe36026d"
)

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

# checkout_in_path(
#     "${SOURCE_PATH}/third_party/libprotobuf-mutator/src"
#     "https://chromium.googlesource.com/external/github.com/google/libprotobuf-mutator.git"
#     "7bf98f78a30b067e22420ff699348f084f802e12"
# )

# checkout_in_path(
#     "${SOURCE_PATH}/third_party/protobuf"
#     "https://chromium.googlesource.com/chromium/src/third_party/protobuf"
#     "1a4051088b71355d44591172c474304331aaddad"
# )

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

# checkout_in_path(
#     "${SOURCE_PATH}/third_party/google_benchmark/src"
#     "https://chromium.googlesource.com/external/github.com/google/benchmark.git"
#     "761305ec3b33abf30e08d50eb829e19a802581cc"
# )

# checkout_in_path(
#     "${SOURCE_PATH}/third_party/googletest"
#     "https://chromium.googlesource.com/external/github.com/google/googletest"
#     "309dab8d4bbfcef0ef428762c6fec7172749de0f"
# )

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

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

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
        -DABSL_MSVC_STATIC_RUNTIME=${STATIC_CRT}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Dawn)

if (VCPKG_TARGET_IS_WINDOWS)
    set(DAWN_PKGCONFIG_CFLAGS "")
    set(DAWN_PKGCONFIG_DEPS "-lwebgpu_dawn -ldxguid -lonecore")
elseif (VCPKG_TARGET_IS_OSX)
    set(DAWN_PKGCONFIG_CFLAGS "")
    set(DAWN_PKGCONFIG_DEPS "-lwebgpu_dawn -framework IOSurface -framework Metal -framework QuartzCore")
else ()
    set(DAWN_PKGCONFIG_CFLAGS "")
    set(DAWN_PKGCONFIG_DEPS "-lwebgpu_dawn")
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
