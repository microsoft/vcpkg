include(vcpkg_common_functions)

set(WINFLEXBISON_PATH ${CURRENT_BUILDTREES_DIR}/flex)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/thrift
    REF 0.10.0
    SHA512 1ca372654cf556e41aecda041ada150515bbb469ba75b05300127702d1f41049338ca67b6e46ce39d89cbf27c1da9ebee75b06bad0cc4035def7a36843dbe8fe
    HEAD_REF master
)

message(STATUS "download win flex bison")
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/winflexbison/files/win_flex_bison-latest.zip/download"
    FILENAME "win_flex_bison-latest.zip"
    SHA512 1a6c1fa3b7603df4db2efbb88c31b28ff1a641d4607afdb89e65e76aedf8da821979f1a9f5a1d291149a567c68346321dcbcffe0d517a836e7099b41dc6d9538
)
message(STATUS "done download")

file(MAKE_DIRECTORY "${WINFLEXBISON_PATH}")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} -E tar xfz ${ARCHIVE}
    WORKING_DIRECTORY ${WINFLEXBISON_PATH}
    LOGNAME extract-winflex
)


set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/thrift-0.10.0)
set(FLEX_EXECUTABLE "${WINFLEXBISON_PATH}/win_flex.exe")
set(BISON_EXECUTABLE "${WINFLEXBISON_PATH}/win_bison.exe")



vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS  -DCMAKE_BUILD_TYPE=RelWithDebInfo  -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON  -DBUILD_TESTING=off -DBUILD_JAVA=off -DBUILD_C_GLIB=off -DBUILD_PYTHON=off -DBUILD_CPP=on -DBUILD_HASKELL=off -DBUILD_TUTORIALS=off -DFLEX_EXECUTABLE=${FLEX_EXECUTABLE} -DBISON_EXECUTABLE=${BISON_EXECUTABLE}
)
message(STATUS "Build ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} --build . --target INSTALL --config Release
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME build-${TARGET_TRIPLET}-rel
)
message(STATUS "Build ${TARGET_TRIPLET}-rel done")

message(STATUS "Build ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} --build . --target INSTALL --config Debug
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME build-${TARGET_TRIPLET}-dbg
)
message(STATUS "Build ${TARGET_TRIPLET}-dbg done")
