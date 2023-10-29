# README Bash Scripts

Esta carpeta es la que contiene los scripts de bash que se usan para el ETL de la información de ecobicis de la CDMX, 2023. Contiene 2 scripts: `download.sh` y `stats.sh`. El primero se encarga de descargar los datos de la página web de ecobici y el segundo de generar las estadísticas descriptivas de los datos descargados.

## Como Usar

### Docker

Para correr los scripts de bash se necesita tener instalado docker. Para instalar la imagen de docker que contiene los scripts de bash se debe correr el siguiente comando:

```bash
docker build -t ecobici .
```

Una vez instalada la imagen de docker, se inicia una sesión interactiva
    
```bash
docker run -it ecobici bash
```

### Descargar Datos

Para descargar los datos se debe correr el siguiente comando dentro de la sesión interactiva de docker:

```bash
cxmod +x src/bash/download.sh # Se da permiso de ejecución al script
src/bash/download.sh # Se corre el script
```

### Generar Estadísticas

Una vez descargados los datos, se debe correr el siguiente comando dentro de la sesión interactiva de docker:

```bash
cxmod +x src/bash/stats.sh # Se da permiso de ejecución al script
src/bash/stats.sh # Se corre el script
```
