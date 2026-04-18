vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tdlib/td
    REF f06b0bac65278b03d26414c096080e7bfecfef52
    HEAD_REF master
    SHA512 91967a24eee9f1491b780ce72a1323aa99e228c10ecd588979e325d57417c6897eeebf375c609c99b2fd0d6137bcb950628a30f5cfc2e6838fb14d2803d02b7a
    PATCHES
        fix-pc.patch
        fix-cross-compile.patch
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

# When cross-compiling, run the generator executables that were installed by
# the host build of tdlib[tools] (declared as a host:true dependency in
# vcpkg.json).  Running them directly avoids a cmake sub-invocation and
# therefore sidesteps the Windows ARM64 problem where a cmake subprocess
# inherits the vcvarsall cross-compiler and produces the wrong architecture.
if(VCPKG_CROSSCOMPILING)
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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
    MAYBE_UNUSED_VARIABLES
        TD_ENABLE_MULTI_PROCESSOR_COMPILATION
        TD_INSTALL_HOST_GENERATORS
)

if(NOT VCPKG_CROSSCOMPILING)
    # generate_json links tdutils which pulls in OpenSSL/zlib as DLLs; ensure
    # the debug-config DLLs are on PATH so the generator can start when Ninja
    # builds the Debug configuration.
    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
endif()

vcpkg_cmake_install()
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
