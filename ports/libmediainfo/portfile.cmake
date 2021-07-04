vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF v20.09
    SHA512 0e9407d0a430c396b98f8e911e606bc4fa14914881540552bc81d78a57908aa4a54666f415474dda176527ed88148629660e3f2c090f648db8b75a92fec2449f
    HEAD_REF master
    PATCHES vcpkg_support_in_cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Project/CMake
    PREFER_NINJA
    OPTIONS
        -DBUILD_ZENLIB=0
        -DBUILD_ZLIB=0
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/mediainfolib TARGET_PATH share/mediainfolib)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
