# Notas fiscales — Nómina Fácil

**Ejercicio:** 2026
**Última actualización de datos:** 2026-08-28
**Archivo de datos:** `lib/models/tax_data_2026.dart`

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
Presupuestos. Las escalas incluidas (`comunidades` en `tax_data_2026.dart`):

| CCAA | Régimen | Notas |
|------|---------|-------|
| Madrid | Común | Escala deflactada; tipos reducidos. |
| Cataluña | Común | Tramo bajo al 10,50 %; tramos altos hasta 25,50 %. |
| Andalucía | Común | Escala deflactada 2023, alineada con la estatal. |
| C. Valenciana | Común | Escala ampliada a 10 tramos; primer tipo 9 %. |
| País Vasco | **Foral** | Escala única (no se suma la estatal). Cálculo muy simplificado: escala foral íntegra − deducción general del trabajo (≈ 4.400 €) − deducciones por descendientes. El sistema real (Álava/Bizkaia/Gipuzkoa) usa bonificación del trabajo y deducciones personales/familiares que aquí se aproximan groseramente. |
| Galicia | Común | Rebaja en los primeros tramos. |
| Aragón | Común | Escala de 9 tramos. |
| Castilla y León | Común | 5 tramos; primer tipo 9 %. |
| Murcia | Común | Rebajas progresivas 2023-2024. |
| Canarias | Común | 6 tramos; primer tipo 9 %. |

**Comunidades no incluidas** (usan la escala estatal duplicada por defecto si
se añaden): Asturias, Cantabria, Castilla-La Mancha, Extremadura, Baleares,
La Rioja, Navarra (foral), Ceuta y Melilla (con bonificación del 60 %).

**Fuentes por comunidad:** texto refundido de disposiciones legales de cada
CCAA en materia de tributos cedidos; leyes autonómicas de medidas fiscales
2023-2025; Haciendas Forales del País Vasco (Normas Forales del IRPF).

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
