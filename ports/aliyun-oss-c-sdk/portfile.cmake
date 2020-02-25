include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aliyun/aliyun-oss-c-sdk
    REF 703ea9a0dee0ddf4eacc7f9782ba970adccc58e8 # 3.9.1
    SHA512 01f33d73031039d64433823c6b7b540071d18560ee0df762ef58b30898bde520c8cfb8bcf631a62cbd709d8c996b9dfc8c31c2286ceb9d1925161c39dbbe97fc
    HEAD_REF master
	PATCHES
	patch.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
