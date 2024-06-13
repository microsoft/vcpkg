vcpkg_download_distfile(
    android-alooper-patch
    URLS https://github.com/realm/realm-core/commit/50a9895544a195afab0450d0c87730e8a31cf667.diff?full_index=1
    FILENAME realm-core-android-alooper-50a989.diff
    SHA512 7c10f166ab61f4ea7a46473aa04eb1b5f440edd81c2997cc10b84b9890eb6dfe7b77d51364fe2d4c537c7809ce03dd8b269309d7da2eede72be8dec3b71c2485
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realm/realm-core
    REF "${VERSION}"
    SHA512 474f5c6d62e42b221f7b934ca2d8070f83e92eeeeb1271594b7d750fc6f4d186889e04722e0f26ca725cf4f3130c5e1851e82e4ab944a05e25465f3115ffe8ce
    HEAD_REF master
    PATCHES 
        UWP_index_set.patch
        fix-zlib.patch
        ${android-alooper-patch}
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
