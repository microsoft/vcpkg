# libgit2 uses winapi functions not available in WindowsStore
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are not supported.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF v0.27.3
    SHA512 e470050b89289908ec64dafaa954ad9bfc8f557ba7dafcab440d9efde474f736c025d8202bfd81a508070d9cf678f3fb1f3687d72a849ce86edd1ee90ad13c3b
    HEAD_REF master)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "shared" BUILD_SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_CLAR=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    OPTIONS_DEBUG
        -DBUILD_CLAR=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)
	

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgit2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libgit2/COPYING ${CURRENT_PACKAGES_DIR}/share/libgit2/copyright)
