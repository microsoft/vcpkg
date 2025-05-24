vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexus2k/tinyproto
    REF e0d5a3b972ae0b50bbca57ac436041364996577c
    SHA512 1699d09815f06c40fc1581d6474e217675054b87b0fa7656fc2db7e181a2336f8efd8caadd3af700d685a37543e901d659995cc5baa219848cbfe11ca8124425
    HEAD_REF master
    PATCHES 
        install.patch
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")