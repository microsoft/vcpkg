vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/crashpad/crashpad
    REF efdc820b087c20eec9e32cb5e5b1a63dcf73a724
    PATCHES fix-missing-stdint.patch
)

vcpkg_find_acquire_program(PYTHON3)
x_vcpkg_get_python_packages(OUT_PYTHON_VAR PYTHON3
    PYTHON_EXECUTABLE "${PYTHON3}"
    PYTHON_VERSION "3"
    PACKAGES setuptools
)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")

# mini_chromium contains the toolchains and build configuration
if(NOT EXISTS "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/BUILD.gn")
    vcpkg_from_git(OUT_SOURCE_PATH mini_chromium
        URL "https://chromium.googlesource.com/chromium/mini_chromium"
        REF e5169551c51f3a52eee36b3b03f219cefe380237
        PATCHES
            # Honor vcpkg's Linux toolchain, including GCC, and fix ARM Android GN generation.
            mini-chromium-toolchain.patch
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

# Rename the archives to the vcpkg_crashpad_* names crashpadConfig.cmake expects.
function(set_gn_output_name FILE TARGET_DECL OUTPUT_NAME)
    vcpkg_replace_string("${FILE}" "${TARGET_DECL} {" "${TARGET_DECL} {\n  output_name = \"${OUTPUT_NAME}\"")
endfunction()
set_gn_output_name("${SOURCE_PATH}/client/BUILD.gn" "crashpad_static_library(\"client\")" vcpkg_crashpad_client)
set_gn_output_name("${SOURCE_PATH}/client/BUILD.gn" "static_library(\"common\")" vcpkg_crashpad_client_common)
set_gn_output_name("${SOURCE_PATH}/util/BUILD.gn" "crashpad_static_library(\"util\")" vcpkg_crashpad_util)
set_gn_output_name("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/base/BUILD.gn" "static_library(\"base\")" vcpkg_crashpad_base)

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
        message(FATAL_ERROR "Could not find release library with names: ${LIBRARY_NAMES}")
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
    "z;zs;zlib;zd;zsd;zlibd"
)

set(OPTIONS "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\"")
set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "")

if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    string(APPEND OPTIONS " target_os=\"android\" android_ndk_root=\"${VCPKG_DETECTED_CMAKE_ANDROID_NDK}\"")
    # mini_chromium defaults android_api_level to 26; follow the triplet instead.
    if(VCPKG_DETECTED_CMAKE_SYSTEM_VERSION MATCHES "^[0-9]+$")
        string(APPEND OPTIONS " android_api_level=${VCPKG_DETECTED_CMAKE_SYSTEM_VERSION}")
    endif()

elseif(VCPKG_TARGET_IS_LINUX)
    string(APPEND OPTIONS " target_os=\"linux\"")

    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    string(APPEND OPTIONS " \
        mini_chromium_cc=\"${VCPKG_DETECTED_CMAKE_C_COMPILER}\" \
        mini_chromium_cxx=\"${VCPKG_DETECTED_CMAKE_CXX_COMPILER}\" \
        mini_chromium_ar=\"${VCPKG_DETECTED_CMAKE_AR}\"")
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        string(APPEND OPTIONS " mini_chromium_is_clang=false extra_cflags=\"-Wno-error\"")
    endif()

    # libstdc++ 14's C++23 std::bind_front is incompatible with Clang.
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        string(PREPEND VCPKG_COMBINED_CXX_FLAGS_DEBUG "-std=c++20 ")
        string(PREPEND VCPKG_COMBINED_CXX_FLAGS_RELEASE "-std=c++20 ")
    endif()

    # GN strings cannot contain raw backslashes, quotes, or `$`; escape the detected flags.
    foreach(flags_var IN ITEMS
            VCPKG_COMBINED_C_FLAGS_DEBUG VCPKG_COMBINED_C_FLAGS_RELEASE
            VCPKG_COMBINED_CXX_FLAGS_DEBUG VCPKG_COMBINED_CXX_FLAGS_RELEASE
            VCPKG_COMBINED_EXE_LINKER_FLAGS_DEBUG VCPKG_COMBINED_EXE_LINKER_FLAGS_RELEASE
            VCPKG_COMBINED_STATIC_LINKER_FLAGS_DEBUG VCPKG_COMBINED_STATIC_LINKER_FLAGS_RELEASE)
        string(REPLACE "\\" "\\\\" ${flags_var} "${${flags_var}}")
        string(REPLACE "\"" "\\\"" ${flags_var} "${${flags_var}}")
        string(REPLACE "\$" "\\\$" ${flags_var} "${${flags_var}}")
    endforeach()

    # extra_ldflags only affects the crashpad_handler executable; all libraries are static.
    set(OPTIONS_DBG "${OPTIONS_DBG} \
        extra_cflags_c=\"${VCPKG_COMBINED_C_FLAGS_DEBUG}\" \
        extra_cflags_cc=\"${VCPKG_COMBINED_CXX_FLAGS_DEBUG}\" \
        extra_ldflags=\"${VCPKG_COMBINED_EXE_LINKER_FLAGS_DEBUG}\" \
        extra_arflags=\"${VCPKG_COMBINED_STATIC_LINKER_FLAGS_DEBUG}\"")

    set(OPTIONS_REL "${OPTIONS_REL} \
        extra_cflags_c=\"${VCPKG_COMBINED_C_FLAGS_RELEASE}\" \
        extra_cflags_cc=\"${VCPKG_COMBINED_CXX_FLAGS_RELEASE}\" \
        extra_ldflags=\"${VCPKG_COMBINED_EXE_LINKER_FLAGS_RELEASE}\" \
        extra_arflags=\"${VCPKG_COMBINED_STATIC_LINKER_FLAGS_RELEASE}\"")

elseif(VCPKG_TARGET_IS_OSX)
    string(APPEND OPTIONS " target_os=\"mac\"")
    # mini_chromium defaults mac_deployment_target to 13.0; follow the triplet when set.
    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        string(APPEND OPTIONS " mac_deployment_target=\"${VCPKG_OSX_DEPLOYMENT_TARGET}\"")
    endif()

elseif(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # Force the vcpkg-selected MSVC toolchain instead of mini_chromium's own clang.
    string(APPEND OPTIONS " target_os=\"win\" mini_chromium_is_clang=false")

    # Load toolchains
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    cmake_path(CONVERT "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}" TO_CMAKE_PATH_LIST CRASHPAD_CXX_COMPILER_PATH NORMALIZE)
    string(REGEX REPLACE "/VC/Tools/.*" "" CRASHPAD_VISUAL_STUDIO_PATH "${CRASHPAD_CXX_COMPILER_PATH}")
    if(NOT CRASHPAD_VISUAL_STUDIO_PATH STREQUAL CRASHPAD_CXX_COMPILER_PATH
       AND EXISTS "${CRASHPAD_VISUAL_STUDIO_PATH}/VC/Auxiliary/Build/vcvarsall.bat")
        # mini_chromium checks VSINSTALLDIR before it falls back to vswhere.
        set(ENV{VSINSTALLDIR} "${CRASHPAD_VISUAL_STUDIO_PATH}")
    endif()

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

# On Windows/MSVC, mirror headers into the root include directory so MSBuild integration
# (which adds only <installed>/include) can resolve un-namespaced includes like
# "client/..." and "base/...".
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    message(STATUS "Mirroring headers into include root for MSBuild consumption...")
    file(COPY "${SOURCE_PATH}/client" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")
    file(COPY "${SOURCE_PATH}/util" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")
    file(COPY "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/base" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")
    file(COPY "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/build" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")
endif()

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

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/include/util/net/testdata"
        "${CURRENT_PACKAGES_DIR}/include/build/ios")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/crashpadConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/crashpadConfig.cmake" @ONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/${PORT}/build/config")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/${PORT}/util/mach/__pycache__")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # Remove empty directory created under the mirrored root include
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/build/config")
endif()

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
