include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cplus/log4cplus
    REF REL_2_0_0-RC2
    SHA512  34392d85088534e0661e6fa9726c5970647a5acaa559bafb5d3746a70f5baca01012f457d50c15e73d9aca1d3ed9ec99028cc65fab07f73cdadbbc0b4329bcb5
    HEAD_REF master
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/log4cplus/ThreadPool/archive/dda9e3d40502e85ce082c05d2c05c1bc94348b6a.tar.gz"
    FILENAME "log4cplus-threadpool-97b5877b9c49d02abf.tar.gz"
    SHA512 97b5877b9c49d02abfcba4ca1312b833b58e4f0e9884fdcf57c20b7ec58801ed24742c8316512b4de8ab29bae42cc1e34058c0d2443c3a5950a2fb3434f86662
)
vcpkg_extract_source_archive(${ARCHIVE})

file(
    COPY
        ${CURRENT_BUILDTREES_DIR}/src/ThreadPool-master/COPYING
        ${CURRENT_BUILDTREES_DIR}/src/ThreadPool-master/example.cpp
        ${CURRENT_BUILDTREES_DIR}/src/ThreadPool-master/README.md
        ${CURRENT_BUILDTREES_DIR}/src/ThreadPool-master/ThreadPool.h
    DESTINATION ${SOURCE_PATH}/threadpool
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DLOG4CPLUS_BUILD_TESTING=OFF -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF -DWITH_UNIT_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/log4cplus)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/log4cplus/LICENSE ${CURRENT_PACKAGES_DIR}/share/log4cplus/copyright)
