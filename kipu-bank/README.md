# solidity2025 - MODULO 2 -

**Descripción de lo que hace el contrato.**  
Ejercicio del módulo 2 del curso de Solidity
Se crea un kipu-bank en el que se pueden estudiar las transacciones de ingreso, salida y consulta de balance.  
Se pueden agregar tokens, retirar total o parcialmente la cantidad depositada.  
Cuando el balance queda en 0, se elimina la cuenta del depositante.  

**Instrucciones de despliegue.**  
Subir contrato a Remix y desplegar  
El contrato está plublicado también en: https://...  

**Cómo interactuar con el contrato.**  
    functiones externas:  
    - funcion pay, agrega el valor enviado al contrato siempre que éste sea mayor a 0.01 ETH.  
    - funcion withrady: retira el monto total en el balance de una dirección.  
    - funcion withdrawParcial: permite especificar el monto a retirar.  
    - funcion getBalance: permite obtener el balance de una dirección determinada (la propia).  
    - funcion getTotalAllocated: permite obtener el monto total del banco (a efectos de transparencia pública).  


## primera version del contrato:
https://sepolia.etherscan.io/address/0xa888f7d220196b0a05afc94496821ec65cc18b72#code

