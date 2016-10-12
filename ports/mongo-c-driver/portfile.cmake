include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
find_program(POWERSHELL powershell)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mongo-c-driver-1.4.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/mongo-c-driver/releases/download/1.4.2/mongo-c-driver-1.4.2.tar.gz"
    FILENAME "mongo-c-driver-1.4.2.tar.gz"
    SHA512 402b9d0f2ae957a07336c9a6d971440472acef8e17a3ba5e89635ca454a13d4b7cf5f9b71151ed6182c012efb5fac6684acfc00443c6bca07cdd04b9f7eddaeb
)
vcpkg_extract_source_archive(${ARCHIVE})

message(STATUS "Patching install header destination...")
vcpkg_execute_required_process(
	COMMAND ${POWERSHELL} -command (gc CMakeLists.txt) -replace(\"/libmongoc-\\`\${MONGOC_API_VERSION}\", '') | Set-Content -Encoding utf8 CMakeLists.txt
	WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_copy_pdbs()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-c-driver/copyright)