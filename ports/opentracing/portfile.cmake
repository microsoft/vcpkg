vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opentracing/opentracing-cpp
    REF 4bb431f7728eaf383a07e86f9754a5b67575dab0 # v1.6.0
    SHA512 1c69ff4cfd5f6037a48815367d3026c1bf06c3c49ebf232a64c43167385fb62e444c3b3224fc38f68ef0fdb378e3736db6ee6ba57160e6e578c87c09e92e527e
    PATCHES
        fix-cmake.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_LINTING=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_DYNAMIC_LOADING=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenTracing)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
