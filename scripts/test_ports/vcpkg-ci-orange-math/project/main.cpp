#if defined(__has_include)
    #if __has_include(<omath/omath.hpp>)
		#include <omath/omath.hpp>
	#else
		#include <omath/Vector2.hpp>
	#endif
#else
    #include <omath/Vector2.hpp>
#endif

int main()
{
	omath::Vector2 w = omath::Vector2(20.0, 30.0);
	return 0;
}
