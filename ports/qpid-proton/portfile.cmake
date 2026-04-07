vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/qpid/proton/${VERSION}/qpid-proton-${VERSION}.tar.gz"
    FILENAME "qpid-proton-${VERSION}.tar.gz"
    SHA512 3e7fe56ca1423f45f71d81f5e1d6ec5f21c073cc580628e12a8dbd545a86805b7312834e0d1234dde43797633d575ed639f21a96239b217500cc0a824482aae3
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        early-cxx.diff
        fix-dependencies.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_BINDINGS=cpp
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_CyrusSASL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL=${VCPKG_TARGET_IS_WINDOWS} # match dependencies
        -DCMAKE_DISABLE_FIND_PACKAGE_opentelemetry-cpp=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=ON
        -DENABLE_JSONCPP=ON
        -DENABLE_LINKTIME_OPTIMIZATION=OFF
        -DENABLE_OPENTELEMETRYCPP=OFF
        -DLIB_SUFFIX=
        -DENABLE_WARNING_ERROR=OFF
        -DENABLE_BENCHMARKS=OFF
        -DENABLE_FUZZ_TESTING=OFF
        "-DPython_EXECUTABLE=${PYTHON3}"
        -DVCPKG_LOCK_FIND_PACKAGE_Libuv=${VCPKG_TARGET_IS_OSX} # match dependencies
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_Libuv
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ProtonCpp" PACKAGE_NAME "protoncpp" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Proton" PACKAGE_NAME "proton")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/proton/CMakeLists.txt"
    "${CURRENT_PACKAGES_DIR}/share/proton/FindCyrusSASL.cmake"
    "${CURRENT_PACKAGES_DIR}/share/proton/examples"
    "${CURRENT_PACKAGES_DIR}/share/proton/tests"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
