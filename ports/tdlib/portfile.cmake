vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tdlib/td
    REF f10611ee1f03f91ddae8185483a1ccfd3d664668
    HEAD_REF master
    SHA512 683bbce0ce41ca38bfc60da28b8eaff4e5c4d50093b581a29ad722d80f92498da8ce6012667a83b259af721c081d811042a073735ccae97d9b67f4c2eaa3907f
    PATCHES
        fix-cross-compile.patch
        # Exclude uninstalled benchmarks/CLI from default builds and disable ambient PHP documentation generation.
        fix-packaging.patch
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

# When cross-compiling, run the generator executables that were installed by
# the host build of tdlib[tools] (declared as a host:true dependency in
# vcpkg.json).  Running them directly avoids a cmake sub-invocation and
# therefore sidesteps the Windows ARM64 problem where a cmake subprocess
# inherits the vcvarsall cross-compiler and produces the wrong architecture.
if(VCPKG_CROSSCOMPILING)
    # When updating this port to a new tdlib version, verify the cross-compile
    # generator invocations below still match what the upstream build does:
    #
    #  1. TL-schema list (the foreach over _scheme):
    #     Compare against the tl_generate_tlo custom target in
    #     td/generate/CMakeLists.txt — every .tl file passed to tl-parser
    #     there must be listed here.
    #
    #  2. MIME-type step (generate_mime_types_gperf + gperf):
    #     Driven by tdutils/generate/CMakeLists.txt.  Check that the input
    #     file (mime_types.txt), the two .gperf output names, and the two
    #     gperf output .cpp names still match that file.
    #
    #  3. Generator executables (the foreach over _gen):
    #     Must include every add_executable() target defined inside the
    #     if (NOT CMAKE_CROSSCOMPILING) block in td/generate/CMakeLists.txt
    #     that is depended upon by the main library's custom commands
    #     (i.e. those that write files into td/generate/auto/).
    #     Currently: tl-parser, generate_mime_types_gperf (handled above),
    #     generate_mtproto, generate_common, generate_json.
    #     Also sync the install(TARGETS ...) list in fix-cross-compile.patch
    #     and the vcpkg_copy_tools() list below.
    #
    #  4. Output directories pre-created with file(MAKE_DIRECTORY):
    #     Must cover every directory that generator executables write into.
    #     Check the WORKING_DIRECTORY and output paths of the custom commands
    #     in td/generate/CMakeLists.txt and tdutils/generate/CMakeLists.txt.

    set(_tools "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}")
    set(_exe   "${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    set(_gperf "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf/gperf${_exe}")

    # ── MIME type sources ────────────────────────────────────────────────────
    file(MAKE_DIRECTORY "${SOURCE_PATH}/tdutils/generate/auto")

    vcpkg_execute_required_process(
        COMMAND "${_tools}/generate_mime_types_gperf${_exe}"
                "${SOURCE_PATH}/tdutils/generate/mime_types.txt"
                "${SOURCE_PATH}/tdutils/generate/auto/mime_type_to_extension.gperf"
                "${SOURCE_PATH}/tdutils/generate/auto/extension_to_mime_type.gperf"
        WORKING_DIRECTORY "${SOURCE_PATH}/tdutils/generate"
        LOGNAME "tdlib-gen-mime-gperf-${TARGET_TRIPLET}"
    )
    vcpkg_execute_required_process(
        COMMAND "${_gperf}" -m100
                "--output-file=auto/mime_type_to_extension.cpp"
                "auto/mime_type_to_extension.gperf"
        WORKING_DIRECTORY "${SOURCE_PATH}/tdutils/generate"
        LOGNAME "tdlib-gen-mime-to-ext-${TARGET_TRIPLET}"
    )
    vcpkg_execute_required_process(
        COMMAND "${_gperf}" -m100
                "--output-file=auto/extension_to_mime_type.cpp"
                "auto/extension_to_mime_type.gperf"
        WORKING_DIRECTORY "${SOURCE_PATH}/tdutils/generate"
        LOGNAME "tdlib-gen-ext-to-mime-${TARGET_TRIPLET}"
    )

    # ── TL schema → .tlo → generated C++ API sources ─────────────────────────
    file(MAKE_DIRECTORY "${SOURCE_PATH}/td/generate/auto/tlo")
    foreach(_scheme IN ITEMS mtproto_api secret_api e2e_api td_api telegram_api)
        vcpkg_execute_required_process(
            COMMAND "${_tools}/tl-parser${_exe}"
                    -e "auto/tlo/${_scheme}.tlo" "scheme/${_scheme}.tl"
            WORKING_DIRECTORY "${SOURCE_PATH}/td/generate"
            LOGNAME "tdlib-gen-tlo-${_scheme}-${TARGET_TRIPLET}"
        )
    endforeach()

    file(MAKE_DIRECTORY "${SOURCE_PATH}/td/generate/auto/td/telegram")
    file(MAKE_DIRECTORY "${SOURCE_PATH}/td/generate/auto/td/mtproto")
    foreach(_gen IN ITEMS generate_mtproto generate_common generate_json)
        vcpkg_execute_required_process(
            COMMAND "${_tools}/${_gen}${_exe}"
            WORKING_DIRECTORY "${SOURCE_PATH}/td/generate/auto"
            LOGNAME "tdlib-${_gen}-${TARGET_TRIPLET}"
        )
    endforeach()

    unset(_tools)
    unset(_exe)
    unset(_gperf)
endif()

if("tools" IN_LIST FEATURES AND NOT VCPKG_CROSSCOMPILING)
    set(_tdlib_install_gen ON)
else()
    set(_tdlib_install_gen OFF)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIBRARIES)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBRARIES)

set(msvc_pdb_options "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # Keep compiler detection from changing the existing configure options.
    function(tdlib_get_msvc_pdb_options out_var)
        vcpkg_cmake_get_vars(cmake_vars_file)
        include("${cmake_vars_file}")
        if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            set("${out_var}" "-DCMAKE_PROJECT_TDLib_INCLUDE=${CMAKE_CURRENT_FUNCTION_LIST_DIR}/cmake-project-include.cmake" PARENT_SCOPE)
        endif()
    endfunction()
    tdlib_get_msvc_pdb_options(msvc_pdb_options)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${msvc_pdb_options}
        -DTD_INSTALL_SHARED_LIBRARIES=${BUILD_DYNAMIC_LIBRARIES}
        -DTD_INSTALL_STATIC_LIBRARIES=${BUILD_STATIC_LIBRARIES}
        -DTD_ENABLE_JNI=${VCPKG_TARGET_IS_ANDROID}
        -DTD_ENABLE_DOTNET=OFF
        -DTD_GENERATE_SOURCE_FILES=OFF
        -DTD_E2E_ONLY=OFF
        -DTD_ENABLE_LTO=${CMAKE_HOST_WIN32}
        -DTD_ENABLE_MULTI_PROCESSOR_COMPILATION=${VCPKG_DETECTED_MSVC}
        -DTD_INSTALL_HOST_GENERATORS=${_tdlib_install_gen}
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Crc32c=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Readline=ON
    MAYBE_UNUSED_VARIABLES
        TD_ENABLE_MULTI_PROCESSOR_COMPILATION
        TD_INSTALL_HOST_GENERATORS
)

vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_cmake_install()
if(msvc_pdb_options AND BUILD_STATIC_LIBRARIES)
    function(tdlib_copy_compile_pdbs config build_suffix destination)
        file(GLOB libraries LIST_DIRECTORIES false "${destination}/*.lib")
        if(NOT libraries)
            message(FATAL_ERROR "No TDLib static libraries found in ${destination}")
        endif()
        foreach(library IN LISTS libraries)
            get_filename_component(name "${library}" NAME_WE)
            set(pdb "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${build_suffix}/compiler-pdb/${config}/${name}.pdb")
            if(NOT EXISTS "${pdb}")
                message(FATAL_ERROR "Compiler PDB for ${library} not found: ${pdb}")
            endif()
            file(INSTALL "${pdb}" DESTINATION "${destination}")
        endforeach()
    endfunction()

    tdlib_copy_compile_pdbs("Release" "rel" "${CURRENT_PACKAGES_DIR}/lib")
    if(NOT VCPKG_BUILD_TYPE)
        tdlib_copy_compile_pdbs("Debug" "dbg" "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
endif()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Td")
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES AND NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tools(
        TOOL_NAMES
            tl-parser
            generate_mtproto
            generate_common
            generate_json
            generate_mime_types_gperf
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
set(copyright_files
    "${SOURCE_PATH}/LICENSE_1_0.txt"
    "${SOURCE_PATH}/sqlite/sqlite/LICENSE"
)
set(copyright_options "")
if("tools" IN_LIST FEATURES AND NOT VCPKG_CROSSCOMPILING)
    list(APPEND copyright_files
        "${SOURCE_PATH}/td/generate/tl-parser/LICENSE"
        "${SOURCE_PATH}/td/generate/tl-parser/tl-parser.h"
    )
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND copyright_files
            "${SOURCE_PATH}/td/generate/tl-parser/wgetopt.h"
        )
        set(copyright_options COMMENT "The LGPL 2.1 license text for the GNU getopt code in the Windows tl-parser tool is not included in the upstream repository. It can be obtained from https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt.")
    endif()
endif()
vcpkg_install_copyright(FILE_LIST ${copyright_files} ${copyright_options})
