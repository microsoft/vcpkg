#include <stdio.h>
#include <podofo/podofo.h>

int main()
{
    PoDoFo::PdfMemDocument document;
    auto font = document.GetFonts().SearchFont("Arial");
    return 0;
}
