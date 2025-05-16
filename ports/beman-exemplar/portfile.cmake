# vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# See:
# https://github.com/bemanproject/exemplar/issues/161
# https://github.com/bemanproject/exemplar/issues/163
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bemanproject/exemplar
    REF "${VERSION}"
    SHA512 492dea71e64f3ee08e502c8eda33697d30f9eb9c04f32b2e1f4ffad28a605448e47dd6242356033ce06fcc972d0816348d44cfb2bd0dead12dffffe3d9ab8e16
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DBEMAN_EXEMPLAR_BUILD_TESTS=OFF
        -DBEMAN_EXEMPLAR_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "beman.exemplar"
    CONFIG_PATH "lib/cmake/beman.exemplar"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
