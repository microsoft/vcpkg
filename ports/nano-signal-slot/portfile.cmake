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
    SHA512 5a9af864190f8ef8dcf896eb075e359b6110e8acd6cb9604b17680a44f899636d7f8c09182661628b90e43ea51c287b4c9b7d69eed7460708c9d1e677c74bde5
    HEAD_REF master
)

file(GLOB INCLUDES ${SOURCE_PATH}/*.hpp)
file(INSTALL ${INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nano-signal-slot RENAME copyright)