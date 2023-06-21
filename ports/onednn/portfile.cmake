vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDNN
    REF v3.1.1
    SHA512 0dae0ccff1e459ce24356694732bf4ee3c459469de70984863e1aed3bc965471793a110dedbb11f2baa762749cea7652a150d2f9a442c299d9ffa00febd87fec
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(DNNL_OPTIONS "-DDNNL_LIBRARY_TYPE=STATIC")
endif()

# Can't have both sycl and any other feature
list(LENGTH FEATURES _features_length)
if ("sycl" IN_LIST FEATURES AND ${_features_length} GREATER 2)
    message(FATAL_ERROR "sycl must be the only feature for GPU + CPU runtimes")
endif()

# Can't have both openmp and tbb
if ("openmp" IN_LIST FEATURES AND "tbb" IN_LIST FEATURES)
    message(FATAL_ERROR "Cannot enable openmp and tbb features simultaneously")
endif()

if ("sycl" IN_LIST FEATURES)
    list(APPEND DNNL_OPTIONS "-DDNNL_CPU_RUNTIME=SYCL" "-DDNNL_GPU_RUNTIME=SYCL")
endif()

if ("openmp" IN_LIST FEATURES)
    list(APPEND DNNL_OPTIONS "-DDNNL_CPU_RUNTIME=OMP")
endif()

if ("tbb" IN_LIST FEATURES)
    list(APPEND DNNL_OPTIONS "-DDNNL_CPU_RUNTIME=TBB")
endif()

if ("opencl" IN_LIST FEATURES)
    list(APPEND DNNL_OPTIONS "-DDNNL_GPU_RUNTIME=OCL")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${DNNL_OPTIONS}
)
vcpkg_cmake_install()

# The port name and the find_package() name are different (onednn versus dnnl)
vcpkg_cmake_config_fixup(PACKAGE_NAME dnnl CONFIG_PATH lib/cmake/dnnl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc/dnnl/reference/html")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
