vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

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
        # Git is an optional build dependency upstream, used only to stamp a build identity
        # into the generated Version.hpp. In v1.0.0 that lookup runs `git rev-parse HEAD`
        # without confirming the source directory is the worktree root, so under vcpkg it
        # walked up and reported vcpkg's own commit as motus provenance. Upstream now bounds
        # the lookup to its own worktree; until a release carries that fix, denying the
        # package outright is what keeps the build honest, and it makes the dependency
        # controlled by the port rather than by whatever happens to be on the machine.
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/motus")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
