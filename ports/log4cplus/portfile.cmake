vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cplus/log4cplus
    REF 9d00f7d10f2507f68f9ab5fea8b842735d9c6cfe # REL_2_0_5
    SHA512 b64a1d3a60584b2ba3a58470a0b0ec4c22eb0c054c0ef8ef3808fcba5604860fbd5b2d96148939ea15d3bf2ff1e40e684710dc81b57b73232851a486251f648d
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH THREADPOOL_SOURCE_PATH
    REPO log4cplus/ThreadPool
    REF cc0b6371d3963f7028c2da5fc007733f9f3bf205
    SHA512 ad4d287c1f83acac4c127136bc92489c43bb5293613dc54b878b8e75a8583f7eefda6434d09789dad47b87a5d38f10a07a746d42d299410c11f2dbcce8af3012
    HEAD_REF master
)

file(
    COPY
        ${THREADPOOL_SOURCE_PATH}/COPYING
        ${THREADPOOL_SOURCE_PATH}/example.cpp
        ${THREADPOOL_SOURCE_PATH}/README.md
        ${THREADPOOL_SOURCE_PATH}/ThreadPool.h
    DESTINATION ${SOURCE_PATH}/threadpool
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    unicode     UNICODE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLOG4CPLUS_BUILD_TESTING=OFF
        -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF
        -DWITH_UNIT_TESTS=OFF
        -DLOG4CPLUS_ENABLE_DECORATED_LIBRARY_NAME=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/log4cplus)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
