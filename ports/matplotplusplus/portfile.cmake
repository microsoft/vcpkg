message(STATUS " ${PORT}'s gnuplot backend currently requires Gnuplot 5.2.6+.
    Windows users may get a pre-built binary installer from http://www.gnuplot.info/download.html.
    Linux and MacOS users may install it from the system package manager.
    Please visit https://alandefreitas.github.io/matplotplusplus/ for more information."
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alandefreitas/matplotplusplus
    REF 8dbea7d359f7b4f456bca7a6015c32b61ad728f4 # 2022-05-04
    SHA512 b09592e7ff6dc4eddf01df549166b6246992257c253f709ce5bece4cf1e09a6e2ab562c1da77925ce270e6c9beb16a1498d8a0e52af1fb951596ade5cb13c057
    HEAD_REF master
    PATCHES
        install-3rd-libraries.patch # Remove this patch when nodesoup is added in vcpkg
        fix-dependencies.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl  BUILD_EXPERIMENTAL_OPENGL_BACKEND
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
        -DCPM_USE_LOCAL_PACKAGES=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_INSTALLER=ON
        -DBUILD_PACKAGE=OFF
        -DBUILD_WITH_PEDANTIC_WARNINGS=OFF
        -DWITH_SYSTEM_CIMG=ON
        -DBUILD_HIGH_RESOLUTION_WORLD_MAP=${BUILD_WORLD_MAP}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME matplot++ CONFIG_PATH lib/cmake/Matplot++)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
