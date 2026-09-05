// Requiere stixbox: atomsInstall("stixbox")

// ====================================================================
// ARCHIVO BASE: CARGA DE DATOS Y DEFINICIÓN DE FUNCIONES AUXILIARE
// Dataset: Estaciones Hidrometeorológicas CAM

// ====================================================================

clear; clc;

// 1. CONFIGURACIÓN INICIAL Y DEFINICIÓN DE VARIABLES DE INTERÉS
archivo   = "Estaciones_CAM.csv";
separador = ","; // Ajustar a ";" si el CSV usa punto y coma

// Definición  de variables numéricas a analizar:
// Columna CSV | Nombre para Reportes | Etiqueta Eje / Unidad
vars_config = [
    "precipitacion_(mm)"     , "Precipitación"      , "mm" ;
    "nivel_agua_(m)"         , "Nivel de Agua"      , "m" ;
    "temperatura_(°C)"       , "Temperatura"        , "°C" ;
    "humedad_relativa_(%)"   , "Humedad Relativa"   , "%" ;
    "radiacion_solar_(W/m2)" , "Radiación Solar"    , "W/m2" ;
];

col_municipio  = "municipio";
//col_fecha_hora = "fecha_hora";

// 2. FUNCIONES AUXILIARES
// PREPROCESAR DATOS
function valores = procesar_columna(datos_columna)
    datos_columna(datos_columna == "VACIO") = "";
    valores = strtod(datos_columna);
endfunction

// ESTADISTICA DESCRIPTIVA
function reportar_estadisticos(nombre_var, serie_numerica)
    datos_validos = serie_numerica(~isnan(serie_numerica));
    
    if isempty(datos_validos) then
        disp(" ");
        disp("- " + nombre_var + ": No contiene registros numéricos válidos.");
        return;
    end
    
    datos_ordenados = gsort(datos_validos, "g", "i");
    n = size(datos_ordenados, 1);
    
    v_min    = datos_ordenados(1);
    v_max    = datos_ordenados($);
    v_mean   = mean(datos_validos);
    v_median = median(datos_validos);
    q1       = datos_ordenados(round(0.25 * n));
    q3       = datos_ordenados(round(0.75 * n));
    v_std    = stdev(datos_validos);
    
    disp(" ");
    disp("=== ANÁLISIS METROLÓGICO: " + nombre_var + " ===");
    disp("  Lecturas Válidas:  " + string(n));
    disp("  Muestras Nulas:    " + string(size(serie_numerica, 1) - n));
    disp("  Mínimo:            " + msprintf("%.2f", v_min));
    disp("  Q1 (25%):          " + msprintf("%.2f", q1));
    disp("  Mediana/Q2 (50%):  " + msprintf("%.2f", v_median));
    disp("  Promedio (Media):  " + msprintf("%.2f", v_mean));
    disp("  Q3 (75%):          " + msprintf("%.2f", q3));
    disp("  Máximo:            " + msprintf("%.2f", v_max));
    disp("  Desv. Estándar:    " + msprintf("%.2f", v_std));
endfunction

//CALCULOS DE IC (95%)
function [ic_media, ic_mediana] = calcular_ic(data, nivel_confianza)
    if nargin < 2 then nivel_confianza = 0.95; end
    
    n = length(data);
    media_val = mean(data);
    s_val = stdev(data);
    
    // IC Paramétrico para la Media (TLC)
    alpha = 1 - nivel_confianza;
    z_crit = cdfnor("X", 0, 1, 1 - alpha/2, alpha/2); 
    
    error_est = z_crit * (s_val / sqrt(n));
    ic_media = [media_val - error_est, media_val + error_est];
    
    // IC No Paramétrico para la Mediana (Bootstrap)
    B = 1000;
    medianas_boot = zeros(B, 1);
    for b = 1:B
        idx_boot = grand(n, 1, "uin", 1, n);
        medianas_boot(b) = median(data(idx_boot));
    end
    medianas_sort = gsort(medianas_boot, "g", "i");
    idx_lower = max(1, round(B * (alpha / 2)));
    idx_upper = min(B, round(B * (1 - alpha / 2)));
    ic_mediana = [medianas_sort(idx_lower), medianas_sort(idx_upper)];
endfunction


// 3. CARGA Y EXTRACCIÓN DINÁMICA DE DATOS
disp("Cargando el archivo: " + archivo + "...");
raw_data  = csvRead(archivo, separador, [], "string");
cabeceras = raw_data(1, :);
datos     = raw_data(2:$, :); // $ = última fila

num_vars  = size(vars_config, 1);
variables = list();

for i = 1:num_vars
    col_idx = find(cabeceras == vars_config(i, 1));
    if ~isempty(col_idx) then
        variables(i) = procesar_columna(datos(:, col_idx));
    else
        warning("Columna no encontrada: " + vars_config(i, 1));
        variables(i) = zeros(size(datos, 1), 1) * %nan;
    end
end

municipios = datos(:, find(cabeceras == col_municipio));
//fecha_hora = datos(:, find(cabeceras == col_fecha_hora));
disp(" ");
disp("=== CONTEXTO GEOGRÁFICO DE LA RED ===");
m_unicos = unique(municipios);
disp("  Total de municipios monitoreados: " + string(size(m_unicos, 1)));



// 5. EJECUCIÓN DE LOS MÓDULOS SECUNDARIOS
//disp("Ejectuando Análisis general...");
//exec("1_analisis_general.sce", -1);

//disp(" ");
//disp("Ejecutando análisis por municipios...");
//exec("2_analisis_municipios.sce", -1);

//disp(" ");
//disp("Ejecutando análisis filtrado por municipio específico...");
//exec("3_analisis_municipio_especifico.sce", -1);

disp(" ");
disp("Procesamiento completado con éxito.");