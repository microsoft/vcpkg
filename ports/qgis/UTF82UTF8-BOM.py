# coding=utf-8
import sys
import os
import chardet

## useage: this.py dir_you_want_to_walk
def addBOM(path):
        f = open(path, 'rb');
        content = f.read()
        f.close()
        detect = chardet.detect(content)
        encoding = detect['encoding'];
        confidence = detect['confidence']
        if( encoding is None ):
                print(path + " encoding: %s" % encoding + " confidence: %f" % confidence)
                return

        encoding = encoding.lower();        
        # print(path + " encoding: %s" % encoding + " confidence: %f" % confidence)        
        
        if(confidence<0.5 or encoding=='utf-8-sig'):return
        encoding = 'utf-8';
        utf8content = content.decode(encoding, 'ignore')
        f = open(path, 'w', encoding='utf-8-sig',newline='')
        f.write(utf8content)
        f.close()
        print(path + " from " + encoding + " to utf-8-sig")
        
def excuteBOM(path):
        if( os.path.isfile(path) ):
                addBOM(path)
        else:
                exts = ['.h', '.c', '.cpp'];
                for root, dirs, files in os.walk(path):
                        for name in files:
                                bTargetFile = False;
                                for e in exts:
                                        if(name.endswith(e)):
                                                bTargetFile = True;
                                if(bTargetFile):
                                        addBOM(os.path.join(root,name))

if __name__ == '__main__':
	targets = []
	excuteBOM(sys.argv[1])
