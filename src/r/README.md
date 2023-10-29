# README R Script

Este script es el encargado de generar las estadísticas descriptivas de los datos descargados por el script de bash `download.sh`. El script se divide en 2 partes: cinco preguntas del profesor y 5 preguntas propias.

## Como Usar

**Primero se debe correr los scripts de bash para descargar los datos.**

Siempre se debe mantener el `working directory` en la carpeta raíz del proyecto. El cual se puede cambiar con el siguiente comando:

```bash
cd ~/hw
```

### RENV

Para correr el script se necesita tener instalado R y RENV. Para instalar RENV se debe correr el siguiente comando:

```r
install.packages("renv")
```

Una vez instalado RENV, se debe correr el siguiente comando para instalar los paquetes necesarios para correr el script:

```r
renv::restore()
```

### Correr Script

Para correr el script se debe correr el siguiente comando:

```r
Rscript src/r/eda.r
```

O bien, se puede correr el script desde RStudio para poder ver los gráficos que genera el script.