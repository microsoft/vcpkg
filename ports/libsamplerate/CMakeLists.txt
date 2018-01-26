add_library(libsamplerate-0
    samplerate.c
    src_sinc.c
    src_zoh.c
    src_linear.c
    ../Win32/libsamplerate-0.def
)

install(TARGETS libsamplerate-0
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

install(FILES samplerate.h DESTINATION include)
