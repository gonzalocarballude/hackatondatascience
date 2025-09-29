# Distribución de tipos societarios por año

Este proyecto documenta el flujo utilizado para explorar y visualizar la distribución de tipos societarios a lo largo del tiempo. El objetivo principal es generar un gráfico de barras apiladas que muestre cómo se reparten las sociedades más frecuentes por año, destacando su peso relativo frente a una categoría "Otras".

## Qué hace el script `codigo.r`
- Solicita interactivamente los archivos de entidades, domicilios y balances para poder trabajar con la información consolidada.
- Realiza un `full_join` entre las tres fuentes usando el identificador correlativo y los metadatos societarios, preservando todos los registros disponibles.
- Genera un campo `anio_creacion` (estimado a partir del correlativo) que sirve como eje temporal para el análisis.
- Calcula la cantidad de registros por combinación de año y tipo societario y obtiene el porcentaje que representa cada tipo sobre el total anual.
- Construye un gráfico de barras apiladas que resume la "distribución de tipos societarios por año", utilizando una paleta que resalta las 10 categorías más relevantes y agrupa el resto dentro de "Otras Sociedades". Cada segmento incluye la etiqueta de porcentaje siempre que sea representativa.

## Requisitos
- R (versión 4.x recomendada).
- Paquetes: `dplyr`, `tidyr`, `ggplot2`, `lubridate`, `stringr`, `scales`, `viridis`, `RColorBrewer`.

## Ejecución
1. Abrí una sesión de R y asegurate de tener instalados los paquetes listados.
2. Ejecutá `source("codigo.r")` o corré el script desde tu IDE preferido (por ejemplo, RStudio).
3. Seleccioná los tres archivos CSV cuando se abra el cuadro de diálogo `file.choose()`. Podés utilizar los datasets de ejemplo ubicados en la carpeta `datos/`.
4. Al finalizar el procesamiento verás el gráfico de distribución con las cantidades y porcentajes por año. Además, el script imprime en consola las tablas de apoyo que detallan los conteos y totales anuales.

## Datos de ejemplo
La carpeta `datos/` incluye muestras de domicilios y entidades utilizadas para probar el flujo. Podés reemplazarlas por tus propias fuentes, siempre que mantengan los campos utilizados en el script.
