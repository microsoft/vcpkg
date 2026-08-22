vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/libpmemobj-cpp
    REF 9599f724d4edc3a3d973bac14eeebdc1bc31d327 #v1.13.0
    SHA512 ae1f8ed8aecdc35e9e78c957fcd154e43c7bcb5bf5cf3e5b23be3e95d21de754dbbd9b6549bd6c7991fad24492b08421df338c3706ab0157c31ebc88b65fa4fe
    HEAD_REF master
    PATCHES
        fixlibpmemobj-cpp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
	    benchmark BUILD_BENCHMARKS
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_EXE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOC=OFF
        -DTESTS_USE_VALGRIND=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/libpmemobj++/cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib/libpmemobj++")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
