message(STATUS " ${PORT}'s gnuplot backend currently requires Gnuplot 5.2.6+.
    Windows users may get a pre-built binary installer from http://www.gnuplot.info/download.html.
    Linux and MacOS users may install it from the system package manager.
    Please visit https://alandefreitas.github.io/matplotplusplus/ for more information."
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alandefreitas/matplotplusplus
    REF ff829d2a8aef134baff6f206994d77e7d26435f8
    SHA512 5134adcb74c36d4de8f221e71c70b8d99d1ede2eb19783cdae119a208369714585ece237fad7ac493555bc977640eb85de01c2db093d4f8f2504b5f7f8cbe8da
    HEAD_REF master
    PATCHES
        install-3rd-libraries.patch # Remove this patch when nodesoup is added in vcpkg
        fix-dependencies.patch
        fix-pass-filesystem-s-required-flags-for-osx-failure.patch
        fix-find-filesystem-on-osx-failure.patch
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
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME matplot++ CONFIG_PATH lib/cmake/Matplot++)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
