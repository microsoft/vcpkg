#include <string>
#include <uwebsockets/App.h>

int main()
{
    uWS::App().get("/hello", [](auto *res, auto *req) {
        res->end("Hello World!");
    });
    return 0;
}
