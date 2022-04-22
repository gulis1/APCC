namespace QGrover {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Diagnostics;    
    
    // Aplica un oráculo para el algoritmo de Grover.
    // Usa un qubit auxiliar inicializado a 0, y lo pone a 1 si qubits == target.
    operation ApplyOracle(qubits: Qubit[], fOut: Qubit, target: Int): Unit {
        
        let bit_repr = IntAsBoolArray(target, Length(qubits));
        
        for (pos, bit) in Enumerated(bit_repr) {         
            if (not bit) { X(qubits[pos]); }
        }

        Controlled X(qubits, fOut);   

        for (pos, bit) in Enumerated(bit_repr) {         
            if (not bit) { X(qubits[pos]); }
        }  
    }

    // Operador de reflexión para el algoritmo de Grover.
    operation Reflection(qubits: Qubit[]): Unit {
        
        let N = Length(qubits);

        ApplyToEachA(X, qubits);
        Controlled Z(qubits[1..N-1], qubits[0]);   
        ApplyToEachA(X, qubits); 

        ApplyToEachA(H, qubits); 
    }

    // Operación que realiza una iteración del algoritmo de Grover.
    operation GroverIter(qubits: Qubit[], target: Int): Unit {

        use qExtra = Qubit();

        // Ponemos el qubit auxiliar en el estado -
        X(qExtra);
        H(qExtra);

        // Se aplica el oráculo.
        ApplyOracle(qubits, qExtra, target);

        // Se aplica una Hadamard a todos los qubits y el operador de reflexión.
        ApplyToEachA(H, qubits);
        Reflection(qubits);

        Reset(qExtra);
    }

    // Algoritmo de Grover de nQubits.
    // Va a realizar intentos de PI * √N / 4 iteraciones hasta 
    // encontrar el resultado correcto. (Normalmente uno es suficiente).
    operation Grover(nQubits: Int, target: Int): Result[] {

        Fact (nQubits >= BitSizeI(target), $"{nQubits} qubits no son suficientes para target = {target}.");

        use qubits = Qubit[nQubits];        
        
        // Aplicamos puerta hadamard a todas los qubits.
        ApplyToEachA(H, qubits);

        let N = PowD(2.0, IntAsDouble(nQubits));
        let nIters = Floor(PI() * Sqrt(N) / 4.0);  

        mutable res = 0;
        mutable tries = 1;

        Message($"Empezando intento {tries}: {nIters} iteraciones.");               
        for i in 1 .. nIters {
            GroverIter(qubits, target);      
        }
        Message($"Completado intento {tries}.");

        return Reversed(MultiM(qubits));
    }

    // @EntryPoint()
    operation RandomNumberGenerator(nqubits: Int, x: Int) : Result[] {
        
        return Grover(nqubits, x);
    }
}