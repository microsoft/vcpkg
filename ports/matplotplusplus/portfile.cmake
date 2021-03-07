message(STATUS " ${PORT}'s gnuplot backend currently requires Gnuplot 5.2.6+.
    Windows users may get a pre-built binary installer from http://www.gnuplot.info/download.html.
    Linux and MacOS users may install it from the system package manager.
    Please visit https://alandefreitas.github.io/matplotplusplus/ for more information."
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alandefreitas/matplotplusplus
    REF e3e48e25505fd5b6cff4d53b0c33c29dcaf9f88e
    SHA512 4b925171ec89890a84f4de3cba22f6acb477863f7b9c579b8d52b5f4f227a02d4ee75506fe69c859fe3a54c9e7e090bf82b8614fc3da0a3b55721fa73207429b
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
