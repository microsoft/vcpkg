vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realm/realm-core
    REF "9cf7ef4ad8e2f4c7a519c9a395ca3d253bb87aa8"
    SHA512 1bd11bfe70204213469687d1e224fabb2ff2798aa25f6d791b3d455acdcacf686248e7a692f23ed67148ef99faf1a7c1f823182f33a45340310477bc51b32bb7
    HEAD_REF master
    PATCHES 
        UWP_index_set.patch
        fix-zlib.patch
)

vcpkg_list(SET REALMCORE_CMAKE_OPTIONS)
if(VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_OSX)
    list(APPEND REALMCORE_CMAKE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL=ON)
else()
    if(VCPKG_TARGET_IS_EMSCRIPTEN)
        list(APPEND REALMCORE_CMAKE_OPTIONS -DREALM_FORCE_OPENSSL=ON)
        list(APPEND REALMCORE_CMAKE_OPTIONS -DREALM_ENABLE_SYNC=OFF) # https://github.com/realm/realm-core/issues/7752
    endif()
    list(APPEND REALMCORE_CMAKE_OPTIONS -DREALM_USE_SYSTEM_OPENSSL=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DREALM_BUILD_LIB_ONLY=ON
        -DREALM_CORE_SUBMODULE_BUILD=OFF
        -DREALM_NO_TESTS=ON
        -DREALM_VERSION=${VERSION}
        -DCMAKE_DISABLE_FIND_PACKAGE_Backtrace=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_BISON=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_FLEX=ON
        ${REALMCORE_CMAKE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_OpenSSL
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "realm" CONFIG_PATH "share/cmake/Realm")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/doc"
    "${CURRENT_PACKAGES_DIR}/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/THIRD-PARTY-NOTICES")
