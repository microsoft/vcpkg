if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO mjsottile/sfsexp
	REF  "v${VERSION}"
	SHA512 26dd1494d570c22264db7175e2e744047507871716198b4db1a24ee8d098dd204cc6efb55ee9dbc3d956eed7b398a08e7b3264955e6350ea546274cf4f8eb67e
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
