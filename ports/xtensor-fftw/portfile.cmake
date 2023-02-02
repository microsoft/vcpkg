# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor-fftw
    REF 29f0442c98f1a219e970c96e99d7be8a42954a0b
    SHA512 09b02fe6b906cde2a7f9071673a140c994316d50aaf639eb402706aaa52b66e73bc77fa1beb683d3740914ff5157283891634a806809c03f12c1def85b49595a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCOMPILE_WARNINGS=OFF
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DBUILD_BENCHMARK=OFF
        -DDOWNLOAD_GBENCHMARK=OFF
        -DBENCHMARK_ENABLE_TESTING=OFF
        -DDEFAULT_COLUMN_MAJOR=OFF
        -DCOVERAGE=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
