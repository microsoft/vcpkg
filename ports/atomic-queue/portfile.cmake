vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO max0x7ba/atomic_queue
    REF 7619054490efdbfe377bd528bc09b21f5cd38a02
    SHA512 0d145f461a5c978c4d6f6d8ec1f06f0c61f3d009e65eac12db806c2aa7941461f881b34b9c4dd9aeebd3206a4598e6081f89f983c389b2f5aecefefcbddd94b6
    HEAD_REF master
)

file(
    COPY 
        ${SOURCE_PATH}/include/atomic_queue/atomic_queue.h 
        ${SOURCE_PATH}/include/atomic_queue/atomic_queue_mutex.h 
        ${SOURCE_PATH}/include/atomic_queue/barrier.h 
        ${SOURCE_PATH}/include/atomic_queue/defs.h 
        ${SOURCE_PATH}/include/atomic_queue/spinlock.h 
    DESTINATION 
        ${CURRENT_PACKAGES_DIR}/include/atomic_queue
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
