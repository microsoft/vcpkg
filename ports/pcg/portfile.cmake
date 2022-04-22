vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imneme/pcg-cpp
    REF ffd522e7188bef30a00c74dc7eb9de5faff90092
    SHA512 e96e40bf63ddb29ebf8679ddaabbf5dc934173f38cb5ed97c5efe068a742a715daa05e38d9ae322a10fa538c8ec7a271622bfb6569256a471fe5e1c9a83f9e3f
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/pcg_extras.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/include/pcg_random.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/include/pcg_uint128.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE-MIT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
