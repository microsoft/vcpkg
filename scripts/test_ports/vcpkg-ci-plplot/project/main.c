
#ifdef USING_CMAKE
#include <plplot/plplot.h>
#else
#include <plplot.h>
#endif

int main()
{
    PLFLT x[5], y[5];
    for (int i = 0; i < 5; i++)
    {
        x[i] = 0.25 * (PLFLT)(i);
        y[i] = 2.0 * x[i];
    }

    plinit();
    plenv(0.0, 1.0, 0.0, 2.0, 0, 0);
    pllab("x", "y", "2D line plot");
    plline(5, x, y);
    plend();

    return 0;
}
