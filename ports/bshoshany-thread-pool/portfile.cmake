vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bshoshany/thread-pool
    REF "v${VERSION}"
    SHA512 8f0752962908b81b096f964729aa47e2bc6111a8458f6ec6f3db5970e0245c0ad5b2af2c3cc38bfeb59c9cffc5710613b977b943e51fc3f4ebb92c0b12d1804e
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/BS_thread_pool.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/modules/BS.thread_pool.cppm" DESTINATION "${CURRENT_PACKAGES_DIR}/modules")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
