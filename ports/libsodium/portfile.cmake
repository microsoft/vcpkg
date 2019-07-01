include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libsodium
    REF 1.0.18
    SHA512 727fe50a5fb1df86ec5d807770f408a52609cbeb8510b4f4183b2a35a537905719bdb6348afcb103ff00ce946a8094ac9559b6e3e5b2ccc2a2d0c08f75577eeb
    HEAD_REF master
)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${SOURCE_PATH}/CMakeLists.txt
    COPYONLY
)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/sodiumConfig.cmake.in
    ${SOURCE_PATH}/sodiumConfig.cmake.in
    COPYONLY
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/unofficial-sodium
    TARGET_PATH share/unofficial-sodium
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

file(REMOVE ${CURRENT_PACKAGES_DIR}/include/Makefile.am)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/sodium/export.h
        "#ifdef SODIUM_STATIC"
        "#if 1 //#ifdef SODIUM_STATIC"
    )
endif ()

configure_file(
    ${SOURCE_PATH}/LICENSE
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright
    COPYONLY
)

#vcpkg_test_cmake(PACKAGE_NAME unofficial-sodium)
