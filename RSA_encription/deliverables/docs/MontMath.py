# A Montgomery Math Implementation
# 
# get bitstring first
# http://code.google.com/p/python-bitstring/downloads/list
#
# copyright by Dung Le
#

bits = 128
print "bits =", bits
from bitstring import BitArray, BitStream

def MontProd(A,B,M):
    S = 0
    i = 0
    b = BitArray(uint=B,length=bits)
    while i < bits:
        q = (S + int(b[bits - 1 - i])*A) % 2       
        S = ( S + q*M + int(b[bits - 1 - i])*A ) / 2
        i = i + 1
    if S >= M :
        return S - M
    else :       
        return S

def MontExp(X,E,M):
    Nr = (1 << (2*bits))% M
    print "Nr=", Nr
    Z = MontProd(1,Nr,M)    
    P = MontProd(X,Nr,M)
    i = 0
    e = BitArray(uint=E,length=bits)
    while i < bits:        
        if (int(e[bits - 1 - i]) == 1):
            Z = MontProd(Z,P,M)
        P = MontProd(P, P, M)
        i = i + 1
    Z = MontProd(1,Z,M)
    return Z

# auxiliary "mod" for testing, obsoleted with Montgomery math 
def mod(y,x):
    p = x
    while( p < y ):
        p = p << 1;                
    while( p >= x ):
        if y >= p:
            y = y - p;
            print y
        p = p >> 1;        
    return y

#==================================== TEST ==================================
#// 32 bit exponents 11, 390350291, M = d1073602561
##x = 868359270
##print "msg=", hex(x)
##
##e = 390350291
##m = 1073602561
##x = MontExp(x,e,m)
##print "encript=", hex(x)
##
##e = 11
##m = 1073602561
##x = MontExp(x,e,m)
##print "encript=", hex(x)


# 128bit key.
#public ( 17, 20769187434139322034329832130609147 )
#private ( 18325753618358223281893785584271353, 20769187434139322034329832130609147 )

#print hex(mod((1 << (2*bits)),20769187434139322034329832130609147))

x = 0xc0de
print "msg=", hex(x)

e = 17
m = 20769187434139322034329832130609147
x = MontExp(x,e,m)
print "encript=", hex(x)

e = 18325753618358223281893785584271353
m = 20769187434139322034329832130609147
x = MontExp(x,e,m)
print "encript=", hex(x)


# 64bit
#public ( 5, 288230439905132863 )
#private ( 172938262574058869, 288230439905132863 )

##x = 983
##print "msg=", hex(x)
##
##e = 172938262574058869
##m = 288230439905132863
##x = MontExp(x,e,m)
##print "encript=", hex(x)
##
##e = 5
##m = 288230439905132863
##x = MontExp(x,e,m)
##print "decript=", hex(x)

###print x**e % m

