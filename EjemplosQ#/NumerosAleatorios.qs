// Idea de: https://docs.microsoft.com/en-us/azure/quantum/tutorial-qdk-quantum-random-number-generator?tabs=tabid-qsharp

namespace Qrng {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;

    operation GetRandomInteger(max : Int) : Int {
        
        use qubits = Qubit[BitSizeI(max)];
        mutable resul = 0; 

        repeat {
            
            ApplyToEach(H, qubits);
            set resul = MeasureInteger(LittleEndian(qubits));
            ResetAll(qubits);

        } until (resul <= max);
        
        return resul;
    }
}