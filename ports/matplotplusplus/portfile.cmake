message(STATUS " ${PORT}'s gnuplot backend currently requires Gnuplot 5.2.6+.
    Windows users may get a pre-built binary installer from http://www.gnuplot.info/download.html.
    Linux and MacOS users may install it from the system package manager.
    Please visit https://alandefreitas.github.io/matplotplusplus/ for more information."
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alandefreitas/matplotplusplus
    REF 36d8dc6c3b94b7a71c4f129763f2c6ad8fc0b54a
    SHA512 ac8902e953a2a9f6bd62e14e2eb0bd42e407bae6c0b2921ad16ce547e4921ba2c8d8a9cc68e75831676dce3cd89cdf8294862710e838510b68e20f8a6cdf806f
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl BUILD_EXPERIMENTAL_OPENGL_BACKEND
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
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

vcpkg_cmake_install()

# The official documentation says:
# find_package(Matplot++ ...)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/lib/cmake/Matplot++/matplot++-config.cmake
    ${CURRENT_PACKAGES_DIR}/lib/cmake/Matplot++/Matplot++-config.cmake
)

vcpkg_cmake_config_fixup(PACKAGE_NAME Matplot++ CONFIG_PATH lib/cmake/Matplot++)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
