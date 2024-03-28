if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO mjsottile/sfsexp
	REF  v1.3.1
	SHA512 56dabc8f0c16c4707f191c8d60e97c6c3db1b359673e77967e3c21acbdc2239f1423fe62a062ce256f3f7a1ccf8572d16a82ef67ffcd215b48e261ed1d8720d7
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
