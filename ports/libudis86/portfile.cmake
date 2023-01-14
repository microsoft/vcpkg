vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vmt/udis86
    REF 56ff6c87c11de0ffa725b14339004820556e343d
    SHA512 7a98333f9310f5f0466294bd980f03f9269c118a7557832015c59a7b6349a0eeab5642e0e6598d0be76d71f5d2d566d8b8af0ec75c26bdcff45646d60ff18e3a
    HEAD_REF master
    PATCHES
        fix-macbuild.patch
        python3.patch # from https://github.com/vmt/udis86/pull/133
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_find_acquire_program(PYTHON3)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/scripts/ud_itab.py" "${SOURCE_PATH}/docs/x86/optable.xml" "${SOURCE_PATH}/libudis86/"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME python-${TARGET_TRIPLET}-generate-sources
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
        -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
