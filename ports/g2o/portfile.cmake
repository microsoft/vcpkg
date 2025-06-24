string(REPLACE "-" "" GIT_TAG "${VERSION}_git")

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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RainerKuemmerle/g2o
    REF eec325a1da1273e87bc97887d49e70570f28570c
    SHA512 22d3d546fbc92bff4767b66dcc9a001b5ed0cac0787874dda8712140aa03004b0312f702ea7d61c5fdcfa0bb00654c873f8b99899cd9e2b89667d8d99667d5cd
    HEAD_REF master
    PATCHES
        fix-absolute.patch
        0003-dependency-spdlog.diff
        "${FIX_UPSTREAM_37d17a9}"
        "${FIX_UPSTREAM_100af05}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_LGPL_SHARED_LIBS)
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindBLAS.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        spdlog      G2O_USE_LOGGING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_LGPL_SHARED_LIBS=${BUILD_LGPL_SHARED_LIBS}
        -DG2O_BUILD_EXAMPLES=OFF
        -DG2O_BUILD_APPS=OFF
        -DBUILD_CSPARSE=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/g2o)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(GLOB_RECURSE HEADERS "${CURRENT_PACKAGES_DIR}/include/*")
    foreach(HEADER ${HEADERS})
        file(READ ${HEADER} HEADER_CONTENTS)
        string(REPLACE "#ifdef G2O_SHARED_LIBS" "#if 1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

file(GLOB EXE "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(GLOB DEBUG_EXE "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(EXE OR DEBUG_EXE)
    file(REMOVE ${EXE} ${DEBUG_EXE})
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/doc/license-bsd.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
