include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "brynet does not support dynamic linkage. Building statically.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IronsDu/brynet
    REF v1.0.0
    SHA512 f2ad0514d5b25828b38d929bf352a8a35c39816982f7a3aaca2b6d74a7e592d8a37d2af6b77d6babf2eec25063ed1bb50704e8871d18d7e5f777021d18604b9c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brynet)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/brynet/LICENSE ${CURRENT_PACKAGES_DIR}/share/brynet/copyright)
