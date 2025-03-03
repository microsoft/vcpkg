message(WARNING "azure-storage-cpp is no longer actively developed. Instead, users should migrate to the new sdk:azure-core-cpp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v7.5.0
    SHA512 83eabcaf2114c8af1cabbc96b6ef2b57c934a06f68e7a870adf336feaa19edd57aedaf8507d5c40500e46d4e77f5059f9286e319fe7cadeb9ffc8fa018fb030c
    HEAD_REF master
    PATCHES
        fix-asio-error.patch
)

vcpkg_replace_string("${SOURCE_PATH}/Microsoft.WindowsAzure.Storage/CMakeLists.txt" [[file(GLOB OPENSSL_ROOT_DIR /usr/local/Cellar/openssl/*)]] "")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Microsoft.WindowsAzure.Storage"
    OPTIONS
        -DCMAKE_FIND_FRAMEWORK=LAST
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
    OPTIONS_RELEASE
        "-DGETTEXT_LIB_DIR=${CURRENT_INSTALLED_DIR}/lib"
    OPTIONS_DEBUG
        "-DGETTEXT_LIB_DIR=${CURRENT_INSTALLED_DIR}/debug/lib"
)

vcpkg_cmake_install()

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
