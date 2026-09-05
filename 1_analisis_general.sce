// ====================================================================
// ARCHIVO 1: ANÁLISIS GLOBAL DE VARIABLES
// ====================================================================

// 4. EJECUCIÓN DEL ANÁLISIS GLOBAL
for v = 1:num_vars
    nom_completo = vars_config(v, 2) + " (" + vars_config(v, 3) + ")";
    reportar_estadisticos(nom_completo, variables(v));
end

// HISTOGRAMAS GENERALES
disp(" ");
disp("Generando histogramas de distribución...");
scf(1); clf();
for v = 1:num_vars
    subplot(2, 3, v);
    serie = variables(v);
    histplot(20, serie(~isnan(serie)), normalization=%f);
    xtitle(vars_config(v, 2), vars_config(v, 3), "Frecuencia");
end

// BOXPLOTS GENERALES
disp("Generando boxplots...");
// LIMITE INFERIOR  Q1-1.5 IQR , LIMITE SUPERIOR Q3+1.5IQR
scf(2); clf();
for v = 1:num_vars
    subplot(2, 3, v);
    serie = variables(v);
    boxplot(serie(~isnan(serie)));
    xtitle(vars_config(v, 2), "", vars_config(v, 3));
end