include(vcpkg_common_functions)

set(LIBOSIP2_VER "5.1.0")

if (VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "libosio2 only support unix currently.")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/gnu/osip/libosip2-${LIBOSIP2_VER}.tar.gz"
    FILENAME "libosip2-${LIBOSIP2_VER}.tar.gz"
    SHA512 391c9a0ea399f789d7061b0216d327eecba5bbf0429659f4f167604b9e703e1678ba6f58079aa4f84b3636a937064ecfb92e985368164fcb679e95654e43d65b
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

find_program(autoreconf autoreconf)
if (NOT autoreconf)
    message(FATAL_ERROR "autoreconf must be installed before libx11 can build. Install them with \"apt-get dh-autoreconf\".")
endif()

find_program(MAKE make)
if (NOT MAKE)
    message(FATAL_ERROR "MAKE not found")
endif()

vcpkg_execute_required_process(
    COMMAND "./autogen.sh"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME autoreconf-${TARGET_TRIPLET}
)

message(STATUS "Configuring ${TARGET_TRIPLET}")
set(OUT_PATH ${CURRENT_BUILDTREES_DIR}/make-build-${TARGET_TRIPLET})

file(REMOVE_RECURSE ${OUT_PATH})
file(MAKE_DIRECTORY ${OUT_PATH})

vcpkg_execute_required_process(
    COMMAND "./configure" --prefix=${OUT_PATH}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME config-${TARGET_TRIPLET}
)

message(STATUS "Building ${TARGET_TRIPLET}")
vcpkg_execute_required_process(
    COMMAND make
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-release
)

message(STATUS "Installing ${TARGET_TRIPLET}")
vcpkg_execute_required_process(
    COMMAND make install
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME install-${TARGET_TRIPLET}-release
)
file(COPY ${OUT_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(COPY ${OUT_PATH}/lib DESTINATION ${CURRENT_PACKAGES_DIR})

file(GLOB_RECURSE LIBOSIP2_BINARIES ${CURRENT_PACKAGES_DIR}/lib *.so)
foreach(LIBOSIP2_BINARY LIBOSIP2_BINARIES)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(COPY ${LIBOSIP2_BINARY} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    endif()
    file(REMOVE ${LIBOSIP2_BINARY})
endforeach()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)