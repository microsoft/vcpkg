if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF v1.3.8
    SHA512 9dba4fa4dd49d323f2e440c5b93eac1ef62eb4046ec4ef611f0978c12c1739002f1ac1f1ec5e61bd359dc89e9ed612db71be91a795184ac5d5433280d27fa4c1
    HEAD_REF master)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/librhash)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/librhash
    PREFER_NINJA
    OPTIONS_DEBUG
        -DRHASH_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/rhash)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rhash/COPYING ${CURRENT_PACKAGES_DIR}/share/rhash/copyright)
