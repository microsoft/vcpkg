vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/umock-c
    REF 504193e65d1c2f6eb50c15357167600a296df7ff
    SHA512 68d5d986314dbd46d20de2a9b9454154c11675c25d1b5a5b1cfecdd0c0945d9dc68d0348ec1dbb00b5d1a6a1f0356121ba561d7c8fffb97ab37864edade5a85b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Drun_unittests=OFF
        -Drun_int_tests=OFF
        -Duse_installed_dependencies=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME umock_c CONFIG_PATH "cmake")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/readme.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
