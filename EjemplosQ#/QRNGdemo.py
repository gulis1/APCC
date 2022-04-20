import qsharp
from Qrng import GetRandomInteger

for i in range(5):
    print(f"Numero aleatorio: {i}", GetRandomInteger.simulate(max=100))