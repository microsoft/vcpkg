if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/cctz
    REF v2.1
    SHA512 b6531ce64fdd8581944457cdeff7f9ff9c00958af51ddb262c74e08fcc076466c59c7bef1ce7edccc9512a7f4cb204e04581d287c4a9a684057fe39421c3fbc6
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-cctz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cctz ${CURRENT_PACKAGES_DIR}/share/unofficial-cctz)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cctz RENAME copyright)
