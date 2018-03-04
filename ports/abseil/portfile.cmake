include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Abseil currently only supports being built for desktop")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF 5337d2d0e312ce6bce0140b5f1da5548a0b3fed5
    SHA512 14b2680c39260c5dc6a4b06583f7581ebfe11cde5c2e93cbca72385b1ba0c216894a3e88aa47ad84cc45af1c237b58e2b6240c35e1c0a73246a06ad472573558
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-abseil)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/abseil ${CURRENT_PACKAGES_DIR}/share/unofficial-abseil)

file(GLOB_RECURSE HEADERS ${CURRENT_PACKAGES_DIR}/include/*)
foreach(FILE ${HEADERS})
    file(READ "${FILE}" _contents)
    string(REPLACE "std::min(" "(std::min)(" _contents "${_contents}")
    string(REPLACE "std::max(" "(std::max)(" _contents "${_contents}")
    file(WRITE "${FILE}" "${_contents}")
endforeach()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/abseil RENAME copyright)
