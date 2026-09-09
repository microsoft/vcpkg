vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nth-bailey/PolyXML
    REF "v${VERSION}"
    SHA512 7e30417433494e02d93df729adc5e27ee6a84d1ef682bf1dd101ece71b09256a8bd019bfa8cbabb48474a46d6ef49622232c75840f0d2747e8832592d7bfa495
    HEAD_REF main
)

find_program(CARGO NAMES cargo cargo.exe HINTS "$ENV{CARGO_HOME}/bin" "$ENV{USERPROFILE}/.cargo/bin" "$ENV{HOME}/.cargo/bin" REQUIRED)

message(STATUS "Building native Rust polyxml-c library...")
vcpkg_execute_required_process(
    COMMAND ${CARGO} build --release -p polyxml-c
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "cargo-build-${TARGET_TRIPLE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/bindings/cpp"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME polyxml_cpp)

file(INSTALL "${SOURCE_PATH}/crates/polyxml-c/include/polyxml.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${SOURCE_PATH}/target/release/polyxml.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin" OPTIONAL)
    file(INSTALL "${SOURCE_PATH}/target/release/polyxml.dll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" OPTIONAL)
elseif(VCPKG_TARGET_IS_OSX)
    file(INSTALL "${SOURCE_PATH}/target/release/libpolyxml.dylib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" OPTIONAL)
else()
    file(INSTALL "${SOURCE_PATH}/target/release/libpolyxml.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" OPTIONAL)
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
