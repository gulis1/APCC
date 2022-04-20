// Idea de: https://docs.microsoft.com/en-us/azure/quantum/tutorial-qdk-quantum-random-number-generator?tabs=tabid-qsharp

namespace Qrng {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    operation RandomBit() : Result {

        use q = Qubit();
        H(q);

        return M(q);
    }

    operation GetRandomNumber(max : Int) : Int {

        mutable output = 0; 

        repeat {
            
            mutable bits = []; 
            for idxBit in 1..BitSizeI(max) {
                set bits += [RandomBit()]; 
            }

            set output = ResultArrayAsInt(bits);

        } until (output <= max);
        
        return output;
    }

    // @EntryPoint()
    operation RandomNumberGenerator() : Unit {
        
        let x = GetRandomNumber(100);
        Message($"Random number: {x}");
    }
}