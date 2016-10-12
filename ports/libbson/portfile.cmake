include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
find_program(POWERSHELL powershell)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libbson-1.4.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/libbson/releases/download/1.4.2/libbson-1.4.2.tar.gz"
    FILENAME "libbson-1.4.2.tar.gz"
    SHA512 4cc8f833978483af3dcbc30bede33f2a9b448930fabf7be2d5581c8368e875dc1707d31eae209c747e69be1f82fa525c7362c5ac9c4e0b6b3f3346dd5147860e
)
vcpkg_extract_source_archive(${ARCHIVE})

message(STATUS "Patching install header destination...")
vcpkg_execute_required_process(
	COMMAND ${POWERSHELL} -command (gc CMakeLists.txt) -replace(\"/libbson-\\`\${BSON_API_VERSION}\", '') | Set-Content -Encoding utf8 CMakeLists.txt
	WORKING_DIRECTORY ${SOURCE_PATH}
)
message(STATUS "Patching done.")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libbson/COPYING ${CURRENT_PACKAGES_DIR}/share/libbson/copyright)