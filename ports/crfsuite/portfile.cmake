if (VCPKG_TARGET_TRIPLET STREQUAL "x64-uwp" OR VCPKG_TARGET_TRIPLET STREQUAL "arm-uwp")
    message(FATAL_ERROR "crfsuite does not support on this platform")
endif()


include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chokkan/crfsuite
    REF 0.12
    SHA512   7cb02c1ac72613bafd639e1ef9a7ce7ddb0d36b2e7038c45f9745ad177344c3f20c7df48dfc1bdce364af1d0a85957a918ed8fee078232d5a2c91ab3796ee7f0
    HEAD_REF master
    PATCHES  fix_msc_ver.patch
)

message(STATUS "source path is : ${SOURCE_PATH}")
list(REMOVE_ITEM SOURCE_FILE ${SOURCE_PATH}/win32/liblbfgs/lbfgs.lib)
list(REMOVE_ITEM SOURCE_FILE ${SOURCE_PATH}/win32/liblbfgs/lbfgs_debug.lib)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFIX_NINJA
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/crfsuite RENAME copyright)