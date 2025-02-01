vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/crashpad/crashpad
    REF 7e0af1d4d45b526f01677e74a56f4a951b70517d
    PATCHES
        fix-linux.patch
        fix-lib-name-conflict.patch
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")

# mini_chromium contains the toolchains and build configuration
if(NOT EXISTS "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/BUILD.gn")
    vcpkg_from_git(OUT_SOURCE_PATH mini_chromium
        URL "https://chromium.googlesource.com/chromium/mini_chromium"
        REF dce72d97d1c2e9beb5e206c6a05a702269794ca3
        PATCHES
            fix-std-20.patch
            ndk-toolchain.diff
            fix-lib-name-conflict-1.patch
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium")
    file(RENAME "${mini_chromium}" "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium")
endif()

if(NOT EXISTS "${SOURCE_PATH}/third_party/lss/lss/BUILD.gn" AND (VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_LINUX))
    vcpkg_from_git(OUT_SOURCE_PATH lss
        URL https://chromium.googlesource.com/linux-syscall-support
        REF 9719c1e1e676814c456b55f5f070eabad6709d31
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/lss/lss")
    file(RENAME "${lss}" "${SOURCE_PATH}/third_party/lss/lss")
endif()

function(replace_gn_dependency INPUT_FILE OUTPUT_FILE LIBRARY_NAMES)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        unset(_LIBRARY_DEB CACHE)
        find_library(_LIBRARY_DEB NAMES ${LIBRARY_NAMES}
          PATHS "${CURRENT_INSTALLED_DIR}/debug/lib"
          NO_DEFAULT_PATH)

        if(_LIBRARY_DEB MATCHES "-NOTFOUND")
            message(FATAL_ERROR "Could not find debug library with names: ${LIBRARY_NAMES}")
        endif()
    endif()

    unset(_LIBRARY_REL CACHE)
    find_library(_LIBRARY_REL NAMES ${LIBRARY_NAMES}
        PATHS "${CURRENT_INSTALLED_DIR}/lib"
        NO_DEFAULT_PATH)

    if(_LIBRARY_REL MATCHES "-NOTFOUND")
        message(FATAL_ERROR "Could not find library with names: ${LIBRARY_NAMES}")
    endif()

    if(VCPKG_BUILD_TYPE STREQUAL "release")
        set(_LIBRARY_DEB ${_LIBRARY_REL})
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

set(OPTIONS "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\"")
set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "")

if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    string(APPEND OPTIONS " target_os=\"android\" android_ndk_root=\"${VCPKG_DETECTED_CMAKE_ANDROID_NDK}\"")

elseif(VCPKG_TARGET_IS_LINUX)
    string(APPEND OPTIONS " target_os=\"linux\"")

elseif(VCPKG_TARGET_IS_OSX)
    string(APPEND OPTIONS " target_os=\"mac\"")

elseif(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    string(APPEND OPTIONS " target_os=\"win\"")

    # Load toolchains
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    set(OPTIONS_DBG "${OPTIONS_DBG} \
        extra_cflags_c=\"${VCPKG_COMBINED_C_FLAGS_DEBUG}\" \
        extra_cflags_cc=\"${VCPKG_COMBINED_CXX_FLAGS_DEBUG}\" \
        extra_ldflags=\"${VCPKG_COMBINED_SHARED_LINKER_FLAGS_DEBUG}\" \
        extra_arflags=\"${VCPKG_COMBINED_STATIC_LINKER_FLAGS_DEBUG}\"")

    set(OPTIONS_REL "${OPTIONS_REL} \
        extra_cflags_c=\"${VCPKG_COMBINED_C_FLAGS_RELEASE}\" \
        extra_cflags_cc=\"${VCPKG_COMBINED_CXX_FLAGS_RELEASE}\" \
        extra_ldflags=\"${VCPKG_COMBINED_SHARED_LINKER_FLAGS_RELEASE}\" \
        extra_arflags=\"${VCPKG_COMBINED_STATIC_LINKER_FLAGS_RELEASE}\"")

    set(DISABLE_WHOLE_PROGRAM_OPTIMIZATION "\
        extra_cflags=\"/GL-\" \
        extra_ldflags=\"/LTCG:OFF\" \
        extra_arflags=\"/LTCG:OFF\"")

    set(OPTIONS_DBG "${OPTIONS_DBG} ${DISABLE_WHOLE_PROGRAM_OPTIMIZATION}")
    set(OPTIONS_REL "${OPTIONS_REL} ${DISABLE_WHOLE_PROGRAM_OPTIMIZATION}")
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "${OPTIONS}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS client client:common util third_party/mini_chromium/mini_chromium/base handler:crashpad_handler
)

message(STATUS "Installing headers...")
set(PACKAGES_INCLUDE_DIR "${CURRENT_PACKAGES_DIR}/include/${PORT}")
function(install_headers DIR)
    file(COPY "${DIR}" DESTINATION "${PACKAGES_INCLUDE_DIR}" FILES_MATCHING PATTERN "*.h")
endfunction()
install_headers("${SOURCE_PATH}/client")
install_headers("${SOURCE_PATH}/util")
install_headers("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/base")
install_headers("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/build")

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen/build/chromeos_buildflags.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/build")
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gen/build/chromeos_buildflags.h.flags" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/build")

if(VCPKG_TARGET_IS_OSX)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/obj/util/libmig_output.a" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/obj/util/libmig_output.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

vcpkg_copy_tools(
    TOOL_NAMES crashpad_handler
    SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools")

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    file(CHMOD "${CURRENT_PACKAGES_DIR}/tools/crashpad_handler" FILE_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
      WORLD_READ WORLD_EXECUTE
    )
endif()

# remove empty directories
file(REMOVE_RECURSE
    "${PACKAGES_INCLUDE_DIR}/util/net/testdata"
    "${PACKAGES_INCLUDE_DIR}/build/ios")

configure_file("${CMAKE_CURRENT_LIST_DIR}/crashpadConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/crashpadConfig.cmake" @ONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/${PORT}/build/config")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/${PORT}/util/mach/__pycache__")

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
