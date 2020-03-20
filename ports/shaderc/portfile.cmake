
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/shaderc
    REF 95185d920a0b3d5a493f6f705ad8f0245c7d55cf
    SHA512 9dd1b961fe380d0a026df0832d9282d5785b5f75229a619d98bcb039fd2253e105cf8dacc04cee1b637007651fdd609e5b926d5aba1f5ae501284ff1376bc6c2
    HEAD_REF master
    PATCHES
        disable-update-version.patch
        find-packages.patch
        install-targets.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/third_party")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/build-version.inc" DESTINATION "${SOURCE_PATH}/glslc/src")

if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(SHADERC_CRT_OPTIONS -DSHADERC_ENABLE_SHARED_CRT:BOOL=ON)
endif()

# shaderc uses python to manipulate copyright information
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DSHADERC_SKIP_TESTS=true
        ${SHADERC_CRT_OPTIONS}
        -Dglslang_SOURCE_DIR=""
        -Dspirv-tools_SOURCE_DIR=""
)

vcpkg_install_cmake()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_fixup_cmake_targets()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/shaderc-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
