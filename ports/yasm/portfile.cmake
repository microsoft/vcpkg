vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yasm/yasm
    REF 009450c7ad4d425fa5a10ac4bd6efbd25248d823 # 1.3.0 plus bugfixes for https://github.com/yasm/yasm/issues/153
    SHA512 a542577558676d11b52981925ea6219bffe699faa1682c033b33b7534f5a0dfe9f29c56b32076b68c48f65e0aef7c451be3a3af804c52caa4d4357de4caad83c
    HEAD_REF master
    PATCHES
        add-feature-tools.patch
        cmake-4.diff
        fix-cross-build.patch
        fix-overlay-pdb.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_find_acquire_program(PYTHON3)

set(HOST_TOOLS_OPTIONS "")
if (VCPKG_CROSSCOMPILING)
    list(APPEND HOST_TOOLS_OPTIONS
        "-D_tmp_RE2C_EXE=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/re2c${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-D_tmp_GENPERF_EXE=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/genperf${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-D_tmp_GENMACRO_EXE=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/genmacro${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-D_tmp_GENVERSION_EXE=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/genversion${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${HOST_TOOLS_OPTIONS}
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
        -DENABLE_NLS=OFF
        -DYASM_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if (NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tools(TOOL_NAMES re2c genmacro genperf genversion AUTO_CLEAN
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
    )
endif()

if(BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES vsyasm yasm ytasm AUTO_CLEAN)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(COPY "${CURRENT_PACKAGES_DIR}/bin/yasmstd${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()
endif()

file(COPY "${CURRENT_PORT_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
