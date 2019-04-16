include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("parson only supports static linkage")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kgabis/parson
    REF 395e70d85b675e98efbb9ea6e534c0c9d089dc4e
    SHA512 6d89239cca57912618b1d29d6b9654e701b9dcfddf19f897dac14f60a347221c2ad30562c5d85a704a5d4359d891a0d93bbe4671f5459a71fcb47f5a6f1b856d
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/parson.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-parson TARGET_PATH share/unofficial-parson)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/parson RENAME copyright)

vcpkg_copy_pdbs()
