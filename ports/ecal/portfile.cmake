vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO continental/ecal
    REF 88d77f278f5e8f3dcb9b4443e3a4e2bc9a3cf5ce #eCAL v5.9.0
	SHA512 a483568b16ae191410d7a8cd8bfba59570be2a2f912f3fa9718fe74a4a5f3de910bed5831781e38617924da69c1cc625836df2e507a9ef7dea04e03c597de8fe
    HEAD_REF master
	PATCHES
	    CMakeLists.txt.patch
		cmake.Modules.Findtclap.cmake.patch
		cmake.Modules.Findsimpleini.cmake.patch
		thirdparty.cmake_functions.cmake.CMakeFunctionsConfig.cmake.in.patch
		thirdparty.cmake_functions.cmake_functions.cmake.patch
		thirdparty.cmake_functions.CMakeLists.txt.patch)

file(REMOVE ${SOURCE_PATH}/cmake/Modules/Findasio.cmake)

file(COPY ${SOURCE_PATH}/thirdparty/cmake_functions/cmake_functions.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake)
file(COPY ${SOURCE_PATH}/thirdparty/cmake_functions/git DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake)
file(COPY ${SOURCE_PATH}/thirdparty/cmake_functions/msvc_helper DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake)
file(COPY ${SOURCE_PATH}/thirdparty/cmake_functions/protoc_functions DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake)
#file(COPY ${SOURCE_PATH}/thirdparty/cmake_functions/qt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake)
file(COPY ${SOURCE_PATH}/thirdparty/cmake_functions/target_definitions DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake)


vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
	    -DDISABLE_FIND_PACKAGE_OVERLOAD=
		-DCMAKE_FUNCTIONS_ROOT=${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake	
	    -DCMakeFunctions_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/thirdparty/cmake_functions/cmake
		-DHAS_QT5=OFF
		-DBUILD_APPS=OFF
		-DBUILD_SAMPLES=OFF
		-DECAL_INSTALL_SAMPLE_SOURCES=OFF
		-DECAL_THIRDPARTY_BUILD_SPDLOG=OFF 
		-DECAL_THIRDPARTY_BUILD_TINYXML2=OFF
		-DECAL_THIRDPARTY_BUILD_FINEFTP=OFF
		-DECAL_THIRDPARTY_BUILD_TERMCOLOR=OFF
		-DECAL_THIRDPARTY_BUILD_PROTOBUF=OFF
		-DECAL_THIRDPARTY_BUILD_CURL=OFF
		-DECAL_THIRDPARTY_BUILD_HDF5=OFF
		-DECAL_LINK_HDF5_SHARED=OFF
		-DCPACK_PACK_WITH_INNOSETUP=OFF
	PREFER_NINJA)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
