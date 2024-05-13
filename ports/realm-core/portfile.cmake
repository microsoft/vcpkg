vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO realm/realm-core
        REF "9cf7ef4ad8e2f4c7a519c9a395ca3d253bb87aa8"
        SHA512 "1bd11bfe70204213469687d1e224fabb2ff2798aa25f6d791b3d455acdcacf686248e7a692f23ed67148ef99faf1a7c1f823182f33a45340310477bc51b32bb7"
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
