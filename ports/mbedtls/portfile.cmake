include(vcpkg_common_functions)

set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF mbedtls-2.13.1
    SHA512 1a70446b533534c075de38ce0839f7947077ffdddffa57172594b8f8a3c4a3fbdfa9b06d13c198008abad33633e509f06abe5362f603f63850d9ec44734b3c0b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTING=OFF
        -DENABLE_PROGRAMS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mbedtls RENAME copyright)

vcpkg_copy_pdbs()
