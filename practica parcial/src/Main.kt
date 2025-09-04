data class producto(
    var nombre: String,
    var marca: String,
    var presentacion: String,
    var cantidad: Int = 1,
    var precioUnitario: Double,
) {
    val precioTotal: Double
        get() = precioUnitario * cantidad

    fun mostrarInfo() {
        println("------------------------------------------")
        println("--Producto: $nombre")
        println("--Marca: $marca")
        println("--Presentación: $presentacion")
        println("--Cantidad: $cantidad")
        println("--Precio Unitario: $precioUnitario")
        println("--Precio Total: $precioTotal")
        println("-------------------------------------------")
    }
}
fun main() {
    var producto1 = producto(
        "Zucaritas","Cereal","Caja",5,5000.0)
    val producto2 = producto(
        nombre = "Leche",
        marca = "Alpina",
        presentacion = "Envasado",
        precioUnitario = 2000.0
    )
    val producto3 = producto(
        nombre = "Atún",
        marca = "Van Camps",
        presentacion = "Enlatado",
        precioUnitario = 3500.0
    )
    producto1.mostrarInfo()
    producto2.mostrarInfo()
    producto3.mostrarInfo()
}


