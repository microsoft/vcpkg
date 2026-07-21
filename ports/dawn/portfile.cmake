if (VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/google/dawn/releases/download/v${VERSION}/emdawnwebgpu_pkg-v${VERSION}.zip"
        FILENAME "emdawnwebgpu_pkg-v${VERSION}.zip"
        SHA512 d83240bb4d1076ff0a690b195e684046eaaae907a67359ed0a623b9d0176a2ed0b8b4982c5ee61c152c1d615de3290a32a7fd5dee68347d061273fe2dd0caf85
    )
    vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        PATCHES
            000-fix-emdawnwebgpu.patch
    )
    set(VCPKG_BUILD_TYPE release)
    file(INSTALL "${SOURCE_PATH}/webgpu/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
    file(INSTALL "${SOURCE_PATH}/webgpu_cpp/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
    file(INSTALL "${SOURCE_PATH}/webgpu/src" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" PATTERN "LICENSE" EXCLUDE)
    file(INSTALL "${SOURCE_PATH}/emdawnwebgpu.port.py" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

    # cmake config file
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/DawnConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    vcpkg_cmake_config_fixup()

    # pkgconfig file
    set(DAWN_PKGCONFIG_CFLAGS "--use-port=\${prefix}/share/${PORT}/emdawnwebgpu.port.py")
    set(DAWN_PKGCONFIG_LIBS "--use-port=\${prefix}/share/${PORT}/emdawnwebgpu.port.py")
    set(DAWN_PKGCONFIG_REQUIRES "")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial_webgpu_dawn.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unofficial_webgpu_dawn.pc" @ONLY)
    vcpkg_fixup_pkgconfig()

    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/webgpu/src/LICENSE" "${SOURCE_PATH}/webgpu_cpp/LICENSE")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    return()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/dawn
    REF "v${VERSION}"
    SHA512 af6667a13a5532fd29f32255b8f607f0c629f0789ed66c331fc136660a3aea876563b64436ab8c2d6efb0572acc4e36b1c3302405dd380c7afbe9ba1c483d9cd
    HEAD_REF master
    PATCHES
        # DAWN_BUILD_MONOLITHIC_LIBRARY SHARED/STATIC requires BUILD_SHARED_LIBS=OFF
        001-fix-linkage.patch
        002-fix-windows-build.patch
        003-force-disable-cxx-module.patch
        004-deps.patch
        005-bsd-support.patch
        008-wrong-dxcapi-include.patch
        009-fix-tint-install.patch
)

function(z_vcpkg_from_github_to_path)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "OUT_SOURCE_PATH;REPO;REF;SHA512;HEAD_REF" "PATCHES")
    if(EXISTS "${arg_OUT_SOURCE_PATH}")
        file(GLOB children LIST_DIRECTORIES true "${arg_OUT_SOURCE_PATH}/*")
        if(NOT "${children}" STREQUAL "")
            message(FATAL_ERROR "The path ${arg_OUT_SOURCE_PATH} already exists and is not empty.")
        else()
            file(REMOVE_RECURSE "${arg_OUT_SOURCE_PATH}")
        endif()
        unset(children)
    endif()
    vcpkg_from_github(
        OUT_SOURCE_PATH out_source_path
        REPO "${arg_REPO}"
        REF "${arg_REF}"
        SHA512 "${arg_SHA512}"
        HEAD_REF "${arg_HEAD_REF}"
        PATCHES ${arg_PATCHES}
    )
    file(RENAME "${out_source_path}" "${arg_OUT_SOURCE_PATH}")
    file(REMOVE_RECURSE "${out_source_path}")
endfunction()

function(z_vcpkg_from_git_to_path)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "OUT_SOURCE_PATH;URL;REF" "PATCHES")
    if(EXISTS "${arg_OUT_SOURCE_PATH}")
        file(GLOB children LIST_DIRECTORIES true "${arg_OUT_SOURCE_PATH}/*")
        if(NOT "${children}" STREQUAL "")
            message(FATAL_ERROR "The path ${arg_OUT_SOURCE_PATH} already exists and is not empty.")
        else()
            file(REMOVE_RECURSE "${arg_OUT_SOURCE_PATH}")
        endif()
        unset(children)
    endif()
    vcpkg_from_git(
        OUT_SOURCE_PATH out_source_path
        URL "${arg_URL}"
        REF "${arg_REF}"
        PATCHES ${arg_PATCHES}
    )
    file(RENAME "${out_source_path}" "${arg_OUT_SOURCE_PATH}")
    file(REMOVE_RECURSE "${out_source_path}")
endfunction()

z_vcpkg_from_git_to_path(
    OUT_SOURCE_PATH "${SOURCE_PATH}/third_party/jinja2"
    URL "https://chromium.googlesource.com/chromium/src/third_party/jinja2"
    REF c3027d884967773057bf74b957e3fea87e5df4d7
)

z_vcpkg_from_git_to_path(
    OUT_SOURCE_PATH "${SOURCE_PATH}/third_party/markupsafe"
    URL "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
    REF 4256084ae14175d38a3ff7d739dca83ae49ccec6
)

z_vcpkg_from_github_to_path(
    OUT_SOURCE_PATH "${SOURCE_PATH}/third_party/spirv-headers/src"
    REPO KhronosGroup/SPIRV-Headers
    REF 29981f65241605e08b0ede4cfeb999fe3b723c6a
    SHA512 3f64c33196ff72c0376311206a38100dbcedd4a414431a1429b5b5b6dcfc9d0e204629444b414b011b426d3f8263cdc2b03ed1d1eed427039b3c57bfd20aa514
    HEAD_REF main
)

z_vcpkg_from_github_to_path(
    OUT_SOURCE_PATH "${SOURCE_PATH}/third_party/spirv-tools/src"
    REPO KhronosGroup/SPIRV-Tools
    REF 85f222ec591863853ea603ce190ea508c7255568
    SHA512 3a034ee4c2b433ba377feaea14edfaeb49b52ebd81a48c7a248d484b2e376b43db16eaea47c2411136867865645efdd0836c08147d0147271fdd5f14cc140ed2
    HEAD_REF main
    PATCHES
        # Dawn sets SPIRV_WERROR to OFF when building SPIRV-Tools, but https://github.com/KhronosGroup/SPIRV-Tools/commit/337fdb6a284fe7f7e374a14271f8e20e579f3263 ignores that CMake variable and forces /WX
        800-msvc-spirv-tools-disable-warnaserror.patch
)

z_vcpkg_from_github_to_path(
    OUT_SOURCE_PATH "${SOURCE_PATH}/third_party/webgpu-headers/src"
    REPO webgpu-native/webgpu-headers
    REF b3f67b89929c133403fd95638be4ef96b56ddca0
    SHA512 bd64b9989970f589e1f4ad2ed94cc6180f0549ef19d97a04a5f1e9c7564bd27f8b72fd6d7fe8bd24ed62f4ea2bc2d1c9df12eb55c083696159890638cbcc7af8
    HEAD_REF main
)

vcpkg_find_acquire_program(PYTHON3)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(DAWN_BUILD_MONOLITHIC_LIBRARY "STATIC")
else()
    set(DAWN_BUILD_MONOLITHIC_LIBRARY "SHARED")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        d3d11       DAWN_ENABLE_D3D11
        d3d12       DAWN_ENABLE_D3D12
        gl          DAWN_ENABLE_DESKTOP_GL
        gles        DAWN_ENABLE_OPENGLES
        metal       DAWN_ENABLE_METAL
        vulkan      DAWN_ENABLE_VULKAN
        wayland     DAWN_USE_WAYLAND
        x11         DAWN_USE_X11
        tint-tools  TINT_BUILD_CMD_TOOLS
)

set(DAWN_USE_BUILT_DXC OFF)
if(DAWN_ENABLE_D3D12)
    set(DAWN_USE_BUILT_DXC ON)
endif()
set(DAWN_USE_TINT_SPV OFF)
if(DAWN_ENABLE_VULKAN)
    set(DAWN_USE_TINT_SPV ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DPython3_EXECUTABLE=${PYTHON3}"
        -DDAWN_BUILD_MONOLITHIC_LIBRARY=${DAWN_BUILD_MONOLITHIC_LIBRARY}
        -DDAWN_ENABLE_INSTALL=ON
        -DDAWN_USE_GLFW=OFF
        -DDAWN_BUILD_PROTOBUF=OFF
        -DDAWN_BUILD_SAMPLES=OFF
        -DDAWN_BUILD_TESTS=OFF
        -DTINT_BUILD_TESTS=OFF
        -DTINT_ENABLE_INSTALL=OFF
        -DTINT_BUILD_WGSL_READER=ON
        -DTINT_BUILD_WGSL_WRITER=ON
        -DTINT_BUILD_SPV_READER=${DAWN_USE_TINT_SPV}
        -DTINT_BUILD_SPV_WRITER=${DAWN_USE_TINT_SPV}
        -DDAWN_ENABLE_NULL=ON
        -DDAWN_USE_BUILT_DXC=${DAWN_USE_BUILT_DXC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Dawn)

list(APPEND DAWN_ABSL_REQUIRES
    absl_flat_hash_set
    absl_flat_hash_map
    absl_inlined_vector
    absl_no_destructor
    absl_overload
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

if(TINT_BUILD_CMD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES tint AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
