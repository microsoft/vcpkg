vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v7.2.0
    SHA512 fb94a3311c1b02e8ef1776569329edfb58021606d2a8ad1d9c14627c01bd4696233451ad5a94cbccae12468cfe5989f90429bc25a02792c5b8889129b0b912b3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Microsoft.WindowsAzure.Storage
    PREFER_NINJA
    OPTIONS
        -DCMAKE_FIND_FRAMEWORK=LAST
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
    OPTIONS_RELEASE
        -DGETTEXT_LIB_DIR=${CURRENT_INSTALLED_DIR}/lib
    OPTIONS_DEBUG
        -DGETTEXT_LIB_DIR=${CURRENT_INSTALLED_DIR}/debug/lib
)

vcpkg_install_cmake()

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/azure-storage-cpp RENAME copyright)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

