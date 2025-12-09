vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF "${VERSION}"
    SHA512 ce24a92d623c9e56666128e243bc58acdbff8f7dfac1f728fdbd97a2c3ec21135b8c2a79c3e13920ca0d52545819766b90fc6aca35318b754eedf5ae5329ff36 
    HEAD_REF next
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
