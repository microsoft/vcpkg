vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitdefender/bddisasm
    REF v1.34.10
    SHA512 441a14c590fa12920bb972ca1d1b255cd03e0444be57eef16565803b446a1d9a49c62642b7947a1dcbf64b650fb7a66ae1796e42872d742cbaa9071a35150527
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBDD_INCLUDE_TOOL=OFF
)

vcpkg_cmake_install()

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bddisasm)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")

vcpkg_fixup_pkgconfig()
