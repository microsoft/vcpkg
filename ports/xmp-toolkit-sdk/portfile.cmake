vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adobe/XMP-Toolkit-SDK
    REF "v${VERSION}"
    SHA512 1ab987cdf50fdd0d28e2d0f97dba3cf30fe23dd1ff700d39bdf1fda7c3ae6ce1aa71806dbd77cec84ffcd7672a0a4545007c9dbcac99c83d17b4c1aa7d6b31fb
    PATCHES
        prepare-for-getting-zlib-and-expat-from-vcpkg.patch
)

set(pdf_handler_mini_pdfl_dir "windows")
set(pdf_handler_resource_dir "win")

# The XMPFilesPlugins folder provides the support code and resources you need to build handlers for custom file formats.
set(plugin_sdk_directory "${CURRENT_PACKAGES_DIR}/src/${PORT}/plugin-sdk")
file(MAKE_DIRECTORY "${plugin_sdk_directory}/XMPFilesPlugins/PDF_Handler/resource")
file(COPY "${SOURCE_PATH}/XMPFilesPlugins/api" DESTINATION "${plugin_sdk_directory}/XMPFilesPlugins")
file(COPY "${SOURCE_PATH}/XMPFilesPlugins/PluginTemplate" DESTINATION "${plugin_sdk_directory}/XMPFilesPlugins")
file(COPY "${SOURCE_PATH}/XMPFilesPlugins/PDF_Handler/resource/${pdf_handler_resource_dir}" DESTINATION "${plugin_sdk_directory}/XMPFilesPlugins/PDF_Handler/resource")
file(COPY "${SOURCE_PATH}/XMPFilesPlugins/PDF_Handler/${pdf_handler_mini_pdfl_dir}" DESTINATION "${plugin_sdk_directory}/XMPFilesPlugins/PDF_Handler")
file(COPY "${SOURCE_PATH}/source" DESTINATION "${plugin_sdk_directory}")
file(COPY "${SOURCE_PATH}/public" DESTINATION "${plugin_sdk_directory}")

if("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x64")
    set(arch_64_bit "ON")
    set(lib_path "${SOURCE_PATH}/public/libraries/windows_x64")    
else()
    set(arch_64_bit "OFF")
    set(lib_path "${SOURCE_PATH}/public/libraries/windows")
endif()

if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    set(build_static "On")
    if("${VCPKG_CRT_LINKAGE}" STREQUAL "static")
        set(expat_debug_lib "libexpatdMT.lib")
        set(expat_release_lib "libexpatMT.lib")
    else()
        set(expat_debug_lib "libexpatdMD.lib")
        set(expat_release_lib "libexpatMD.lib")
    endif()
else()
    set(build_static "Off")
    set(expat_debug_lib "libexpatd.lib")
    set(expat_release_lib "libexpat.lib")
endif()

# Redirect build to use expat library from vcpkg
configure_file(${CURRENT_PORT_DIR}/expat.h ${SOURCE_PATH}/third-party/expat/lib/expat.h @ONLY)
string(APPEND VCPKG_LINKER_FLAGS_DEBUG " ${CURRENT_INSTALLED_DIR}/${TRIPLET}/debug/lib/${expat_debug_lib} ")
string(APPEND VCPKG_LINKER_FLAGS_RELEASE " ${CURRENT_INSTALLED_DIR}/${TRIPLET}/lib/${expat_release_lib} ")

# Redirect build to use zlib library from vcpkg
configure_file(${CURRENT_PORT_DIR}/zlib.h ${SOURCE_PATH}/third-party/zlib/zlib.h @ONLY)
string(APPEND VCPKG_LINKER_FLAGS_DEBUG " ${CURRENT_INSTALLED_DIR}/${TRIPLET}/debug/lib/zlibd.lib ")
string(APPEND VCPKG_LINKER_FLAGS_RELEASE " ${CURRENT_INSTALLED_DIR}/${TRIPLET}/lib/zlib.lib ")


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/build"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DXMP_CMAKEFOLDER_NAME="msbuild"
        -DCMAKE_CL_64=${arch_64_bit}
        -DXMP_BUILD_WARNING_AS_ERROR=On 
        -DXMP_BUILD_STATIC=${build_static}
)

vcpkg_cmake_build()


file(RENAME "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/copyright")
file(COPY "${SOURCE_PATH}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(RENAME "${SOURCE_PATH}/public/include" "${SOURCE_PATH}/public/${PORT}")
file(COPY "${SOURCE_PATH}/public/${PORT}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    file(COPY "${lib_path}/Debug/XMPCoreStatic.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY "${lib_path}/Debug/XMPCoreStatic.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY "${lib_path}/Debug/XMPFilesStatic.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY "${lib_path}/Debug/XMPFilesStatic.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    file(COPY "${lib_path}/Release/XMPCoreStatic.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${lib_path}/Release/XMPCoreStatic.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${lib_path}/Release/XMPFilesStatic.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${lib_path}/Release/XMPFilesStatic.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
    file(COPY "${lib_path}/Debug/XMPCore.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY "${lib_path}/Debug/XMPCore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(COPY "${lib_path}/Debug/XMPCore.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(COPY "${lib_path}/Debug/XMPFiles.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY "${lib_path}/Debug/XMPFiles.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(COPY "${lib_path}/Debug/XMPFiles.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

    file(COPY "${lib_path}/Release/XMPCore.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${lib_path}/Release/XMPCore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY "${lib_path}/Release/XMPCore.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY "${lib_path}/Release/XMPFiles.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY "${lib_path}/Release/XMPFiles.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY "${lib_path}/Release/XMPFiles.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()