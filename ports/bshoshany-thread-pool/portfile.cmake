vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bshoshany/thread-pool
    REF "v${VERSION}"
    SHA512 ba118decce074a3bbd004dcd3d2ee233b629c6f7b452e6e81700107f22c1b426931121b03e6497c1e3035dfdc6631080ebb539201fcbe1c3a8e919210d3ebf91
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/BS_thread_pool.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/modules/BS.thread_pool.cppm" DESTINATION "${CURRENT_PACKAGES_DIR}/modules")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
