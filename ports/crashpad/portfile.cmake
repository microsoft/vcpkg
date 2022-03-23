vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
set(VCPKG_TARGET_TRIPLET ${TARGET_TRIPLET})
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/crashpad/crashpad
    REF 68aba08c48bb428b7b159b3371163f86e8d5a126
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")

function(checkout_into_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "DEST;URL;REF;PATCHES" "")
    
    if(EXISTS "${arg_DEST}")
        return()
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${arg_URL}"
        REF "${arg_REF}"
        PATCHES "${arg_PATCHES}"
    )
    file(RENAME "${DEP_SOURCE_PATH}" "${arg_DEST}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

# mini_chromium contains the toolchains and build configuration
checkout_into_path(
    DEST "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium"
    URL "https://chromium.googlesource.com/chromium/mini_chromium"
    REF "502930381b23c5fa3911c8b82ec3e4ba6ceb3658"
    PATCHES update-toolchain.patch
)

# lss
checkout_into_path(
    DEST "${SOURCE_PATH}/third_party/lss/lss"
    URL "https://chromium.googlesource.com/linux-syscall-support.git"
    REF "7bde79cc274d06451bf65ae82c012a5d3e476b5a"
)

function(replace_gn_dependency INPUT_FILE OUTPUT_FILE LIBRARY_NAMES)
    unset(_LIBRARY_DEB CACHE)
    find_library(_LIBRARY_DEB NAMES ${LIBRARY_NAMES}
        PATHS "${CURRENT_INSTALLED_DIR}/debug/lib"
        NO_DEFAULT_PATH)

    if(_LIBRARY_DEB MATCHES "-NOTFOUND")
        message(FATAL_ERROR "Could not find debug library with names: ${LIBRARY_NAMES}")
    endif()

    unset(_LIBRARY_REL CACHE)
    find_library(_LIBRARY_REL NAMES ${LIBRARY_NAMES}
        PATHS "${CURRENT_INSTALLED_DIR}/lib"
        NO_DEFAULT_PATH)

    if(_LIBRARY_REL MATCHES "-NOTFOUND")
        message(FATAL_ERROR "Could not find library with names: ${LIBRARY_NAMES}")
    endif()

    set(_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")

    file(REMOVE "${OUTPUT_FILE}")
    configure_file("${INPUT_FILE}" "${OUTPUT_FILE}" @ONLY)
endfunction()

replace_gn_dependency(
    "${CMAKE_CURRENT_LIST_DIR}/zlib.gn"
    "${SOURCE_PATH}/third_party/zlib/BUILD.gn"
    "z;zlib;zlibd"
)

set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "")
set(GN_OPTIONS "")
if("${VCPKG_TARGET_TRIPLET}" MATCHES ".*-windows")
    message(STATUS "Setting GN options for Windows")
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

    foreach(_VAR CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS
        CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE)
        string(STRIP "${${_VAR}}" ${_VAR})
    endforeach()

    set(OPTIONS_DBG "${OPTIONS_DBG} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}\"")

    set(OPTIONS_REL "${OPTIONS_REL} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}\"")

    set(DISABLE_WHOLE_PROGRAM_OPTIMIZATION "\
        extra_cflags=\"/GL-\" \
        extra_ldflags=\"/LTCG:OFF\" \
        extra_arflags=\"/LTCG:OFF\"")

    set(OPTIONS_DBG "${OPTIONS_DBG} ${DISABLE_WHOLE_PROGRAM_OPTIMIZATION}")
    set(OPTIONS_REL "${OPTIONS_REL} ${DISABLE_WHOLE_PROGRAM_OPTIMIZATION}")
elseif("${VCPKG_TARGET_TRIPLET}" MATCHES ".*-android")
    message(STATUS "Setting GN options for Android")
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

    foreach(_VAR CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS
        CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE CMAKE_SHARED_LINKER_FLAGS)
        string(STRIP "${${_VAR}}" ${_VAR})
    endforeach()

    set(OPTIONS_DBG "${OPTIONS_DBG} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}\" \
        extra_ldflags=\"${CMAKE_SHARED_LINKER_FLAGS}\"")

    set(OPTIONS_REL "${OPTIONS_REL} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}\" \
        extra_ldflags=\"${CMAKE_SHARED_LINKER_FLAGS}\"")
    
    string(TOLOWER ${VCPKG_CMAKE_SYSTEM_NAME} TARGET_OS)
    set(GN_OPTIONS 
        "target_os=\"${TARGET_OS}\" \
        target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\" \
        android_ndk_root=\"$ENV{ANDROID_NDK_HOME}\""
    )
elseif("${VCPKG_TARGET_TRIPLET}" MATCHES ".*-linux")
    message(STATUS "Setting GN options for Linux")
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

    foreach(_VAR CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS
        CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE)
        string(STRIP "${${_VAR}}" ${_VAR})
    endforeach()
    
    set(OPTIONS_DBG "${OPTIONS_DBG} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}\"")

    set(OPTIONS_REL "${OPTIONS_REL} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}\"")
elseif("${VCPKG_TARGET_TRIPLET}" MATCHES ".*-osx")
    message(STATUS "Setting GN options for OSX")
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

    foreach(_VAR CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS
        CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE CMAKE_SHARED_LINKER_FLAGS
        CMAKE_EXE_LINKER_FLAGS CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_EXE_LINKER_FLAGS_RELEASE)
        string(STRIP "${${_VAR}}" ${_VAR})
    endforeach()

    string(APPEND CMAKE_EXE_LINKER_FLAGS " -lobjc -framework IOKit -framework CoreFoundation -framework ApplicationServices -framework Foundation -framework Security ")
    set(OPTIONS_DBG "${OPTIONS_DBG} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}\" \
        extra_ldflags=\"${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_DEBUG}\"")

    set(OPTIONS_REL "${OPTIONS_REL} \
        extra_cflags_c=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}\" \
        extra_cflags_cc=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}\" \
        extra_ldflags=\"${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_RELEASE}\"")
endif()
message(STATUS "Configure GN")
vcpkg_configure_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "${GN_OPTIONS}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)
## Compile and install targets via GN and Ninja
message(STATUS "Install GN")
vcpkg_install_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS 
        client
        client:common
        util
        third_party/mini_chromium/mini_chromium/base
        handler:crashpad_handler
        tools:generate_dump
)

## Install headers
message(STATUS "Installing headers to ${CURRENT_PACKAGES_DIR}/include/${PORT}")
set(PACKAGES_INCLUDE_DIR "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(GLOB_RECURSE HEADER_PATHS
    RELATIVE "${SOURCE_PATH}"
    "${SOURCE_PATH}/*.h"
)
foreach(HEADER_PATH ${HEADER_PATHS})
    cmake_path(GET HEADER_PATH PARENT_PATH HEADER_FILE_DIR)
    message(VERBOSE "Copying ${SOURCE_PATH}/${HEADER_PATH} to ${PACKAGES_INCLUDE_DIR}/${HEADER_FILE_DIR}")
    file(COPY "${SOURCE_PATH}/${HEADER_PATH}" DESTINATION "${PACKAGES_INCLUDE_DIR}/${HEADER_FILE_DIR}")
endforeach()
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/gen/build/chromeos_buildflags.h"
    DESTINATION "${PACKAGES_INCLUDE_DIR}/build"
)
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/gen/build/chromeos_buildflags.h.flags"
    DESTINATION "${PACKAGES_INCLUDE_DIR}/build"
)

if("${TARGET_OS}" STREQUAL "android")
    ## Rename crashpad_handler executable to libcrashpad_handler.so so it can be bundled in future package
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/crashpad_handler"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        RENAME "libcrashpad_handler.so"
    )
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/crashpad_handler"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
        RENAME "libcrashpad_handler.so"
    )

    ## Rename generate_dump executable to libgenerate_dump.so so it can be bundled in future package
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/generate_dump"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        RENAME "libgenerate_dump.so"
    )
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/generate_dump"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
        RENAME "libgenerate_dump.so"
    )
endif()

## Configure cmake config for find_package
configure_file("${CMAKE_CURRENT_LIST_DIR}/crashpadConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/crashpadConfig.cmake" @ONLY
)

vcpkg_copy_pdbs()
## Install copyright file
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
