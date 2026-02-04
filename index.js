console.log("Hello World");

/**
 * Soma dois números
 * @param {number} a - Primeiro número
 * @param {number} b - Segundo número
 * @returns {number} A soma de a e b
 */
function sum(a, b) {
  return a + b;
}

/**
 * Subtrai dois números
 * @param {number} a - Primeiro número
 * @param {number} b - Segundo número
 * @returns {number} A subtração de b de a
 */
function subtract(a, b) {
  return a - b;
}

console.log(sum(1, 2));
console.log(subtract(1, 2));

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  return a / b;
}

console.log(multiply(1, 2));
console.log(divide(1, 2));

function power(a, b) {
  return Math.pow(a, b);
}

console.log(power(2, 3));

function squareRoot(a) {
  return Math.sqrt(a);
}

console.log(squareRoot(4));

function cubeRoot(a) {
  return Math.cbrt(a);
}

console.log(cubeRoot(8));
