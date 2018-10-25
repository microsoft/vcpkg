include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Abseil currently only supports being built for desktop")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF f340f773edab951656b19b6f1a77c964a78ec4c2
    SHA512 48f7de32255313292f0a86113149180d299902a1ced9cdf9dc5e6beefbd75eb0522ff4ab61e216474e64dd38aebc7c544a6cf7a3fea5836c82f28f19a582965a
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
