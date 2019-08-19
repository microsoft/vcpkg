# coding=utf-8
import sys
import os
import re

## useage: this.py dir_you_want_to_walk
def changeFile(path):
        f = open(path, 'r');
        alllines=f.readlines()
        f.close()
        f = open(path, 'w+', encoding='utf-8');
        for eachline in alllines:
                a=re.sub('#import site','import site',eachline)
                f.writelines(a)
        f.close()
        
def excuteChange(path):
        if( os.path.isfile(path) ):
                changeFile(path)
        else:
                exts = ['._pth'];
                for root, dirs, files in os.walk(path):
                        for name in files:
                                bTargetFile = False;
                                for e in exts:
                                        if(name.endswith(e)):
                                                bTargetFile = True;
                                if(bTargetFile):
                                        changeFile(os.path.join(root,name))

if __name__ == '__main__':
	targets = []
	excuteChange(sys.argv[1])
