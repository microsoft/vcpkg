message(STATUS " ${PORT}'s gnuplot backend currently requires Gnuplot 5.2.6+.
    Windows users may get a pre-built binary installer from http://www.gnuplot.info/download.html.
    Linux and MacOS users may install it from the system package manager.
    Please visit https://alandefreitas.github.io/matplotplusplus/ for more information."
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alandefreitas/matplotplusplus
    REF 77de308584674654731fc1af0fdec86d02684b60 # v1.2.0 with patches merged upstream
    SHA512 ecf2edb7e9c6bdb8a94a135465a5ddaa6bc7db1e14c35ad4dace29dcf53b4c178ff21affd44cd92aab30c88563cffe4edcd6bdb2a2ccdfb37607c864f2f0ac81
    HEAD_REF master
    PATCHES
        install-3rd-libraries.patch # Remove this patch when nodesoup is added in vcpkg
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
