include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Abseil currently only supports being built for desktop")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF 3f622d6c5990a7ae80eb8e52450c309a28bbec77
    SHA512 27c11bbe4e321fcd42f1947fab2a7deb108443bf46260e7f7920cc28442a4dbfbf315d579e866b2d82e92cfe1fd43e82cbd51e907cbf74a25d724cfd8acda055
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
