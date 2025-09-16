vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://invent.kde.org/frameworks/kimageformats.git
    REF 7858c4eeec712c59b3214386d7e5639cab636bba
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKIMAGEFORMATS_DDS=OFF
	-DKIMAGEFORMATS_HEIF=OFF
	-DKIMAGEFORMATS_JXL=OFF
	-DKIMAGEFORMATS_JP2=OFF
	-DKIMAGEFORMATS_JXR=OFF # says that there are security issues with this plugin in their CMakeLists.txt
	# not sure how comfortable I feel including it as a feature if there are active security issues,
	# but I guess it could be considered "not our problem". Maybe just having a warning is good?
	# Whoever reviews this, please comment <3
)

vcpkg_cmake_install()
