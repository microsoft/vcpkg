include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cplus/log4cplus
    REF REL_2_0_1
    SHA512  7a84bf237bb5db3eccd90196c0f97adb75d0dd247d73852150078b9458f169d883f3ae92908217ea668bcf25c64766c86380bbcc64b432eb1bae6427c9268b18
    HEAD_REF master
)

set(THREADPOOL_REF dda9e3d40502e85ce082c05d2c05c1bc94348b6a)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/log4cplus/ThreadPool/archive/${THREADPOOL_REF}.tar.gz"
    FILENAME "log4cplus-threadpool-${THREADPOOL_REF}.tar.gz"
    SHA512 225adb11f447495a00e401d32f63d9a7eb3a8191d477a21bfa3c39f1ff5cbe8bfb7770a740e840c5748f816137cdef1a5915b17d16b3dd4c3399d1a67ab0f381
)
vcpkg_extract_source_archive(${ARCHIVE})

file(
    COPY
        ${CURRENT_BUILDTREES_DIR}/src/ThreadPool-${THREADPOOL_REF}/COPYING
        ${CURRENT_BUILDTREES_DIR}/src/ThreadPool-${THREADPOOL_REF}/example.cpp
        ${CURRENT_BUILDTREES_DIR}/src/ThreadPool-${THREADPOOL_REF}/README.md
        ${CURRENT_BUILDTREES_DIR}/src/ThreadPool-${THREADPOOL_REF}/ThreadPool.h
    DESTINATION ${SOURCE_PATH}/threadpool
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DLOG4CPLUS_BUILD_TESTING=OFF -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF -DWITH_UNIT_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/log4cplus)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/log4cplus)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/log4cplus/LICENSE ${CURRENT_PACKAGES_DIR}/share/log4cplus/copyright)
