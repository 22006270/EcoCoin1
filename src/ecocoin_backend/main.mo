import Array "mo:base/Array";
import Nat "mo:base/Nat";

actor EcoCoin {
    // Definimos una estructura para un usuario de EcoCoin
    type Usuario = {
        id: Nat;
        nombre: Text;
        wallet: Text;
        email: ?Text;
        puntos: Nat;
    };

    // Estructura para un centro de acopio
    type CentroAcopio = {
        id: Nat;
        nombre: Text;
        ubicacion: Text;
        materiales: [Text]; // Lista de materiales que se aceptan
    };

    // Estructura para un material reciclable
    type Material = {
        id: Nat;
        tipo: Text;
        puntosPorKilo: Nat; // Puntos otorgados por cada kilo reciclado
    };

    // Almacenamiento de usuarios, centros de acopio y materiales reciclables
    var usuarios: [Usuario] = [];
    var centrosAcopio: [CentroAcopio] = [];
    var materiales: [Material] = [];
    
    // Función para registrar un nuevo usuario, puedes elegir wallet o correo electrónico
    public func registrarUsuario(nombre: Text, wallet: ?Text, email: ?Text) : async Text {
        let walletSeleccionada = switch wallet {
            case (?w) w;
            case null "MetaMask"; // Valor predeterminado para wallet
        };
        
        let nuevoUsuario = {
            id = usuarios.size() + 1;
            nombre = nombre;
            wallet = walletSeleccionada;
            email = email;
            puntos = 0;
        };
        usuarios := Array.append<Usuario>(usuarios, [nuevoUsuario]);
        return "Usuario registrado exitosamente con wallet " # walletSeleccionada;
    };

    // Función para buscar un centro de acopio por tipo de material reciclable
    public func buscarCentroAcopio(material: Text) : async [CentroAcopio] {
        return Array.filter<CentroAcopio>(centrosAcopio, func (centro) {
            Array.find<Text>(centro.materiales, func (m) { m == material }) != null
        });
    };

    // Función para obtener el menú de materiales reciclables
    public func obtenerMenuMateriales() : async [Material] {
        return materiales;
    };

    // Función para agregar un nuevo tipo de material reciclable
    public func agregarMaterial(tipo: Text, puntosPorKilo: Nat) : async Text {
        let nuevoMaterial = {
            id = materiales.size() + 1;
            tipo = tipo;
            puntosPorKilo = puntosPorKilo;
        };
        materiales := Array.append<Material>(materiales, [nuevoMaterial]);
        return "Material agregado exitosamente: " # tipo;
    };

    // Función auxiliar para encontrar el índice de un usuario
    func encontrarIndiceUsuario(id: Nat, usuarios: [Usuario]) : ?Nat { 
        var i: Nat = 0;
        for (usuario in usuarios.vals()) {
            if (usuario.id == id) {
                return ?i;
            };
            i += 1;
        };
        return null;
    };

    // Función para registrar una acción de reciclaje y recompensar puntos
    public func registrarReciclaje(usuarioId: Nat, materialId: Nat, cantidadKilos: Nat) : async Text {
        let usuarioOpt = Array.find<Usuario>(usuarios, func (u) { u.id == usuarioId });
        let materialOpt = Array.find<Material>(materiales, func (m) { m.id == materialId });

        switch (usuarioOpt, materialOpt) {
            case (?usuario, ?material) {
                let puntosGanados = material.puntosPorKilo * cantidadKilos;
                let indexOpt = encontrarIndiceUsuario(usuarioId, usuarios);
                
                switch (indexOpt) {
                    case (?i) {
                        let usuarioActualizado = {
                            id = usuario.id;
                            nombre = usuario.nombre;
                            wallet = usuario.wallet;
                            email = usuario.email;
                            puntos = usuario.puntos + puntosGanados;
                        };
                        usuarios := Array.tabulate<Usuario>(usuarios.size(), func(j) {
                            if (j == i) { usuarioActualizado } else { usuarios[j] }
                        });
                        return "Reciclaje registrado, puntos añadidos: " # Nat.toText(puntosGanados) # " a " # usuario.nombre;
                    };
                    case null {
                        return "No se encontró el índice del usuario.";
                    };
                };
            };
            case (_, null) {
                return "Material no encontrado.";
            };
            case (null, _) {
                return "Usuario no encontrado.";
            };
        };
    };
}