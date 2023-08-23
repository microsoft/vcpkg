message(STATUS " ${PORT}'s gnuplot backend currently requires Gnuplot 5.2.6+.
    Windows users may get a pre-built binary installer from http://www.gnuplot.info/download.html.
    Linux and MacOS users may install it from the system package manager.
    Please visit https://alandefreitas.github.io/matplotplusplus/ for more information."
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alandefreitas/matplotplusplus
    REF "v${VERSION}"
    SHA512 9193381fd9d4925259f28a03da33231b3da1273237e7510b93da1ca076610455746feb4ea0d8aa9a4a9e46a5f5f344fc1322f7ffc57963837dbe8b0be0b811ac
    HEAD_REF master
    PATCHES
                fix-dependencies.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl  MATPLOTPP_BUILD_EXPERIMENTAL_OPENGL_BACKEND
        jpeg    WITH_JPEG
        tiff    WITH_TIFF
        zlib    WITH_ZLIB
        lapack  WITH_LAPACK
        blas    WITH_BLAS
        fftw3   WITH_FFTW3
        opencv  WITH_OPENCV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DMATPLOTPP_BUILD_EXAMPLES=OFF
        -DMATPLOTPP_BUILD_TESTS=OFF
        -DMATPLOTPP_BUILD_INSTALLER=ON
        -DMATPLOTPP_BUILD_PACKAGE=OFF
        -DMATPLOTPP_BUILD_WITH_PEDANTIC_WARNINGS=OFF
        -DWITH_SYSTEM_CIMG=ON
        -DMATPLOTPP_BUILD_HIGH_RESOLUTION_WORLD_MAP=${BUILD_WORLD_MAP}
        -DMATPLOTPP_BUILD_WITH_SANITIZERS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME matplot++ CONFIG_PATH lib/cmake/Matplot++)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/matplotplusplus/")
