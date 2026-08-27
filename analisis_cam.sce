// Requiere stixbox: atomsInstall("stixbox")

// ====================================================================
// ANÁLISIS ESTADÍSTICO EXPLORATORIO SIMPLIFICADO Y ELEGANTE
// Dataset: Estaciones Hidrometeorológicas CAM
// ====================================================================

clear; clc;

// Configuración de archivo local
archivo = "Estaciones_CAM.csv";
separador = ","; // Ajustar a ";" si tu CSV local usa punto y coma

printf("Cargando el archivo: %s...\n", archivo);

// Leemos la matriz completa como texto (debido al entrecomillado "" y la palabra "VACIO")
raw_data = csvRead(archivo, separador, [], "string");

cabeceras = raw_data(1, :);
datos = raw_data(2:$, :);

// 1. Relación Explicita de Columnas de Interés
// Se mapean directamente buscando la coincidencia exacta de texto
idx_fecha  = find(cabeceras == "fecha_hora");
idx_precip = find(cabeceras == "precipitacion_(mm)");
idx_nivel  = find(cabeceras == "nivel_agua_(m)");
idx_temp   = find(cabeceras == "temperatura_(°C)");
idx_hum    = find(cabeceras == "humedad_relativa_(%)");
idx_rad    = find(cabeceras == "radiacion_solar_(W/m2)");
idx_viento = find(cabeceras == "direccion_viento_(°)");

idx_mun    = find(cabeceras == "municipio");
idx_zona   = find(cabeceras == "zona_hidrografica");
idx_alt    = find(cabeceras == "altitud");

// 2. Función de Extracción y Conversión Numérica Limpia
// Remueve explícitamente "VACIO" y convierte a números usando la API estándar de Scilab
function valores = procesar_columna(datos_columna)
    // Reemplazamos la palabra "VACIO" por una cadena vacía para que strtod la reconozca como NaN (%nan)
    datos_columna(datos_columna == "VACIO") = "";
    valores = strtod(datos_columna);
endfunction

// 3. Extracción de Mediciones de Interés
precip  = procesar_columna(datos(:, idx_precip));
nivel   = procesar_columna(datos(:, idx_nivel));
temp    = procesar_columna(datos(:, idx_temp));
hum     = procesar_columna(datos(:, idx_hum));
rad     = procesar_columna(datos(:, idx_rad));
viento  = procesar_columna(datos(:, idx_viento));
altitud = procesar_columna(datos(:, idx_alt));

// Datos Geográficos y Temporales (Mantenidos como texto)
fecha_hora = datos(:, idx_fecha);
municipios = datos(:, idx_mun);
zonas      = datos(:, idx_zona);

// 4. Función de Reporte Descriptivo por Variable
function reportar_estadisticos(nombre_var, serie_numerica)
    // Filtramos los valores nulos (%nan) generados por los "VACIO" o celdas faltantes
    datos_validos = serie_numerica(~isnan(serie_numerica));
    
    if isempty(datos_validos) then
        printf("\n- %s: No contiene registros numéricos válidos.\n", nombre_var);
        return;
    end
    
    // Ordenamos de menor a mayor para cuartiles exactos
    datos_ordenados = gsort(datos_validos, "g", "i");
    n = size(datos_ordenados, 1);
    
    v_min    = datos_ordenados(1);
    v_max    = datos_ordenados($);
    v_mean   = mean(datos_validos);
    v_median = median(datos_validos);
    q1       = datos_ordenados(round(0.25 * n));
    q3       = datos_ordenados(round(0.75 * n));
    v_std    = stdev(datos_validos);
    
    printf("\n=== ANÁLISIS METROLÓGICO: %s ===\n", nombre_var);
    printf("  Lecturas Válidas:  %d\n", n);
    printf("  Muestras Nulas:    %d\n", size(serie_numerica, 1) - n);
    printf("  Mínimo:            %.2f\n", v_min);
    printf("  Q1 (25%%):          %.2f\n", q1);
    printf("  Mediana (50%%):     %.2f\n", v_median);
    printf("  Promedio (Media):  %.2f\n", v_mean);
    printf("  Q3 (75%%):          %.2f\n", q3);
    printf("  Máximo:            %.2f\n", v_max);
    printf("  Desv. Estándar:    %.2f\n", v_std);
endfunction

// 5. Ejecución del Análisis Estadístico
reportar_estadisticos("Precipitación (mm)", precip);
reportar_estadisticos("Nivel de Agua (m)", nivel);
reportar_estadisticos("Temperatura (C)", temp);
reportar_estadisticos("Humedad Relativa (%%)", hum);
reportar_estadisticos("Radiación Solar (W/m2)", rad);
reportar_estadisticos("Dirección de Viento (grados)", viento);
reportar_estadisticos("Altitud Estaciones (msnm)", altitud);

// 6. Resumen de Ubicación Geográfica
printf("\n=== CONTEXTO GEOGRÁFICO DE LA RED ===\n");
m_unicos = unique(municipios);
z_unicas = unique(zonas);
printf("  Total de municipios monitoreados: %d\n", size(m_unicos, 1));
printf("  Zonas hidrográficas cubiertas:    %d\n", size(z_unicas, 1));



// 7. Histogramas de las 7 variables
printf("\nGenerando histogramas de distribución...\n");
scf(1); clf();

subplot(3, 3, 1);
histplot(20, precip(~isnan(precip)), normalization=%f);
xtitle("Precipitación (mm)", "mm", "Densidad");

subplot(3, 3, 2);
histplot(20, nivel(~isnan(nivel)), normalization=%f);
xtitle("Nivel de Agua (m)", "metros", "Densidad");

subplot(3, 3, 3);
histplot(20, temp(~isnan(temp)), normalization=%f);
xtitle("Temperatura (C)", "°C", "Densidad");

subplot(3, 3, 4);
histplot(20, hum(~isnan(hum)), normalization=%f);
xtitle("Humedad Relativa (%)", "%%", "Densidad");

subplot(3, 3, 5);
histplot(20, rad(~isnan(rad)), normalization=%f);
xtitle("Radiación Solar (W/m2)", "W/m2", "Densidad");

subplot(3, 3, 6);
histplot(20, viento(~isnan(viento)), normalization=%f);
xtitle("Dirección de Viento (°)", "grados", "Densidad");

subplot(3, 3, 7);
histplot(20, altitud(~isnan(altitud)), normalization=%f);
xtitle("Altitud (msnm)", "metros", "Densidad");


// 11. Boxplots de las 7 variables con stixbox (figura aparte)
printf("Generando boxplots...\n");
scf(2); clf();

subplot(3, 3, 1);
boxplot(precip(~isnan(precip)));
xtitle("Precipitación (mm)", "", "mm");

subplot(3, 3, 2);
boxplot(nivel(~isnan(nivel)));
xtitle("Nivel de Agua (m)", "", "metros");

subplot(3, 3, 3);
boxplot(temp(~isnan(temp)));
xtitle("Temperatura (C)", "", "°C");

subplot(3, 3, 4);
boxplot(hum(~isnan(hum)));
xtitle("Humedad Relativa (%)", "", "%%");

subplot(3, 3, 5);
boxplot(rad(~isnan(rad)));
xtitle("Radiación Solar (W/m2)", "", "W/m2");

subplot(3, 3, 6);
boxplot(viento(~isnan(viento)));
xtitle("Dirección de Viento (°)", "", "grados");

subplot(3, 3, 7);
boxplot(altitud(~isnan(altitud)));
xtitle("Altitud (msnm)", "", "metros");


// ====================================================================
// 8. ANÁLISIS COMPARATIVO POR MUNICIPIO
// ====================================================================

// Estructurar variables y nombres para iteración
variables = list(precip, nivel, temp, hum, rad, viento, altitud);
nombres_vars = [
    "Precipitación (mm)", ..
    "Nivel de Agua (m)", ..
    "Temperatura (°C)", ..
    "Humedad Relativa (%)", ..
    "Radiación Solar (W/m2)", ..
    "Dirección de Viento (°)", ..
    "Altitud (msnm)"
];

m_unicos = unique(municipios);
num_muns = size(m_unicos, 1);
num_vars = length(variables);

// 8.1 Tabla Resumen Comparativa (Consola)
for v = 1:num_vars
    var_actual = variables(v);
    nombre_actual = nombres_vars(v);
    
    printf("\n====================================================================\n");
    printf("COMPARATIVA POR MUNICIPIO: %s\n", nombre_actual);
    printf("%-20s | %-8s | %-8s | %-8s | %-8s | %-8s\n", "Municipio", "N_Val", "Media", "Mediana", "Mín", "Máx");
    printf("--------------------------------------------------------------------\n");
    
    for m = 1:num_muns
        mun_nombre = m_unicos(m);
        idx_filtro = (municipios == mun_nombre);
        datos_mun = var_actual(idx_filtro);
        datos_validos = datos_mun(~isnan(datos_mun));
        
        if isempty(datos_validos) then
            printf("%-20s | %-8d | %-8s | %-8s | %-8s | %-8s\n", mun_nombre, 0, "N/A", "N/A", "N/A", "N/A");
        else
            v_mean = mean(datos_validos);
            v_med  = median(datos_validos);
            v_min  = min(datos_validos);
            v_max  = max(datos_validos);
            n_val  = size(datos_validos, 1);
            
            printf("%-20s | %-8d | %-8.2f | %-8.2f | %-8.2f | %-8.2f\n", ..
                   mun_nombre, n_val, v_mean, v_med, v_min, v_max);
        end
    end
end

// ====================================================================
// 8.2 Boxplots Comparativos por Municipio (Subplots 2x1 por Figura)
// ====================================================================
printf("\nGenerando boxplots comparativos por municipio...\n");

fig_base_num = 3; 

for v = 1:num_vars
    var_actual = variables(v);
    nom_actual = nombres_vars(v);
    
    // Asignar figuras (2 variables por ventana)
    fig_idx = fig_base_num + floor((v - 1) / 2);
    sub_idx = modulo(v - 1, 2) + 1;
    
    scf(fig_idx);
    if sub_idx == 1 then
        clf();
    end
    
    subplot(2, 1, sub_idx);
    
    // 1. Filtrar NaNs manteniendo los nombres de municipio correspondientes
    filtro_validos = ~isnan(var_actual);
    datos_limpios  = var_actual(filtro_validos);
    muns_limpios   = municipios(filtro_validos);
    
    if ~isempty(datos_limpios) then
        // 2. Ejecutar boxplot agrupado nativo de stixbox
        boxplot(datos_limpios, muns_limpios);
        xtitle(nom_actual, "Municipios", "");
        
        // 3. Ajuste estético de márgenes
        ax = gca();
        ax.margins = [0.12, 0.1, 0.15, 0.2]; // [left, right, top, bottom] para ver bien los nombres
    else
        plot(0, 0);
        xtitle(nom_actual + " (Sin Datos Válidos)", "Municipios", "");
    end
end

// ====================================================================
// 9. FILTRADO ESPECÍFICO: TEMPERATURA EN UN MUNICIPIO
// ====================================================================

target_mun = "NEIVA"; // Municipio de interés en mayúsculas

// 1. Crear máscara lógica combinando municipio y datos válidos (sin NaN)
// convstr(municipios, "u") convierte a mayúsculas para evitar errores de tipeo
mascara_mun = (convstr(municipios, "u") == target_mun) & (~isnan(temp));

// 2. Extraer vectores filtrados
temp_mun  = temp(mascara_mun);
fecha_mun = fecha_hora(mascara_mun);

// 3. Evaluar y reportar estadísticas específicas
if ~isempty(temp_mun) then
    printf("\n=======================================================\n");
    printf("   ANÁLISIS DE TEMPERATURA - MUNICIPIO: %s\n", target_mun);
    printf("=======================================================\n");
    reportar_estadisticos("Temperatura " + target_mun + " (°C)", temp_mun);
    
    // 4. Visualización Individual (Histograma y Boxplot en una ventana)
    scf(10); clf();
    
    subplot(1, 2, 1);
    histplot(15, temp_mun, normalization=%f, style=12, polygon=%t);
    xtitle("Histograma Temperaura - " + target_mun, "Temperatura (°C)", "Densidad");
    
    subplot(1, 2, 2);
    boxplot(temp_mun);
    xtitle("Boxplot Temperatura - " + target_mun, "", "Temperatura (°C)");
else
    printf("\nNo se encontraron registros válidos de temperatura para el municipio: %s\n", target_mun);
end




disp("Procesamiento completado con éxito.");