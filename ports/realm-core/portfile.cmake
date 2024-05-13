vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO realm/realm-core
        REF "adbefab1b21e92c45c21e6cff8eb42632f14a09a"
        SHA512 "595a314a47dd12ced139bbb36c8e79d79f8a326b4da181b3badd53fc9d1294883448f3f18846a899b75c7593294caf24ef8fe2dc7818fe2710764043e785fc0e"
        HEAD_REF "master"
        PATCHES 
            "UWP_index_set.patch")

set(REALMCORE_CMAKE_OPTIONS -DREALM_CORE_SUBMODULE_BUILD=OFF)
list(APPEND REALMCORE_CMAKE_OPTIONS -DREALM_BUILD_LIB_ONLY=ON)
list(APPEND REALMCORE_CMAKE_OPTIONS -DREALM_NO_TESTS=ON)
list(APPEND REALMCORE_CMAKE_OPTIONS -DREALM_NEEDS_OPENSSL=ON)

if (ANDROID OR WIN32 OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
    list(APPEND REALMCORE_CMAKE_OPTIONS -DREALM_USE_SYSTEM_OPENSSL=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${REALMCORE_CMAKE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "realm" CONFIG_PATH "share/cmake/Realm")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/doc"
    "${CURRENT_PACKAGES_DIR}/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
