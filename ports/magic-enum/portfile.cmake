include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "Neargye/magic_enum"
    REF 4dfaa4b7b4814c2cf85b08ad3084fc28c8b129c6
    SHA512 924e5a134f4200652fdc3f3d676b49efa8c30b5577d638f60134ce81092b23f7976a494ce50b58b25ed7bce0653a7e29206acf9e512408c4701ec6822ab2d176
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS
      -DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF
      -DMAGIC_ENUM_OPT_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/magic_enum)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/magic-enum RENAME copyright)
