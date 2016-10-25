include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cpprestsdk-2.9.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/cpprestsdk/archive/v2.9.0.tar.gz"
    FILENAME "cpprestsdk-2.9.0.tar.gz"
    SHA512 c75de6ad33b3e8d2c6ba7c0955ed851d557f78652fb38a565de0cfbc99e7db89cb6fa405857512e5149df80356c51ae9335abd914c3c593fa6658ac50adf4e29
)
vcpkg_extract_source_archive(${ARCHIVE})


vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
        ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Release
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DCPPREST_EXCLUDE_WEBSOCKETS=OFF
    OPTIONS_DEBUG
        -DCASA_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(INSTALL
    ${SOURCE_PATH}/license.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpprestsdk RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_copy_pdbs()
endif()

