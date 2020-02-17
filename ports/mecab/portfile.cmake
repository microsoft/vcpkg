if (VCPKG_TARGET_TRIPLET STREQUAL "x64-uwp" OR VCPKG_TARGET_TRIPLET STREQUAL "arm64-windows" OR VCPKG_TARGET_TRIPLET STREQUAL "arm-uwp")
    message(FATAL_ERROR "mecab does not support on this platform")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO taku910/mecab
	REF master
	SHA512 2a7f1d159ddca846357b5bcab2d2b5de2e6a27dca4301cdd1cc52c155c352f9c7030b77d1187afe9c0a7f1b131a1acdcc40ee81ce7ba5c0fa6b2325c56676353
	HEAD_REF master
	PATCHES
		fix_wpath_unsigned.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/mecab/src)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in DESTINATION ${SOURCE_PATH}/mecab/src)
file(COPY ${SOURCE_PATH}/mecab/COPYING DESTINATION ${SOURCE_PATH}/mecab/src)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/mecab/src
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/mecab/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mecab)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mecab/COPYING ${CURRENT_PACKAGES_DIR}/share/mecab/copyright)