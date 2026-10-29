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
        -DBUILD_GRAPHICAL_TOOLS=OFF #${BUILD_GRAPHICAL_TOOLS}
)

vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/MOOS")
if (VCPKG_TARGET_IS_WINDOWS)
	file(RENAME "${CURRENT_PACKAGES_DIR}/bin/uPoke.exe" "${CURRENT_PACKAGES_DIR}/tools/MOOS/uPoke.exe")
	file(RENAME "${CURRENT_PACKAGES_DIR}/bin/iRemoteLite.exe" "${CURRENT_PACKAGES_DIR}/tools/MOOS/iRemoteLite.exe")
else()
	file(RENAME "${CURRENT_PACKAGES_DIR}/bin/uPoke" "${CURRENT_PACKAGES_DIR}/tools/MOOS/uPoke")
	file(RENAME "${CURRENT_PACKAGES_DIR}/bin/iRemoteLite" "${CURRENT_PACKAGES_DIR}/tools/MOOS/iRemoteLite")
endif()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/MOOS") 

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug")

file(WRITE "${CURRENT_PACKAGES_DIR}/include/fake_header_ui.h" "// fake header to pass vcpkg post install check \n")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "see moos-core for copyright\n" )
