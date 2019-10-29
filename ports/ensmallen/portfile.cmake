include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF 7c37b614e35bd1e8f2131d5ee631013493be53bf # 2.10.3
    SHA512 7865b36fbcd0c8ae634ada7da9aac7a919bef5eb92445ff2363783b50fd5705abd9b125437514ed9d05ffcd61651a4d09d2879b7097b4bd11d8a8a317c49a3db
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
