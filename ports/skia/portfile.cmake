vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/google/skia
    REF f86f242886692a18f5adc1cf9cbd6740cd0870fd
)
vcpkg_replace_string("${SOURCE_PATH}/gn/toolchain/BUILD.gn" " \$win_sdk/bin/SetEnv.cmd /x86 " " echo . ")
vcpkg_replace_string("${SOURCE_PATH}/src/utils/win/SkWGL_win.cpp" "(WINUWP)" "(SK_WINUWP)")

# Replace hardcoded python paths
vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")
vcpkg_replace_string("${SOURCE_PATH}/gn/toolchain/BUILD.gn" "python3 " "\\\"${PYTHON3}\\\" ")

function(checkout_in_path PATH URL REF)
    if(EXISTS "${PATH}")
        return()
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
    )
    file(RENAME "${DEP_SOURCE_PATH}" "${PATH}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

set(EXTERNALS "${SOURCE_PATH}/third_party/externals")
file(MAKE_DIRECTORY "${EXTERNALS}")

# these following aren't available in vcpkg
# to update, visit the DEPS file in Skia's root directory
# define SKIA_USE_MIRROR in a triplet to use the mirrors
checkout_in_path("${EXTERNALS}/sfntly"
    "https://github.com/googlefonts/sfntly"
    "b55ff303ea2f9e26702b514cf6a3196a2e3e2974"
)
checkout_in_path("${EXTERNALS}/dng_sdk"
    "https://android.googlesource.com/platform/external/dng_sdk"
    "c8d0c9b1d16bfda56f15165d39e0ffa360a11123"
)
checkout_in_path("${EXTERNALS}/libgifcodec"
    "https://skia.googlesource.com/libgifcodec"
    "fd59fa92a0c86788dcdd84d091e1ce81eda06a77"
)
checkout_in_path("${EXTERNALS}/piex"
    "https://android.googlesource.com/platform/external/piex"
    "bb217acdca1cc0c16b704669dd6f91a1b509c406"
)

function(third_party_from_pkgconfig gn_group)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "PATH" "DEFINES;MODULES")
    if(NOT arg_PATH)
        set(arg_PATH "third_party/${gn_group}")
    endif()
    if(NOT arg_MODULES)
        set(arg_MODULES "${gn_group}")
    endif()
    if(arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unparsed arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    x_vcpkg_pkgconfig_get_modules(PREFIX PC_${module} MODULES ${arg_MODULES} CFLAGS LIBS)
    foreach(config IN ITEMS DEBUG RELEASE)
        separate_arguments(cflags UNIX_COMMAND "${PC_${module}_CFLAGS_${config}}")
        set(defines "${cflags}")
        list(FILTER defines INCLUDE REGEX "^-D" )
        list(TRANSFORM defines REPLACE "^-D" "")
        list(APPEND defines ${arg_DEFINES})
        set(include_dirs "${cflags}")
        list(FILTER include_dirs INCLUDE REGEX "^-I" )
        list(TRANSFORM include_dirs REPLACE "^-I" "")
        separate_arguments(libs UNIX_COMMAND "${PC_${module}_LIBS_${config}}")
        set(lib_dirs "${libs}")
        list(FILTER lib_dirs INCLUDE REGEX "^-L" )
        list(TRANSFORM lib_dirs REPLACE "^-L" "")
        # Passing link libraries via ldflags, cf. third-party.gn.in
        set(ldflags "${libs}")
        list(FILTER ldflags INCLUDE REGEX "^-l" )
        if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
            list(TRANSFORM ldflags REPLACE "^-l" "")
            list(TRANSFORM ldflags APPEND ".lib")
        endif()
        set(GN_OUT_${config} "")
        foreach(item IN ITEMS defines include_dirs lib_dirs ldflags)
            set("gn_${item}_${config}" "")
            if(NOT "${${item}}" STREQUAL "")
                list(JOIN ${item} [[", "]] list)
                set("gn_${item}_${config}" "\"${list}\"")
            endif()
        endforeach()
    endforeach()
    configure_file("${CMAKE_CURRENT_LIST_DIR}/third-party.gn.in" "${SOURCE_PATH}/${arg_PATH}/BUILD.gn" @ONLY)
endfunction()

third_party_from_pkgconfig(expat)
third_party_from_pkgconfig(libjpeg PATH "third_party/libjpeg-turbo" MODULES libturbojpeg libjpeg)
third_party_from_pkgconfig(libpng)
third_party_from_pkgconfig(libwebp MODULES libwebpdecoder libwebpdemux libwebpmux libwebp)
third_party_from_pkgconfig(zlib)

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

if("fontconfig" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_fontconfig=true")
    third_party_from_pkgconfig(fontconfig PATH "third_party")
else()
    string(APPEND OPTIONS " skia_use_fontconfig=false")
endif()

if("freetype" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_freetype=true")
    third_party_from_pkgconfig(freetype2)
else()
    string(APPEND OPTIONS " skia_use_freetype=false")
endif()

if("harfbuzz" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_harfbuzz=true")
    third_party_from_pkgconfig(harfbuzz MODULES harfbuzz harfbuzz-subset)
else()
    string(APPEND OPTIONS " skia_use_harfbuzz=false")
endif()

if("icu" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_icu=true")
    third_party_from_pkgconfig(icu MODULES icu-uc DEFINES "U_USING_ICU_NAMESPACE=0")
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
    string(APPEND OPTIONS "${OPTIONS} skia_use_vulkan=true")
endif()

if("direct3d" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_direct3d=true")

    checkout_in_path("${EXTERNALS}/spirv-cross"
        "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross"
        "61c603f3baa5270e04bcfb6acf83c654e3c57679"
    )

    checkout_in_path("${EXTERNALS}/spirv-headers"
        "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git"
        "0bcc624926a25a2a273d07877fd25a6ff5ba1cfb"
    )

    checkout_in_path("${EXTERNALS}/spirv-tools"
        "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git"
        "0073a1fa36f7c52ad3d58059cb5d5de8efa825ad"
    )

    checkout_in_path("${EXTERNALS}/d3d12allocator"
        "https://skia.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git"
        "169895d529dfce00390a20e69c2f516066fe7a3b"
    )
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

    string(APPEND OPTIONS " skia_use_dawn=true")
    string(REPLACE "dynamic" "shared" DAWN_LINKAGE "${VCPKG_LIBRARY_LINKAGE}")
    vcpkg_list(APPEND SKIA_TARGETS
        "third_party/externals/dawn/src/dawn:proc_${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/native:${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/platform:${DAWN_LINKAGE}"
    )

   checkout_in_path("${EXTERNALS}/spirv-cross"
       "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross"
       "61c603f3baa5270e04bcfb6acf83c654e3c57679"
   )

   checkout_in_path("${EXTERNALS}/spirv-headers"
       "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git"
       "0bcc624926a25a2a273d07877fd25a6ff5ba1cfb"
   )

   checkout_in_path("${EXTERNALS}/spirv-tools"
       "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git"
       "0073a1fa36f7c52ad3d58059cb5d5de8efa825ad"
   )

   checkout_in_path("${EXTERNALS}/tint"
         "https://dawn.googlesource.com/tint"
         "200492e32b94f042d9942154fb4fa7f93bb8289a"
   )

   checkout_in_path("${EXTERNALS}/jinja2"
       "https://chromium.googlesource.com/chromium/src/third_party/jinja2"
       "ee69aa00ee8536f61db6a451f3858745cf587de6"
   )

   checkout_in_path("${EXTERNALS}/markupsafe"
       "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
       "0944e71f4b2cb9a871bcbe353f95e889b64a611a"
   )

## Remove
   checkout_in_path("${EXTERNALS}/vulkan-headers"
       "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Headers"
       "c896e2f920273bfee852da9cca2a356bc1c2031e"
   )

   checkout_in_path("${EXTERNALS}/vulkan-tools"
       "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Tools"
       "d55c7aaf041af331bee8c22fb448a6ff4c797f73"
   )

   checkout_in_path("${EXTERNALS}/abseil-cpp"
       "https://skia.googlesource.com/external/github.com/abseil/abseil-cpp.git"
       "c5a424a2a21005660b182516eb7a079cd8021699"
   )

## REMOVE ^
   checkout_in_path("${EXTERNALS}/dawn"
       "https://dawn.googlesource.com/dawn.git"
       "30fa0d8d2ced43e44baa522dd4bd4684b14a3099"
   )

   vcpkg_find_acquire_program(GIT)
   file(READ "${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py" DVG_CONTENT)
   string(REPLACE "return 'git.bat' if sys.platform == 'win32' else 'git'" "return '${GIT}'" DVG_CONTENT ${DVG_CONTENT})
   file(WRITE "${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py" ${DVG_CONTENT})
endif()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(REGEX REPLACE "[\\]\$" "" WIN_VC "$ENV{VCINSTALLDIR}")
    string(APPEND OPTIONS " win_vc=\"${WIN_VC}\"")
else()
    string(APPEND OPTIONS_DBG " \
        cc=\"${VCPKG_DETECTED_CMAKE_C_COMPILER}\" \
        cxx=\"${VCPKG_DETECTED_CMAKE_CXX_COMPILER}\"")
endif()

# Turn a space separated string into a gn list:
# "a b c" -> ["a","b","c"]
function(string_to_gn_list out_var input)
    separate_arguments(list UNIX_COMMAND "${input}")
    if(NOT list STREQUAL "")
        list(JOIN list [[","]] temp)
        set(list "\"${temp}\"")
    endif()
    set("${out_var}" "[${list}]" PARENT_SCOPE)
endfunction()

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

vcpkg_configure_gn(
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

vcpkg_install_gn(
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
set(skia_dll_static "0")
set(skia_dll_dynamic "1")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/skia/include/core/SkTypes.h" "defined(SKIA_DLL)" "${skia_dll_${VCPKG_LIBRARY_LINKAGE}}")

function(auto_clean dir)
    file(GLOB entries "${dir}/*")
    file(GLOB files LIST_DIRECTORIES false "${dir}/*")
    foreach(entry IN LISTS entries)
        if(entry IN_LIST files)
            continue()
        endif()
        file(GLOB_RECURSE children "${entry}/*")
        if(children)
            auto_clean("${entry}")
        else()
            file(REMOVE_RECURSE "${entry}")
        endif()
    endforeach()
endfunction()
auto_clean("${CURRENT_PACKAGES_DIR}/include/skia")
# vcpkg legacy layout omits "include/" component. Just duplicate.
file(COPY "${CURRENT_PACKAGES_DIR}/include/skia/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/skia")

function(list_from_json out_var json) # <path>
    vcpkg_list(SET list)
    string(JSON array ERROR_VARIABLE error GET "${json}" ${ARGN})
    if(NOT error)
        string(JSON len ERROR_VARIABLE error LENGTH "${array}")
        if(NOT error AND NOT len STREQUAL "0")
            math(EXPR last "${len} - 1")
            foreach(i RANGE "${last}")
                string(JSON item GET "${array}" "${i}")
                vcpkg_list(APPEND list "${item}")
            endforeach()
        endif()
    endif()
    set("${out_var}" "${list}" PARENT_SCOPE)
endfunction()

function(get_definitions out_var desc_json target)
    list_from_json(output "${desc_json}" "${target}" "defines")
    list(FILTER output INCLUDE REGEX "^SK_")
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()

function(get_link_libs out_var desc_json target)
    # From ldflags, we only want lib names or filepaths (cf. third_party_from_pkgconfig)
    list_from_json(ldflags "${desc_json}" "${target}" "ldflags")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        list(FILTER ldflags INCLUDE REGEX "[.]lib\$")
    else()
        list(FILTER ldflags INCLUDE REGEX "^-l|^/")
    endif()
    list(TRANSFORM ldflags REPLACE "^-l" "")
    list_from_json(libs "${desc_json}" "${target}" "libs")
    vcpkg_list(SET frameworks)
    if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
        list_from_json(frameworks "${desc_json}" "${target}" "frameworks")
    endif()
    vcpkg_list(SET output)
    foreach(lib IN LISTS frameworks ldflags libs)
        string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${vcpkg_root}]] lib "${lib}")
        string(REPLACE "${CURRENT_PACKAGES_DIR}" [[${vcpkg_root}]] lib "${lib}")
        if(NOT lib MATCHES "^-L")
            vcpkg_list(REMOVE_ITEM output "${lib}")
        endif()
        vcpkg_list(APPEND output "${lib}")
    endforeach()
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()

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
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
