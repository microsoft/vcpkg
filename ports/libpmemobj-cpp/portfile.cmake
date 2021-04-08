vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/libpmemobj-cpp
    REF b570268bec37735df1d4591605c0c7b2077c7bed #v1.12
    SHA512 0914c35c708b5fec81ac2632cfbae52412c2ff2255940b54e72acc03875fdebf03f83194a6f91f1ac1d9c3531c7d1537fa0b9bc1a9da53acc50339a3b7df7b62
    HEAD_REF master
    PATCHES
        fixlibpmemobj-cpp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
	benchmark BUILD_BENCHMARKS
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_EXE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOC=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/libpmemobj++/cmake TARGET_PATH share/libpmemobj++)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib/libpmemobj++)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
