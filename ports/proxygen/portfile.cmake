vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF v2021.05.31.00
    SHA512 45d5a7b3920a02d3b27fbbfb1c1b7dbad3cec13fd7dabab2947b2c446493e96701bdf2aefb17c7e00965d3cad3b4aaaa42074788b554f4036f0edebc4b0fed5d
    HEAD_REF master
    PATCHES
        remove-register.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(GPERF)
    get_filename_component(GPERF_PATH ${GPERF} DIRECTORY)
    vcpkg_add_to_path(${GPERF_PATH})
else()
    # gperf only have windows package in vcpkg now.
    if (NOT EXISTS /usr/bin/gperf)
        message(FATAL_ERROR "proxygen requires gperf, these can be installed on Ubuntu systems via apt-get install gperf.")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_tools(TOOL_NAMES proxygen_curl proxygen_echo proxygen_proxy proxygen_push proxygen_static AUTO_CLEAN)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/proxygen)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
