vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO themoos/ui-moos
    REF ba7dd1db7db1848acb3e68b9e54d3da9d7014684
    SHA512 96225216973656a9029d4e8ac8a8b69df15db5c160bcbd02755cd291bfe5817dbde3a6a5f46b71a138ddf4a389c3c702d4d502ade91ad88554042d7b9d75f843
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_CONSOLE_TOOLS=ON
        -DBUILD_GRAPHICAL_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES uPoke iRemoteLite AUTO_CLEAN)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "see moos-core for copyright\n" )
