# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor-io
    REF ffada938383b0f24c9e0b07cea7d5780057e1d96 # 0.13.0
    SHA512 ce5d085e500ef7043eb51538cab9a53c857983ac43e392cd65958c76fcde3ddb00161097cb70d334fa7d12af12e8109bb958b51f39afd9eeb60bb3421424058e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDOWNLOAD_GBENCHMARK=OFF
        -DHAVE_HighFive=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

foreach(bit "64" "32" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/xtensor-io/xtensor_io_config.hpp" "#pragma cling add_library_path(\"${CURRENT_PACKAGES_DIR}/lib${bit}\")" "")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
