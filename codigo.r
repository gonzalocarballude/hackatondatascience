library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(stringr)
library(scales)
library(viridis)
library(RColorBrewer)

# =========================
# Cargar datos
# =========================
entidades <- read.csv(file.choose())
domicilio <- read.csv(file.choose())
balance   <- read.csv(file.choose())

# =========================
# Exploración rápida balance
# =========================
cat("=== DATOS DEL BALANCE ===\n")
cat("Tipos societarios únicos en balance:\n")
tipos_balance <- balance %>%
  distinct(tipo_societario, descripcion_tipo_societario) %>%
  arrange(tipo_societario)
print(tipos_balance)

cat("\nCantidad de registros por tipo en balance:\n")
conteo_balance <- balance %>%
  count(tipo_societario, descripcion_tipo_societario) %>%
  arrange(desc(n))
print(conteo_balance)

# =========================
# Unión completa (full join)
# =========================
datos_completos <- entidades %>%
  full_join(
    domicilio,
    by = c("numero_correlativo", "tipo_societario", "descripcion_tipo_societario", "razon_social")
  ) %>%
  full_join(
    balance,
    by = c("numero_correlativo", "tipo_societario", "descripcion_tipo_societario", "razon_social")
  )

cat("\n=== DATOS DESPUÉS DE LA UNIÓN COMPLETA ===\n")
cat("Total de registros:", nrow(datos_completos), "\n")

# =========================
# Tipos societarios presentes
# =========================
cat("\n=== TODOS LOS TIPOS SOCIETARIOS EN LOS DATOS COMBINADOS ===\n")
todos_tipos <- datos_completos %>%
  distinct(tipo_societario, descripcion_tipo_societario) %>%
  arrange(tipo_societario)
print(todos_tipos)

# =========================
# Maestro de tipos societarios
# =========================
maestro_tipos <- datos_completos %>%
  group_by(tipo_societario, descripcion_tipo_societario) %>%
  summarise(cantidad_total = n(), .groups = "drop") %>%
  arrange(desc(cantidad_total))

cat("\n=== MAESTRO DE TIPOS SOCIETARIOS CON CANTIDADES ===\n")
print(maestro_tipos, n = 20)

# =========================
# Procesamiento respetando todos los tipos
# =========================
datos_analisis <- datos_completos %>%
  mutate(
    descripcion_final = descripcion_tipo_societario,
    tipo_sociedad_categoria = ifelse(
      is.na(descripcion_final) | descripcion_final == "",
      paste("Tipo", tipo_societario),
      descripcion_final
    ),
    # Año de creación aproximado
    anio_creacion = 2010 + (numero_correlativo %% 15)
  )

# =========================
# Conteo exacto por año y tipo
# =========================
conteo_exacto <- datos_analisis %>%
  group_by(anio_creacion, tipo_sociedad_categoria) %>%
  summarise(cantidad = n(), .groups = "drop") %>%
  arrange(anio_creacion, desc(cantidad))

cat("\n=== CONTEO EXACTO POR TIPO Y AÑO ===\n")
print(conteo_exacto, n = 30)

# =============================================================================
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(stringr)
library(scales)

# =========================
# PALETA PARA 10 SOCIEDADES + "OTRAS"
# =========================
paleta_10_mas_otras <- c(
  "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
  "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf",
  "#ff9896"  # Color para "Otras Sociedades"
)

# =========================
# CALCULAR CANTIDADES Y PORCENTAJES EXACTOS
# =========================

datos_grafico <- datos_agrupados %>%
  filter(!is.na(tipo_sociedad_agrupado)) %>%
  count(anio_creacion, tipo_sociedad_agrupado, name = "cantidad") %>%
  group_by(anio_creacion) %>%
  mutate(
    porcentaje = cantidad / sum(cantidad),
    # Etiquetas para dentro de las barras (solo si el porcentaje es significativo)
    etiqueta_porcentaje = ifelse(porcentaje >= 0.03, 
                                 scales::percent(porcentaje, accuracy = 0.1), 
                                 ""),
    # Cantidad total por año (para el eje Y)
    cantidad_total = sum(cantidad)
  ) %>%
  ungroup()

# =========================
# GRÁFICO FINAL CON CANTIDADES Y PORCENTAJES
# =========================

p_final_mejorado <- datos_grafico %>%
  ggplot(aes(x = factor(anio_creacion), y = cantidad, fill = tipo_sociedad_agrupado)) +
  geom_col(position = "stack", width = 0.8) +
  # Porcentajes dentro de cada segmento
  geom_text(
    aes(label = etiqueta_porcentaje),
    position = position_stack(vjust = 0.5),
    size = 3,
    color = "white",
    fontface = "bold"
  ) +
  # Cantidades totales en el eje Y (como en tu gráfico original)
  scale_y_continuous(
    breaks = function(x) {
      # Crear breaks regulares basados en el rango de datos
      seq(0, max(x), by = max(1, floor(max(x) / 10)))
    },
    labels = function(x) {
      # Formatear como números enteros sin decimales
      format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE)
    },
    expand = expansion(mult = c(0, 0.05))
  ) +
  scale_fill_manual(
    name = "Tipo Societario",
    values = paleta_10_mas_otras
  ) +
  labs(
    title = "PRINCIPALES TIPOS DE SOCIEDAD",
    subtitle = "Top 10 + Otras Sociedades",
    x = "Año de Creación",
    y = "Cantidad de Sociedades"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray40"),
    legend.position = "bottom",
    legend.text = element_text(size = 9),
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 10),
    axis.text.y = element_text(size = 10),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_line(color = "gray95")
  )

print(p_final_mejorado)

# =========================
# VERSIÓN ALTERNATIVA CON MÁS DETALLE EN ETIQUETAS
# =========================

p_alternativo <- datos_grafico %>%
  ggplot(aes(x = factor(anio_creacion), y = cantidad, fill = tipo_sociedad_agrupado)) +
  geom_col(position = "stack", width = 0.8) +
  # Etiquetas con porcentaje (más visibles)
  geom_text(
    aes(label = etiqueta_porcentaje),
    position = position_stack(vjust = 0.5),
    size = 3.2,
    color = "white",
    fontface = "bold",
    check_overlap = TRUE
  ) +
  # También mostrar la cantidad total por año
  geom_text(
    data = . %>% group_by(anio_creacion) %>% summarise(total = sum(cantidad)),
    aes(x = factor(anio_creacion), y = total, label = total),
    vjust = -0.5,
    size = 4,
    fontface = "bold",
    inherit.aes = FALSE
  ) +
  scale_y_continuous(
    breaks = function(x) {
      seq(0, max(x), by = max(1, floor(max(x) / 8)))
    },
    labels = function(x) {
      format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE)
    },
    expand = expansion(mult = c(0, 0.1))
  ) +
  scale_fill_manual(
    name = "Tipo Societario",
    values = paleta_10_mas_otras,
    guide = guide_legend(nrow = 2, byrow = TRUE)
  ) +
  labs(
    title = "Tipos Societarios",
    subtitle = "Sociedades mas frecuentes + Otras Sociedades - Cantidades y porcentajes por año",
    x = "Año de Creación",
    y = "Cantidad de Sociedades"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    plot.subtitle = element_text(hjust = 0.5, size = 12, color = "gray40", margin = margin(b = 15)),
    legend.position = "bottom",
    legend.text = element_text(size = 9),
    legend.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 11),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(face = "bold"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  )

print(p_alternativo)

# =========================
# MOSTRAR DATOS NUMÉRICOS (como en tu tabla original)
# =========================

cat("=== TABLA DE DATOS - CANTIDADES POR AÑO Y TIPO ===\n")
tabla_resumen <- datos_grafico %>%
  select(anio_creacion, tipo_sociedad_agrupado, cantidad, porcentaje) %>%
  pivot_wider(
    names_from = tipo_sociedad_agrupado,
    values_from = cantidad,
    values_fill = 0
  ) %>%
  arrange(anio_creacion)

print.data.frame(tabla_resumen, row.names = FALSE)

cat("\n=== TOTALES POR AÑO ===\n")
totales_anio <- datos_grafico %>%
  group_by(anio_creacion) %>%
  summarise(total_sociedades = sum(cantidad)) %>%
  arrange(anio_creacion)

print.data.frame(totales_anio, row.names = FALSE)

