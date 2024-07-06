#include <OpenImageIO/imageio.h>

int main(int, char**)
{
    auto inp = OIIO::ImageInput::open("none");
    return inp ? 0 : 1;
}
