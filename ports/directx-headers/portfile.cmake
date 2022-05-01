vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectX-Headers
    REF v1.602.0
    SHA512 75d81191e3e0b60bc901f04fcb9cf53f0faae7f0c196a1b04f2b9199c72243d4dddaeacad29d82ca7ccb209b16d07b4f1b71a58368fccad13c4d8421e0c9f0d9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DDXHEADERS_BUILD_TEST=OFF -DDXHEADERS_BUILD_GOOGLE_TEST=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/directx-headers/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
