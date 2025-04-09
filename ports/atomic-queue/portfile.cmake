vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO max0x7ba/atomic_queue
    REF "v${VERSION}"
    SHA512 2c1813074fd166f1d3491527a1faac1cc297f0b0e15fedf66a64465efc310256cce657e7205e41d277fa513bb322d18a273c6a9a6ce85ec8d182a2c81f90c35c
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

file(
    COPY
        "${SOURCE_PATH}/include/atomic_queue/atomic_queue.h"
        "${SOURCE_PATH}/include/atomic_queue/atomic_queue_mutex.h"
        "${SOURCE_PATH}/include/atomic_queue/barrier.h"
        "${SOURCE_PATH}/include/atomic_queue/defs.h"
        "${SOURCE_PATH}/include/atomic_queue/spinlock.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/atomic_queue"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
