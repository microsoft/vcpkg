vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO quickfix/quickfix
    REF v1.15.1
    SHA512 6c3dc53f25932c9b7516ab9228f634511ae0f399719f87f0ec2b38c380c0a7d1c808f0f9a14a70a063e1956118550d1121222283a9139f23cd4f8f038f595f70
    HEAD_REF master
    PATCHES 
        00001-fix-build.patch
        fix_wsl_symlink_error.patch
)

file(GLOB_RECURSE SRC_FILES RELATIVE ${SOURCE_PATH} 
	"${SOURCE_PATH}/src/*.cpp" 
	"${SOURCE_PATH}/src/*.h"
)

list(REMOVE_ITEM SRC_FILES "src/C++/Utility.h")
list(REMOVE_ITEM SRC_FILES "src/C++/pugixml.cpp")

foreach(SRC_FILE IN LISTS SRC_FILES)
    file(READ "${SOURCE_PATH}/${SRC_FILE}" _contents)
	string(REPLACE "throw("  "QUICKFIX_THROW(" _contents "${_contents}")
	string(REPLACE "throw (" "QUICKFIX_THROW(" _contents "${_contents}")
    file(WRITE "${SOURCE_PATH}/${SRC_FILE}" "${_contents}")
endforeach()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DHAVE_EMX=OFF
        -DHAVE_MYSQL=OFF
        -DHAVE_POSTGRESQL=OFF
        -DHAVE_PYTHON=OFF
        -DHAVE_PYTHON2=OFF
        -DHAVE_PYTHON3=OFF
        -DHAVE_SSL=ON
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/quickfix)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
