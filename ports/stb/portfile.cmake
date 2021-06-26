vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nothings/stb
    REF 80c8f6af0304588b9d780a41015472013b705194 # accessed on 2021-06-24
    SHA512 0a1d8ad6b606a0904fce29855693a6fed6de1979272edf5bcb9837904dff79abaaf8f1ef9606cd5933396daa56c0851e6c1e3fc24547ab91accc7a1f17ace9f4
    HEAD_REF master
)

# create a header file for stb_vorbis
file(READ "${SOURCE_PATH}/stb_vorbis.c" stb_vorbis)
#   find beginning and length of header
string(FIND "${stb_vorbis}" "//  HEADER BEGINS HERE" stb_vorbis_header_begin)
string(FIND "${stb_vorbis}" "//  HEADER ENDS HERE" stb_vorbis_header_end)
math(EXPR stb_vorbis_header_length "${stb_vorbis_header_end} - ${stb_vorbis_header_begin}")
#   create a substring for the header
string(SUBSTRING "${stb_vorbis}" "${stb_vorbis_header_begin}" "${stb_vorbis_header_length}" stb_vorbis_header)
#   create a string for the source
string(SUBSTRING "${stb_vorbis}" "0" "${stb_vorbis_header_begin}" stb_vorbis_source_before)
string(SUBSTRING "${stb_vorbis}" "${stb_vorbis_header_end}" "-1" stb_vorbis_source_after)
string(CONCAT stb_vorbis_source "${stb_vorbis_source_before}" "#include \"stb_vorbis.h\"\n" "${stb_vorbis_source_after}")
#   write source to file, replacing the original source file
file(WRITE "${SOURCE_PATH}/stb_vorbis.c" "${stb_vorbis_source}")
#   prepend export macro
string(PREPEND stb_vorbis_header [[
#ifdef _WIN32
    #ifdef STB_VORBIS_EXPORTS
        #define STB_VORBIS __declspec(dllexport)
    #else
        #define STB_VORBIS __declspec(dllimport)
    #endif
#else
    #define STB_VORBIS
#endif
]])
#   replace all instances of 'extern' beyond 'extern "C"' with 'STB_VORBIS extern'
#     split string into before 'extern "C"' and after 'extern "C"'
string(FIND "${stb_vorbis_header}" "extern \"C\"" extern_c_pos)
math(EXPR after_extern_c_pos "${extern_c_pos} + 10")
string(SUBSTRING "${stb_vorbis_header}" "0" "${after_extern_c_pos}" before_extern_c)
string(SUBSTRING "${stb_vorbis_header}" "${after_extern_c_pos}" "-1" after_extern_c)
#     replace
string(REPLACE "extern" "STB_VORBIS extern" after_extern_c_modified "${after_extern_c}")
#     concatenate
string(CONCAT stb_vorbis_header_modified "${before_extern_c}" "${after_extern_c_modified}")
#   write header to file
file(WRITE "${SOURCE_PATH}/stb_vorbis.h" "${stb_vorbis_header_modified}")
# configure
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
# install
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindStb.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
