vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numactl/numactl
    REF "v${VERSION}"
    SHA512 fc062e7fcfd90e3d26d0e3b144b4c4328b54874aef6ad0c91d7740e5989787a182037c5d409ce9271f0a6459d4d7e70f49cc5f701d93b64a15d3b7772accb9b4
    HEAD_REF master
)

message(
"numactl currently requires the following libraries from the system package manager:
    autoconf libtool
These can be installed on Ubuntu systems via sudo apt install autoconf libtool"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(SHARED_STATIC --enable-static --disable-shared)
else()
    set(SHARED_STATIC --disable-static --enable-shared)
endif()

set(OPTIONS ${SHARED_STATIC})
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/autogen.sh
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME setup-${TARGET_TRIPLET}
)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
set(CFLAGS "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG} -fPIC -O0 -g -I${SOURCE_PATH}/include")
set(LDFLAGS "${VCPKG_LINKER_FLAGS}")
vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR}/debug ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}/debug
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
    COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR} ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}
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

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
configure_file(${SOURCE_PATH}/README.md ${CURRENT_PACKAGES_DIR}/share/numactl/copyright COPYONLY)
