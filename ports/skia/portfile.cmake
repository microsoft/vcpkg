vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/google/skia
    REF 3aa7f602018816ab3f009f1b8d359ccde752e1de
    PATCHES
        "use_vcpkg_fontconfig.patch"
)

# Replace hardcoded python paths
vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")

vcpkg_replace_string("${SOURCE_PATH}/gn/toolchain/BUILD.gn" "command = \"$shell python" "command = \"$shell '${PYTHON3}'")

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

function(checkout_in_path_with_patch PATH URL REF PATCH)
    if(EXISTS "${PATH}")
        return()
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
        PATCHES "${PATCH}"
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

# turn a CMake list into a GN list of quoted items
# "a;b;c" -> ["a","b","c"]
function(cmake_to_gn_list OUTPUT_ INPUT_)
    if(NOT INPUT_)
        set(${OUTPUT_} "[]" PARENT_SCOPE)
    else()
        string(REPLACE ";" "\",\"" TEMP "${INPUT_}")
        set(${OUTPUT_} "[\"${TEMP}\"]" PARENT_SCOPE)
    endif()
endfunction()

# multiple libraries with multiple names may be passed as
# "libA,libA2;libB,libB2,libB3;..."
function(find_libraries RESOLVED LIBRARY_NAMES PATHS)
    set(_RESOLVED "")
    foreach(_LIB_GROUP ${LIBRARY_NAMES})
        string(REPLACE "," ";" _LIB_GROUP_NAMES "${_LIB_GROUP}")
        unset(_LIB CACHE)
        find_library(_LIB NAMES ${_LIB_GROUP_NAMES}
            PATHS "${PATHS}"
            NO_DEFAULT_PATH)

        if(_LIB MATCHES "-NOTFOUND")
            message(FATAL_ERROR "Could not find library with names: ${_LIB_GROUP_NAMES}")
        endif()

        list(APPEND _RESOLVED "${_LIB}")
    endforeach()
    set(${RESOLVED} "${_RESOLVED}" PARENT_SCOPE)
endfunction()

# For each .gn file in the current list directory, configure and install at
# the corresponding directory to replace Skia dependencies with ones from vcpkg.
function(replace_skia_dep NAME INCLUDES LIBS_DBG LIBS_REL DEFINITIONS)
    list(TRANSFORM INCLUDES PREPEND "${CURRENT_INSTALLED_DIR}")
    cmake_to_gn_list(_INCLUDES "${INCLUDES}")

    find_libraries(_LIBS_DBG "${LIBS_DBG}" "${CURRENT_INSTALLED_DIR}/debug/lib")
    cmake_to_gn_list(_LIBS_DBG "${_LIBS_DBG}")

    find_libraries(_LIBS_REL "${LIBS_REL}" "${CURRENT_INSTALLED_DIR}/lib")
    cmake_to_gn_list(_LIBS_REL "${_LIBS_REL}")

    cmake_to_gn_list(_DEFINITIONS "${DEFINITIONS}")

    set(OUT_FILE "${SOURCE_PATH}/third_party/${NAME}/BUILD.gn")
    file(REMOVE "${OUT_FILE}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/${NAME}.gn" "${OUT_FILE}" @ONLY)
endfunction()

set(_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")

replace_skia_dep(expat "/include" "libexpat,libexpatd,libexpatdMD" "libexpat,libexpatMD" "")
replace_skia_dep(freetype2 "/include" "freetype,freetyped" "freetype" "")
replace_skia_dep(harfbuzz "/include/harfbuzz" "harfbuzz;harfbuzz-subset" "harfbuzz;harfbuzz-subset" "")
replace_skia_dep(icu "/include" "icuuc,icuucd" "icuuc" "U_USING_ICU_NAMESPACE=0")
replace_skia_dep(libjpeg-turbo "/include" "jpeg,jpegd;turbojpeg,turbojpegd" "jpeg;turbojpeg" "")
replace_skia_dep(libpng "/include" "libpng16,libpng16d" "libpng16" "")
replace_skia_dep(libwebp "/include"
    "webp,webpd;webpdemux,webpdemuxd;webpdecoder,webpdecoderd;webpmux,webpmuxd"
    "webp;webpdemux;webpdecoder;webpmux" "")
replace_skia_dep(zlib "/include" "z,zlib,zlibd" "z,zlib" "")
if(CMAKE_HOST_UNIX)
     replace_skia_dep(fontconfig "/include" "fontconfig" "fontconfig" "")
 endif()

set(OPTIONS "\
skia_use_lua=false \
skia_enable_tools=false \
skia_enable_spirv_validation=false \
target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\"")

# used for passing feature-specific definitions to the config file
set(SKIA_PUBLIC_DEFINITIONS
    SK_SUPPORT_PDF
    SK_HAS_JPEG_LIBRARY
    SK_USE_LIBGIFCODEC
    SK_HAS_PNG_LIBRARY
    SK_HAS_WEBP_LIBRARY
    SK_XML)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    string(APPEND OPTIONS " is_component_build=true")
    if(CMAKE_HOST_WIN32)
        set(SKIA_PUBLIC_DEFINITIONS SKIA_DLL)
    endif()
else()
    string(APPEND OPTIONS " is_component_build=false")
endif()

if(CMAKE_HOST_APPLE)
    if("metal" IN_LIST FEATURES)
        set(OPTIONS "${OPTIONS} skia_use_metal=true")
        list(APPEND SKIA_PUBLIC_DEFINITIONS SK_METAL)
    endif()
endif()

if("vulkan" IN_LIST FEATURES)
     set(OPTIONS "${OPTIONS} skia_use_vulkan=true")
     list(APPEND SKIA_PUBLIC_DEFINITIONS SK_VULKAN)
 endif()

if(CMAKE_HOST_WIN32)
   if("direct3d" IN_LIST FEATURES)
       set(OPTIONS "${OPTIONS} skia_use_direct3d=true")
       list(APPEND SKIA_PUBLIC_DEFINITIONS SK_DIRECT3D)

       checkout_in_path("${EXTERNALS}/spirv-cross"
           "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross"
           "6a67891418a3f08be63f92726e049dc788e46f5b"
       )

       checkout_in_path("${EXTERNALS}/spirv-headers"
           "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git"
           "82becc8a8a92e509d3d8d635889da0a3c17d0606"
       )

       checkout_in_path("${EXTERNALS}/spirv-tools"
           "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git"
           "cb96abbf7affd986016f17dd09f9f971138a922b"
       )

       checkout_in_path("${EXTERNALS}/d3d12allocator"
           "https://skia.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git"
           "169895d529dfce00390a20e69c2f516066fe7a3b"
       )
   endif()
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

   set(OPTIONS "${OPTIONS} skia_use_dawn=true")
   list(APPEND SKIA_PUBLIC_DEFINITIONS SK_DAWN)

   checkout_in_path("${EXTERNALS}/spirv-cross"
       "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross"
       "6a67891418a3f08be63f92726e049dc788e46f5b"
   )

   checkout_in_path("${EXTERNALS}/spirv-headers"
       "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git"
       "82becc8a8a92e509d3d8d635889da0a3c17d0606"
   )

   checkout_in_path("${EXTERNALS}/spirv-tools"
       "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git"
       "cb96abbf7affd986016f17dd09f9f971138a922b"
   )

   checkout_in_path("${EXTERNALS}/tint"
         "https://dawn.googlesource.com/tint"
         "b612c505939bf86c80a55c193b93c41ed0f252a1"
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
       "76f00ef6cbb1886eb1162d1fa39bee8b51e22ee8"
   )

   checkout_in_path("${EXTERNALS}/vulkan-tools"
       "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Tools"
       "ef20059aea7ec24d0842edca2f75255eaa33a7b0"
   )

   checkout_in_path("${EXTERNALS}/abseil-cpp"
       "https://skia.googlesource.com/external/github.com/abseil/abseil-cpp.git"
       "c5a424a2a21005660b182516eb7a079cd8021699"
   )

## REMOVE ^
   checkout_in_path("${EXTERNALS}/dawn"
       "https://dawn.googlesource.com/dawn.git"
       "e6d4598d36157639606a780164c425c6bffb93f6"
   )

   vcpkg_find_acquire_program(GIT)
   file(READ "${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py" DVG_CONTENT)
   string(REPLACE "return 'git.bat' if sys.platform == 'win32' else 'git'" "return '${GIT}'" DVG_CONTENT ${DVG_CONTENT})
   file(WRITE "${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py" ${DVG_CONTENT})
endif()

if("gl" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_gl=true")
    list(APPEND SKIA_PUBLIC_DEFINITIONS SK_GL)
endif()

set(OPTIONS_DBG "${OPTIONS} is_debug=true")
set(OPTIONS_REL "${OPTIONS} is_official_build=true")

if(CMAKE_HOST_WIN32)
    # Load toolchains
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

    # turn a space delimited string into a gn list:
    # "a b c" -> ["a","b","c"]
    function(to_gn_list OUTPUT_ INPUT_)
        string(STRIP "${INPUT_}" TEMP)
        string(REPLACE "  " " " TEMP "${TEMP}")
        string(REPLACE " " "\",\"" TEMP "${TEMP}")
        set(${OUTPUT_} "[\"${TEMP}\"]" PARENT_SCOPE)
    endfunction()

    to_gn_list(SKIA_C_FLAGS_DBG "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    to_gn_list(SKIA_C_FLAGS_REL "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")

    to_gn_list(SKIA_CXX_FLAGS_DBG "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
    to_gn_list(SKIA_CXX_FLAGS_REL "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")

    string(APPEND OPTIONS_DBG " extra_cflags_c=${SKIA_C_FLAGS_DBG} \
        extra_cflags_cc=${SKIA_CXX_FLAGS_DBG}")
    string(APPEND OPTIONS_REL " extra_cflags_c=${SKIA_C_FLAGS_REL} \
        extra_cflags_cc=${SKIA_CXX_FLAGS_REL}")

    set(WIN_VC "$ENV{VCINSTALLDIR}")
    string(REPLACE "\\VC\\" "\\VC" WIN_VC "${WIN_VC}")
    string(APPEND OPTIONS_DBG " win_vc=\"${WIN_VC}\"")
    string(APPEND OPTIONS_REL " win_vc=\"${WIN_VC}\"")
endif()

vcpkg_configure_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

set(DAWN_LINKAGE "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(DAWN_LINKAGE "shared")
else()
    set(DAWN_LINKAGE "static")
endif()

vcpkg_list(SET SKIA_TARGETS ":skia")
if("dawn" IN_LIST FEATURES)
    vcpkg_list(APPEND SKIA_TARGETS
        "third_party/externals/dawn/src/dawn:proc_${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/native:${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/platform:${DAWN_LINKAGE}"
    )
endif()

vcpkg_install_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS
        ${SKIA_TARGETS}
)

message(STATUS "Installing: ${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${SOURCE_PATH}/include"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/include"
    "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(GLOB_RECURSE SKIA_INCLUDE_FILES LIST_DIRECTORIES false
    "${CURRENT_PACKAGES_DIR}/include/${PORT}/*")
foreach(file_ ${SKIA_INCLUDE_FILES})
    vcpkg_replace_string("${file_}" "#include \"include/" "#include \"${PORT}/")
endforeach()

# get a list of library dependencies for TARGET
function(gn_desc_target_libs OUTPUT BUILD_DIR TARGET)
    z_vcpkg_install_gn_get_desc("${OUTPUT}"
        SOURCE_PATH "${SOURCE_PATH}"
        BUILD_DIR "${BUILD_DIR}"
        TARGET "${TARGET}"
        WHAT_TO_DISPLAY libs)
endfunction()

function(gn_desc_target_defines OUTPUT BUILD_DIR TARGET)
    z_vcpkg_install_gn_get_desc(OUTPUT_
        SOURCE_PATH "${SOURCE_PATH}"
        BUILD_DIR "${BUILD_DIR}"
        TARGET "${TARGET}"
        WHAT_TO_DISPLAY defines)
    # exclude system defines such as _HAS_EXCEPTIONS=0
    list(FILTER OUTPUT_ EXCLUDE REGEX "^_")
    set(${OUTPUT} ${OUTPUT_} PARENT_SCOPE)
endfunction()

# skiaConfig.cmake.in input variables
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    gn_desc_target_libs(SKIA_DEP_DBG
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        //:skia)
    gn_desc_target_defines(SKIA_DEFINITIONS_DBG
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        //extract_public_config:extract_skia)
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    gn_desc_target_libs(SKIA_DEP_REL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        //:skia)
    gn_desc_target_defines(SKIA_DEFINITIONS_REL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        //extract_public_config:extract_skia)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/skiaConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/skia/skiaConfig.cmake" @ONLY)

file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
