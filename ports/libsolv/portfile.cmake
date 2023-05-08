vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openSUSE/libsolv
    REF "${VERSION}"
    SHA512 a0975d3f80ae8c364d5b32df4c26bc7eb5abb3be81259595848f1f5f74b00e708af3153074041d49383547718e68cee2e82cf4bdeab6221dfdcc605812689d37
    HEAD_REF master
    PATCHES
        windows.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        perl ENABLE_PERL
        python ENABLE_PYTHON
        ruby ENABLE_RUBY
        comps ENABLE_COMPS
        helixrepo ENABLE_HELIXREPO
        debian ENABLE_DEBIAN
        cudfrepo ENABLE_CUDFREPO
        conda ENABLE_CONDA
        lzma-compression ENABLE_LZMA_COMPRESSION
        bzip2-compression ENABLE_BZIP2_COMPRESSION
        zstd-compression ENABLE_ZSTD_COMPRESSION
)

if (ENABLE_PYTHON OR ENABLE_PERL OR ENABLE_RUBY)
    vcpkg_find_acquire_program(SWIG)
    list(APPEND FEATURE_OPTIONS "-DSWIG_EXECUTABLE=${SWIG}")
endif()

if (ENABLE_PYTHON)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND FEATURE_OPTIONS "-DPYTHON_EXECUTABLE=${PYTHON3}")
endif()

if (ENABLE_PERL)
    vcpkg_find_acquire_program(PERL)
    list(APPEND FEATURE_OPTIONS "-DPERL_EXECUTABLE=${PERL}")
endif()

if (ENABLE_RUBY)
    vcpkg_find_acquire_program(RUBY)
    list(APPEND FEATURE_OPTIONS "-DRUBY_EXECUTABLE=${RUBY}")
endif()

if(WIN32)
    list(APPEND FEATURE_OPTIONS "-DWITHOUT_COOKIEOPEN=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DDISABLE_SHARED=${BUILD_STATIC_LIBS}
        -DENABLE_STATIC=${BUILD_STATIC_LIBS}
        -DMULTI_SEMANTICS=ON
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.BSD")
