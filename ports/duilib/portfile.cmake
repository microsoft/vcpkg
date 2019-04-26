include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO duilib/duilib
	REF d7f3a331a0fc6ba48429cd9e5c427570cc73bc35
	SHA512 6381cac467d42e4811859411a5fa620e52075622e8fbec38a6ab320c33bc7d6fdddc809c150d6a10cc40c55a651345bda9387432898d24957b6ab0f5c4b5391c
    HEAD_REF master
	PATCHES "fix-encoding.patch"
)

file(REMOVE ${SOURCE_PATH}/DuiLib/Control/UIGifAnim.cpp)
file(RENAME ${SOURCE_PATH}/DuiLib/Control/UIGifAnim-patch.cpp ${SOURCE_PATH}/DuiLib/Control/UIGifAnim.cpp)

file(REMOVE_RECURSE ${SOURCE_PATH}/DuiLib/Build)
file(INSTALL ${SOURCE_PATH}/DuiLib DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)

vcpkg_build_msbuild(PROJECT_PATH ${SOURCE_PATH}/DuiLib/DuiLib.vcxproj)

file(INSTALL ${SOURCE_PATH}/bin/DuiLib.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${SOURCE_PATH}/bin/DuiLib_d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL ${SOURCE_PATH}/Lib/DuiLib.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/Lib/DuiLib_d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/duilib RENAME copyright)
file(REMOVE_RECURSE ${SOURCE_PATH})
