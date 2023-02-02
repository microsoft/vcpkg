vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO amrayn/licensepp
    REF 0b6d669c0b323be004f73d8c811d38158ce8c0c7
    SHA512 2161575815d8ff49110d7c2823662ba30d9f1ca2eb6be6dad1ee0807fb3fa9f28483839a133c9d380035254df7c452f8d6fa7f17fd4f29acd8b9bfbbda059291
    HEAD_REF master
    PATCHES
        0001-use-old-pem-pack.patch
        0002-fix-cmake.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindCryptoPP.cmake DESTINATION ${SOURCE_PATH}/cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dtest=OFF
        -Dtravis=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT}/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
