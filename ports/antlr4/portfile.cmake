vcpkg_minimum_required(VERSION 2022-10-12)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO antlr/antlr4
    HEAD_REF master
    REF "refs/tags/${VERSION}"
    SHA512 947ecca28712aa4dd98d7b7e0753e91881e55642f7951ca65a576b94db87440767a1b93d08e82db69ad527ee28bf89f0b2f9c0aaa604a999a7e48c163764ee12
)

set(RUNTIME_PATH "${SOURCE_PATH}/runtime/Cpp")

message(INFO "Configure at '${RUNTIME_PATH}'")

vcpkg_cmake_configure(
    SOURCE_PATH "${RUNTIME_PATH}"
    OPTIONS
        -DANTLR_BUILD_STATIC=OFF
        -DANTLR4_INSTALL=ON
        -DANTLR_BUILD_CPP_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME antlr4-generator CONFIG_PATH lib/cmake/antlr4-generator DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME antlr4-runtime CONFIG_PATH lib/cmake/antlr4-runtime)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
