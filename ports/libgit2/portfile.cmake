# libgit2 uses winapi functions not available in WindowsStore
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are not supported.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF v0.26.0
    SHA512 b6e51f2216c7c23f352572b780ea1325a25a517396709f036bb573295c2bd02aa505ba616846ac7e07863e99e640e7d47fefc5727478a257b283da99060ee47c
    HEAD_REF master)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_CLAR=OFF
    OPTIONS_DEBUG
		-DBUILD_CLAR=OFF
)
	

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgit2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libgit2/COPYING ${CURRENT_PACKAGES_DIR}/share/libgit2/copyright)
