import math
import numpy as np
import matplotlib.pyplot as plt

N = 4
K = 8
om = list(range(0, K))
i = 0
Xs = [0] * K
kom = [0] * N
k = [0] * N

for x in om:
    print('uh')
x = x / (K * 2 * math.pi)

while (i < K - 1):
    print('ae')
    Xs[i] = 1 - 0.5 * math.cos(om[i]) + 1.5 * 1j * math.sin(om[i])
    i += 1

ampXS = np.absolute(Xs)
phaseXS = np.angle(Xs)
realXS = np.real(Xs)
imagXS = np.imag(Xs)

k = list(range(0, N))


xD = [1, -1, np.zeros(N - 3), 0.5]

XDdft = np.fft.fft(xD, N)


ampXD = np.absolute(XDdft)
phaseXD = np.angle(XDdft)
realXD = np.real(XDdft)
imagXD = np.imag(XDdft)

i=0
while (i < N):
    kom[i] = k[i] * 2 * math.pi / N
    i += 1

plt.figure()
plt.stem(range(0, N), xD)
plt.figure()
plt.subplot(211)
plt.plot(om, ampXS, '-', kom, ampXD, 'o')
plt.ylabel('Amplitude')
plt.subplot(212)
plt.plot(om, phaseXS, '-', kom, phaseXD, 'o')
plt.ylabel('Faze')
plt.show()
plt.figure()
plt.subplot(211)
plt.plot(om, realXS, '-', kom, realXD, 'o')
plt.ylabel('"-" Re{X(w)}, "o" Re{X(k)}')
plt.subplot(212), \
plt.plot(om, imagXS, '-', kom, imagXD, 'o')
plt.ylabel('"-" Im{X(w)}, "o" Im{X(k)}')
plt.show()