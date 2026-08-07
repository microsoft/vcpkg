vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Flaxmbot/PipeQL
    REF v1.1.4
    SHA512 5f5327e91eb27afef83ac4d51c4ea6f5b53cb485a240e405c2f6a5a5600b7ad9475746d53ec5002a6894dff0a5a0bd9c9e5886e4060e781d114dea5e5377f53b
    HEAD_REF master
)

# Rust toolchain is not shipped with vcpkg - acquire cargo + rustc on demand.
vcpkg_find_acquire_program(RUSTC)
vcpkg_find_acquire_program(CARGO)

set(ENV{CARGO_HOME} "${CURRENT_BUILDTREES_DIR}/cargo-home")

vcpkg_execute_required_process(
    COMMAND "${CARGO}" build --release
        -p pipeql-cffi
        --target-dir "${CURRENT_BUILDTREES_DIR}/cargo-target"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "cargo-build-${TARGET_TRIPLET}"
)

set(CARGO_OUT "${CURRENT_BUILDTREES_DIR}/cargo-target/release")

# Header
file(INSTALL "${SOURCE_PATH}/crates/pipeql-cffi/include/libpipeql.h"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Shared library + import/static libs (platform specific names)
if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${CARGO_OUT}/pipeql_cffi.dll"
         DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    if(EXISTS "${CARGO_OUT}/pipeql_cffi.lib")
        file(INSTALL "${CARGO_OUT}/pipeql_cffi.lib"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    endif()
    if(EXISTS "${CARGO_OUT}/pipeql_cffi.dll.lib")
        file(INSTALL "${CARGO_OUT}/pipeql_cffi.dll.lib"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    endif()
    if(EXISTS "${CARGO_OUT}/libpipeql_cffi.dll.a")
        file(INSTALL "${CARGO_OUT}/libpipeql_cffi.dll.a"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    file(INSTALL "${CARGO_OUT}/libpipeql_cffi.dylib"
         DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
    file(INSTALL "${CARGO_OUT}/libpipeql_cffi.so"
         DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
