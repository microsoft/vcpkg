# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/utf_range
    REF b20d4037db30f69ef73daa4428a631f95e0bbb10
    SHA512 4f9d4b4831c4bd6dc560830077965ae5b3351dc7695d0523262bc6229c8d7623e03338be772337f89084038d7039b4a0b41ef8de2ef98eb880f85ca5e01d5838
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH 
    ${SOURCE_PATH}
    OPTIONS
    -DDAW_USE_PACKAGE_MANAGEMENT=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# remove empty lib and debug/lib directories (and duplicate files from debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
