vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sebastiandev/zipper
  REF 155e17347b64f7182985a2772ebb179184e4f518 #v1.0.3
  SHA512 91ec37bf230d3f636fce60316281c5314c0b41764397b1a45bc22c30e4178f6bc95400c361dc72ea0611949456879dfb43e53827d4e2b006a4677e16d2284ed0
  HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH MINIZIP_SOURCE_PATH
    REPO Lecrapouille/minizip
    REF 469fa4bfc8620550db514f940ebc5053b32cf6c9
    SHA512 3f52a94f790456cdf9056c64049f03e2ce74ea70696ffeda181e6dab09f00b94b3470b59f092f75077180a9b6ac55bf4566b3656ae277f63cdadd97c62b6bb5a
    HEAD_REF master
)

file(REMOVE_RECURSE "${SOURCE_PATH}/minizip")
if(NOT EXISTS "${SOURCE_PATH}/minizip")
    file(RENAME "${MINIZIP_SOURCE_PATH}" "${SOURCE_PATH}/minizip")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TEST=OFF
        -DBUILD_SHARED_VERSION=${BUILD_SHARED}
        -DBUILD_STATIC_VERSION=${BUILD_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)