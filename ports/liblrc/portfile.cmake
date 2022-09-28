vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ywh233/LRC-Tools
    REF 1fc3872320cd449933bffefc6527928262ee0629
    SHA512 5b0a52a557ffb28554b33e77efb3832944facfd4e039d8afe60c322d56872eb12cb93f3974d17f083c659dcddf9c63075d3b09ba6abd3adba7b40b2ffb615f1c
    PATCHES
    set_up_compile_error.patch
)

file(COPY 
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION  
    "${SOURCE_PATH}"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
