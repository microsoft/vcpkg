import logging
from logging import StreamHandler
import sys
import os

# #### LOGGER, MOVED FROM CONF BECAUSE OF MULTIPLE PROBLEM WITH CIRCULAR INCLUDES #####
CONAN_LOGGING_LEVEL = int(os.getenv('CONAN_LOGGING_LEVEL', logging.DEBUG))
CONAN_LOGGING_FILE = os.getenv('CONAN_LOGGING_FILE', None)  # None is stdout


class MultiLineFormatter(logging.Formatter):
    def format(self, record):
        str_ = logging.Formatter.format(self, record)
        separator = record.message if record.message else None
        if separator is None:
            return separator
        tmp = str_.split(separator)
        if len(tmp) == 2:
            header, _ = tmp
        else:
            header = tmp
#        num = len(header)
        num = 0
        str_ = str_.replace('\n', '\n' + ' ' * num)
        return str_


logger = logging.getLogger('conans')
if CONAN_LOGGING_FILE is not None:
    hdlr = logging.FileHandler(CONAN_LOGGING_FILE)
else:
    hdlr = StreamHandler(sys.stderr)

formatter = MultiLineFormatter('\n######################################################### \n\n%(levelname)s: '
                               '%(message)s \n\n#########################################################\n')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(CONAN_LOGGING_LEVEL)


#CRITICAL = 50
#FATAL = CRITICAL
#ERROR = 40
#WARNING = 30
#WARN = WARNING
#INFO = 20
#DEBUG = 10
#NOTSET = 0
