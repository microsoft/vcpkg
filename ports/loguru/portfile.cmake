vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emilk/loguru
    REF 9c2fea0d4530657f23259be4132f8101c98b579e  #v2.1.0
    SHA512 49eebf8648f9d29273af76dca0a4e49155daa3664e98979df005e64eb0fa9f4eeb4228245327d469772c51076571acbe39a644eba531444d8676d9709a7e3914
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL ${SOURCE_PATH}/loguru.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/loguru)
    file(INSTALL ${SOURCE_PATH}/loguru.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/loguru)
endif()

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/loguruConfig.cmake.in  ${SOURCE_PATH}/loguruConfig.cmake.in COPYONLY)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS_DEBUG
            -DINSTALL_HEADERS=OFF
     )

    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets()
    vcpkg_copy_pdbs()
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
