message(STATUS " ${PORT}'s gnuplot backend currently requires Gnuplot 5.2.6+.
    Windows users may get a pre-built binary installer from http://www.gnuplot.info/download.html.
    Linux and MacOS users may install it from the system package manager.
    Please visit https://alandefreitas.github.io/matplotplusplus/ for more information."
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alandefreitas/matplotplusplus
    REF 2278dfe279cf361cd2b2da22e3732ce74284bad1
    SHA512 fb73b303bdf7ed0bf9a9fe1e6e6f0eeef652d53c81bfe3b2c378f68a1ffc10274233e01d26893d572bb1d74d4b5e38874faead57807e2611344c4bf2bee443e1
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
