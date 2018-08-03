if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message("Rttr only supports dynamic library linkage")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "Rttr only supports dynamic library linkage, so cannot be built with static CRT")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rttrorg/rttr
    REF v0.9.5
    SHA512 b451f24fd4bdc4b7d9ecabdb6fd261744852e68357ec36573109354a25f2bf494908b9d4174602b59dd5005c42ba8edc3b35ec1d1386384db421805ac9994608
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/fix-directory-output.patch"
        "${CMAKE_CURRENT_LIST_DIR}/disable-unit-tests.patch"
        "${CMAKE_CURRENT_LIST_DIR}/remove-owner-read-perms.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(GLOB REL_EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DBG_EXES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
if(REL_EXES)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/rttr)
    file(COPY ${REL_EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/rttr)
endif()

if(REL_EXES)
	file(REMOVE ${REL_EXES})
endif(REL_EXES)

if(DBG_EXES)
	file(REMOVE ${DBG_EXES})
endif(DBG_EXES)

#Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rttr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rttr/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/rttr/copyright)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/README.md
    ${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt
    ${CURRENT_PACKAGES_DIR}/LICENSE.txt
    ${CURRENT_PACKAGES_DIR}/README.md
)


