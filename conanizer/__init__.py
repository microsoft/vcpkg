import os
import logging
from os import getenv

VCPKG_ROOT_FOLDER = getenv("VCPKG_ROOT_FOLDER", os.path.abspath("."))

logger = logging.getLogger('conanizer')
ch = logging.StreamHandler()
ch.setLevel(logging.ERROR)
logger.addHandler(ch)