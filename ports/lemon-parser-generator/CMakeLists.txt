project(lemon-parser-generator C)
add_executable(lemon lemon.c)
install(TARGETS lemon
    RUNTIME DESTINATION tools/lemon
)
