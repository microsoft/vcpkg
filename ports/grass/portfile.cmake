vcpkg_from_github(ARCHIVE
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osgeo/grass
    REF "${VERSION}"
    SHA512 ef0d8ade86276e26709fd9d94ef172733e829c6ee7171fe83fddc691f385285d65bdbd083227517c9a68d76c91422c0fd37bc116979efcf1be00a3195a7ba2a3
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    x11             WITH_X11
)

if ("x11" IN_LIST FEATURES)
    message(WARNING "You will need to install Xorg dependencies to use feature x11:\nsudo apt install libx11-dev libxext-dev libxfixes-dev libx11-xcb-dev libxcb-dri3-dev\n")
endif()

if(WITH_X11)
    list(APPEND options -DWITH_X11=ON)
else()
    list(APPEND options -DWITH_X11=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -WITH_DOCS=OFF
        -WITH_READLINE=ON
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
