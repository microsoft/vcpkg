vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v7.3.0
    SHA512 4297fa9e70fc4f4dde63f78f21714c2f9f6a9a63529cc3595f61e08659ea86a3590dbf9e99ee67572099c6bb7cc5b376bba6f29fbf59c5a1b705d841bb9a32e4
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

