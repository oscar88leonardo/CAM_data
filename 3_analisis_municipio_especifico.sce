// =====================================================ex===============
// ARCHIVO 3: ANÁLISIS FILTRADO, MUESTREO Y DISTRIBUCIÓN MUESTRAL
// ====================================================================
target_mun = "RIVERA"; 

// TAMAÑO DE MUESTRA PARA EL ANÁLISIS
// Cambia este valor para observar cómo se estrecha/ensancha la Distribución Muestral
tamano_muestra = 30; 


/* Definición  de variables numéricas a analizar:
// Columna CSV | Nombre para Reportes | Etiqueta Eje / Unidad
vars_config = [
  1  "precipitacion_(mm)"     , "Precipitación"      , "mm" ;
  2 "nivel_agua_(m)"         , "Nivel de Agua"      , "m" ;
  3  "temperatura_(°C)"       , "Temperatura"        , "°C" ;
  4  "humedad_relativa_(%)"   , "Humedad Relativa"   , "%" ;
  5  "radiacion_solar_(W/m2)" , "Radiación Solar"    , "W/m2" ;
];
*/
indices_vars_interes = [3 4]; // 3: Temperatura, 4: Humedad Relativa
num_vars = length(indices_vars_interes);

disp(" ");
disp("=======================================================");
disp("   ANÁLISIS MULTIVARIABLE E IC (95%) - MUNICIPIO: " + target_mun);
if tamano_muestra > 0 then
    disp("   [ Muestra Aleatoria seleccionada: n = " + string(tamano_muestra) + " ]");
end
disp("=======================================================");

for k = 1:num_vars
    idx_var = indices_vars_interes(k);
    
    var_datos = variables(idx_var);
    
    if isdef("vars_config") then
        var_nombre = vars_config(idx_var); 
    else
        var_nombre = "Variable " + string(idx_var);
    end
    
    // 1. Filtrado por Municipio
    mascara_mun = (convstr(municipios, "u") == convstr(target_mun, "u")) & (~isnan(var_datos));
    var_mun     = var_datos(mascara_mun);
    N_total     = length(var_mun);
    
    if ~isempty(var_mun) then
        // 2. Extraer muestra si aplica
        if tamano_muestra > 0 & tamano_muestra < N_total then
            idx_aleatorios = grand(1, "prm", (1:N_total)');
            var_mun = var_mun(idx_aleatorios(1:tamano_muestra));
        end
        
        n_obs = length(var_mun);
        
        disp("-------------------------------------------------------");
        disp("  Variable (" + string(k) + "/" + string(num_vars) + "): " + var_nombre);
        disp("  Registros Usados (n): " + string(n_obs) + " (de " + string(N_total) + " totales)");
        disp("-------------------------------------------------------");
        
        // Reporte Estadístico Descriptivo existente
        reportar_estadisticos(var_nombre + " - " + target_mun, var_mun);
        
        // Cálculo de IC
        [ic_med, ic_medn] = calcular_ic(var_mun, 0.95);
        
        disp(" ");
        disp("--- INTERVALOS DE CONFIANZA DEL 95% ---");
        disp("  Media estimación:   " + string(mean(var_mun)) + "  --> IC 95%: [ " + string(ic_med(1)) + " , " + string(ic_med(2)) + " ]");
        disp("  Mediana estimación: " + string(median(var_mun)) + "  --> IC 95% (Bootstrap): [ " + string(ic_medn(1)) + " , " + string(ic_medn(2)) + " ]");
        disp(" ");
        
        // --- 3. SIMULACIÓN DE LA DISTRIBUCIÓN MUESTRAL DEL PROMEDIO (TLC) ---
        K_sim = 1000; // 1000 muestras para construir la distribución del promedio
        medias_muestrales = zeros(K_sim, 1);
        
        for i = 1:K_sim
            idx_s = grand(n_obs, 1, "uin", 1, n_obs);
            medias_muestrales(i) = mean(var_mun(idx_s));
        end
        
        // --- 4. GRAFICACIÓN EN 3 SUBPLOTS ---
        scf(10 + k); clf();
        
        // Subplot 1: Histograma de los Datos de la Muestra
        subplot(1, 3, 1);
        histplot(15, var_mun, normalization=%f, style=12, polygon=%t);
        xgrid(1);
        xtitle("Datos Individuales (n=" + string(n_obs) + ")", var_nombre, "Frecuencia");
        
        // Subplot 2: Boxplot
        subplot(1, 3, 2);
        boxplot(var_mun);
        xtitle("Boxplot", "", var_nombre);
        
        // Subplot 3: Distribución Muestral del Promedio (Teorema del Límite Central)
        subplot(1, 3, 3);
        // Normalización normalizada (%t) para visualizar la densidad probabilística
        histplot(20, medias_muestrales, normalization=%t, style=12); 
        
        // Superposición de la Curva Normal Teórica N(mu, s/sqrt(n))
        mu_hat = mean(var_mun);
        se_hat = stdev(var_mun) / sqrt(n_obs);
        x_eje  = linspace(min(medias_muestrales), max(medias_muestrales), 200)';
        pdf_teorica = (1 / (se_hat * sqrt(2*%pi))) * exp(-0.5 * ((x_eje - mu_hat)/se_hat).^2);
        
        plot(x_eje, pdf_teorica, "r-", "LineWidth", 2);
        
        // Líneas verticales para el IC del 95% en la distribución del promedio
        plot([ic_med(1) ic_med(1)], [0 max(pdf_teorica)], "b--");
        plot([ic_med(2) ic_med(2)], [0 max(pdf_teorica)], "b--");
        
        xgrid(1);
        xtitle("Dist. Muestral del Promedio", "Promedio " + var_nombre, "Densidad");
    else
        disp(" ");
        disp("No se encontraron registros válidos de " + var_nombre + " para: " + target_mun);
    end
end