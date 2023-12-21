import numpy as np
import sys, getopt
from struct import *
from toqito.random import random_unitary

def main(argv):
  iDir=""
  oDir=""
  qList = []
  mList = []
  opts, args = getopt.getopt(argv,"q:o:i:m:",["iDir=","oDir="])
  for opt, arg in opts:
    if "-q" in opt:
      qList = arg.split(sep=" ", maxsplit=-1)
      qList = [eval(i) for i in qList]
    elif "-m" in opt:
      mList = arg.split(sep=" ", maxsplit=-1)
      mList = [eval(i) for i in mList]
    elif "-i"in opt:
      iDir = arg
    elif "-o"in opt:
      oDir = arg
  if not iDir.endswith('/'):
    iDir+="/"
  if not oDir.endswith('/'):
    oDir+="/"
  for testNum in range(len(qList)):

    N = 1<<qList[testNum]
    M = mList[testNum]
    a = [np.complex128(random_unitary(N)) for i in range(M)]
    # a = [np.complex128(random_unitary(N, True)) for i in range(M)]

    b = np.complex128(random_unitary([N,1]))
    # b = np.complex128(random_unitary(N, True))
    c = np.copy(b)
    cc = np.copy(b)

    for j in range(M):
      a[j] = a[j].reshape(N,N)

    for j in range (M):
      c = np.matmul(a[j],c,dtype='complex128' )

    v = np.copy(cc)
    for i in range (M):
      for j in range (N):
        v[j] = 0.0
        for k in range (N):
          v[j] = np.add(v[j],np.multiply(a[i][j][k],cc[k],dtype='complex128'),dtype='complex128')
      cc = np.copy(v)


    def float_to_hex(f):
          return hex(unpack('<I', pack('<f', f))[0])

    def double_to_hex(f):
          return hex(unpack('<Q', pack('<d', f))[0])


    a_address = 0x00000000
    b_address = 0x00000000
    c_address = 0x00000000

    c=np.copy(cc)
    aStr = "";
    for i,A in enumerate(a) :
      for j,v in enumerate(A.flatten()):
        aStr+="// {:.7f} {:.7f}j\n".format(v.real.item(), v.imag.item())
        aStr+=" @{:08X} ".format(a_address+i*N*N+j) + double_to_hex(v.real.item()).replace('0x','') + double_to_hex(v.imag.item()).replace('0x','') + "\n"
    with open(iDir+"test" + str(testNum+1) + "_A.dat","w") as F:
      F.write(aStr)

    bStr = "// Q: {}, M: {}\n".format(qList[testNum],mList[testNum])
    bStr += " @{:08X} ".format(0) + "{:016X}".format(qList[testNum])+ "{:016X} \n".format(mList[testNum])
    for j,v in enumerate(b):
      bStr+="// {:.7f} {:.7f}j\n".format(v.real.item(), v.imag.item())
      bStr+=" @{:08X} ".format(b_address+j+1) + double_to_hex(v.real.item()).replace('0x','') + double_to_hex(v.imag.item()).replace('0x','') + "\n"
    with open(iDir+"test" + str(testNum+1) + "_B.dat","w") as F:
      F.write(bStr)

    cStr = ""
    for j,v in enumerate(c):
      cStr+="// {:.7f} {:.7f}j\n".format(v.real.item(), v.imag.item())
      cStr+=" @{:08X} ".format(c_address+j) + double_to_hex(v.real.item()).replace('0x','') + double_to_hex(v.imag.item()).replace('0x','') + "\n"
    with open(oDir+"test" + str(testNum+1) + "_C.dat","w") as F:
      F.write(cStr)



if __name__ == "__main__":
     main(sys.argv[1:])
