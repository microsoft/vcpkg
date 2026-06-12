include_guard(GLOBAL)

set(output_path "${DOWNLOADS}/tools")
find_program(ISPC_EXECUTABLE NAMES ispc PATHS "${output_path}/ispc-${version}")
if(NOT ISPC_EXECUTABLE)
  set(ispc_ver "@VERSION@")
  set(file_suffix ".tar.gz")
  if(VCPKG_TARGET_IS_WINDOWS)
      set(archive_suffix "-windows")
      set(file_suffix ".zip")
      set(download_sha512 97d5d7bba9933f2bcda7374c738ff8a48371487df1720b803767cc9f6fffeaf06424f713360356e7ba57ca7766a1caefe01133a5657cde59ab0bde0e35988409)
  elseif(VCPKG_TARGET_IS_OSX)
      set(archive_suffix "-macOS")
      set(download_sha512 44abfd63b4e05bd80f67adfa9051a61815abe58aaa96277d8a54fe9e05788d54a4a6c4b02ee129245fe66a52a35e4a904a629cda5a6d9474e663ba3262b96d6c)
  elseif(VCPKG_TARGET_IS_LINUX)
      set(archive_suffix "-linux")
      set(ispc_ver "1.18.1")
      set(download_sha512 704fdda0a3a944da043d9f26b5e71c1a9175bfa915654debf2426ba5482f69a3cc39d11a62515c2c958551d1da6c8d7d6b23bf4608ba7e337e8b57a9e5c81ce7)
  endif()

  set(subfolder_name "ispc-v${ispc_ver}${archive_suffix}")
  set(download_filename "${subfolder_name}${file_suffix}")
  set(download_urls "https://github.com/ispc/ispc/releases/download/v${ispc_ver}/${download_filename}")

  vcpkg_download_distfile(archive_path
      URLS ${download_urls}
      SHA512 "${download_sha512}"
      FILENAME "${download_filename}"
  )

  file(MAKE_DIRECTORY "${output_path}")
  message(STATUS "Extracting ispc ...")
  vcpkg_extract_source_archive(src_path 
                               ARCHIVE "${archive_path}"
                                )
  file(RENAME "${src_path}/" "${output_path}/ispc-${ispc_ver}/")
  message(STATUS "Extracting ispc ... finished!")
  set(ISPC_EXECUTABLE "${output_path}/ispc-${ispc_ver}/ispc${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()
