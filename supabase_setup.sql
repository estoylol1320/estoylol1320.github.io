-- ============================================================
--  EDUMEP SAS — Arreglo de la tabla `productos` en Supabase
--  Pégalo COMPLETO en:  Dashboard -> SQL Editor -> New query -> Run
-- ============================================================
--  Situación detectada:
--   - `productos`  : tabla con esquema equivocado (solo id + created_at). La página la lee, por eso no salen productos.
--   - `productoss` : tabla con el esquema CORRECTO (donde importaste el CSV), pero la página NO la consulta.
--  Este script deja UNA sola tabla `productos` con el esquema bueno + lectura pública.
-- ============================================================

-- 1) Elimina la tabla rota (id + created_at con datos viejos).
drop table if exists public.productos;

-- 2) Renombra la tabla buena `productoss` -> `productos` (conserva tus filas).
alter table if exists public.productoss rename to productos;

-- 3) Activa RLS y permite SOLO lectura pública (la anon key podrá leer, no escribir).
alter table public.productos enable row level security;

drop policy if exists "Lectura publica de productos" on public.productos;
create policy "Lectura publica de productos"
  on public.productos
  for select
  to anon, authenticated
  using (true);

-- 4) Asegura el privilegio SELECT para los roles públicos.
grant select on public.productos to anon, authenticated;

-- 5) VERIFICACIÓN: cuántas filas quedaron (el SQL Editor ignora RLS y muestra el total real).
select count(*) as total_productos from public.productos;

-- ============================================================
--  Si el conteo da 0  -> la tabla estaba vacía: importa el CSV ahora.
--    Table Editor -> productos -> Insert -> Import data from CSV
--    -> sube catalogo_inter_electricas.csv  (NO mapees `id`).
--  Si el conteo da ~128 -> ya estaba la data: la página ya debería mostrarla.
-- ============================================================
