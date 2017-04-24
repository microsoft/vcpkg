function(vcpkg_acquire_msys PATH_TO_ROOT_OUT)
  set(TOOLPATH ${DOWNLOADS}/tools/msys2)
  if (TRIPLET_SYSTEM_ARCH MATCHES "x64")
    set(TOOLSUBPATH msys64)
    set(URL "https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20161025.tar.xz/download")
    set(ARCHIVE "msys2-base-x86_64-20161025.tar.xz")
    set(HASH 6c4c18ec59db80b8269698d074866438a624f1ce735ee5005a01b148b02e8f2e966ae381aa1cb4c50f6226c3b7feb271e36907cf26580df084d695b3c9f5c0eb)
  else()
    set(TOOLSUBPATH msys32)
    set(URL "https://sourceforge.net/projects/msys2/files/Base/i686/msys2-base-i686-20161025.tar.xz/download")
    set(ARCHIVE "msys2-base-i686-20161025.tar.xz")
    set(HASH c9260a38e0c6bf963adeaea098c4e376449c1dd0afe07480741d6583a1ac4c138951ccb0c5388bd148e04255a5c1a23bf5ee2d58dcd6607c14f1eaa5639a7c85)
  endif()

  set(PATH_TO_ROOT ${TOOLPATH}/${TOOLSUBPATH})

  if(NOT EXISTS "${TOOLPATH}/initialized-msys2.stamp")
    message(STATUS "Acquiring MSYS2...")
    file(DOWNLOAD ${URL} ${DOWNLOADS}/${ARCHIVE}
      EXPECTED_HASH SHA512=${HASH}
    )
    file(REMOVE_RECURSE ${TOOLPATH})
    file(MAKE_DIRECTORY ${TOOLPATH})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${DOWNLOADS}/${ARCHIVE}
      WORKING_DIRECTORY ${TOOLPATH}
    )
    execute_process(
      COMMAND ${PATH_TO_ROOT}/usr/bin/bash.exe --noprofile --norc -c "PATH=/usr/bin:\$PATH;pacman-key --init;pacman-key --populate"
      WORKING_DIRECTORY ${TOOLPATH}
    )
    file(WRITE "${TOOLPATH}/initialized-msys2.stamp" "0")
    message(STATUS "Acquiring MSYS2... OK")
  endif()

  set(${PATH_TO_ROOT_OUT} ${PATH_TO_ROOT} PARENT_SCOPE)
endfunction()
