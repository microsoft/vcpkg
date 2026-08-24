# vcpkg port for motus.
#
# The SHA512 below is the checksum of the v1.0.0 source archive; recompute for any new REF
# with `vcpkg hash <tarball>` (the SUBMITTING.md beside this port has the exact command).

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mertefesensoy/motus
    REF "v${VERSION}"
    SHA512 f4703a29a0bed2b94f8fce46a293be998500c393d4e2ba0d02f0211699a87e83cde003e43011ac941ec0e9d879f1c3cb39616887da64b9e6bbe1c0c2e889f073
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMOTUS_BUILD_TESTS=OFF
        -DMOTUS_WITH_AMQPCPP=ON
        -DMOTUS_WITH_INMEMORY=ON
        -DMOTUS_WITH_SIMPLEAMQP=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/motus")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
