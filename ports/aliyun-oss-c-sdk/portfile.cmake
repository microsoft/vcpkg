if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aliyun/aliyun-oss-c-sdk
    REF f9e441137620d712c7d89587c951bed459ebc843 # 3.10.0
    SHA512 6621d105706fb69b3f1998d7c83c94ff93747946040f0c45ec52986c0e8d8db3d48237d1e3f0959e09536ca43bcbe3bcdb32f90622ce51de6ea7132be6dd7cf7
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
