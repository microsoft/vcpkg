vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF 6ae482092cca4d4a408e6bdf24714153d9203797
    SHA512 1865f6178b2885483f0b43c1641e602f957d4e64e77b802e64a64038b709dbf63fa2dd6037720e7180434e91341f2e1a0eb86424c1ee1556db5971cba3434bb0
    HEAD_REF dev
    PATCHES
        unofficial-webview2.patch
        fix-source-generation.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS -Dsaucer_prefer_remote=OFF -Dsaucer_remote_webview2=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
