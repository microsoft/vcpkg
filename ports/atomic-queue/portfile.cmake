vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO max0x7ba/atomic_queue
    REF "v${VERSION}"
    SHA512 cd4ca07f04f7c994b0e5dce5b4986192ee77d7ca376140717b2e4f848a2fad4bbe33059a9cb8127a517a859dc2670c3be56bf48f91a1ed77c86509c6b6288ce2
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
