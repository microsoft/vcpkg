vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO casadi/casadi
    REF "${VERSION}"
    SHA512 2c95368281f0bda385c6c451e361c168589f13aa66af6bc6fadf01f899bcd6c785ea7da3dee0fb5835559e58982e499182a4d244af3ea208ac05f672ea99cfd1
    HEAD_REF main
)

# Pending upstream fix https://github.com/casadi/casadi/issues/3896
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
	 -DWITH_SELFCONTAINED=OFF
	 -DWITH_TINYXML=OFF
	 -DWITH_BUILD_TINYXML=OFF
	 -DWITH_QPOASES=OFF
	 -DWITH_SUNDIALS=OFF
	 -DWITH_CSPARSE=OFF
	 -DLIB_PREFIX="${CURRENT_PACKAGES_DIR}/lib"
	 -DBIN_PREFIX="${CURRENT_PACKAGES_DIR}/bin"
	 -DINCLUDE_PREFIX="${CURRENT_PACKAGES_DIR}/include"
	 -DCMAKE_PREFIX="${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

vcpkg_fixup_pkgconfig()

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)