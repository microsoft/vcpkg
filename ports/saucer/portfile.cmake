vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF 4d41e0f356c5b95f77803cdb760a3c01eac0aabd
    SHA512 b5fe7484c80f0efde3c9f445a3a38421aff48d589ee27778495b501de4d232da44d55072664371ade79891ea7218ab1ddab385e2316b7ae20b5c32cd2332dd56
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
