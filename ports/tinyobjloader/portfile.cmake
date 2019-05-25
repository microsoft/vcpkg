include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyobjloader
    REF e4637eb508aa3e41233875f6ce3891d96fbc5d33
    SHA512 556b808690abd7b36e7af7fc6fa21b37459614b2d93da175981c073f2a7706f2cdee57f9c2f7aa902769b35bb6dd36831e07e736a5746a5934a0e6d1c5d2a4b2
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DCMAKE_INSTALL_DOCDIR:STRING=share/tinyobjloader
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/tinyobjloader/cmake")

file(
    REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/tinyobjloader
    ${CURRENT_PACKAGES_DIR}/debug/lib/tinyobjloader
)

vcpkg_copy_pdbs()

# Put the licence file where vcpkg expects it
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/LICENSE ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/copyright)
