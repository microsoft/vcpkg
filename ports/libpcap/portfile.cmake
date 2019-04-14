include(vcpkg_common_functions)

vcpkg_download_distfile(
    SOURCE_ARCHIVE_PATH
    URLS http://www.tcpdump.org/release/libpcap-1.9.0.tar.gz
    FILENAME libpcap-1.9.0.tar.gz
    SHA512 0ff25641f1e9d29082766caef45888c19214f770c4f378818caa73fcbc4ae54ad9195549c2499d4879ff46e35741d93b2b02cc5f3d6aa99e85a32194cf10bfe7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${SOURCE_ARCHIVE_PATH}
    REF 1.9.0
)

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "Package only supports linux platform.")
endif()

message(
"libpcap currently requires the following libraries from the system package manager:
    flex
    libbison-dev

These can be installed on Ubuntu systems via sudo apt install flex libbison-dev"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(SHARED_STATIC --enable-static --disable-shared)
else()
    set(SHARED_STATIC --disable-static --enable-shared)
endif()

set(OPTIONS ${SHARED_STATIC})

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
set(CFLAGS "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG} -fPIC -O0 -g -I${SOURCE_PATH}/include")
set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR}/debug ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}/debug --enable-usb=no --enable-netmap=no --enable-bluetooth=no --enable-dbus=no --enable-rdma=no --enable-shared=no --with-libnl=no
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME configure-${TARGET_TRIPLET}-dbg
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME install-${TARGET_TRIPLET}-dbg
)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
set(CFLAGS "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE} -fPIC -O3 -I${SOURCE_PATH}/include")
set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR} ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR} --enable-usb=no --enable-netmap=no --enable-bluetooth=no --enable-dbus=no --enable-rdma=no --enable-shared=no --with-libnl=no
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME configure-${TARGET_TRIPLET}-rel
)
message(STATUS "Building ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND make -j install "CFLAGS=${CFLAGS}" "LDFLAGS=${LDFLAGS}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME install-${TARGET_TRIPLET}-rel
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
configure_file(${SOURCE_PATH}/README.md ${CURRENT_PACKAGES_DIR}/share/libpcap/copyright COPYONLY)
