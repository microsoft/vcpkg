# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

INCLUDE(vcpkg_common_functions)
SET(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/prometheus-cpp)
VCPKG_FROM_GITHUB(OUT_SOURCE_PATH SOURCE_PATH
                  REPO jupp0r/prometheus-cpp
                  REF v0.6.0
                  SHA512 a7e6f902f3007007ec68add5ac63e833c6f383ed0ce103e238b7248497f495e664446df7801000e36021adcb7cfb1d461bbb45e1b4fba9ffa4edfcaf5b5957dd
                  )

VCPKG_DOWNLOAD_DISTFILE(GTEST_ARCHIVE
                        URLS "https://github.com/google/googletest/archive/release-1.8.1.tar.gz"
                        FILENAME "release-1.8.1.tar.gz"
                        SHA512 e6283c667558e1fd6e49fa96e52af0e415a3c8037afe1d28b7ff1ec4c2ef8f49beb70a9327b7fc77eb4052a58c4ccad8b5260ec90e4bceeac7a46ff59c4369d7
                        )
VCPKG_EXTRACT_SOURCE_ARCHIVE(${GTEST_ARCHIVE} ${SOURCE_PATH}/3rdparty/)

if(EXISTS ${SOURCE_PATH}/3rdparty/googletest-release-1.8.1)
    FILE(RENAME ${SOURCE_PATH}/3rdparty/googletest-release-1.8.1 ${SOURCE_PATH}/3rdparty/googletest)
endif()

VCPKG_DOWNLOAD_DISTFILE(CIVETWEB_ARCHIVE
                        URLS "https://github.com/civetweb/civetweb/archive/v1.11.tar.gz"
                        FILENAME "v1.11.tar.gz"
                        SHA512 e1520fd2f4a54b6ab4838f4da2ce3f0956e9884059467d196078935a3fce61dad619f3bb1bc2b4c6a757e1a8abfed0e83cba38957c7c52fff235676e9dd1d428
                        )
VCPKG_EXTRACT_SOURCE_ARCHIVE(${CIVETWEB_ARCHIVE} ${SOURCE_PATH}/3rdparty/)
if(EXISTS ${SOURCE_PATH}/3rdparty/civetweb-1.11)
    FILE(RENAME ${SOURCE_PATH}/3rdparty/civetweb-1.11 ${SOURCE_PATH}/3rdparty/civetweb)
endif()

VCPKG_CONFIGURE_CMAKE(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
        -DENABLE_TESTING=OFF
        -DCMAKE_INSTALL_CMAKEDIR:STRING=share/prometheus-cpp
)

VCPKG_INSTALL_CMAKE()

VCPKG_FIXUP_CMAKE_TARGETS(CONFIG_PATH lib/cmake)

FILE(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

FILE(COPY
     ${SOURCE_PATH}/README.md
     ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/prometheus-cpp
     )
FILE(RENAME ${CURRENT_PACKAGES_DIR}/share/prometheus-cpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/prometheus-cpp/copyright)
