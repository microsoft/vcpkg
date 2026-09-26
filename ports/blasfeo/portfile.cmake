vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO giaf/blasfeo
    REF d3da74db6d16d03ee376c6e5cdaa8b6f97436197
    SHA512 a0f7f47d4b02eecf8adfa7348f2cf35952c459d8e9f906a226be4bf883d066c5f9b007ba4057283dba841578b3fea204aa450c0aab9ac2a42e43a825edf8e568
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    # configure_file() writes include/blasfeo_target.h into the source tree
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        # Portable C kernels: the only target buildable everywhere (and the only one MSVC accepts)
        -DTARGET=GENERIC
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
        -DBLASFEO_EXAMPLES=OFF
        -DBLASFEO_TESTING=OFF
        -DBLASFEO_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/blasfeo)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
