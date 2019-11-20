vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO protocolbuffers/upb
	REF  9effcbcb27f0a665f9f345030188c0b291e32482
	SHA512 416ff26ec21181d53be23e94203205072152ab3a8e4b3b28d16263a601995fd2d2f8afe5d8cfbecdac8543249482287b9fe6129314f7c9a7880660f5508bb85e
    HEAD_REF master
    PATCHES fix-cmakelists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    asan UPB_ENABLE_ASAN
    ubsan UPB_ENABLE_UBSAN
    tests ENABLE_TEST
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
