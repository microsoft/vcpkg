vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO max0x7ba/atomic_queue
    REF "v${VERSION}"
    SHA512 1e6aa7f06f8254520303e600187c4d2968ca3747ab3127e6a58e537c34bc06d0a417c20c1d7fabbfd81eec1936cd3017c1b5eb546f8fcb4993ccc0708667da73
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
