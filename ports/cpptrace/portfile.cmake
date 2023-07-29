vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO jeremy-rifkin/cpptrace
	REF 4b11b87e4d905d003d0325a53994441cc767017a
	SHA512
7800f38e765bf667abf6b91dff88041ec9f3d6bc94a98f0745c90cfa575b6694adbe9f620de9518ebab1b1cb65d2c3c16fc58d8fae23084a94d3806cd7901c5b
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
