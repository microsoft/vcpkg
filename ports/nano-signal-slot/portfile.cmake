include(vcpkg_common_functions)

vcpkg_check_linkage(
	ONLY_STATIC_LIBRARY
)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds not supported yet.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NoAvailableAlias/nano-signal-slot
    REF 34223a4a7e97f8e114ef007e5360cf7a71265da3
    SHA512 79f5bc23bf96ff9df208c8672ec5847974a799ff25264234974109cf686c32e1931f92d4924f17593b2cdc279459b4791f75298908a02ce62b295f5e2fab50a3
    HEAD_REF master
)

file(GLOB INCLUDES ${SOURCE_PATH}/*.hpp)
file(INSTALL ${INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nano-signal-slot RENAME copyright)