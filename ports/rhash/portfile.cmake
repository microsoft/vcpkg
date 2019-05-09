if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF v1.3.6
    SHA512 54f7f238ed1fdc01c29cc1338fa86be90b69beff0df8f20d24ce9cb3c48c7f4668b84a3fe0d4d8b04b54bc8145485d493435edf3219de3a637af0f9c007c85c6
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
