vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/libyuv/libyuv
    REF 3abd6f36b6e4f5a2e0ce236580a8bc1da3c7cf7e #2022-12-15
    PATCHES
        fix-cmakelists.patch
)

# Most of libyuv accelerated features need to be compiled by clang/gcc, so force use clang, otherwise the performance is too poor.
# Manually build the port with clang.
vcpkg_find_acquire_program(CLANG)
if(CLANG MATCHES "-NOTFOUND")
    message(FATAL_ERROR "Clang is required.")
endif()
get_filename_component(CLANG "${CLANG}" DIRECTORY)

vcpkg_find_acquire_program(NINJA)
if(NINJA MATCHES "-NOTFOUND")
    message(FATAL_ERROR "Ninja is required.")
endif()

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(CLANG_TRIPLE "arm")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(CLANG_TRIPLE "aarch64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(CLANG_TRIPLE "i686")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CLANG_TRIPLE "x86_64")
else()
    message(FATAL_ERROR "Unsupported target architecture")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(CLANG_TRIPLE "${CLANG_TRIPLE}-pc-windows-msvc")
elseif(VCPKG_TARGET_IS_OSX)
    set(CLANG_TRIPLE "${CLANG_TRIPLE}-pc-darwin-macho")
elseif(VCPKG_TARGET_IS_LINUX)
    set(CLANG_TRIPLE "${CLANG_TRIPLE}-pc-linux-gnu")
endif()

message(STATUS "Using clang triple ${CLANG_TRIPLE}")

# Release build
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

    set(BUILD_DIR         "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    set(INST_PREFIX       "${CURRENT_PACKAGES_DIR}")

    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
            COMMAND "${CMAKE_COMMAND}"
                    -DCMAKE_BUILD_TYPE=Release
                    -DCMAKE_MAKE_PROGRAM=${NINJA}
                    -DCMAKE_INSTALL_PREFIX=${INST_PREFIX}
                    -DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake
                    -DCMAKE_CXX_COMPILER=${CLANG}/clang++.exe
                    -DCMAKE_C_COMPILER=${CLANG}/clang.exe
                    -DCMAKE_CXX_FLAGS="--target=${CLANG_TRIPLE}"
                    -DCMAKE_C_FLAGS="--target=${CLANG_TRIPLE}"
                    -G Ninja
                    -S ${SOURCE_PATH}
                    -B ${BUILD_DIR}
            WORKING_DIRECTORY "${BUILD_DIR}"
            LOGNAME "configure-${TARGET_TRIPLET}-rel"
    )

    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
            COMMAND "${CMAKE_COMMAND}"
            --build ${BUILD_DIR}
            --target install
            -j ${VCPKG_CONCURRENCY}
            WORKING_DIRECTORY "${BUILD_DIR}"
            LOGNAME "build-${TARGET_TRIPLET}-rel"
    )

    message(STATUS "Installed to ${INST_PREFIX}")
endif()

# Debug build
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    set(BUILD_DIR         "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    set(INST_PREFIX       "${CURRENT_PACKAGES_DIR}/debug")

    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
            COMMAND "${CMAKE_COMMAND}"
                    -DCMAKE_BUILD_TYPE=Debug
                    -DCMAKE_MAKE_PROGRAM=${NINJA}
                    -DCMAKE_INSTALL_PREFIX=${INST_PREFIX}
                    -DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake
                    -DCMAKE_DEBUG_POSTFIX=d
                    -DCMAKE_CXX_COMPILER=${CLANG}/clang++.exe
                    -DCMAKE_C_COMPILER=${CLANG}/clang.exe
                    -DCMAKE_CXX_FLAGS="--target=${CLANG_TRIPLE}"
                    -DCMAKE_C_FLAGS="--target=${CLANG_TRIPLE}"
                    -G Ninja
                    -S ${SOURCE_PATH}
                    -B ${BUILD_DIR}
            WORKING_DIRECTORY "${BUILD_DIR}"
            LOGNAME "configure-${TARGET_TRIPLET}-dbg"
    )

    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
            COMMAND "${CMAKE_COMMAND}"
            --build ${BUILD_DIR}
            --target install
            -j ${VCPKG_CONCURRENCY}
            WORKING_DIRECTORY "${BUILD_DIR}"
            LOGNAME "build-${TARGET_TRIPLET}-dbg"
    )

    message(STATUS "Installed to ${INST_PREFIX}")
endif()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/libyuv)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${CMAKE_CURRENT_LIST_DIR}/libyuv-config.cmake  ${CURRENT_PACKAGES_DIR}/share/${PORT} COPYONLY)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
