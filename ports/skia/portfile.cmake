vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://skia.googlesource.com/skia.git
    REF fb0b35fed5580d49392df7ce9374551b348fffbf
    PATCHES add-missing-tuple.patch
)

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
    "d06d2a6d42baf6c0c91cacc28df2542a911d05fe"
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
replace_skia_dep(harfbuzz "/include/harfbuzz" "harfbuzz-icu" "harfbuzz-icu" "")
replace_skia_dep(icu "/include" "icuuc,icuucd" "icuuc" "U_USING_ICU_NAMESPACE=0")
replace_skia_dep(libjpeg-turbo "/include" "jpeg,jpegd;turbojpeg,turbojpegd" "jpeg;turbojpeg" "")
replace_skia_dep(libpng "/include" "libpng16,libpng16d" "libpng16" "")
replace_skia_dep(libwebp "/include"
    "webp,webpd;webpdemux,webpdemuxd;webpdecoder,webpdecoderd;libwebpmux,libwebpmuxd"
    "webp;webpdemux;webpdecoder;libwebpmux" "")
replace_skia_dep(zlib "/include" "z,zlib,zlibd" "z,zlib" "")

set(OPTIONS "\
skia_use_lua=false \
skia_enable_tools=false \
skia_enable_spirv_validation=false")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(OPTIONS "${OPTIONS} target_cpu=\"arm64\"")
endif()

# used for passing feature-specific definitions to the config file
set(SKIA_PUBLIC_DEFINITIONS "")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPTIONS "${OPTIONS} is_component_build=true")
else()
    set(OPTIONS "${OPTIONS} is_component_build=false")
endif()

if("metal" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} skia_use_metal=true")
    list(APPEND SKIA_PUBLIC_DEFINITIONS SK_METAL)
endif()

set(OPTIONS_REL "${OPTIONS} is_official_build=true")
set(OPTIONS_DBG "${OPTIONS} is_debug=true")

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

    set(OPTIONS_DBG "${OPTIONS_DBG} extra_cflags_c=${SKIA_C_FLAGS_DBG} \
        extra_cflags_cc=${SKIA_CXX_FLAGS_DBG}")

    set(OPTIONS_REL "${OPTIONS_REL} extra_cflags_c=${SKIA_C_FLAGS_REL} \
        extra_cflags_cc=${SKIA_CXX_FLAGS_REL}")

    set(WIN_VC "$ENV{VCINSTALLDIR}")
    string(REPLACE "\\VC\\" "\\VC" WIN_VC "${WIN_VC}")
    set(OPTIONS_DBG "${OPTIONS_DBG} win_vc=\"${WIN_VC}\"")
    set(OPTIONS_REL "${OPTIONS_REL} win_vc=\"${WIN_VC}\"")

endif()

vcpkg_configure_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

vcpkg_install_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ":skia"
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
    vcpkg_find_acquire_program(GN)
    execute_process(
        COMMAND ${GN} desc "${BUILD_DIR}" "${TARGET}" libs
        WORKING_DIRECTORY "${SOURCE_PATH}"
        OUTPUT_VARIABLE OUTPUT_
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX REPLACE "\n|(\r\n)" ";" OUTPUT_ "${OUTPUT_}")
    set(${OUTPUT} ${OUTPUT_} PARENT_SCOPE)
endfunction()

# skiaConfig.cmake.in input variables
gn_desc_target_libs(SKIA_DEP_DBG
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    //:skia)
gn_desc_target_libs(SKIA_DEP_REL
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    //:skia)

configure_file("${CMAKE_CURRENT_LIST_DIR}/skiaConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/skia/skiaConfig.cmake" @ONLY)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/skia")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
