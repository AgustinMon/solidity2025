# solidity2025 - MODULO 2 -

## Descripción de lo que hace el contrato. 
Ejercicio del módulo 2 del curso de Solidity
Se crea un kipu-bank en el que se pueden estudiar las transacciones de ingreso, salida y consulta de balance.  
Se pueden agregar tokens, retirar total o parcialmente la cantidad depositada.  

## Instrucciones de despliegue.
1. Se desplegará en Sepolia.
2. Subir código a Remix.
3. Conectar billetera Metamask para pagar el costo de la publicación en la red Sepolia.
4. Compilar código. En este caso se compila con la versión **0.8.30 + commit.73712a01**
5. Una vez compilado se obtendrá la dirección del contrato. En este caso es: 0xfe4D43639a338D046C98d2452B71EeC7A3696837
6. Para verificar el contrato hay que dirigirse a la web de sepolia https://sepolia.etherscan.io/verifyContract?a=0xfe4D43639a338D046C98d2452B71EeC7A3696837
    - Buscar en el buscador de contratos el nuestro.
    - Dirigirse a Contract y pegar el codigo del contrato y contestar las preguntas de verificación (versión de compilación, Type: Solidity Single File, tipo de licencia, aceptar términos y condiciones)
    - Pegar el ABI que se ha descargado.
    - En la siguiente página hay que pegar el código del contrato exactamente como estaba redactado y elegir la versión del EVM con la que se compiló (en nuestro caso Cancun).
    - Si todos los datos son correctos, el contrato quedará verificado con una tilde y aparecerá el Contract ABI en la página de confirmación.

## Cómo interactuar con el contrato.
**Se crearon varias funciones para interactuar con el contrato, algunas exclusivas del owner y otras no.**
### Funciones exclusivas del owner:
Estas funciones se crearon para agregar seguridad al contrato aunque podría discutirse si es o no apropiado para cualquier caso.
   - función **withdrawAll**: Permite al owner del contrsto retirar el monto total en el balance de una dirección.
   - functión **withdrawPartialFromOwner**: permite al owner retirar una cantidad concreta de un contrato de terceros. 

### Funciones públicas para interactuar:
   - función **addAmount**, agrega el valor enviado al contrato siempre que éste sea mayor a 0.01 ETH.  
   - función **withdrawPartial**: permite especificar el monto a retirar.  
   - función **getBalance**: permite obtener el balance de una dirección determinada (la propia).  
   - función **getTotalAllocated**: permite obtener el monto total del banco (a efectos de transparencia pública).  

### Funciones privadas:
   - función **_removeBalance**: Creada para separar trabajos.

## Contrato:
https://sepolia.etherscan.io/address/0xfe4d43639a338d046c98d2452b71eec7a3696837

