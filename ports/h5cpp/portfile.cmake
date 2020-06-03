set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steven-varga/h5cpp
    REF 852dbcf14632c12d5567092ea638434a0f0f5d71
    SHA512 d0e0f2164f1024eb64e0d74d832273e05d6206752175b9da11755b0750ef05949a3f3cbde9c7cc5daed338df0d6da6302ee8a85541a1920d556fe76fc4ad0659
    HEAD_REF v1.10.4-6
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DH5CPP_BUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/${PORT}/cmake)
file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug
	${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
