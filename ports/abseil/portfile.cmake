include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Abseil currently only supports being built for desktop")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF c2e00d341913bf03b4597ade5b056042e23e8c58
    SHA512 60e9f0abc4ebbc356314c144b769a6918d4c5215df9f01aafb234f94756b08b670bdaf4cf88363ea4daf3bd19cb193ba6817aba70b208275d3d5d1ed2926ce9a
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-abseil TARGET_PATH share/unofficial-abseil)

file(GLOB_RECURSE HEADERS ${CURRENT_PACKAGES_DIR}/include/*)
foreach(FILE ${HEADERS})
    file(READ "${FILE}" _contents)
    string(REPLACE "std::min(" "(std::min)(" _contents "${_contents}")
    string(REPLACE "std::max(" "(std::max)(" _contents "${_contents}")
    file(WRITE "${FILE}" "${_contents}")
endforeach()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/abseil RENAME copyright)
