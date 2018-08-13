include(vcpkg_common_functions)

set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF mbedtls-2.12.0
    SHA512 c7c2aeb1717886ad87486af2dccb05b2f051372c69fc914f30e4ace1067f5be39ba04e093ad522f904e23a576c1ff430bd772e77823d0f4720f6fc5c1b8aa98c
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
