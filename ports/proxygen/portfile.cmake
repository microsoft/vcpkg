vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF 43778e064b0ae26f812377cf6c39a3b5efd183bb #v2021.05.31.00
    SHA512 aa8c6bdab743b087a2339e63b57cd33d7598c4d5085b7df14919ebe5790b533953292a9a27822867b3ae221dcc3a63813470692bb893cb0fb5a9e53c4441acfd
    HEAD_REF master
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
