vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO max0x7ba/atomic_queue
    REF "v${VERSION}"
    SHA512 d2b329698412127d23e9ee55472f65869c59b228439e714ebbe6cc66202b654a102f32583e7cc3b5999c22c1dba69a5aa4365870cc4b88b75b1ac0b4d94b979a
    HEAD_REF master
)

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
