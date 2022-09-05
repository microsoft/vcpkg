vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exzap/ZArchive
    REF v0.1.2
    SHA512 b9666e8e86e5162b4ee641905a288088311d5cd1af510b2fbf22eba722ad2d8ca43a081b14c0106743807eff256bac9a0cacbdeb06e8ccad0e8d5b9ed8fa886e
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
