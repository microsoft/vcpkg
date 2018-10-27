#ifndef CONFIG_H
#define CONFIG_H

#cmakedefine HAVE_ARPA_INET_H
#cmakedefine HAVE_BYTESWAP_H
#cmakedefine HAVE_ERRNO_H
#cmakedefine HAVE_FCNTL_H
#cmakedefine HAVE_LIMITS_H
#cmakedefine HAVE_LINUX_SERIAL_H
#cmakedefine HAVE_NETDB_H
#cmakedefine HAVE_NETINET_IN_H
#cmakedefine HAVE_NETINET_TCP_H
#cmakedefine HAVE_SYS_IOCTL_H
#cmakedefine HAVE_SYS_PARAMS_H
#cmakedefine HAVE_SYS_SOCKET_H
#cmakedefine HAVE_SYS_TIME_H
#cmakedefine HAVE_SYS_TYPES_H
#cmakedefine HAVE_TERMIOS_H
#cmakedefine HAVE_TIME_H
#cmakedefine HAVE_UNISTD_H

#cmakedefine HAVE_ACCEPT4
#cmakedefine HAVE_FORK
#cmakedefine HAVE_GETADDRINFO
#cmakedefine HAVE_GETTIMEOFDAY
#cmakedefine HAVE_INET_NTOA
#cmakedefine HAVE_MALLOC
#cmakedefine HAVE_MEMSET
#cmakedefine HAVE_SELECT
#cmakedefine HAVE_SOCKET
#cmakedefine HAVE_STRERROR
#cmakedefine HAVE_STRLCPY

#cmakedefine HAVE_TIOCRS485
#cmakedefine HAVE_TIOCM_RTS

#ifdef HAVE_TIOCM_RTS
#define HAVE_DECL_TIOCM_RTS 1
#else
#define HAVE_DECL_TIOCM_RTS 0
#endif

#ifdef HAVE_TIOCRS485
#define HAVE_DECL_TIOCSRS485 1
#else
#define HAVE_DECL_TIOCSRS485 0
#endif

#endif