include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.") # See note below
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_find_acquire_program(WINFLEXBISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/thrift
    REF 0.10.0
    SHA512 1ca372654cf556e41aecda041ada150515bbb469ba75b05300127702d1f41049338ca67b6e46ce39d89cbf27c1da9ebee75b06bad0cc4035def7a36843dbe8fe
    HEAD_REF master
)

set(FLEX_EXECUTABLE "${DOWNLOADS}/tools/winflexbison/win_flex.exe")
set(BISON_EXECUTABLE "${DOWNLOADS}/tools/winflexbison/win_bison.exe")


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS   -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON  -DBUILD_TESTING=off -DBUILD_JAVA=off -DBUILD_C_GLIB=off -DBUILD_PYTHON=off -DBUILD_CPP=on -DBUILD_HASKELL=off -DBUILD_TUTORIALS=off -DFLEX_EXECUTABLE=${FLEX_EXECUTABLE} -DBISON_EXECUTABLE=${BISON_EXECUTABLE}
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/thrift RENAME copyright)

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")

if(EXES)
    file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
vcpkg_copy_pdbs()
