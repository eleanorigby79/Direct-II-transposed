import math
import array as array
import numpy as np
import matplotlib.pyplot as plt

P=L=N=10
m = 1

n = np.array(range(0, L))
k = np.array(range(0, N))

x = [math.cos(2 * math.pi * ( m / P ) * i) for i in k]

xDFT = np.fft.fft(x, N)

ampXD = np.absolute(xDFT)
phaseXD = np.angle(xDFT)
realXD = np.real(xDFT)
imagXD = np.imag(xDFT)

plt.figure()
plt.stem(n,x)
plt.show()

plt.figure()
plt.subplot(211)
plt.stem(n, ampXD)
plt.ylabel('Amplituda')
plt.subplot(212)
plt.stem(n,phaseXD)
plt.ylabel('Faza')
plt.show()

plt.figure()
plt.subplot(211)
plt.stem(n, realXD)
plt.ylabel('Realni dio')
plt.subplot(212), \
plt.stem(n, imagXD)
plt.ylabel('Imaginarni dio')
plt.show()