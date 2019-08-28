include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rpclib/rpclib
    REF v2.2.1
    SHA512 a63c6d09a411fb6b87d0df7c4f75a189f775ff0208f5f1c67333a85030a47efe60d5518e5939e98abc683a6063afb6cfed51f118f594a2a08be32330a9691051
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/rpclib)

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/rpclib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rpclib/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/rpclib/copyright)
