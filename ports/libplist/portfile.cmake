include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libplist
    REF f279ef534ab5adeb81f063dee5e8a8fc3ca6d3ab
    SHA512 52001a46935693e3ac5f0b8c3d13d9bf51c5f34189f6f006bd697d7e965f402460060708c4fb54ed43f49a217ac442fcb8dca252fcbccd3e6a154b6c9a8c2104
    HEAD_REF msvc-master
    PATCHES dllexport.patch
)

set(ENV{_CL_} "$ENV{_CL_} /GL-")
set(ENV{_LINK_} "$ENV{_LINK_} /LTCG:OFF")


if (VCPKG_TARGET_IS_WINDOWS)
	vcpkg_install_msbuild(
		SOURCE_PATH ${SOURCE_PATH}
		PROJECT_SUBPATH libplist.sln
		INCLUDES_SUBPATH include
		LICENSE_SUBPATH COPYING.lesser
		REMOVE_ROOT_INCLUDES
	)
else()
	message("libplist need to install automake first.")
	vcpkg_find_acquire_program(PYTHON3)
	get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
	set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")
	
	vcpkg_execute_required_process_repeat(
		COUNT 1
		COMMAND autogen.sh
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME autogen-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}
	)
	
	vcpkg_execute_required_process(
		COMMAND ./configure
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME configure-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}
	)
	
	vcpkg_execute_required_process(
		COMMAND make
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME make-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}
	)
	
	vcpkg_execute_required_process(
		COMMAND make install
		WORKING_DIRECTORY ${SOURCE_PATH}
		LOGNAME install-${TARGET_TRIPLET}-${BOTAN_BUILD_TYPE}
	)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()