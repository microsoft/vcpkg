function(vcpkg_find_acquire_program VAR)
  if(${VAR} AND NOT ${VAR} MATCHES "-NOTFOUND")
    return()
  endif()

  unset(NOEXTRACT)

  if(VAR MATCHES "PERL")
    set(PROGNAME perl)
    set(PATHS ${DOWNLOADS}/tools/perl/perl/bin)
    set(URL "http://strawberryperl.com/download/5.20.2.1/strawberry-perl-5.20.2.1-64bit-portable.zip")
    set(ARCHIVE "strawberry-perl-5.20.2.1-64bit-portable.zip")
    set(HASH 5fca4b3cfa7c9cc95e0c4fd8652eba80)
  elseif(VAR MATCHES "NASM")
    set(PROGNAME nasm)
    set(PATHS ${DOWNLOADS}/tools/nasm/nasm-2.11.08)
    set(URL "http://www.nasm.us/pub/nasm/releasebuilds/2.11.08/win32/nasm-2.11.08-win32.zip")
    set(ARCHIVE "nasm-2.11.08-win32.zip")
    set(HASH 46a31e22be69637f7a9ccba12874133f)
  elseif(VAR MATCHES "YASM")
    set(PROGNAME yasm)
    set(PATHS ${DOWNLOADS}/tools/yasm)
    set(URL "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win32.exe")
    set(ARCHIVE "yasm.exe")
    set(NOEXTRACT ON)
    set(HASH 51e967dceddd1f84e67bff255df977b3)
  else()
    message(FATAL "unknown tool ${VAR} -- unable to acquire.")
  endif()

  find_program(${VAR} ${PROGNAME} PATHS ${PATHS})
  if(${VAR} MATCHES "-NOTFOUND")
    file(DOWNLOAD ${URL} ${DOWNLOADS}/${ARCHIVE}
      EXPECTED_MD5 ${HASH}
      SHOW_PROGRESS
    )
    file(MAKE_DIRECTORY ${DOWNLOADS}/tools/${PROGNAME})
    if(DEFINED NOEXTRACT)
      file(COPY ${DOWNLOADS}/${ARCHIVE} DESTINATION ${DOWNLOADS}/tools/${PROGNAME})
    else()
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf ${DOWNLOADS}/${ARCHIVE}
        WORKING_DIRECTORY ${DOWNLOADS}/tools/${PROGNAME}
      )
    endif()

    find_program(${VAR} ${PROGNAME} PATHS ${PATHS})
  endif()

  set(${VAR} ${${VAR}} PARENT_SCOPE)
endfunction()
