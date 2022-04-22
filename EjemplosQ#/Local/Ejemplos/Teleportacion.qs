namespace Qtp {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    operation bellPair(q0: Qubit, q1: Qubit) : Unit {

        H(q0);
        CNOT(q0, q1);
    }

    operation Alice(bit: Bool, q0: Qubit, bell_alice: Qubit) : Unit {

        // Qubit que se quiere enviar.
        if (bit) {
            X(q0);
        }

        CNOT(q0, bell_alice);
    }

    operation Bob(bell_bob: Qubit, bell_alice: Qubit, qAlice: Qubit): Unit {
        
        CNOT(bell_alice, bell_bob);
        CZ(qAlice, bell_bob);
    }

    // @EntryPoint()
    operation Main(): Unit {
        
        use qubits = Qubit[3];
     
        let bitAlice = true;
        Message($"Alice quire enviar: {bitAlice}");
        
        // Creamos el par de bell.
        bellPair(qubits[1], qubits[2]);

        // Alice aplica su parte y le envia los bits a Bob.
        Alice(bitAlice, qubits[0], qubits[1]);

        // Bob decodifica el mensaje de Alice.
        Bob(qubits[2], qubits[1], qubits[0]);

        // Medimos el resultado para comprobar si funciona.
        let resul = M(qubits[2]);
        Message("------------------------");
        Message($"Bob recibe: {resul}");

        ResetAll(qubits);
    }
}