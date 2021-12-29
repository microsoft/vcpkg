set(OATPP_VERSION "1.2.5")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-postgresql
    REF ${OATPP_VERSION}
    SHA512 43381422224f0254a823fdc702d1a007c405930157e6ea361f51e5232df4b04073181de175f61ab4986f3468d21f9ac25a0820d14efcecb0afb0096bdd674dcb
    HEAD_REF master
    PATCHES
        fix-windows-build.patch # see https://github.com/oatpp/oatpp-postgresql/pull/8
)

set(VCPKG_C_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-postgresql-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
