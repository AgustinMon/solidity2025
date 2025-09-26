pragma solidity >=0.8.0;

contraccto todolist{

    enum State {
        "sinHacer",
        "completado"
    }

    struct Tarea {
        /*descripcion y tiempo de ejecucion */
        string description;
        uint256 creationTime;
        State state;
    }

    Tarea[] private s_tareas;
    uint256 private nextIndex;
    enum private status{
        "eliminada",
        "agregada",
        "modificada"
    }

    event TaskAdded(uint256 indexed id, string indexed description, uint256 creationTime, enum State);
    event TaskStatusChanged(uint256 indexed id, string indexed description, enum status, enum State);

    function setTarea(string calldata _description) external {
        uint256 _lastIndex = nextIndex++; //no usar dos veces la de afuera (ahorro), ademas ++ incrementa a posterior ahorrando volver a llamarla (gas)
        tarea.push(_description, block.timestamp, _lastIndex);
        //++_lastIndex; //++ adelante ahorra mas gas que atras
        //lastIndex = _lastIndex; ahorro con linea 22
        emit TaskAdded(_lastIndex, _description, block.timestamp, State.sinHacer);//llamado a block.timestamp mas barato que variable time
    }

    function getTareas() external view returns(Tarea[] memory){
        return tarea;
    }

    function eliminarTarea(string calldata _description) external {
        
        uint256 len = tarea.length;
        for (uint256 i; i<len; i++){
            //comparar hashes, no se puede comparar strings
            if (keccak256(bytes(tarea[i].description)) == keccak256(bytes(_description))) {
                //si i==len-1, hago pop directamente + emit
                emit TaskStatusChanged(tarea[i].index, tarea[i].description, status.eliminado);
                tarea[i] = tarea[len-1];//sobreescribir con la ultima
                tarea.pop(); //elimninar la ultima
                break;
            }
            unchecked {
                ++i;
            }
        }
    }

}