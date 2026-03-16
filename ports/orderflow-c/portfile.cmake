vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gregorian-09/orderflow
    REF v0.1.1
    SHA512 5f51de19256f252c0f4f59497e6e53b64be04103e4073778a8f57f30245a26463499b7ccb78a70030d217f56e65b529021386fd5fa72b5ff0cc309eb1180dab6
    HEAD_REF main
)

find_program(CARGO NAMES cargo REQUIRED)

if(VCPKG_TARGET_IS_WINDOWS)
    set(RUST_TARGET "x86_64-pc-windows-msvc")
elseif(VCPKG_TARGET_IS_OSX)
    set(RUST_TARGET "x86_64-apple-darwin")
elseif(VCPKG_TARGET_IS_LINUX)
    set(RUST_TARGET "x86_64-unknown-linux-gnu")
else()
    message(FATAL_ERROR "Unsupported platform for orderflow-c")
endif()

set(ENV{CARGO_TARGET_DIR} "${CURRENT_BUILDTREES_DIR}/cargo-target")

function(orderflow_cargo_build BUILD_KIND)
    if("${BUILD_KIND}" STREQUAL "debug")
        set(PROFILE_ARG "")
    elseif("${BUILD_KIND}" STREQUAL "release")
        set(PROFILE_ARG "--release")
    else()
        message(FATAL_ERROR "Unknown cargo build kind: ${BUILD_KIND}")
    endif()

    vcpkg_execute_required_process(
        COMMAND "${CARGO}" build ${PROFILE_ARG} --locked --target "${RUST_TARGET}" --manifest-path "${SOURCE_PATH}/crates/of_ffi_c/Cargo.toml"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "cargo-build-${TARGET_TRIPLET}-${BUILD_KIND}"
    )
endfunction()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    orderflow_cargo_build("release")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    orderflow_cargo_build("debug")
endif()

file(INSTALL "${SOURCE_PATH}/crates/of_ffi_c/include/orderflow.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

function(orderflow_install_artifacts BUILD_KIND)
    if("${BUILD_KIND}" STREQUAL "debug")
        set(PROFILE_DIR "debug")
        set(LIB_DEST "debug/lib")
        set(BIN_DEST "debug/bin")
    else()
        set(PROFILE_DIR "release")
        set(LIB_DEST "lib")
        set(BIN_DEST "bin")
    endif()

    set(BUILD_OUT "${CURRENT_BUILDTREES_DIR}/cargo-target/${RUST_TARGET}/${PROFILE_DIR}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(INSTALL "${BUILD_OUT}/of_ffi_c.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/${LIB_DEST}")
        else()
            file(INSTALL "${BUILD_OUT}/libof_ffi_c.a" DESTINATION "${CURRENT_PACKAGES_DIR}/${LIB_DEST}")
        endif()
    else()
        if(VCPKG_TARGET_IS_WINDOWS)
            file(INSTALL "${BUILD_OUT}/of_ffi_c.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/${BIN_DEST}")
            if(EXISTS "${BUILD_OUT}/of_ffi_c.dll.lib")
                file(INSTALL "${BUILD_OUT}/of_ffi_c.dll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/${LIB_DEST}")
            else()
                file(INSTALL "${BUILD_OUT}/of_ffi_c.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/${LIB_DEST}")
            endif()
        elseif(VCPKG_TARGET_IS_OSX)
            file(INSTALL "${BUILD_OUT}/libof_ffi_c.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/${LIB_DEST}")
        else()
            file(INSTALL "${BUILD_OUT}/libof_ffi_c.so" DESTINATION "${CURRENT_PACKAGES_DIR}/${LIB_DEST}")
        endif()
    endif()
endfunction()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    orderflow_install_artifacts("release")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    orderflow_install_artifacts("debug")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/orderflow.pc"
"prefix=\${pcfiledir}/../..\n\
exec_prefix=\${prefix}\n\
libdir=\${prefix}/lib\n\
includedir=\${prefix}/include\n\
\n\
Name: orderflow\n\
Description: Orderflow C ABI runtime\n\
Version: 0.1.1\n\
Libs: -L\${libdir} -lof_ffi_c\n\
Cflags: -I\${includedir}\n")
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${CURRENT_PORT_DIR}/copyright")
