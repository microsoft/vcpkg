vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yasm/yasm
    REF 009450c7ad4d425fa5a10ac4bd6efbd25248d823 # 1.3.0 plus bugfixes for https://github.com/yasm/yasm/issues/153
    SHA512 a542577558676d11b52981925ea6219bffe699faa1682c033b33b7534f5a0dfe9f29c56b32076b68c48f65e0aef7c451be3a3af804c52caa4d4357de4caad83c
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(NOT "${TARGET_TRIPLET}" STREQUAL "${HOST_TRIPLET}")
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_NLS=OFF
        -DYASM_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/yasmstd${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}
         DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()
vcpkg_copy_tools(TOOL_NAMES vsyasm yasm ytasm genperf re2c genmacro genversion AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)