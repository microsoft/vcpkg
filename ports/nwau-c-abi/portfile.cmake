# Draft vcpkg portfile for the NWAU C ABI surface.
#
# This file is intentionally kept in the MCHS repository as local readiness
# evidence. Upstream vcpkg submission still requires moving the port into the
# vcpkg registry, replacing draft version metadata with the upstream git-tree,
# and validating against vcpkg's CI policy.

vcpkg_download_distfile(NWAU_C_ABI_ARCHIVE
    URLS "https://github.com/edithatogo/mchs/releases/download/nwau-c-abi-v0.1.0/nwau-c-abi-0.1.0-source-r2.tar.gz"
    FILENAME "nwau-c-abi-0.1.0-source-r2.tar.gz"
    SHA512 eda962cc2f2569f87b8c21f600e3f5abce0c46f98bf587b410e42d72c5ffe73ec717d6bc3a78ffa4009cf6c0f07edd532a86ddf54cf1eb5199c555980ddddabc
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${NWAU_C_ABI_ARCHIVE}"
)

set(NWAU_C_ABI_TARGET_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-cargo-target")
set(NWAU_C_ABI_HEADER "${SOURCE_PATH}/rust/crates/nwau-c-abi/include/nwau_abi.h")

find_program(CARGO_EXE NAMES cargo REQUIRED)

if(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(NWAU_C_ABI_RUST_TARGET "aarch64-apple-darwin")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(NWAU_C_ABI_RUST_TARGET "x86_64-apple-darwin")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(NWAU_C_ABI_RUST_TARGET "aarch64-unknown-linux-gnu")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(NWAU_C_ABI_RUST_TARGET "x86_64-unknown-linux-gnu")
    endif()
elseif(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(NWAU_C_ABI_RUST_TARGET "aarch64-pc-windows-msvc")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(NWAU_C_ABI_RUST_TARGET "x86_64-pc-windows-msvc")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(NWAU_C_ABI_RUST_TARGET "i686-pc-windows-msvc")
    endif()
endif()

if(NOT NWAU_C_ABI_RUST_TARGET)
    message(FATAL_ERROR "Unsupported nwau-c-abi Rust target for ${TARGET_TRIPLET}")
endif()

if(NOT EXISTS "${NWAU_C_ABI_HEADER}")
    message(FATAL_ERROR "Expected header not found: ${NWAU_C_ABI_HEADER}")
endif()

file(INSTALL "${NWAU_C_ABI_HEADER}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/nwau-c-abi-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

function(nwau_c_abi_install_profile PROFILE DESTINATION_ROOT)
    if(PROFILE STREQUAL "release")
        set(CARGO_PROFILE_FLAG --release)
        set(PROFILE_DIR "release")
    else()
        set(CARGO_PROFILE_FLAG)
        set(PROFILE_DIR "debug")
    endif()

    vcpkg_execute_required_process(
        COMMAND "${CARGO_EXE}" build ${CARGO_PROFILE_FLAG} --locked -p nwau-c-abi --target "${NWAU_C_ABI_RUST_TARGET}" --target-dir "${NWAU_C_ABI_TARGET_DIR}"
        WORKING_DIRECTORY "${SOURCE_PATH}/rust"
        LOGNAME build-${TARGET_TRIPLET}-${PROFILE}
    )

    set(RELEASE_DIR "${NWAU_C_ABI_TARGET_DIR}/${NWAU_C_ABI_RUST_TARGET}/${PROFILE_DIR}")

    if(VCPKG_TARGET_IS_WINDOWS)
        set(NWAU_C_ABI_IMPLIB "${RELEASE_DIR}/nwau_c_abi.lib")
        set(NWAU_C_ABI_DLL "${RELEASE_DIR}/nwau_c_abi.dll")
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            if(NOT EXISTS "${NWAU_C_ABI_IMPLIB}")
                message(FATAL_ERROR "Expected import library not found: ${NWAU_C_ABI_IMPLIB}")
            endif()
            if(NOT EXISTS "${NWAU_C_ABI_DLL}")
                message(FATAL_ERROR "Expected DLL not found: ${NWAU_C_ABI_DLL}")
            endif()
            file(INSTALL "${NWAU_C_ABI_IMPLIB}" DESTINATION "${DESTINATION_ROOT}/lib")
            file(INSTALL "${NWAU_C_ABI_DLL}" DESTINATION "${DESTINATION_ROOT}/bin")
        else()
            if(NOT EXISTS "${NWAU_C_ABI_IMPLIB}")
                message(FATAL_ERROR "Expected static library not found: ${NWAU_C_ABI_IMPLIB}")
            endif()
            file(INSTALL "${NWAU_C_ABI_IMPLIB}" DESTINATION "${DESTINATION_ROOT}/lib")
        endif()
    else()
        set(NWAU_C_ABI_STATIC "${RELEASE_DIR}/libnwau_c_abi.a")
        if(VCPKG_TARGET_IS_OSX)
            set(NWAU_C_ABI_SHARED "${RELEASE_DIR}/libnwau_c_abi.dylib")
        else()
            set(NWAU_C_ABI_SHARED "${RELEASE_DIR}/libnwau_c_abi.so")
        endif()
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            if(NOT EXISTS "${NWAU_C_ABI_SHARED}")
                message(FATAL_ERROR "Expected shared library not found: ${NWAU_C_ABI_SHARED}")
            endif()
            file(INSTALL "${NWAU_C_ABI_SHARED}" DESTINATION "${DESTINATION_ROOT}/lib")
        else()
            if(NOT EXISTS "${NWAU_C_ABI_STATIC}")
                message(FATAL_ERROR "Expected static library not found: ${NWAU_C_ABI_STATIC}")
            endif()
            file(INSTALL "${NWAU_C_ABI_STATIC}" DESTINATION "${DESTINATION_ROOT}/lib")
        endif()
    endif()
endfunction()

if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    nwau_c_abi_install_profile(release "${CURRENT_PACKAGES_DIR}")
endif()

if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    nwau_c_abi_install_profile(debug "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
