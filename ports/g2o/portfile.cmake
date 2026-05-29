vcpkg_download_distfile(FIX_UPSTREAM_37d17a9
    URLS https://github.com/RainerKuemmerle/g2o/commit/37d17a94594648acf9cce85e8483c0405c510f0d.patch?full_index=1
    SHA512 dc333fa43770fbdfc98592b4beb0ff03fdb033990b7054ae65953bad31899d11053fe08977526d70fa7fdf299ad0d2368ed79f29b9db847fdca3ff4e3d0415d9
    FILENAME g2o-37d17a94594648acf9cce85e8483c0405c510f0d.patch
)

vcpkg_download_distfile(FIX_UPSTREAM_100af05
    URLS https://github.com/RainerKuemmerle/g2o/commit/100af05931ae3497f39ab42cbeba240f50cc7b66.patch?full_index=1
    SHA512 bc837081f14476e28e638de097fa7d8d44fa336d6f126391b4856dbfb6165d4fc89bf5a16d7e165a846288700596fd8d550c0a478bb7eb52d612d5d1ef62cbed
    FILENAME g2o-100af05931ae3497f39ab42cbeba240f50cc7b66.patch
)

string(REPLACE "-" "" GIT_TAG "${VERSION}_git")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RainerKuemmerle/g2o
    REF "${GIT_TAG}"
    SHA512 575e97a54f87a4df239b2137c58ebb7025dfa78f6046808d155bec978f8ef88b2e4e6ef53401941fdb30cf88916c4eacb43512d615c5f8d30301cd176c53b05e
    HEAD_REF master
    PATCHES
        0001-dependencies.patch
        0002-fix-absolute.patch
        "${FIX_UPSTREAM_37d17a9}"
        "${FIX_UPSTREAM_100af05}"
        0003-support-eigen3-5.patch
)
file(REMOVE
    "${SOURCE_PATH}/cmake_modules/FindBLAS.cmake"
    "${SOURCE_PATH}/cmake_modules/FindCSparse.cmake"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_LGPL_SHARED_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        spdlog      G2O_USE_LOGGING
        spdlog      VCPKG_LOCK_FIND_PACKAGE_spdlog
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_LGPL_SHARED_LIBS=${BUILD_LGPL_SHARED_LIBS}
        -DG2O_BUILD_APPS=OFF
        -DG2O_BUILD_EXAMPLES=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_QGLViewer=OFF
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_spdlog
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/g2o")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB_RECURSE HEADERS "${CURRENT_PACKAGES_DIR}/include/*")
    foreach(HEADER IN LISTS HEADERS)
        vcpkg_replace_string("${HEADER}" "#ifdef G2O_SHARED_LIBS" "#if 1" IGNORE_UNCHANGED)
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${SOURCE_PATH}/README.md" readme)
string(REGEX REPLACE "^.*## License" "" readme "${readme}")
string(REGEX REPLACE "\n##.*" "" readme "${readme}")
string(STRIP "${readme}" readme)
set(ceres_license "${CURRENT_PACKAGES_DIR}/include/g2o/autodiff/Ceres Solver in autodiff")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/g2o/autodiff/LICENSE" "${ceres_license}")
vcpkg_install_copyright(
    COMMENT "${readme}"
    FILE_LIST
        "${SOURCE_PATH}/doc/license-bsd.txt"
        "${ceres_license}"
        "${SOURCE_PATH}/doc/license-lgpl.txt"
)
file(REMOVE "${ceres_license}")
