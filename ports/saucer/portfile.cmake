vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF 33a738d15727b285ed0ec979f1b6e1c7943ccd45
    SHA512 2f68955772f6532a53a291c5fa8cd05556d56964e32978d0992f1bcb6f20888921a72578f2f4aaa33a1868f1294354fb91cf9f5b5918a284d3d38d6bbb1d6b11
    HEAD_REF dev
    PATCHES "unofficial-webview2.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS -Dsaucer_prefer_remote=OFF -Dsaucer_remote_webview2=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
