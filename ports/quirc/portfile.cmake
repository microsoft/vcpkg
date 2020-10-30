vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dlbeer/quirc
    REF 2e8c4ce7bc45fbe137e50e338c297e265777e7dd # v1.1
    SHA512 83eeab7c70c93477f9a7a2d3114e080ce831d27e035bb47c3fc114d5ede8852599c37af591af348dde1a870f65f8a860284e4a3e1e05585cb7948556b464f59c
    HEAD_REF master
    PATCHES
        patch-for-msvc.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/quirc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/quirc/license ${CURRENT_PACKAGES_DIR}/share/quirc/copyright)
