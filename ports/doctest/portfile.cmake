vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 7d42bd0fab6c44010c8aed9338bd02bea5feba41 #version 2.3.7
    SHA512 4e71c8dd49a97ee2324207e063d47ce56cfb0371c0e855dd26ce4f169299f1710e4f30a9c5f16a078690c983e6ce7b6d5bb4fe9e0ec6be017905b2381a85b5a6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDOCTEST_WITH_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/doctest)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)