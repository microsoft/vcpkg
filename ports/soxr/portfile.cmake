vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO soxr
    FILENAME "soxr-0.1.3-Source.tar.xz"
    SHA512 f4883ed298d5650399283238aac3dbe78d605b988246bea51fa343d4a8ce5ce97c6e143f6c3f50a3ff81795d9c19e7a07217c586d4020f6ced102aceac46aaa8
	PATCHES
		001_initialize-resampler.patch
		002_disable_warning.patch
		003_detect_arm_on_windows.patch
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DBUILD_TESTS=OFF
		-DBUILD_EXAMPLES=OFF
		-DWITH_OPENMP=OFF
		-DWITH_LSR_BINDINGS=OFF
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/soxr RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
