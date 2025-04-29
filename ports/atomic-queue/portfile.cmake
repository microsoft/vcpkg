vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO max0x7ba/atomic_queue
    REF "v${VERSION}"
    SHA512 9cd9785c2ad4e88e8ad99061fe06c97f33329b0293ae79676d1465f679d19a53933be7c51f1acd5508ffc97f72433c13e59abe1592abeee2ca07268a88dd0cbf
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
