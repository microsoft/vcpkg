include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libsodium
    REF 1.0.17
    SHA512 faf6ab57d113b6b1614b51390823a646f059018327b6f493e9e918a908652d0932a75a1a6683032b7a3869f516f387d67acdf944568387feddff7b2f5b6e77d6
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
