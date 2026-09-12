if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(IRONPRESS_PLATFORM "windows-x86_64")
    set(IRONPRESS_ARCHIVE_EXTENSION "zip")
    set(IRONPRESS_ARCHIVE_SHA512 df6995f5a71e68d84698c284c01c6cc49f7872e7d3978e6754577170b38faa0aa3453313d259be23a8de28413112be4ff2945a36fcf89923a11931bf9976844c)
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(IRONPRESS_PLATFORM "macos-aarch64")
    set(IRONPRESS_ARCHIVE_EXTENSION "tar.gz")
    set(IRONPRESS_ARCHIVE_SHA512 aff20683e56ae0f6b45f2d1a2e3a4caf32f6cb4f0aa8e113c645e7461340908606601a860c337a4fb511f6921d2d9436aa9f0598ba2e80b499f9b5688434cb63)
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(IRONPRESS_PLATFORM "macos-x86_64")
    set(IRONPRESS_ARCHIVE_EXTENSION "tar.gz")
    set(IRONPRESS_ARCHIVE_SHA512 0dcd46928bc824dce491a35c4fa99e9c69e665de0b47e0f4e2aa55a75666ac27d648fe0db0880e448543df22f73a1264daf425c4667fa20aa24e581aec0e13f1)
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(IRONPRESS_PLATFORM "linux-aarch64")
    set(IRONPRESS_ARCHIVE_EXTENSION "tar.gz")
    set(IRONPRESS_ARCHIVE_SHA512 952bccb581fc5dc48f699f77f22d812f74611fc485b2e53bc981b853e94a8cb8bcb4ca1d0e1e093f3baca13d1ad46ce0b6ce2c7213741be6bb752b4553409ebb)
elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(IRONPRESS_PLATFORM "linux-x86_64")
    set(IRONPRESS_ARCHIVE_EXTENSION "tar.gz")
    set(IRONPRESS_ARCHIVE_SHA512 9fd3110c0c3038576bf9b8e92c0e47b41933c290398a3ee28586ffb272594f88f9231f4ba83141e06eef14cee05a39490719c0638dd3f49bccda8858789cacff)
else()
    message(FATAL_ERROR "Ironpress has no native archive for ${TARGET_TRIPLET}.")
endif()

set(IRONPRESS_ARCHIVE "ironpress-c-${VERSION}-${IRONPRESS_PLATFORM}.${IRONPRESS_ARCHIVE_EXTENSION}")
vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/gastongouron/ironpress/releases/download/v${VERSION}/${IRONPRESS_ARCHIVE}"
    FILENAME "${IRONPRESS_ARCHIVE}"
    SHA512 "${IRONPRESS_ARCHIVE_SHA512}"
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

# Ironpress publishes release-mode native archives. The same artifact backs
# Debug consumers, so Windows' debug CRT check does not apply to this package.
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)
endif()

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

function(ironpress_install_library destination)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(INSTALL "${SOURCE_PATH}/lib/ironpress_ffi.dll"
                DESTINATION "${CURRENT_PACKAGES_DIR}/${destination}bin")
            file(INSTALL "${SOURCE_PATH}/lib/ironpress_ffi.dll.lib"
                DESTINATION "${CURRENT_PACKAGES_DIR}/${destination}lib")
        elseif(VCPKG_TARGET_IS_OSX)
            file(INSTALL "${SOURCE_PATH}/lib/libironpress_ffi.dylib"
                DESTINATION "${CURRENT_PACKAGES_DIR}/${destination}lib")
        else()
            file(INSTALL "${SOURCE_PATH}/lib/libironpress_ffi.so"
                DESTINATION "${CURRENT_PACKAGES_DIR}/${destination}lib")
        endif()
    elseif(VCPKG_TARGET_IS_WINDOWS)
        file(INSTALL "${SOURCE_PATH}/lib/ironpress_ffi.lib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/${destination}lib")
    else()
        file(INSTALL "${SOURCE_PATH}/lib/libironpress_ffi.a"
            DESTINATION "${CURRENT_PACKAGES_DIR}/${destination}lib")
    endif()
endfunction()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    ironpress_install_library("")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    ironpress_install_library("debug/")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(IRONPRESS_LIBRARY_TYPE SHARED)
else()
    set(IRONPRESS_LIBRARY_TYPE STATIC)
endif()
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/IronpressConfig.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/ironpress/IronpressConfig.cmake"
    @ONLY
)
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CURRENT_PACKAGES_DIR}/share/ironpress/IronpressConfigVersion.cmake"
    VERSION "${VERSION}"
    COMPATIBILITY SameMajorVersion
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/ironpress")

string(CONCAT IRONPRESS_LICENSE_COMMENT
    "The prebuilt Ironpress library contains statically linked Rust dependencies. "
    "Their licenses and copyright notices can be obtained by checking out "
    "https://github.com/gastongouron/ironpress/tree/v${VERSION} and running "
    "cargo-about against bindings/c/Cargo.toml."
)
vcpkg_install_copyright(
    COMMENT "${IRONPRESS_LICENSE_COMMENT}"
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
