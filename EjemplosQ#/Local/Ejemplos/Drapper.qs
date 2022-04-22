namespace QDrapper {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;


    // Operación que inicializa un registro de qubits a un valor entero (BigEndian).
    // Supone que todos los qubits se encuentran a 0 inicialmente.
    operation initOperator(op: Qubit[], value: Int): Unit {
        
        let N = Length(op);

        for i in 0 .. N {
            
            if ((value >>> N - i - 1) &&& 0x1) == 1 {
                X(op[i]);      
            }
        }
    }
    
    // Definmos nuestra propia QFT, ya que la que viene en la librería estándar es distinta.
    // https://github.com/microsoft/QuantumLibraries/blob/987a2670e852ae77965b4b0b6873d2c5d3bcac69/Standard/src/Canon/QFT.qs
    operation MyQFT(qubits: Qubit[]): Unit is Adj + Ctl {

        let N = Length(qubits);

        for i in 0 .. N-1 {
            
            H(qubits[i]);
            for j in i+1 .. N-1 {
                
                let angle = PI() * PowD(0.5, IntAsDouble(j - i));
                Controlled Rz([qubits[j]], (angle, qubits[i]));   
            }
        }
    }

    // Operación que aplica la parte intermedia del sumador de Drapper.
    operation Adder(op1: Qubit[], op2: Qubit[]): Unit {

        let N = Length(op1);
        let N2 = Length(op2);
        
        // Lanzamos excepción si len(op1) != len(op2)
        Fact(N == N2, "Los registros de qubits son de tamaños distintos");
        
        for i in 0 .. N - 1 {
            for j in i .. N - 1 {
                
                let angle = PI() * PowD(0.5, IntAsDouble(j - i));
                Controlled Rz([op2[j]], (angle, op1[i]));   
            }
        }          
    }

    // Devuelve la suma de dos operandos de opSize qubits.
    operation QDrapper(a: Int, b: Int, opSize: Int): Int {

        use op1 = Qubit[opSize];
        use op2 = Qubit[opSize];

        
        initOperator(op1, a);
        initOperator(op2, b);

        // Se aplica la QFT a op1.
        MyQFT(op1);

        // Se aplice la parte intermedia del sumador.
        Adder(op1, op2);

        // Se aplica la QFT inversa a op1.
        Adjoint MyQFT(op1);
        
        // Medimos op1 para obtener el resultado. (Hay que darle la vuelta al orden de los qubits)
        let resul = MeasureInteger(BigEndianAsLittleEndian(BigEndian(op1)));
 
        ResetAll(op1);
        ResetAll(op2);
        return resul;
    }


    // @EntryPoint()
    operation Main(opsize: Int, a: Int, b: Int): Unit {

        Fact (opsize >= BitSizeI(a), "El tamaño de operando no es suficiente para representar a.");
        Fact (opsize >= BitSizeI(b), "El tamaño de operando no es suficiente para representar b.");

        Message($"Se va a sumar {a} + {b} con operandos de {opsize} qubtis.");

        let resultado = QDrapper(a, b, opsize);
        Message($"Resultado: {resultado}.");     
    }
}