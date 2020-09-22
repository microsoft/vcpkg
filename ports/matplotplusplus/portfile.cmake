message(STATUS " ${PORT}'s gnuplot backend currently requires Gnuplot 5.2.6+.
    Windows users may get a pre-built binary installer from http://www.gnuplot.info/download.html.
    Linux and MacOS users may install it from the system package manager.
    Please visit https://alandefreitas.github.io/matplotplusplus/ for more information."
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alandefreitas/matplotplusplus
    REF 5c9fa683672c8e555356374a80efb16e000c8459 # v1.0.1
    SHA512 7293ee618fd676a639234e6284a7216db1c1eae11e9d83814ffc76ae8a2751d21512501ab4ce9105cb74d3daef6977c9d39fcfbe1f14d30ff69760edd2b9df74
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    opengl BUILD_EXPERIMENTAL_OPENGL_BACKEND
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCPM_USE_LOCAL_PACKAGES=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_INSTALLER=ON
        -DBUILD_PACKAGE=OFF
        -DBUILD_WITH_PEDANTIC_WARNINGS=OFF
        -DWITH_SYSTEM_CIMG=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

# The official documentation says:
# find_package(Matplot++ ...)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/lib/cmake/Matplot++/matplot++-config.cmake
    ${CURRENT_PACKAGES_DIR}/lib/cmake/Matplot++/Matplot++-config.cmake
)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Matplot++ TARGET_PATH share/Matplot++)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
