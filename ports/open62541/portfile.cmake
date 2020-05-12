vcpkg_fail_port_install(ON_TARGET "UWP")

set(VERSION v1.0.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541/open62541
    REF e4309754fc2f6ea6508b59ca82e08c27b0118d74 # v1.0.1
    SHA512 bfff9e722c5ee70b93abc54fe0b3267c531bbe039d3344376069175b5d5d95324cd9471ad45674c50393fb0259faacfa94eac1814de11dde4538d76f3e74b2bb
    HEAD_REF master
    PATCHES fix-install-bindir.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPEN62541_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/open62541/tools)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
