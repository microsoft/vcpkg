if (VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/google/dawn/releases/download/v${VERSION}/emdawnwebgpu_pkg-v${VERSION}.zip"
        FILENAME "emdawnwebgpu_pkg-v${VERSION}.zip"
        SHA512 bd89894435f502d904955ad0207a4245c192dda183857eb87c6487cdb5a799ae3bbd19ab1f4c90e32b8f808dfcabf58a190e5c480de198dd7aa5728506bef6c1
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
    SHA512 3c1c2f71508547adbe564dc0da8215e6d54c64176e611ba7e597db2f38d93cba2e735dc6f672585da8ed7ae0ad0c0784f02adcdda85026fe6def3b87fc4349d5
    HEAD_REF master
    PATCHES
        # DAWN_BUILD_MONOLITHIC_LIBRARY SHARED/STATIC requires BUILD_SHARED_LIBS=OFF
        001-fix-linkage.patch
        002-fix-windows-build.patch
        003-force-disable-cxx-module.patch
        004-deps.patch
        005-bsd-support.patch
        006-fix-header-bsd.patch
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
    REF 04fd3caa1e8267e4d95c806cad901181728e1006
    SHA512 90a60f8538b704b9c4e799d044c2e14673d6a42742d17315cd65e2ef7870fb094eb74450bf12a768a539c920d2cb9962fc83e328594ef72507f6b882915eb5ab
    HEAD_REF main
)

z_vcpkg_from_github_to_path(
    OUT_SOURCE_PATH "${SOURCE_PATH}/third_party/spirv-tools/src"
    REPO KhronosGroup/SPIRV-Tools
    REF e265f557e3db20843c6d135d2b9eeb51ecc79d73
    SHA512 2c06b7fc6fdf51fdb27ee5c80cc632521f53da14571f5511d34646277580c184a0b52033169437848791e28737f08e612d350f88ba230ff7eb5fc73ef439446b
    HEAD_REF main
    PATCHES
        # Dawn sets SPIRV_WERROR to OFF when building SPIRV-Tools, but https://github.com/KhronosGroup/SPIRV-Tools/commit/337fdb6a284fe7f7e374a14271f8e20e579f3263 ignores that CMake variable and forces /WX
        800-msvc-spirv-tools-disable-warnaserror.patch
)

z_vcpkg_from_github_to_path(
    OUT_SOURCE_PATH "${SOURCE_PATH}/third_party/webgpu-headers/src"
    REPO webgpu-native/webgpu-headers
    REF b5ff182caa90e53293f47939716281342c0812ba
    SHA512 ec5a9d1afff0c55b2892e6cf4372d8065220222e5e7b7e639faf5def43d8d5e68f4d5203555449d347009c17bac20ab4975766bc12ddd3ca5c25525815086463
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
