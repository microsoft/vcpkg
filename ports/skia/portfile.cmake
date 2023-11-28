include("${CMAKE_CURRENT_LIST_DIR}/skia-functions.cmake")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/skia
    REF "canvaskit/${VERSION}"
    SHA512 4672cfef8c92f37418e27df30a4e3fd6f7ca6273521e9d6b7755d9285800ad1ea6eff66639a17f591e6921ec8b78aa828500399a83295f9984ab58ebaff0ec24
    PATCHES
        uwp.patch
        core-opengl32.patch
        disable-dev-test.patch
        support-x86-MSVC-build.patch
)

# these following aren't available in vcpkg
# to update, visit the DEPS file in Skia's root directory
declare_external_from_git(abseil-cpp
    URL "https://skia.googlesource.com/external/github.com/abseil/abseil-cpp.git"
    REF "c5a424a2a21005660b182516eb7a079cd8021699"
    LICENSE_FILE LICENSE
)
declare_external_from_git(d3d12allocator
    URL "https://skia.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git"
    REF "169895d529dfce00390a20e69c2f516066fe7a3b"
    LICENSE_FILE LICENSE.txt
)
declare_external_from_git(dawn
    URL "https://dawn.googlesource.com/dawn.git"
    REF "30fa0d8d2ced43e44baa522dd4bd4684b14a3099"
    LICENSE_FILE LICENSE
)
declare_external_from_git(dng_sdk
    URL "https://android.googlesource.com/platform/external/dng_sdk.git"
    REF "c8d0c9b1d16bfda56f15165d39e0ffa360a11123"
    LICENSE_FILE LICENSE
)
declare_external_from_git(jinja2
    URL "https://chromium.googlesource.com/chromium/src/third_party/jinja2"
    REF "ee69aa00ee8536f61db6a451f3858745cf587de6"
    LICENSE_FILE LICENSE.rst
)
declare_external_from_git(libgifcodec
    URL "https://skia.googlesource.com/libgifcodec"
    REF "fd59fa92a0c86788dcdd84d091e1ce81eda06a77"
    LICENSE_FILE LICENSE.md
)
declare_external_from_git(markupsafe
    URL "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
    REF "0944e71f4b2cb9a871bcbe353f95e889b64a611a"
    LICENSE_FILE LICENSE
)
declare_external_from_git(piex
    URL "https://android.googlesource.com/platform/external/piex.git"
    REF "bb217acdca1cc0c16b704669dd6f91a1b509c406"
    LICENSE_FILE LICENSE
)
declare_external_from_git(sfntly
    URL "https://github.com/googlefonts/sfntly.git"
    REF "b55ff303ea2f9e26702b514cf6a3196a2e3e2974"
    LICENSE_FILE README.md
)
declare_external_from_git(spirv-cross
    URL "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross"
    REF "61c603f3baa5270e04bcfb6acf83c654e3c57679"
    LICENSE_FILE LICENSE
)
declare_external_from_git(spirv-headers
    URL "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git"
    REF "0bcc624926a25a2a273d07877fd25a6ff5ba1cfb"
    LICENSE_FILE LICENSE
)
declare_external_from_git(spirv-tools
    URL "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git"
    REF "0073a1fa36f7c52ad3d58059cb5d5de8efa825ad"
    LICENSE_FILE LICENSE
)
declare_external_from_git(tint
    URL "https://dawn.googlesource.com/tint"
    REF "200492e32b94f042d9942154fb4fa7f93bb8289a"
    LICENSE_FILE LICENSE
)
declare_external_from_git(vulkan-tools
    URL "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Tools"
    REF "d55c7aaf041af331bee8c22fb448a6ff4c797f73"
    LICENSE_FILE LICENSE.txt
)
declare_external_from_git(wuffs
    URL "https://skia.googlesource.com/external/github.com/google/wuffs-mirror-release-c.git"
    REF "e3f919ccfe3ef542cfc983a82146070258fb57f8"
    LICENSE_FILE LICENSE
)

declare_external_from_pkgconfig(expat)
declare_external_from_pkgconfig(fontconfig PATH "third_party")
declare_external_from_pkgconfig(freetype2)
declare_external_from_pkgconfig(harfbuzz MODULES harfbuzz harfbuzz-subset)
declare_external_from_pkgconfig(icu MODULES icu-uc DEFINES "U_USING_ICU_NAMESPACE=0")
declare_external_from_pkgconfig(libjpeg PATH "third_party/libjpeg-turbo" MODULES libturbojpeg libjpeg)
declare_external_from_pkgconfig(libpng)
declare_external_from_pkgconfig(libwebp MODULES libwebpdecoder libwebpdemux libwebpmux libwebp)
declare_external_from_pkgconfig(zlib)

declare_external_from_vcpkg(vulkan_headers PATH third_party/externals/vulkan-headers)

set(known_cpus x86 x64 arm arm64 wasm)
if(NOT VCPKG_TARGET_ARCHITECTURE IN_LIST known_cpus)
    message(WARNING "Unknown target cpu '${VCPKG_TARGET_ARCHITECTURE}'.")
endif()

set(OPTIONS "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\"")
set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "is_official_build=true")
vcpkg_list(SET SKIA_TARGETS ":skia")

if(VCPKG_TARGET_IS_ANDROID)
    string(APPEND OPTIONS " target_os=\"android\"")
elseif(VCPKG_TARGET_IS_IOS)
    string(APPEND OPTIONS " target_os=\"ios\"")
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    string(APPEND OPTIONS " target_os=\"wasm\"")
elseif(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(APPEND OPTIONS " target_os=\"win\"")
    if(VCPKG_TARGET_IS_UWP)
        string(APPEND OPTIONS " skia_enable_winuwp=true skia_enable_fontmgr_win=false skia_use_xps=false")
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(APPEND OPTIONS " is_component_build=true")
else()
    string(APPEND OPTIONS " is_component_build=false")
endif()

set(required_externals
    dng_sdk
    expat
    libgifcodec
    libjpeg
    libpng
    libwebp
    piex
    sfntly
    zlib
    wuffs
)

if("fontconfig" IN_LIST FEATURES)
    list(APPEND required_externals fontconfig)
    string(APPEND OPTIONS " skia_use_fontconfig=true")
else()
    string(APPEND OPTIONS " skia_use_fontconfig=false")
endif()

if("freetype" IN_LIST FEATURES)
    list(APPEND required_externals freetype2)
    string(APPEND OPTIONS " skia_use_freetype=true")
else()
    string(APPEND OPTIONS " skia_use_freetype=false")
endif()

if("harfbuzz" IN_LIST FEATURES)
    list(APPEND required_externals harfbuzz)
    string(APPEND OPTIONS " skia_use_harfbuzz=true")
else()
    string(APPEND OPTIONS " skia_use_harfbuzz=false")
endif()

if("icu" IN_LIST FEATURES)
    list(APPEND required_externals icu)
    string(APPEND OPTIONS " skia_use_icu=true")
else()
    string(APPEND OPTIONS " skia_use_icu=false")
endif()

if("gl" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_gl=true")
else()
    string(APPEND OPTIONS " skia_use_gl=false")
endif()

if("metal" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_metal=true")
endif()

if("vulkan" IN_LIST FEATURES)
    list(APPEND required_externals
        vulkan_headers
        vulkan-tools
    )
    string(APPEND OPTIONS " skia_use_vulkan=true")
    file(COPY "${CURRENT_INSTALLED_DIR}/include/vk_mem_alloc.h" DESTINATION "${SOURCE_PATH}/third_party/externals/vulkanmemoryallocator/include")
    # Cf. third_party/vulkanmemoryallocator/GrVulkanMemoryAllocator.h:25
    vcpkg_replace_string("${SOURCE_PATH}/third_party/externals/vulkanmemoryallocator/include/vk_mem_alloc.h"
        "#include <vulkan/vulkan.h>"
        "#ifndef VULKAN_H_\n    #include <vulkan/vulkan.h>\n#endif"
    )
endif()

if("direct3d" IN_LIST FEATURES)
    list(APPEND required_externals
        spirv-cross
        spirv-headers
        spirv-tools
        d3d12allocator
    )
    string(APPEND OPTIONS " skia_use_direct3d=true")
endif()

if("dawn" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_LINUX)
        message(WARNING
[[
dawn support requires the following libraries from the system package manager:

    libx11-xcb-dev mesa-common-dev

They can be installed on Debian based systems via

    apt-get install libx11-xcb-dev mesa-common-dev
]]
        )
    endif()

    list(APPEND required_externals
        spirv-cross
        spirv-headers
        spirv-tools
        tint
        jinja2
        markupsafe
        vulkan_headers
## Remove
        vulkan-tools
        abseil-cpp
## REMOVE ^
        dawn
    )
    string(APPEND OPTIONS " skia_use_dawn=true")
    string(REPLACE "dynamic" "shared" DAWN_LINKAGE "${VCPKG_LIBRARY_LINKAGE}")
    vcpkg_list(APPEND SKIA_TARGETS
        "third_party/externals/dawn/src/dawn:proc_${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/native:${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/platform:${DAWN_LINKAGE}"
    )
endif()

get_externals(${required_externals})
if(EXISTS "${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py")
    vcpkg_find_acquire_program(GIT)
    vcpkg_replace_string("${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py"
        "get_git()," 
        "\"${GIT}\","
    )
endif()

vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")
vcpkg_replace_string("${SOURCE_PATH}/gn/toolchain/BUILD.gn" "python3 " "\\\"${PYTHON3}\\\" ")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(REGEX REPLACE "[\\]\$" "" WIN_VC "$ENV{VCINSTALLDIR}")
    string(APPEND OPTIONS " win_vc=\"${WIN_VC}\"")
else()
    string(APPEND OPTIONS " \
        cc=\"${VCPKG_DETECTED_CMAKE_C_COMPILER}\" \
        cxx=\"${VCPKG_DETECTED_CMAKE_CXX_COMPILER}\"")
endif()

string_to_gn_list(SKIA_C_FLAGS_DBG "${VCPKG_COMBINED_C_FLAGS_DEBUG}")
string_to_gn_list(SKIA_CXX_FLAGS_DBG "${VCPKG_COMBINED_CXX_FLAGS_DEBUG}")
string(APPEND OPTIONS_DBG " \
    extra_cflags_c=${SKIA_C_FLAGS_DBG} \
    extra_cflags_cc=${SKIA_CXX_FLAGS_DBG}")
string_to_gn_list(SKIA_C_FLAGS_REL "${VCPKG_COMBINED_C_FLAGS_RELEASE}")
string_to_gn_list(SKIA_CXX_FLAGS_REL "${VCPKG_COMBINED_CXX_FLAGS_RELEASE}")
string(APPEND OPTIONS_REL " \
    extra_cflags_c=${SKIA_C_FLAGS_REL} \
    extra_cflags_cc=${SKIA_CXX_FLAGS_REL}")
if(VCPKG_TARGET_IS_UWP)
    string_to_gn_list(SKIA_LD_FLAGS "-APPCONTAINER WindowsApp.lib")
    string(APPEND OPTIONS " extra_ldflags=${SKIA_LD_FLAGS}")
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "${OPTIONS} skia_use_lua=false skia_enable_tools=false skia_enable_spirv_validation=false"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

# desc json output is dual-use: logging and further processing
vcpkg_find_acquire_program(GN)
vcpkg_execute_required_process(
    COMMAND "${GN}" desc --format=json --all --testonly=false "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "*"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "desc-${TARGET_TRIPLET}-rel"
    OUTPUT_VARIABLE desc_release
)
file(READ "${CURRENT_BUILDTREES_DIR}/desc-${TARGET_TRIPLET}-rel-out.log" desc_release)
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_execute_required_process(
        COMMAND "${GN}" desc --format=json --all --testonly=false "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" "*"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "desc-${TARGET_TRIPLET}-dbg"
        OUTPUT_VARIABLE desc_debug
    )
    file(READ "${CURRENT_BUILDTREES_DIR}/desc-${TARGET_TRIPLET}-dbg-out.log" desc_debug)
endif()

vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ${SKIA_TARGETS}
)

# Use skia repository layout in ${CURRENT_PACKAGES_DIR}/include/skia
file(COPY "${SOURCE_PATH}/include"
          "${SOURCE_PATH}/modules"
          "${SOURCE_PATH}/src"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/skia"
    FILES_MATCHING PATTERN "*.h"
)
auto_clean("${CURRENT_PACKAGES_DIR}/include/skia")
set(skia_dll_static "0")
set(skia_dll_dynamic "1")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/skia/include/core/SkTypes.h" "defined(SKIA_DLL)" "${skia_dll_${VCPKG_LIBRARY_LINKAGE}}")

# vcpkg legacy layout omits "include/" component. Just duplicate.
file(COPY "${CURRENT_PACKAGES_DIR}/include/skia/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/skia")

get_definitions(SKIA_DEFINITIONS_REL "${desc_release}" "//:skia")
get_link_libs(SKIA_DEP_REL "${desc_release}" "//:skia")
if(NOT VCPKG_BUILD_TYPE)
    get_definitions(SKIA_DEFINITIONS_DBG "${desc_debug}" "//:skia")
    get_link_libs(SKIA_DEP_DBG "${desc_debug}" "//:skia")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/unofficial-skia")
configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-skia-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-skia/unofficial-skia-config.cmake" @ONLY)
# vcpkg legacy
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/skiaConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/skia")

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/example/CMakeLists.txt"
    "${SOURCE_PATH}/tools/convert-to-nia.cpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/example"
)
file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/example/convert-to-nia.cpp" [[
// Test for https://github.com/microsoft/vcpkg/issues/27219
#include "include/core/SkColorSpace.h"
]])

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(GLOB third_party_licenses "${SOURCE_PATH}/third_party_licenses/*")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" ${third_party_licenses})
