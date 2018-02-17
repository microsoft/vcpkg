include(vcpkg_common_functions)

set(LIBUSB_REVISION fc9962027f2c4f22f2c5e7853d737ef89aa5b6a3)
set(LIBUSB_HASH f8485b68feb7759ef4b469fa2fae10b93794bdb2c69d48aacd4a6fb87d7597779e06a15e8d9a72fe223a2f08c861c6f5023c4f6e869f13a8c4c92091fb38780e)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libusb)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb
    REF ${LIBUSB_REVISION}
    SHA512 ${LIBUSB_HASH}
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/libfreenect2.patch"
)

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

if(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
  set(MSVS_VERSION 2017)
else()
  set(MSVS_VERSION 2015)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(LIBUSB_LIBFOLDER_NAME dll)
    set(LIBUSB_PROJECT_TYPE dll)
else()
    set(LIBUSB_LIBFOLDER_NAME lib)
    set(LIBUSB_PROJECT_TYPE static)
endif()

vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj
    )

vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/msvc/libusb_usbdk_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj
    )
   
   
file(
    INSTALL
        ${SOURCE_PATH}/${MSBUILD_PLATFORM}/Debug/${LIBUSB_LIBFOLDER_NAME}/libusb-1.0.lib
        ${SOURCE_PATH}/${MSBUILD_PLATFORM}/Debug/${LIBUSB_LIBFOLDER_NAME}/libusb-usbdk-1.0.lib
    DESTINATION 
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(
    INSTALL
        ${SOURCE_PATH}/${MSBUILD_PLATFORM}/Release/${LIBUSB_LIBFOLDER_NAME}/libusb-1.0.lib
        ${SOURCE_PATH}/${MSBUILD_PLATFORM}/Release/${LIBUSB_LIBFOLDER_NAME}/libusb-usbdk-1.0.lib
    DESTINATION 
        ${CURRENT_PACKAGES_DIR}/lib
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(
        INSTALL
            ${SOURCE_PATH}/${MSBUILD_PLATFORM}/Debug/${LIBUSB_LIBFOLDER_NAME}/libusb-1.0.dll
            ${SOURCE_PATH}/${MSBUILD_PLATFORM}/Debug/${LIBUSB_LIBFOLDER_NAME}/libusb-usbdk-1.0.dll
        DESTINATION 
            ${CURRENT_PACKAGES_DIR}/debug/bin
    )

    file(
        INSTALL
            ${SOURCE_PATH}/${MSBUILD_PLATFORM}/Release/${LIBUSB_LIBFOLDER_NAME}/libusb-1.0.dll
            ${SOURCE_PATH}/${MSBUILD_PLATFORM}/Release/${LIBUSB_LIBFOLDER_NAME}/libusb-usbdk-1.0.dll
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/bin
    )
endif()

vcpkg_copy_pdbs()

file(INSTALL
    ${SOURCE_PATH}/libusb/libusb.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/libusb-1.0
)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libusb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libusb/COPYING ${CURRENT_PACKAGES_DIR}/share/libusb/copyright)
