vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rttrorg/rttr
    REF v0.9.6
    SHA512 5c94f037b319568d351ee6d25f1404adce00b40598dce4a331789d5357c059e50aae3894f90e60d37307b7e96f4672ae09d3798bbe47f796ef2044f1ac6f9e50
    HEAD_REF master
    PATCHES
        fix-directory-output.patch
        Fix-depends.patch
        remove-owner-read-perms.patch
)

#Handle static lib
set(BUILD_STATIC_LIB OFF) 
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
	set(BUILD_STATIC_LIB ON) 
else()
	set(BUILD_STATIC_LIB OFF) 
endif()
vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DBUILD_BENCHMARKS=OFF
		-DBUILD_UNIT_TESTS=OFF
		-DBUILD_STATIC=${BUILD_STATIC_LIB}
)

vcpkg_install_cmake()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
	vcpkg_fixup_cmake_targets(CONFIG_PATH share/rttr/cmake)
elseif(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
	vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
	message(FATAL_ERROR "RTTR does not support this platform")
endif()

#Handle static lib
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

#Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/README.md
    ${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt
    ${CURRENT_PACKAGES_DIR}/LICENSE.txt
    ${CURRENT_PACKAGES_DIR}/README.md
)
