vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO objectcomputing/quickfast
    REF V1_5
    SHA512 f224ffbe0ee1b84616b46d536d27da01346103cf9ed135a87543da51e8e979ec3735e08ece8525ee1316ea323d41dcacc4d44eabe2e033d68f93432ea43d1ce9
    HEAD_REF master
    PATCHES 00001-fix-boost-asio.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if(NOT EXISTS "${SOURCE_PATH}/quickfast")
	file(RENAME "${SOURCE_PATH}/src" "${SOURCE_PATH}/quickfast")
endif()

file(GLOB_RECURSE SRC_FILES  "${SOURCE_PATH}/quickfast/*.cpp" "${SOURCE_PATH}/quickfast/*.h")
foreach(SRC_FILE IN LISTS SRC_FILES)
    file(READ "${SRC_FILE}" _contents)
	string(REPLACE "#include <Common/"        "#include <quickfast/Common/"        _contents "${_contents}")
	string(REPLACE "#include <Application/"   "#include <quickfast/Application/"   _contents "${_contents}")
	string(REPLACE "#include <Communication/" "#include <quickfast/Communication/" _contents "${_contents}")
	string(REPLACE "#include <Codecs/"        "#include <quickfast/Codecs/"        _contents "${_contents}")
	string(REPLACE "#include <Messages/"      "#include <quickfast/Messages/"      _contents "${_contents}")
    file(WRITE "${SRC_FILE}" "${_contents}")
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(BUILD_SHARED_LIBS ON)
else()
  set(BUILD_SHARED_LIBS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/quickfast)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/license.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
