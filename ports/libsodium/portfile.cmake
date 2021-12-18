vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libsodium
    REF 1.0.18
    SHA512 727fe50a5fb1df86ec5d807770f408a52609cbeb8510b4f4183b2a35a537905719bdb6348afcb103ff00ce946a8094ac9559b6e3e5b2ccc2a2d0c08f75577eeb
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-sodium
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(REMOVE ${CURRENT_PACKAGES_DIR}/include/Makefile.am)

configure_file(
    ${SOURCE_PATH}/LICENSE
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright
    COPYONLY
)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/sodiumConfig.cmake.in
    ${CURRENT_PACKAGES_DIR}/share/unofficial-sodium/unofficial-sodiumConfig.cmake
    @ONLY
)
