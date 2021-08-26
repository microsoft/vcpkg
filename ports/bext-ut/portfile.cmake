vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/ut
    REF v1.1.8
    SHA512 0df2f8ce784dc69c3cca5554a8b2be7c1664dd66bf52e83f305db5fae84d416a851e9282e9a8cfe50fbcada85b17da00fb25c1228d9cca32226a18bae18acb83
    HEAD_REF master
)

vcpkg_download_distfile(LICENSE_FILE
    URLS https://www.boost.org/LICENSE_1_0.txt
    FILENAME d6078467835dba893231.txt
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBOOST_UT_BUILD_BENCHMARKS=OFF
        -DBOOST_UT_BUILD_EXAMPLES=OFF
        -DBOOST_UT_BUILD_TESTS=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ut TARGET_PATH share/ut)

configure_file("${LICENSE_FILE}" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug
                    ${CURRENT_PACKAGES_DIR}/lib
)
