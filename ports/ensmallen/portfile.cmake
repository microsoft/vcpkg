include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF 8bea8d214b40be3cb42e817328c0791541fbcd6c
    SHA512 b075b763c136c1d2d5088c533a8557e3d425da7bcfeb3748063c1e3225e58969eddfc5bd786cb02f29f71ea5e3288327481a0961f64b1d2ff1251a0f59c07779
    HEAD_REF master
	PATCHES
		disable_tests.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ensmallen RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
