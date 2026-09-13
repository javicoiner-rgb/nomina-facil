# Notas fiscales — Nómina Fácil

**Ejercicio:** 2026
**Última actualización de datos:** 2026-09-13
**Archivo de datos:** `lib/models/tax_data_2026.dart`

> **Cambios v1.3 (2026-09-13) — verificación de escalas autonómicas contra AEAT:**
> Una primera pasada intentando verificar las escalas autonómicas contra
> webs fiscales de terceros (guiafiscal.es, billeo.es, etc.) resultó en
> datos contradictorios entre sí, así que se descartó ese método (ver
> historial de v1.2 más abajo si se conserva en el control de versiones).
>
> En su lugar se usó el **manual práctico de la Agencia Tributaria (AEAT),
> ejercicio 2025** — que dedica una página por comunidad autónoma con la
> escala oficial y su cuota íntegra acumulada tramo a tramo — como fuente
> primaria. Cada tabla se validó recalculando la cuota íntegra acumulada de
> cada tramo a partir del tipo y el umbral; **las 15 tablas de régimen
> común cuadran al céntimo**, lo que da alta confianza en que no son
> contenido generado/alucinado (a diferencia de las webs de v1.2). Aragón
> se contrastó además de forma independiente en aragon.es (Gobierno de
> Aragón), con resultado idéntico.
>
> **Resultado:**
> - **Corregidas (tenían datos erróneos o desactualizados):**
>   - **Aragón:** 1er umbral corregido de 13.972,50 € a 13.072,50 €
>     (transposición de dígitos); tramos 5º-8º realineados (61.100→60.000,
>     82.360→80.000, 102.360→90.000, 122.360→130.000) y el tipo del 8º
>     tramo de 24,50 % a 25,00 %.
>   - **Cataluña:** la tabla anterior (9 tramos, 10,50 % inicial,
>     umbrales 17.707,20/21.000/33.007,20/53.407,20/175.000) correspondía a
>     una escala **anterior** a la reforma de la Llei de mesures fiscals
>     2025. La escala vigente tiene **8 tramos**, empieza al **9,50 %** y
>     usa umbrales redondos propios (12.500/22.000/33.000/53.000/90.000/
>     120.000/175.000), máximo 25,50 % sin cambios.
>   - **Galicia:** se eliminó un tramo espurio (47.600 €, 18,40 %) que no
>     existe en la escala oficial; la escala real tiene 5 tramos, no 6
>     (12.985,35/21.068,60/35.200/60.000, tipos 9/11,65/14,9/18,4/22,5 %).
>   - **Andalucía:** 2º umbral corregido de 21.000 € a 21.100 €.
>   - **Canarias:** la tabla tenía solo 6 tramos y un máximo de 24 %,
>     desactualizada. La escala vigente tiene **7 tramos**, máximo **26 %**
>     (13.748/19.422/35.924/57.566/93.268/123.745).
>   - **Valencia:** faltaba un tramo (52.000-62.000 €, 20 %); la escala
>     real de 2025 tiene 11 tramos, no 10. **Aviso:** para 2026 la
>     Generalitat aprobó una nueva rebaja (Ley 5/2026, confirmada por
>     Garrigues: rango 8,80 %-29,35 %, antes 9,00 %-29,50 %) cuyo desglose
>     tramo a tramo no está aún disponible en el manual AEAT (que en la
>     fecha de esta revisión solo cubre el ejercicio 2025); se ha dejado la
>     escala 2025 como mejor aproximación disponible, marcada en su
>     `descripcion` en el código.
> - **Confirmadas sin cambios:** Madrid, Murcia, Castilla y León (las
>   tablas ya presentes coincidían exactamente con el manual AEAT).
> - **Rellenadas por primera vez con datos reales** (antes usaban el
>   placeholder de la escala estatal, `tramosEstatales`): **Asturias** (8
>   tramos, 9 %-26 %), **Baleares** (9 tramos, 9 %-24,75 %), **Cantabria**
>   (6 tramos, 8,5 %-24,5 %), **Castilla-La Mancha** (5 tramos, 9,5 %-22,5 %),
>   **Extremadura** (9 tramos, 8 %-25 %), **La Rioja** (8 tramos, 8 %-27 %).
> - **Sigue sin verificar:** Navarra (foral). No hay página equivalente en
>   el manual de régimen común de la AEAT para los territorios forales; se
>   mantiene la aproximación provisional con la escala foral del País
>   Vasco. País Vasco no se ha tocado (tal como se pidió).
>
> **Limitación conocida:** el manual AEAT usado es el del ejercicio 2025
> (el más reciente publicado en su totalidad; el de 2026 se publica el año
> siguiente a su devengo). Para la mayoría de comunidades no hay indicios
> de cambio para 2026; donde sí los hay (Valencia) se ha anotado
> explícitamente. Si una comunidad cambió su escala a mitad de 2026, esta
> tabla podría no reflejarlo todavía.

> **Cambios v1.1 (2026-08-28):**
> - Cotización del trabajador a la Seguridad Social: **6,50 %** (antes 6,35 %),
>   al incluir el MEI 2026 (0,15 % a cargo del trabajador).
> - IRPF: la retención se calcula con la **escala del art. 85 RIRPF**
>   (19/24/30/37/45/47), igual para todas las comunidades de régimen común.
> - Base del IRPF = `bruto − cotización SS` (ya **no** se resta el gasto
>   genérico de 2.000 € del art. 19.2.f; ver punto 1 y `otrosGastosDeducibles`).
> - Reducción por rendimientos del trabajo (art. 20): umbrales 2026
>   **16.825 € / 21.000 €**.

> ⚠️ Los datos son **orientativos**. En la fecha de esta versión algunas
> comunidades autónomas todavía no habían publicado su escala definitiva de
> 2026; en esos casos se ha mantenido la última escala vigente conocida
> (2024-2025). Verifica siempre contra el BOE / boletín autonómico antes de
> tomar decisiones.

---

## 1. Metodología del cálculo

La app estima la **retención de IRPF** (no la cuota de la declaración anual),
de forma simplificada, siguiendo el esquema del art. 82 y ss. del Reglamento
del IRPF (RD 439/2007):

1. Rendimiento íntegro = bruto anual.
2. Base del IRPF = íntegro − cotización del trabajador a la Seguridad Social.
   **No** se resta el gasto genérico de 2.000 € del art. 19.2.f: las fuentes
   de referencia usadas definen la base como `bruto − SS`. Es una
   simplificación conservadora (sube ligeramente la retención de las rentas
   bajas). Para volver al procedimiento estricto de la AEAT, poner
   `TaxData2026.otrosGastosDeducibles = 2000`.
3. Reducción por obtención de rendimientos del trabajo (art. 20 LIRPF),
   que es **0 € por encima de 21.000 €** de rendimiento.
4. Base para el tipo = base − reducción (mínimo 0).
5. Cuota = escala(base) − escala(mínimo personal y familiar), con la
   **escala de retención del art. 85.1.1º RIRPF** (19 / 24 / 30 / 37 / 45 /
   47 %). Esta escala es única a nivel nacional: la retención mensual **no
   varía por comunidad autónoma** en el régimen común. Las diferencias
   autonómicas reales se regularizan en la declaración de la renta (fuera
   del alcance de esta estimación). El **País Vasco** (foral) sí usa su
   propia escala.
6. Tipo de retención = cuota / retribución bruta. Retención anual ≈ cuota.
7. Neto = bruto − retención IRPF − cotización SS.

### Ejemplo verificado: 30.000 € brutos, Madrid, soltero sin hijos, 14 pagas

| Concepto | Importe |
|----------|---------|
| Cotización SS (6,50 %) | 1.950 € |
| Base del IRPF (30.000 − 1.950) | 28.050 € |
| Reducción art. 20 (rendimiento > 21.000 €) | 0 € |
| Mínimo personal | 5.550 € |
| Cuota de retención = escala85(28.050) − escala85(5.550) | 5.526 € |
| Tipo efectivo de IRPF | 18,4 % |
| **Neto anual** | **22.524 €** |
| **Neto mensual (÷14)** | **≈ 1.609 €** |

Fuentes externas sitúan el neto en ~22.612 € / ~1.615 €/mes; la diferencia
(< 0,4 %) proviene del redondeo de la escala en cada fuente.

### Simplificaciones asumidas

- Contribuyente menor de 65 años, sin discapacidad, soltero, situación
  familiar tipo 2 (o descendientes solo a su cargo).
- Contrato indefinido (desempleo al 1,55 %).
- Sin rendimientos irregulares, sin regularizaciones a mitad de año.
- Descendientes: se asume que **el 100 % del mínimo por descendiente**
  corresponde al contribuyente (no se prorratea al 50 %). "3+" se calcula
  como 3 hijos.
- No se aplica el mínimo incrementado por descendiente menor de 3 años
  (+2.800 €).
- No se contempla el límite de la reducción por trabajo cuando hay otras
  rentas > 6.500 €.

---

## 2. Escalas del IRPF

### 2.1. Escala de retención — la que aplica la app (art. 85.1.1º RIRPF)

| Base para el tipo hasta | Tipo |
|-------------------------|------|
| 12.450 €   | 19,00 % |
| 20.200 €   | 24,00 % |
| 35.200 €   | 30,00 % |
| 60.000 €   | 37,00 % |
| 300.000 €  | 45,00 % |
| En adelante | 47,00 % |

Es la escala que el pagador aplica en nómina. Equivale a la escala estatal
(2.2) más un tramo autonómico general idéntico, y **no varía por comunidad
autónoma**. Constante `tramosRetencion` en `tax_data_2026.dart`.

### 2.2. Escala general estatal (art. 63 LIRPF) — solo referencia

| Base liquidable hasta | Tipo estatal |
|-----------------------|--------------|
| 12.450 €   | 9,50 %  |
| 20.200 €   | 12,00 % |
| 35.200 €   | 15,00 % |
| 60.000 €   | 18,50 % |
| 300.000 €  | 22,50 % |
| En adelante | 24,50 % |

Se conserva (`tramosEstatales`) para el régimen foral y una eventual
liquidación de cuota diferencial. **No** se usa en el cálculo de nómina.

**Fuente:** arts. 63 y 85 Ley 35/2006 / RD 439/2007, vigentes desde la Ley
26/2014 (tramo > 300.000 € añadido por la Ley 31/2022). Sin cambios para 2026
a fecha de actualización.

---

## 3. Cotización del trabajador a la Seguridad Social

Régimen general, tipos a cargo del trabajador:

| Concepto | Tipo |
|----------|------|
| Contingencias comunes | 4,70 % |
| Desempleo (contrato indefinido) | 1,55 % |
| Formación profesional | 0,10 % |
| MEI (Mec. de Equidad Intergeneracional) | 0,15 % |
| **Total aplicado en la app** | **6,50 %** |

- **MEI:** en 2026 el tipo total del MEI es 0,90 % (0,75 % empresa + **0,15 %
  trabajador**). En 2025 era 0,80 % (0,13 % trabajador). Sube 0,10 puntos al
  año hasta 2029 y luego se revisa. Constante `ssMEI` en `tax_data_2026.dart`.
- **Base máxima de cotización:** se usa `58.914 €/año` (≈ 4.909,50 €/mes × 12,
  valor 2024-2025). Actualizar con la base máxima de 2026 cuando se publique
  la Orden de cotización. Sobre la parte de bruto que excede la base máxima
  no se cotiza (pero sí tributa por IRPF).

**Fuente:** Ley General de la Seguridad Social; Orden PJC/ de cotización
anual; art. 127 bis LGSS (MEI), disposición transitoria cuadragésima tercera.

---

## 4. Mínimo personal y familiar (arts. 57-61 LIRPF)

| Concepto | Importe |
|----------|---------|
| Mínimo del contribuyente | 5.550 € |
| 1er descendiente | 2.400 € |
| 2º descendiente | 2.700 € |
| 3er descendiente | 4.000 € |
| 4º y siguientes | 4.500 € |

La app acumula: 0 hijos → 0; 1 → 2.400; 2 → 5.100; 3+ → 9.100.

**Fuente:** arts. 57-61 Ley 35/2006. Importes sin cambios desde 2015.

---

## 5. Reducción por rendimientos del trabajo (art. 20 LIRPF)

| Rendimiento neto del trabajo (RNT) | Reducción |
|-----------------------------------|-----------|
| ≤ 16.825 € | 7.302 € |
| 16.825 € < RNT ≤ 21.000 € | 7.302 − 1,7489 × (RNT − 16.825) |
| > 21.000 € | 0 € |

La pendiente se calcula en código para que la reducción valga exactamente 0
en 21.000 €: `reduccionTrabajoMaxima / (21.000 − 16.825)`.

**Fuente:** art. 20 LIRPF, redacción actualizada para 2026 al hilo de la
subida del SMI. **Pendiente de confirmar contra el BOE** el importe máximo
(¿7.302 € o superior?) y los umbrales exactos. Revisar cada enero: estos
valores se han modificado varias veces en los últimos años.

> **Aviso:** al no restar el gasto genérico de 2.000 € (ver punto 1), las
> rentas cercanas al SMI pueden salir con una retención pequeña (~200-400 €/
> año) donde en la práctica es casi 0. Si esto importa para el público
> objetivo, reactivar `otrosGastosDeducibles = 2000`.

---

## 6. Escalas autonómicas

**Importante:** desde la v1.1 la retención mensual usa la escala única del
art. 85 RIRPF y **no** aplica estas escalas autonómicas en el régimen común
(sí en el País Vasco). Las tablas siguen en `comunidades` como referencia y
para el foral. El selector de CCAA en la app sigue teniendo sentido para el
País Vasco y para dar contexto; para las comunidades de régimen común el
resultado es el mismo (la diferencia se ve en la declaración de la renta).

Cada comunidad publica su escala en su Ley de Medidas Fiscales o de
Presupuestos. Las escalas incluidas (`comunidades` en `tax_data_2026.dart`,
orden alfabético con las forales al final):

Estado de verificación (2026-09-13), fuente primaria: **manual práctico
IRPF 2025 de la AEAT** (`sede.agenciatributaria.gob.es`, sección
"gravamen autonómico"), con validación cruzada recalculando la cuota
íntegra acumulada de cada tramo — las 15 tablas de régimen común cuadran
al céntimo. Aragón, además, contrastado independientemente en
`aragon.es` (resultado idéntico).

| CCAA | Régimen | Tipo mín. | Tipo máx. | Estado |
|------|---------|-----------|-----------|--------|
| Andalucía | Común | 9,50 % | 22,50 % | ✅ Verificada AEAT; corregido 2º umbral 21.000→21.100 €. |
| Aragón | Común | 9,50 % | 25,50 % | ✅ Verificada AEAT + aragon.es (doble fuente, idénticas); corregidos 5 de 9 umbrales y el tipo del 8º tramo. |
| Asturias | Común | 9,00 % | 26,00 % | ✅ Verificada AEAT. Antes usaba el placeholder estatal. |
| Baleares | Común | 9,00 % | 24,75 % | ✅ Verificada AEAT. Antes usaba el placeholder estatal. |
| Canarias | Común | 9,00 % | 26,00 % | ✅ Verificada AEAT; pasa de 6 a 7 tramos (estaba desactualizada, máx. antiguo 24 %). |
| Cantabria | Común | 8,50 % | 24,50 % | ✅ Verificada AEAT. Antes usaba el placeholder estatal. |
| Castilla-La Mancha | Común | 9,50 % | 22,50 % | ✅ Verificada AEAT. Antes usaba el placeholder estatal. |
| Castilla y León | Común | 9,00 % | 21,50 % | ✅ Verificada AEAT: coincide exactamente con los datos previos. |
| Cataluña | Común | 9,50 % | 25,50 % | ✅ Verificada AEAT — **tabla anterior obsoleta** (era una escala previa a la reforma 2025, con 9 tramos y 10,50 % inicial); ahora 8 tramos, 9,50 % inicial, umbrales redondos. |
| C. Valenciana | Común | 9,00 % | 29,50 % | 🟡 Verificada AEAT para el ejercicio **2025** (11 tramos, se corrigió un tramo que faltaba); para 2026 hay una rebaja confirmada (Ley 5/2026, Garrigues: 8,80 %–29,35 %) sin desglose tramo a tramo disponible todavía — ver `descripcion` en el código. |
| Extremadura | Común | 8,00 % | 25,00 % | ✅ Verificada AEAT. Antes usaba el placeholder estatal. |
| Galicia | Común | 9,00 % | 22,50 % | ✅ Verificada AEAT; eliminado un tramo espurio (47.600 €) que no existe en la escala real (son 5 tramos, no 6). |
| Madrid | Común | 8,50 % | 20,50 % | ✅ Verificada AEAT: coincide exactamente con los datos previos. |
| Murcia | Común | 9,50 % | 22,50 % | ✅ Verificada AEAT: coincide exactamente con los datos previos. |
| La Rioja | Común | 8,00 % | 27,00 % | ✅ Verificada AEAT. Antes usaba el placeholder estatal. |
| Navarra | **Foral** | — | — | ⚠️ Sin verificar. El manual de régimen común de la AEAT no cubre los territorios forales. Se mantiene la aproximación provisional con la escala foral del País Vasco. |
| País Vasco | **Foral** | 23,00 % | 49,00 % | Sin tocar (no forma parte de esta revisión). Escala única (no se suma la estatal). Cálculo muy simplificado: escala foral íntegra − deducción general del trabajo (≈ 4.400 €) − deducciones por descendientes. El sistema real (Álava/Bizkaia/Gipuzkoa) usa bonificación del trabajo y deducciones personales/familiares que aquí se aproximan groseramente. |

**Comunidades aún no incluidas:** Ceuta y Melilla (con bonificación del 60 %,
no son CCAA en sentido estricto).

**Fuente principal:** manual práctico IRPF 2025, Agencia Tributaria,
`sede.agenciatributaria.gob.es/Sede/ayuda/manuales-videos-folletos/manuales-practicos/irpf-2025/c15-calculo-impuesto-determinacion-cuotas-integras/gravamen-base-liquidable-general/gravamen-autonomico/`
(una página por comunidad). Complementada con `aragon.es` (Aragón) y
Garrigues (aviso de la rebaja 2026 en Valencia). Esta es la escala del
ejercicio 2025 (el manual de 2026 se publica el año siguiente a su
devengo); se usa como mejor aproximación disponible para 2026 salvo donde
se ha documentado un cambio conocido (Valencia).

---

## 7. Casos límite (edge cases) contemplados en el código

| Caso | Comportamiento |
|------|----------------|
| Bruto ≤ 0 | Se trata como 0; neto 0, IRPF 0, SS 0. |
| Bruto por debajo del SMI | Se calcula igualmente (el slider empieza en 14.000 €). |
| Bruto > base máxima de cotización | La SS se calcula sobre 58.914 €, no sobre el bruto. |
| Cuota de IRPF negativa (mínimo > base) | Se limita a 0 (no hay "IRPF negativo"). |
| Reducción por trabajo negativa | La fórmula se acota a 0 por encima de 21.000 €. |
| CCAA de régimen común distinta de Madrid | Mismo neto: la retención no varía por comunidad (art. 85 RIRPF). |
| `pagas` = 0 o negativo | Se fuerza a 12. |
| Bisección (neto → bruto) que no converge | Devuelve la última estimación tras 100 iteraciones (tolerancia 0,01 €). |
| Neto deseado ≤ 0 en modo inverso | Devuelve bruto 0. |
| Neto deseado muy alto | La cota superior de la bisección se amplía ×1,5 hasta 40 veces antes de empezar. |
| País Vasco / régimen foral | No se aplica la escala estatal; se usa la escala foral con deducciones aproximadas. |
| CCAA desconocida | Se usa Madrid como valor por defecto. |

---

## 8. Checklist de actualización anual (enero)

- [ ] Renombrar `tax_data_2026.dart` → `tax_data_AAAA.dart` y la clase.
- [ ] Actualizar imports y `AppConstants.anioFiscal`.
- [ ] Revisar la escala de retención (art. 85 RIRPF, `tramosRetencion`) y la
      escala estatal (art. 63, `tramosEstatales`) en la Ley de PGE / BOE.
- [ ] Actualizar la base máxima de cotización y el **tipo del MEI** del año
      (`ssMEI`; sube ~0,10 pp/año hasta 2029) en la Orden de cotización.
- [ ] Revisar mínimo personal y familiar.
- [ ] Revisar umbrales de la reducción por trabajo (art. 20).
- [ ] Actualizar cada escala autonómica con su boletín oficial.
- [ ] `flutter test` y `flutter analyze` sin errores.
- [ ] Actualizar la fecha y las fuentes de este documento.
