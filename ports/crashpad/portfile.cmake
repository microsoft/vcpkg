vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/crashpad/crashpad
    REF 7e0af1d4d45b526f01677e74a56f4a951b70517d
    PATCHES
        fix-linux.patch
        output-names.diff
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")

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

# mini_chromium contains the toolchains and build configuration
checkout_in_path(
    "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium"
    "https://chromium.googlesource.com/chromium/mini_chromium"
    "dce72d97d1c2e9beb5e206c6a05a702269794ca3"
)
vcpkg_apply_patches(
    SOURCE_PATH "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium"
    PATCHES
      "fix-std-20.patch"
)      
vcpkg_replace_string("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/build/config/BUILD.gn" "tool_prefix = \"arm-linux-androideabi\"" "# unused")

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID)
    # fetch lss
    checkout_in_path(
        "${SOURCE_PATH}/third_party/lss/lss"
        https://chromium.googlesource.com/linux-syscall-support
        9719c1e1e676814c456b55f5f070eabad6709d31
    )
endif()

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

if(CMAKE_HOST_WIN32)
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

set(OPTIONS "")
if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    vcpkg_replace_string("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/build/config/BUILD.gn" [[ndk_bin_dir + tool_prefix + "-ar"]] "\"${VCPKG_DETECTED_CMAKE_AR}\"")
    string(APPEND OPTIONS " target_os=\"android\" android_ndk_root=\"${VCPKG_DETECTED_CMAKE_ANDROID_NDK}\"")
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS " target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\" ${OPTIONS}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

vcpkg_gn_install(
    TARGETS
        # Cf. https://chromium.googlesource.com/crashpad/crashpad/+/main/doc/overview_design.md#overview
        client
        handler:crashpad_handler
)

vcpkg_gn_export_cmake(TARGETS client handler:crashpad_handler)
vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

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

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")

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
