include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF ensmallen-1.14.3
    SHA512 138713849e9cd55517893c9b0c21afa751bff157c968fbdfa0fbefd10439006c27af023c13f5ffbc349b417b6539ce5fa67652f0a15d53f8204511f1c0d81adb
    HEAD_REF master
	PATCHES
		disable_tests.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ensmallen RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
