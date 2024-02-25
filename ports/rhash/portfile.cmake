vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF "v${VERSION}"
    SHA512 00a7e5e058b53ce20ae79509815452ed9cb699d1322b678220b72c61dea3ea2f8fa131acfade8bb6d9f6af913f0c3c472330841181b22314b8755166310c946f
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/librhash")

# cf. configure: RHASH_XVERSION = $(printf "0x%02x%02x%02x%02x" "$_v1" "$_v2" "$_v3" 0)
if(NOT VERSION MATCHES [[^([0-9]+)[.]([0-9]+)[.]([0-9]+)$]])
    message(FATAL_ERROR "Cannot derive RHASH_XVERSION from '${VERSION}'")
endif()
MATH(EXPR RHASH_XVERSION "((${CMAKE_MATCH_1} * 256 + ${CMAKE_MATCH_2}) * 256 + ${CMAKE_MATCH_3}) * 256" OUTPUT_FORMAT HEXADECIMAL)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/librhash"
    OPTIONS
        -DRHASH_XVERSION=${RHASH_XVERSION}
    OPTIONS_DEBUG
        -DRHASH_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-rhash)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
