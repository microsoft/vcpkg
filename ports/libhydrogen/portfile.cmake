include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libhydrogen
    REF c7e86332f6370a16ca59581d5c0afc08dd444499
    SHA512 70ee94ce2f7dc568e6262b0bd64edaba5f200a1ae6228a9aa1e489ac50292214858d2fa029d85676c75941f27787b2a4237e14630ac33878bc9334b9b863333c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/hydrogen TARGET_PATH share/hydrogen)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME hydrogen)
