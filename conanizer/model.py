import os


class Port(object):
    
    def __init__(self, name, port_dir):
        self.name = name
        self.port_dir = port_dir
        self._control = None
    
    def process(port):
        pass
    
    @property
    def control(self):
        if not self._control:
            self._control = {}
            with open(os.path.join(self.port_dir, "CONTROL"), "r") as handle:
                content = handle.read()
                for line in content.splitlines():
                    try:
                        key, value = line.split(":")[0:2]
                        self._control[key.lower()] = value.strip()
                    except Exception:
                        pass
        return self._control
    
    @property
    def version(self):
        tmp = self.control["version"]
        if len(tmp.split(".")) == 2:
            return "%s.0" % tmp
        return tmp
     
    @property
    def source(self):
        return self.control["source"]           