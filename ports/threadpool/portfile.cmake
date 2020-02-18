vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jhasse/ThreadPool
    REF e9123ff7843c9e84bda625905fe65673a0ec670d
    SHA512 6a74dda2507ee0cb5517f74fb66dd03c971a6899be487cbe95f75f5f29c3c2e144e9afd4b921fa0eb9780fb47ac43c4dd982404b652248562a0714693b34393b
    HEAD_REF master
)

# Get the required source files
file(INSTALL ${SOURCE_PATH}/ThreadPool.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/threadpool)
file(INSTALL ${SOURCE_PATH}/ThreadPool.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/threadpool)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/threadpool RENAME copyright)