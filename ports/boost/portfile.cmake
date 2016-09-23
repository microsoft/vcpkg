include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE_FILE
    URL "http://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.tar.bz2"
    FILENAME "boost_1_61_0.tar.bz2"
    SHA512 a1c7338e2d2dbac8552ede7c554640d22cbb2fda7fbc325dc3cdcb51e769713626695426ffc158cbe0e1729dd9a7b5ad18af4800d74e24539e8d8564268c2b9d
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

if(NOT EXISTS ${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0/b2.exe)
    message(STATUS "Bootstrapping")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0/bootstrap.bat"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0
        LOGNAME bootstrap
    )
endif()
message(STATUS "Bootstrapping done")

set(B2_OPTIONS
    --toolset=msvc
    -j$ENV{NUMBER_OF_PROCESSORS}
    -q
    --without-python
    threading=multi
    link=shared
    runtime-link=shared
    --debug-configuration
)
if(TRIPLET_SYSTEM_ARCH MATCHES "x64")
    list(APPEND B2_OPTIONS address-model=64)
endif()
if(TRIPLET_SYSTEM_NAME MATCHES "WindowsStore")
    list(APPEND B2_OPTIONS windows-api=store)
    set(ENV{BOOST_BUILD_PATH} ${CMAKE_CURRENT_LIST_DIR})
endif()


file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND "${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0/b2.exe"
        --stagedir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/stage
        --build-dir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        ${B2_OPTIONS}
        variant=release
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0
    LOGNAME build-${TARGET_TRIPLET}-rel
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND "${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0/b2.exe"
        --stagedir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/stage
        --build-dir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        ${B2_OPTIONS}
        variant=debug
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0
    LOGNAME build-${TARGET_TRIPLET}-dbg
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

message(STATUS "Packaging headers")
file(
    COPY ${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0/boost
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    PATTERN "config/user.hpp" EXCLUDE
)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0/boost/config/user.hpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/boost/config/
)
file(APPEND ${CURRENT_PACKAGES_DIR}/include/boost/config/user.hpp
    "\n#define BOOST_ALL_DYN_LINK\n"
)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/boost_1_61_0/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost RENAME copyright)
message(STATUS "Packaging headers done")

message(STATUS "Packaging ${TARGET_TRIPLET}-rel")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/stage/lib/
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    FILES_MATCHING PATTERN "*.lib")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/stage/lib/
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    FILES_MATCHING PATTERN "*.dll")
message(STATUS "Packaging ${TARGET_TRIPLET}-rel done")

message(STATUS "Packaging ${TARGET_TRIPLET}-dbg")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/stage/lib/
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    FILES_MATCHING PATTERN "*.lib")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/stage/lib/
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    FILES_MATCHING PATTERN "*.dll")
message(STATUS "Packaging ${TARGET_TRIPLET}-dbg done")

vcpkg_copy_pdbs()