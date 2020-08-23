# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF b30ddc6a50dc582c93cd49d8d0cf8f5025ba1d2b # 1.5
    SHA512 faeeef88aef11e89e9565850c23087925fb4d75ef48a16434055f18831db8e230d044c81574d840dacca406d7095cb83a113afc326996e289ab11a02d8caa2f4
    HEAD_REF master
    PATCHES 
        fix-includes-not-found.patch
        disable-examples.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSQLITE_ORM_ENABLE_CXX_17=OFF
        -DSqliteOrm_BuildTests=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sqlite_orm TARGET_PATH share/SqliteOrm)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)