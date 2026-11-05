#include <glaze/ext/glaze_asio.hpp>

int main()
{
    asio::io_context context;
    return context.stopped() ? 0 : 1;
}
