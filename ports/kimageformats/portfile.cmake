vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://invent.kde.org/frameworks/kimageformats.git
    REF 7858c4eeec712c59b3214386d7e5639cab636bba
    HEAD_REF master
    PATCHES
        fixinstall.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dds KIMAGEFORMATS_DDS
	heif KIMAGEFORMATS_HEIF
	jxl KIMAGEFORMATS_JXL
	jp2 KIMAGEFORMATS_JP2
	jxr KIMAGEFORMATS_JXR
	eps BUILD_EPS_PLUGIN
    INVERTED_FEATURES
        kritaraster 	CMAKE_DISABLE_FIND_PACKAGE_KF6Archive
	openexr		CMAKE_DISABLE_FIND_PACKAGE_OpenEXR
	avif		CMAKE_DISABLE_FIND_PACKAGE_libavif
	raw		CMAKE_DISABLE_FIND_PACKAGE_LibRaw
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
	-DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")

vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
