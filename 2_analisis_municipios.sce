// ====================================================================
// ARCHIVO 2: ANÁLISIS COMPARATIVO POR MUNICIPIOS
// ====================================================================

num_muns = size(m_unicos, 1);

// TABLA RESUMEN COMPARATIVA
for v = 1:num_vars
    var_actual    = variables(v);
    nombre_actual = vars_config(v, 2) + " (" + vars_config(v, 3) + ")";
    
    disp(" ");
    disp("====================================================================");
    disp("COMPARATIVA POR MUNICIPIO: " + nombre_actual);
    disp("Municipio" + "	" + "N_Val" + "	" + "Media" + "	" + "Mediana" + "	" + "Mín" + "	" + "Máx");
    disp("--------------------------------------------------------------------");
    
    for m = 1:num_muns
        mun_nombre    = m_unicos(m);
        datos_mun     = var_actual(municipios == mun_nombre);
        datos_validos = datos_mun(~isnan(datos_mun));
        
        if isempty(datos_validos) then
            disp(mun_nombre + "	" + "0" + "	" + "N/A" + "	" + "N/A" + "	" + "N/A" + "	" + "N/A");
        else
            disp(mun_nombre + "	" + ..
                 string(size(datos_validos, 1)) + "	" + ..
                 msprintf("%.2f", mean(datos_validos)) + "	" + ..
                 msprintf("%.2f", median(datos_validos)) + "	" + ..
                 msprintf("%.2f", min(datos_validos)) + "	" + ..
                 msprintf("%.2f", max(datos_validos)));
        end
    end
end

// BOXPLOTS COMPARATIVOS
disp(" ");
disp("Generando boxplots comparativos por municipio...");
fig_base_num = 3; 

for v = 1:num_vars
    var_actual = variables(v);
    nom_actual = vars_config(v, 2) + " (" + vars_config(v, 3) + ")";
    
    fig_idx = fig_base_num + floor((v - 1) / 2);
    sub_idx = modulo(v - 1, 2) + 1;
    
    scf(fig_idx);
    if sub_idx == 1 then clf(); end
    
    subplot(2, 1, sub_idx);
    
    filtro_validos = ~isnan(var_actual);
    datos_limpios  = var_actual(filtro_validos);
    muns_limpios   = municipios(filtro_validos);
    
    if ~isempty(datos_limpios) then
        boxplot(datos_limpios, muns_limpios);
        xtitle(nom_actual, "Municipios", "");
        ax = gca();
        ax.margins = [0.12, 0.1, 0.15, 0.2];
    else
        plot(0, 0);
        xtitle(nom_actual + " (Sin Datos Válidos)", "Municipios", "");
    end
end