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
    set(HASH 6e14e5580e52da5d35f29b67a52ef9db0e021af1575b4bbd84ebdbf18580522287890bdc21c0d21ddc1b2529d888f8e159dcaa017a3ff06d8fd23d16901bcc8b)
  elseif(VAR MATCHES "NASM")
    set(PROGNAME nasm)
    set(PATHS ${DOWNLOADS}/tools/nasm/nasm-2.11.08)
    set(URL "http://www.nasm.us/pub/nasm/releasebuilds/2.11.08/win32/nasm-2.11.08-win32.zip")
    set(ARCHIVE "nasm-2.11.08-win32.zip")
    set(HASH cd80b540530d3995d15dc636e97673f1d34f471baadf1dac993165232c61efefe7f8ec10625f8f718fc89f0dd3dcb6a4595e0cf40c5fd7cbac1b71672b644d2d)
  elseif(VAR MATCHES "YASM")
    set(PROGNAME yasm)
    set(PATHS ${DOWNLOADS}/tools/yasm)
    set(URL "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win32.exe")
    set(ARCHIVE "yasm.exe")
    set(NOEXTRACT ON)
    set(HASH 850b26be5bbbdaeaf45ac39dd27f69f1a85e600c35afbd16b9f621396b3c7a19863ea3ff316b025b578fce0a8280eef2203306a2b3e46ee1389abb65313fb720)
  elseif(VAR MATCHES "PYTHON3")
    set(PROGNAME python)
    set(PATHS ${DOWNLOADS}/tools/python)
    set(URL "https://www.python.org/ftp/python/3.5.2/python-3.5.2-embed-amd64.zip")
    set(ARCHIVE "python-3.5.2-embed-amd64.zip")
    set(HASH 48bdcb6f94c993acad6782ee33ad4a07a0ea3b9b1bfcdeadf446d459a9224336837e2e7b518d54d8d99c5c3f4e9f8877ea1789cae513fa2eda2a3cad9e4dfd8f)
  elseif(VAR MATCHES "PYTHON2")
    find_program(PYTHON2 NAMES python2 python PATHS C:/python27 ENV PYTHON)
    if(NOT PYTHON2 MATCHES "NOTFOUND")
        execute_process(
            COMMAND ${PYTHON2} --version
            OUTPUT_VARIABLE PYTHON_VER_CHECK_OUT
            ERROR_VARIABLE PYTHON_VER_CHECK_ERR
        )
        set(PYTHON_VER_CHECK "${PYTHON_VER_CHECK_OUT}${PYTHON_VER_CHECK_ERR}")
        debug_message("PYTHON_VER_CHECK=${PYTHON_VER_CHECK}")
        if(NOT PYTHON_VER_CHECK MATCHES "Python 2.7")
            set(PYTHON2 PYTHON2-NOTFOUND)
            find_program(PYTHON2 NAMES python2 python PATHS C:/python27 ENV PYTHON NO_SYSTEM_ENVIRONMENT_PATH)
        endif()
    endif()
    if(PYTHON2 MATCHES "NOTFOUND")
        message(FATAL_ERROR "Python 2.7 was not found in the path or by searching inside C:\\Python27.\n"
        "There is no portable redistributable for Python 2.7, so you will need to install the MSI located at:\n"
        "    https://www.python.org/ftp/python/2.7.11/python-2.7.11.amd64.msi\n"
        )
    endif()
  elseif(VAR MATCHES "JOM")
    set(PROGNAME jom)
    set(PATHS ${DOWNLOADS}/tools/jom)
    set(URL "http://download.qt.io/official_releases/jom/jom_1_1_1.zip")
    set(ARCHIVE "jom_1_1_1.zip")
    set(HASH 23a26dc7e29979bec5dcd3bfcabf76397b93ace64f5d46f2254d6420158bac5eff1c1a8454e3427e7a2fe2c233c5f2cffc87b376772399e12e40b51be2c065f4)
  elseif(VAR MATCHES "7Z")
    set(PROGNAME 7z)
    set(PATHS ${DOWNLOADS}/tools/7z/Files/7-Zip)
    set(URL "http://7-zip.org/a/7z1604.msi")
    set(ARCHIVE "7z1604.msi")
    set(HASH 556f95f7566fe23704d136239e4cf5e2a26f939ab43b44145c91b70d031a088d553e5c21301f1242a2295dcde3143b356211f0108c68e65eef8572407618326d)
  else()
    message(FATAL "unknown tool ${VAR} -- unable to acquire.")
  endif()

  find_program(${VAR} ${PROGNAME} PATHS ${PATHS})
  if(${VAR} MATCHES "-NOTFOUND")
    file(DOWNLOAD ${URL} ${DOWNLOADS}/${ARCHIVE}
      EXPECTED_HASH SHA512=${HASH}
      SHOW_PROGRESS
    )
    file(MAKE_DIRECTORY ${DOWNLOADS}/tools/${PROGNAME})
    if(DEFINED NOEXTRACT)
      file(COPY ${DOWNLOADS}/${ARCHIVE} DESTINATION ${DOWNLOADS}/tools/${PROGNAME})
    else()
      get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} EXT)
      string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
      if(${ARCHIVE_EXTENSION} STREQUAL ".msi")
        file(TO_NATIVE_PATH "${DOWNLOADS}/${ARCHIVE}" ARCHIVE_NATIVE_PATH)
        file(TO_NATIVE_PATH "${DOWNLOADS}/tools/${PROGNAME}" DESTINATION_NATIVE_PATH)
        execute_process(
          COMMAND msiexec /a ${ARCHIVE_NATIVE_PATH} /qn TARGETDIR=${DESTINATION_NATIVE_PATH}
          WORKING_DIRECTORY ${DOWNLOADS}
        )
      else()
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E tar xzf ${DOWNLOADS}/${ARCHIVE}
          WORKING_DIRECTORY ${DOWNLOADS}/tools/${PROGNAME}
        )
      endif()
    endif()

    find_program(${VAR} ${PROGNAME} PATHS ${PATHS})
  endif()

  set(${VAR} ${${VAR}} PARENT_SCOPE)
endfunction()
