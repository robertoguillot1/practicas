//TIP To <b>Run</b> code, press <shortcut actionId="Run"/> or
// click the <icon src="AllIcons.Actions.Execute"/> icon in the gutter.
fun main() {
    println("¿Cuántas veces quiere modificar el valor a la variable?")
    val n = readLine()?.toIntOrNull() ?: 0

    var texto: String = ""

    for (i in 0..n) {
        texto = "iteración número $i"
        println("variable texto = \"$texto\" (esta es la iteración $i)")
    }

    println("\nLa variable ha sido modificada ${n + 1} veces y ahora tiene un valor de: \"$texto\"")
    print("Gracias por todo Att: Roberto Guillot")
}
