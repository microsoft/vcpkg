include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cplus/log4cplus
    REF REL_2_0_4
    SHA512 194e37b8de7be377dabe911d1cec831de41f5ce14dd617b5333739a7ab8dbc3061aa24351abe811588db507aa1563a637023b26684fb21bbfc88d24b4e4ce062
    HEAD_REF master
    PATCHES fix-usage-error.patch
)

set(THREADPOOL_REF cc0b6371d3963f7028c2da5fc007733f9f3bf205)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/log4cplus/ThreadPool/archive/${THREADPOOL_REF}.tar.gz"
    FILENAME "log4cplus-threadpool-${THREADPOOL_REF}.tar.gz"
    SHA512 ad4d287c1f83acac4c127136bc92489c43bb5293613dc54b878b8e75a8583f7eefda6434d09789dad47b87a5d38f10a07a746d42d299410c11f2dbcce8af3012
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
