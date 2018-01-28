include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "brynet does not support dynamic linkage. Building statically.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IronsDu/brynet
    REF v0.9.0
    SHA512 49543833be0d8eb2dce2b00a85d48087e9756b93febaae0c7cd83b7f44f9cd8d81976069f8b84344807bee2df785b80fbb65a1a93e8c6a9c942f9554063a05c1
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
