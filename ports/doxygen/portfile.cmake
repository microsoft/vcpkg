set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO doxygen/doxygen
    REF Release_1_16_1
    SHA512 99db422f65ee32a76f2b9c016b035ccc1297d34b494c947235544bbaf5c44962273b52fa2c728af6ee0b17c5614b8808367fcce1d7dd872557eeb5cb37c34d32
    HEAD_REF master
    PATCHES
        fix-sqlite3-link.patch
	remove-deps-testing.patch
	use-ext-deps.patch
	fix-ghc-fs.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/deps/TinyDeflate")
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/filesystem")
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/liblodepng")
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/spdlog")
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/sqlite3")
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/iconv_winbuild")
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/fmt")

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
	    -Duse_sys_spdlog=ON
	    -Duse_sys_fmt=ON
	    -Duse_sys_sqlite3=ON
	    -DFLEX_EXECUTABLE=${FLEX}
	    -DBISON_EXECUTABLE=${BISON}
	    -DPython_EXECUTABLE=${PYTHON3}
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES doxygen AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
