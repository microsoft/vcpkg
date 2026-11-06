vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO stella-cv/FBoW
	REF c6e3c29e3332a0b0834021797e2aa4e8eb66a3c1
	SHA512 a7f80874c396163a8cbebfbcdf150ea1f1de99ac58a1bd26f69257046e7fe3d32478c80a89eeab329a845e9a6a8c1264cf8750ccd44b380d93def9535048dbb4
	PATCHES
		fix-arm-windows.patch
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
		-DBUILD_UTILS=OFF
		-DBUILD_TESTS=OFF
		-DUSE_CONTRIB=OFF
		-DUSE_AVX=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
	CONFIG_PATH share/cmake/fbow
	PACKAGE_NAME fbow)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	"${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
