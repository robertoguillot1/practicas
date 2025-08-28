fun main() {
    println("¿Cuántos elementos desea agregar a la lista?")
    val n = readLine()?.toIntOrNull() ?: 0

    val lista = mutableListOf<String>()


    for (i in 0 until n) {
        println("Ingrese el elemento número $i:")
        val elemento = readLine() ?: ""
        lista.add(elemento)
    }


    println("\n--- Lista de elementos para el profe Bryan J. Otero Arrieta ---")
    for (i in lista.indices) {
        println("Elemento \"${lista[i]}\", ubicado en la posición $i")
    }
}
